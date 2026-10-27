import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateSalaryAllowanceDto } from './dto/create-salary-allowance.dto';
import { UpdateSalaryAllowanceDto } from './dto/update-salary-allowance.dto';

@Injectable()
export class SalaryAllowanceService {
  constructor(private readonly prisma: PrismaService) {}

  private includeRels() {
    return {
      branches: true,
      company: true,
      serviceProvider: true,
      monthlyPayGradeAllowanceList: true, // child list
    };
  }

  async create(dto: CreateSalaryAllowanceDto) {
    let serviceProviderID = dto.serviceProviderID ?? null;

    // The company's saved association is the source of truth.
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
      // Validate a provider when no company is supplied.
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

    return this.prisma.salaryAllowance.create({
      data: {
        serviceProviderID,
        companyID: dto.companyID ?? null,
        branchesID: dto.branchesID ?? null,
        salaryAllowanceName: dto.salaryAllowanceName ?? null,
        displayName: dto.displayName ?? null,
        allowanceType: dto.allowanceType ?? null,
        basedOn: dto.basedOn ?? null,
        salaryAllowanceType: dto.salaryAllowanceType ?? null,
        salaryAllowanceValue: dto.salaryAllowanceValue ?? null,
        salaryAllowanceMonthLimit: dto.salaryAllowanceMonthLimit ?? null,
      },
      include: this.includeRels(),
    });
  }

  async findAll() {
    return this.prisma.salaryAllowance.findMany({
      include: this.includeRels(),
      orderBy: { id: 'desc' },
    });
  }

  async findOne(id: number) {
    const rec = await this.prisma.salaryAllowance.findUnique({
      where: { id },
      include: this.includeRels(),
    });
    if (!rec) throw new NotFoundException(`SalaryAllowance id ${id} not found`);
    return rec;
  }

  async update(id: number, dto: UpdateSalaryAllowanceDto) {
    await this.ensureExists(id);
    return this.prisma.salaryAllowance.update({
      where: { id },
      data: {
        serviceProviderID: dto.serviceProviderID ?? undefined,
        companyID: dto.companyID ?? undefined,
        branchesID: dto.branchesID ?? undefined,
        salaryAllowanceName: dto.salaryAllowanceName ?? undefined,
        displayName: dto.displayName ?? undefined,
        allowanceType: dto.allowanceType ?? undefined,
        basedOn: dto.basedOn ?? undefined,
        salaryAllowanceType: dto.salaryAllowanceType ?? undefined,
        salaryAllowanceValue: dto.salaryAllowanceValue ?? undefined,
        salaryAllowanceMonthLimit: dto.salaryAllowanceMonthLimit ?? undefined,
      },
      include: this.includeRels(),
    });
  }

  async remove(id: number) {
    await this.ensureExists(id);
    await this.prisma.monthlyPayGradeAllowanceList.deleteMany({
      where: { salaryallowanceID: id },
    });
    return this.prisma.salaryAllowance.delete({
      where: { id },
    });
  }

  private async ensureExists(id: number) {
    const ok = await this.prisma.salaryAllowance.findUnique({ where: { id } });
    if (!ok) throw new NotFoundException(`SalaryAllowance id ${id} not found`);
  }
}
