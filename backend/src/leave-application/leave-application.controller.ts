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
import { assertEmployeeModuleAccess } from '../common/employee-permission.util';

@Controller('leave-application')
@UseGuards(AuthGuard('jwt'))
export class LeaveApplicationController {
  constructor(
    private readonly leaveApplicationService: LeaveApplicationService,
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
    if (this.isEmployee(req)) {
      const employeeId = this.getEmployeeId(req);

      if (empId !== employeeId) {
        throw new NotFoundException('Leave application not found');
      }

      const records =
        await this.leaveApplicationService.findByEmployee(employeeId);

      return records.filter(
        (record) => Number(record.manageEmployeeID) === employeeId,
      );
    }

    return this.leaveApplicationService.findByEmployee(empId);
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
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateLeaveApplicationDto,
    @Req() req: any,
  ) {
    if (this.isEmployee(req)) {
      throw new ForbiddenException(
        'Employee accounts cannot directly update leave records',
      );
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
