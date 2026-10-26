import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { snapBranchesIDToCompany } from '../common/org-scope.util';
import { CreateWorkShiftDto } from './dto/create-work-shift.dto';
import { UpdateWorkShiftDto } from './dto/update-work-shift.dto';

@Injectable()
export class WorkShiftService {
  constructor(private prisma: PrismaService) {}

  private toPositiveId(value: unknown): number | null {
    const id = Number(value);
    return Number.isInteger(id) && id > 0 ? id : null;
  }

  private async resolveServiceProviderAssociation(
    companyID?: number | null,
    branchesID?: number | null,
    requestedServiceProviderID?: number | null,
  ): Promise<number | null> {
    const companyId = this.toPositiveId(companyID);
    const branchId = this.toPositiveId(branchesID);

    const branch = branchId
      ? await this.prisma.branches.findUnique({
          where: { id: branchId },
          select: {
            companyID: true,
            serviceProviderID: true,
          },
        })
      : null;

    const effectiveCompanyId =
      companyId ?? this.toPositiveId(branch?.companyID);

    const company = effectiveCompanyId
      ? await this.prisma.company.findUnique({
          where: { id: effectiveCompanyId },
          select: { serviceProviderID: true },
        })
      : null;

    // Prefer the association stored on the company, then the branch.
    const candidates = [
      this.toPositiveId(company?.serviceProviderID),
      this.toPositiveId(branch?.serviceProviderID),
    ].filter((id): id is number => id !== null);

    for (const id of [...new Set(candidates)]) {
      const provider = await this.prisma.serviceProvider.findUnique({
        where: { id },
        select: { id: true },
      });

      if (provider) {
        return provider.id;
      }
    }

    // Without a company or branch association, validate the supplied ID.
    if (!effectiveCompanyId && !branchId) {
      const requestedId = this.toPositiveId(requestedServiceProviderID);

      if (!requestedId) {
        return null;
      }

      const provider = await this.prisma.serviceProvider.findUnique({
        where: { id: requestedId },
        select: { id: true },
      });

      return provider?.id ?? null;
    }

    // Never save a stale, unverified provider ID.
    return null;
  }

  async create(data: CreateWorkShiftDto) {
    const { workShiftDays, ...workShiftData } = data;
    const branchesID = await snapBranchesIDToCompany(
      this.prisma,
      workShiftData.companyID,
      workShiftData.branchesID,
    );

    const resolvedServiceProviderID =
      await this.resolveServiceProviderAssociation(
        workShiftData.companyID,
        branchesID,
        workShiftData.serviceProviderID,
      );

    // Prepare the data object for creation
    const createData: any = {
      serviceProviderID: resolvedServiceProviderID,
      companyID: workShiftData.companyID,
      branchesID,
      workShiftName: workShiftData.workShiftName,
      workShiftType: workShiftData.workShiftType,
      isFlexible: workShiftData.isFlexible ?? false,
      isRotating: workShiftData.isRotating ?? false,
      isActive: workShiftData.isActive || '1',
      breakTimeMin: workShiftData.breakTimeMin ?? 0,
    };

    // Remove undefined values to avoid Prisma errors
    Object.keys(createData).forEach((key) => {
      if (createData[key] === undefined) {
        delete createData[key];
      }
    });

    // Add workShiftDays if they exist
    if (workShiftDays && workShiftDays.length > 0) {
      createData.workShiftDay = {
        create: workShiftDays.map((day) => ({
          weekDay: day.weekDay,
          shiftType: day.shiftType || 'WORK',
          weeklyOff: day.weeklyOff,
          startTime: day.startTime,
          endTime: day.endTime,
          breakStart: day.breakStart || null,
          breakEnd: day.breakEnd || null,
          totalMinutes: day.weeklyOff ? 0 : day.totalMinutes,
        })),
      };
    }

    return this.prisma.workShift.create({
      data: createData,
      include: {
        branches: true,
        company: true,
        serviceProvider: true,
        workShiftDay: true,
      },
    });
  }

  findAll(companyID?: number) {
    return this.prisma.workShift.findMany({
      where: companyID ? { companyID } : undefined,
      include: {
        branches: true,
        company: true,
        serviceProvider: true,
        workShiftDay: true,
      },
    });
  }

  findOne(id: number) {
    return this.prisma.workShift.findUnique({
      where: { id },
      include: {
        branches: true,
        company: true,
        serviceProvider: true,
        workShiftDay: true,
      },
    });
  }

  async update(id: number, data: UpdateWorkShiftDto) {
    const { workShiftDays, ...workShiftData } = data;

    // Resolve the existing associations first so partial updates
    // preserve the current company and branch.
    const existing = await this.prisma.workShift.findUnique({
      where: { id },
      select: {
        companyID: true,
        branchesID: true,
        serviceProviderID: true,
      },
    });

    const companyWasProvided = workShiftData.companyID !== undefined;
    const branchWasProvided = workShiftData.branchesID !== undefined;
    const providerWasProvided = workShiftData.serviceProviderID !== undefined;

    const requestedCompanyID = companyWasProvided
      ? workShiftData.companyID
      : existing?.companyID;

    const requestedBranchesID = branchWasProvided
      ? workShiftData.branchesID
      : existing?.branchesID;

    // Resolve the branch's actual company when the request has no
    // valid company ID.
    const requestedBranchId = this.toPositiveId(requestedBranchesID);

    const branchRecord = requestedBranchId
      ? await this.prisma.branches.findUnique({
          where: { id: requestedBranchId },
          select: {
            companyID: true,
          },
        })
      : null;

    const effectiveCompanyID =
      this.toPositiveId(requestedCompanyID) ??
      this.toPositiveId(branchRecord?.companyID);

    const resolvedBranchesID = await snapBranchesIDToCompany(
      this.prisma,
      effectiveCompanyID,
      requestedBranchesID,
    );

    const requestedServiceProviderID = providerWasProvided
      ? workShiftData.serviceProviderID
      : existing?.serviceProviderID;

    const resolvedServiceProviderID =
      await this.resolveServiceProviderAssociation(
        effectiveCompanyID,
        resolvedBranchesID,
        requestedServiceProviderID,
      );

    const updateData: any = {};

    // Update organizational associations only when relevant fields
    // were provided. Always use the validated provider ID.
    if (companyWasProvided || branchWasProvided) {
      updateData.companyID = effectiveCompanyID;
      updateData.branchesID = resolvedBranchesID;
    }

    if (providerWasProvided || companyWasProvided || branchWasProvided) {
      updateData.serviceProviderID = resolvedServiceProviderID;
    }
    if (workShiftData.workShiftName !== undefined) {
      updateData.workShiftName = workShiftData.workShiftName;
    }
    if (workShiftData.workShiftType !== undefined) {
      updateData.workShiftType = workShiftData.workShiftType;
    }
    if (workShiftData.isFlexible !== undefined) {
      updateData.isFlexible = workShiftData.isFlexible; // Already boolean
    }
    if (workShiftData.isRotating !== undefined) {
      updateData.isRotating = workShiftData.isRotating; // Already boolean
    }
    if (workShiftData.isActive !== undefined) {
      updateData.isActive = workShiftData.isActive;
    }
    if (workShiftData.breakTimeMin !== undefined) {
      updateData.breakTimeMin = workShiftData.breakTimeMin;
    }

    // Handle workShiftDays
    if (workShiftDays !== undefined) {
      updateData.workShiftDay = {
        deleteMany: {}, // Delete all existing days
        create: workShiftDays.map((day) => ({
          weekDay: day.weekDay,
          shiftType: day.shiftType || 'WORK',
          weeklyOff: day.weeklyOff,
          startTime: day.startTime,
          endTime: day.endTime,
          breakStart: day.breakStart || null,
          breakEnd: day.breakEnd || null,
          totalMinutes: day.weeklyOff ? 0 : day.totalMinutes,
        })),
      };
    }

    return this.prisma.workShift.update({
      where: { id },
      data: updateData,
      include: {
        branches: true,
        company: true,
        serviceProvider: true,
        workShiftDay: true,
      },
    });
  }

  remove(id: number) {
    return this.prisma.$transaction(async (prisma) => {
      // First delete all related WorkShiftDay records
      await prisma.workShiftDay.deleteMany({
        where: { workShiftID: id },
      });

      // Then delete the WorkShift record
      return prisma.workShift.delete({ where: { id } });
    });
  }
}
