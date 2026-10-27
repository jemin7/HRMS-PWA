import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateSalaryDeductionDto } from './dto/create-salary-deduction.dto';
import { UpdateSalaryDeductionDto } from './dto/update-salary-deduction.dto';

@Injectable()
export class SalaryDeductionService {
  constructor(private readonly prisma: PrismaService) {}

  private includeRels() {
    return {
      branches: true,
      company: true,
      serviceProvider: true,
      monthlyPayGradeDeductionList: true,
    };
  }

  async create(dto: CreateSalaryDeductionDto) {
    let serviceProviderID = dto.serviceProviderID ?? null;

    // Use the company's saved service-provider association.
    if (dto.companyID != null) {
      const company = await this.prisma.company.findUnique({
        where: { id: dto.companyID },
        select: {
          id: true,
          serviceProviderID: true,
        },
      });

      if (!company) {
        throw new NotFoundException(
          'The selected company was not found. Refresh the page and try again.',
        );
      }

      serviceProviderID = company.serviceProviderID ?? null;
    } else if (serviceProviderID != null) {
      // Validate the provider when no company is supplied.
      const provider = await this.prisma.serviceProvider.findUnique({
        where: { id: serviceProviderID },
        select: { id: true },
      });

      if (!provider) {
        throw new BadRequestException(
          'The selected service provider does not exist. Refresh the page and try again.',
        );
      }
    }

    return this.prisma.salaryDeduction.create({
      data: {
        serviceProviderID,
        companyID: dto.companyID ?? null,
        branchesID: dto.branchesID ?? null,
        salaryDeductionName: dto.salaryDeductionName ?? null,
        displayName: dto.displayName ?? null,
        deductionTypeField: dto.deductionTypeField ?? null,
        basedOn: dto.basedOn ?? null,
        salaryDeductionType: dto.salaryDeductionType ?? null,
        salaryDeductionValue: dto.salaryDeductionValue ?? null,
        salaryDeductionMonthLimit: dto.salaryDeductionMonthLimit ?? null,
      },
      include: this.includeRels(),
    });
  }

  async findAll() {
    return this.prisma.salaryDeduction.findMany({
      include: this.includeRels(),
      orderBy: { id: 'desc' },
    });
  }

  async findOne(id: number) {
    const rec = await this.prisma.salaryDeduction.findUnique({
      where: { id },
      include: this.includeRels(),
    });
    if (!rec) throw new NotFoundException(`SalaryDeduction id ${id} not found`);
    return rec;
  }

  async update(id: number, dto: UpdateSalaryDeductionDto) {
    await this.ensureExists(id);
    return this.prisma.salaryDeduction.update({
      where: { id },
      data: {
        serviceProviderID: dto.serviceProviderID ?? undefined,
        companyID: dto.companyID ?? undefined,
        branchesID: dto.branchesID ?? undefined,
        salaryDeductionName: dto.salaryDeductionName ?? undefined,
        displayName: dto.displayName ?? undefined,
        deductionTypeField: dto.deductionTypeField ?? undefined,
        basedOn: dto.basedOn ?? null,
        salaryDeductionType: dto.salaryDeductionType ?? undefined,
        salaryDeductionValue: dto.salaryDeductionValue ?? undefined,
        salaryDeductionMonthLimit: dto.salaryDeductionMonthLimit ?? undefined,
      },
      include: this.includeRels(),
    });
  }

  async remove(id: number) {
    await this.ensureExists(id);

    // Delete dependent MonthlyPayGradeDeductionList entries first
    await this.prisma.monthlyPayGradeDeductionList.deleteMany({
      where: { salaryDeductionID: id },
    });

    return this.prisma.salaryDeduction.delete({
      where: { id },
    });
  }

  private async ensureExists(id: number) {
    const ok = await this.prisma.salaryDeduction.findUnique({ where: { id } });
    if (!ok) throw new NotFoundException(`SalaryDeduction id ${id} not found`);
  }
}
