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
import { AuthGuard } from '@nestjs/passport';
import { GenerateSalaryService } from './generate-salary.service';
import { CreateGenerateSalaryDto } from './dto/create-generate-salary.dto';
import { UpdateGenerateSalaryDto } from './dto/update-generate-salary.dto';

@Controller('generate-salary')
@UseGuards(AuthGuard('jwt'))
export class GenerateSalaryController {
  constructor(private readonly service: GenerateSalaryService) {}

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

  @Post()
  create(@Body() dto: CreateGenerateSalaryDto, @Req() req: any) {
    if (this.isEmployee(req)) {
      throw new ForbiddenException(
        'Employee accounts cannot create payroll records',
      );
    }

    return this.service.create(dto);
  }

  @Get()
  findAll(@Req() req: any) {
    if (this.isEmployee(req)) {
      return this.service.findAll(this.getEmployeeId(req));
    }

    return this.service.findAll();
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    if (this.isEmployee(req)) {
      return this.service.findOne(id, this.getEmployeeId(req));
    }

    return this.service.findOne(id);
  }

  @Patch(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateGenerateSalaryDto,
    @Req() req: any,
  ) {
    if (this.isEmployee(req)) {
      throw new ForbiddenException(
        'Employee accounts cannot update payroll records',
      );
    }

    return this.service.update(id, dto);
  }

  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    if (this.isEmployee(req)) {
      throw new ForbiddenException(
        'Employee accounts cannot delete payroll records',
      );
    }

    return this.service.remove(id);
  }
}
