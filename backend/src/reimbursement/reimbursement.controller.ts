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
} from '@nestjs/common';
import type { Request } from 'express';
import { ReimbursementService } from './reimbursement.service';
import { CreateReimbursementDto } from './dto/create-reimbursement.dto';
import { UpdateReimbursementDto } from './dto/update-reimbursement.dto';
import { AuthGuard } from '@nestjs/passport';

type AuthenticatedRequest = Request & {
  user?: {
    employeeId?: number | string;
    sub?: number | string;
    role?: string;
    type?: string;
  };
};

@UseGuards(AuthGuard('jwt'))
@Controller('reimbursement')
export class ReimbursementController {
  constructor(private readonly service: ReimbursementService) {}

  // ➕ Single record
  @Post()
  create(@Body() dto: CreateReimbursementDto) {
    return this.service.create(dto);
  }

  // 🧾 Multiple records in one request
  @Post('bulk')
  createMany(@Body() dtos: CreateReimbursementDto[]) {
    return this.service.createMany(dtos);
  }

  // 📄 All reimbursements
  @Get()
  async findAll(@Req() req: AuthenticatedRequest) {
    const user = req.user;

    const isEmployee =
      user?.type === 'employee' ||
      String(user?.role || '').toUpperCase() === 'EMPLOYEE';

    if (isEmployee) {
      const viewerId = Number(user?.employeeId ?? user?.sub);

      if (!Number.isInteger(viewerId) || viewerId <= 0) {
        throw new UnauthorizedException(
          'Employee ID not found in authentication token',
        );
      }

      return this.service.findByEmployee(viewerId);
    }

    return this.service.findAll();
  }

  // 👨 Employee specific reimbursements

  @Get('employee/:empId')
  async findByEmployee(
    @Param('empId', ParseIntPipe) empId: number,
    @Req() req: AuthenticatedRequest,
  ) {
    const user = req.user;

    const isEmployee =
      user?.type === 'employee' ||
      String(user?.role || '').toUpperCase() === 'EMPLOYEE';

    if (isEmployee) {
      const viewerId = Number(user?.employeeId ?? user?.sub);

      if (!Number.isInteger(viewerId) || viewerId <= 0) {
        throw new UnauthorizedException(
          'Employee ID not found in authentication token',
        );
      }

      const allowed = await this.service.canViewEmployeeClaims(viewerId, empId);

      if (!allowed) {
        throw new ForbiddenException(
          'You are not allowed to view this employee’s reimbursement claims',
        );
      }
    }

    return this.service.findByEmployee(empId);
  }

  /** Team claims can only be requested for the signed-in employee's own team. */
  @Get('team/:managerId')
  async findTeamByManager(
    @Param('managerId', ParseIntPipe) managerId: number,
    @Req() req: AuthenticatedRequest,
  ) {
    const user = req.user;

    const isEmployee =
      user?.type === 'employee' ||
      String(user?.role || '').toUpperCase() === 'EMPLOYEE';

    if (!isEmployee) {
      throw new ForbiddenException(
        'An employee account is required to load team reimbursement claims',
      );
    }

    const viewerId = Number(user?.employeeId ?? user?.sub);

    if (!Number.isInteger(viewerId) || viewerId <= 0) {
      throw new UnauthorizedException(
        'Employee ID not found in authentication token',
      );
    }

    if (viewerId !== managerId) {
      throw new ForbiddenException(
        'You can only load your own reporting hierarchy',
      );
    }

    return this.service.findByManager(managerId);
  }

  // 🏢 Company specific reimbursements
  @Get('company/:companyId')
  findByCompany(@Param('companyId', ParseIntPipe) companyId: number) {
    return this.service.findByCompany(companyId);
  }

  @Patch(':id/items/:itemId/approve')
  approveItem(
    @Param('id', ParseIntPipe) id: number,
    @Param('itemId', ParseIntPipe) itemId: number,
    @Body() body?: { actorRole?: string },
  ) {
    return this.service.approveItem(id, itemId, body?.actorRole);
  }

  @Patch(':id/items/:itemId/reject')
  rejectItem(
    @Param('id', ParseIntPipe) id: number,
    @Param('itemId', ParseIntPipe) itemId: number,
    @Body() body?: { actorRole?: string },
  ) {
    return this.service.rejectItem(id, itemId, body?.actorRole);
  }

  @Patch(':id/items/:itemId/payment')
  updateItemPayment(
    @Param('id', ParseIntPipe) id: number,
    @Param('itemId', ParseIntPipe) itemId: number,
    @Body() body: { paidStatus: string; paymentRemark?: string },
  ) {
    return this.service.updateItemPayment(id, itemId, body);
  }

  // 🔍 Single reimbursement
  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.service.findOne(id);
  }

  // ✏️ Update reimbursement
  @Patch(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateReimbursementDto,
  ) {
    return this.service.update(id, dto);
  }

  @Patch(':id/payment')
  async updatePayment(
    @Param('id') id: string,
    @Body()
    paymentData: {
      paymentMode?: string;
      paymentType?: string;
      paymentDate?: string;
      paymentRemark?: string;
      paymentProof?: string;
      status?: string;
    },
  ) {
    return this.service.updatePayment(+id, paymentData);
  }

  @Patch(':id/approval')
  async updateApproval(
    @Param('id') id: string,
    @Body()
    approvalData: {
      approvalType?: string;
      salaryPeriod?: string;
      voucherCode?: string;
      voucherDate?: string;
      status?: string;
    },
  ) {
    return this.service.updateApproval(+id, approvalData);
  }

  @Get('status/:status')
  async findByStatus(@Param('status') status: string) {
    return this.service.findByStatus(status);
  }

  @Get('approval-type/:type')
  async findByApprovalType(@Param('type') type: string) {
    return this.service.findByApprovalType(type);
  }

  // ❌ Delete reimbursement
  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.service.remove(id);
  }
}
