import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  ParseIntPipe,
  UseGuards,
  Req,
  ForbiddenException,
  UnauthorizedException,
  NotFoundException,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { LeaveApplicationService } from './leave-application.service';
import { CreateLeaveApplicationDto } from './dto/create-leave-application.dto';
import { UpdateLeaveApplicationDto } from './dto/update-leave-application.dto';
import { PrismaService } from '../prisma/prisma.service';
import { EmpManagerScopeService } from '../common/emp-manager-scope.service';
import { assertEmployeeModuleAccess } from '../common/employee-permission.util';

@Controller('leave-application')
@UseGuards(AuthGuard('jwt'))
export class LeaveApplicationController {
  constructor(
    private readonly leaveApplicationService: LeaveApplicationService,
    private readonly prisma: PrismaService,
    private readonly managerScope: EmpManagerScopeService,
  ) {}

  private isEmployee(req: any): boolean {
    return (
      String(req?.user?.type ?? '').toLowerCase() === 'employee' ||
      String(req?.user?.role ?? '').toUpperCase() === 'EMPLOYEE'
    );
  }

  private getEmployeeId(req: any): number {
    const id = Number(req?.user?.employeeId ?? req?.user?.sub);

    if (!Number.isInteger(id) || id <= 0) {
      throw new UnauthorizedException('Employee ID not found in token');
    }

    return id;
  }

  private async assertOwnLeave(id: number, req: any): Promise<void> {
    if (!this.isEmployee(req)) return;

    const leave = await this.leaveApplicationService.findOne(id);

    if (!leave || Number(leave.manageEmployeeID) !== this.getEmployeeId(req)) {
      throw new NotFoundException('Leave application not found');
    }
  }

  @Post()
  create(@Body() dto: CreateLeaveApplicationDto, @Req() req: any) {
    if (!this.isEmployee(req)) {
      return this.leaveApplicationService.create(dto);
    }

    const employeeId = this.getEmployeeId(req);

    // Use the authenticated employee's identity and company context.
    return this.leaveApplicationService.create({
      ...dto,
      manageEmployeeID: employeeId,
      serviceProviderID: req.user.serviceProviderID,
      companyID: req.user.companyID,
      branchesID: req.user.branchesID,
    });
  }

  @Get('employee/:empId')
  async findByEmployee(
    @Param('empId', ParseIntPipe) empId: number,
    @Req() req: any,
  ) {
    if (!this.isEmployee(req)) {
      return this.leaveApplicationService.findByEmployee(empId);
    }

    const employeeId = this.getEmployeeId(req);

    // Employee accounts may only request their own endpoint.
    if (empId !== employeeId) {
      throw new NotFoundException('Leave application not found');
    }

    const employee = await this.prisma.manageEmployee.findUnique({
      where: { id: employeeId },
      select: {
        id: true,
        companyID: true,
        isCompanyOwner: true,
        isDeleted: true,
      },
    });

    if (!employee || employee.isDeleted) {
      throw new UnauthorizedException('Employee account not found');
    }

    // A verified Company Owner can load leave requests for their company.
    if (employee.isCompanyOwner === true) {
      const tokenCompanyID = Number(req.user?.companyID);

      if (
        !employee.companyID ||
        !Number.isInteger(tokenCompanyID) ||
        tokenCompanyID !== employee.companyID
      ) {
        throw new ForbiddenException(
          'Company Owner access could not be verified.',
        );
      }

      return this.leaveApplicationService.findByCompany(employee.companyID);
    }

    // Managers receive their own records plus their reporting-tree records.
    // Keep results within their company where a company is assigned.
    const records =
      await this.leaveApplicationService.findByEmployee(employeeId);

    const reporteeIds =
      await this.managerScope.getDescendantReporteeIds(employeeId);

    const allowedIds = new Set([employeeId, ...reporteeIds]);

    return records.filter((record) => {
      const recordEmployeeId = Number(record.manageEmployeeID);

      if (!allowedIds.has(recordEmployeeId)) return false;

      // Always allow the employee to see their own records.
      if (recordEmployeeId === employeeId) return true;

      // Reportee records must belong to the manager's company.
      return (
        employee.companyID != null &&
        Number(record.companyID) === employee.companyID
      );
    });
  }
  @Get(':id')
  async findOne(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    await this.assertOwnLeave(id, req);
    return this.leaveApplicationService.findOne(id);
  }

  @Get()
  async findAll(@Req() req: any) {
    if (this.isEmployee(req)) {
      const employeeId = this.getEmployeeId(req);
      const records =
        await this.leaveApplicationService.findByEmployee(employeeId);

      return records.filter(
        (record) => Number(record.manageEmployeeID) === employeeId,
      );
    }

    return this.leaveApplicationService.findAll();
  }

  @Patch('revoke/:id')
  async revokeLeave(
    @Param('id', ParseIntPipe) id: number,
    @Body() body: { revokedReason?: string },
    @Req() req: any,
  ) {
    await this.assertOwnLeave(id, req);

    return this.leaveApplicationService.revokeLeave(id, body.revokedReason);
  }

  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateLeaveApplicationDto,
    @Req() req: any,
  ) {
    // Keep the existing non-employee account flow.
    if (!this.isEmployee(req)) {
      return this.leaveApplicationService.update(id, dto);
    }

    const actorId = this.getEmployeeId(req);

    const actor = await this.prisma.manageEmployee.findUnique({
      where: { id: actorId },
      select: {
        id: true,
        companyID: true,
        isCompanyOwner: true,
        isDeleted: true,
      },
    });

    if (!actor || actor.isDeleted) {
      throw new UnauthorizedException('Employee account not found');
    }

    const leave = await this.leaveApplicationService.findOne(id);

    if (!leave || !leave.manageEmployeeID) {
      throw new NotFoundException('Leave application not found');
    }

    const target = await this.prisma.manageEmployee.findUnique({
      where: { id: Number(leave.manageEmployeeID) },
      select: {
        id: true,
        companyID: true,
        isDeleted: true,
      },
    });

    if (!target || target.isDeleted) {
      throw new NotFoundException('Leave application not found');
    }

    // Both the leave and its employee must belong to the actor's company.
    if (
      !actor.companyID ||
      leave.companyID !== actor.companyID ||
      target.companyID !== actor.companyID
    ) {
      throw new ForbiddenException(
        'You cannot review leave requests outside your company.',
      );
    }
    if (Number(leave.manageEmployeeID) === actorId) {
      throw new ForbiddenException(
        'You cannot approve or reject your own leave request.',
      );
    }
    // Company Owners can review leave requests for their verified company.
    if (actor.isCompanyOwner === true) {
      const tokenCompanyID = Number(req.user?.companyID);

      if (
        !Number.isInteger(tokenCompanyID) ||
        tokenCompanyID !== actor.companyID
      ) {
        throw new ForbiddenException(
          'Company Owner access could not be verified.',
        );
      }
    } else {
      // Other employee accounts can review only employees in their reporting tree.
      const reporteeIds =
        await this.managerScope.getDescendantReporteeIds(actorId);

      if (!reporteeIds.includes(Number(leave.manageEmployeeID))) {
        throw new ForbiddenException(
          'You can only review leave requests from your reportees.',
        );
      }
    }

    return this.leaveApplicationService.update(id, dto);
  }

  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    if (this.isEmployee(req)) {
      throw new ForbiddenException(
        'Employee accounts cannot delete leave records',
      );
    }

    return this.leaveApplicationService.remove(id);
  }
}
