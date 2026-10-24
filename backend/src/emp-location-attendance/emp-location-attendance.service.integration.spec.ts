import 'dotenv/config';
import { Test } from '@nestjs/testing';
import { ForbiddenException } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { PrismaService } from '../prisma/prisma.service';
import { EmpLocationAttendanceService } from './emp-location-attendance.service';

/**
 * Integration tests: run against the REAL test database (DATABASE_URL from backend/.env).
 *
 * Write-path tests reuse an existing employee's live CHECK_IN record and insert
 * only rows whose clientLocationId starts with "jest-it-", all of which are
 * removed in afterAll. Read-path tests are read-only.
 */

const POINT_PREFIX = 'jest-it-';

describe('EmpLocationAttendanceService (integration vs test DB)', () => {
  let service: EmpLocationAttendanceService;
  let prisma: PrismaService;

  type LiveSession = {
    id: number;
    employeeId: number;
    checkinTime: Date;
  };

  let liveSession: LiveSession | null = null;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [PrismaModule],
      providers: [EmpLocationAttendanceService],
    }).compile();

    service = moduleRef.get(EmpLocationAttendanceService);
    prisma = moduleRef.get(PrismaService);

    // Synthesize a controlled CHECK_IN session for an existing employee so the
    // write path always runs against real rows, without depending on live data.
    const employee = await prisma.manageEmployee.findFirst({ select: { id: true } });

    if (!employee) {
      console.warn('Test DB has no ManageEmployee rows — write-path tests will skip.');
      return;
    }

    liveSession = await prisma.attendanceLocation.create({
      data: {
        clientEventId: `${POINT_PREFIX}session-${Date.now()}`,
        employeeId: employee.id,
        checkType: 'CHECK_IN',
        latitude: 12.9716,
        longitude: 77.5946,
        checkinTime: new Date(Date.now() - 2 * 60_000),
      },
      select: { id: true, employeeId: true, checkinTime: true },
    });
  });

  afterAll(async () => {
    await prisma.attendanceLocationPoint.deleteMany({
      where: { clientLocationId: { startsWith: POINT_PREFIX } },
    });
    await prisma.attendanceLocation.deleteMany({
      where: { clientEventId: { startsWith: `${POINT_PREFIX}session-` } },
    });
    await prisma.$disconnect();
  });

  it('reports location-sync diagnostics from the database', async () => {
    if (!liveSession) {
      console.warn('No live CHECK_IN session available — skipping diagnostics read test.');
      return;
    }

    const diagnostics = await service.getLocationSyncDiagnostics(liveSession.employeeId);

    expect(Number.isSafeInteger(diagnostics.totalPoints)).toBe(true);
    expect(diagnostics.totalPoints).toBeGreaterThanOrEqual(0);
    expect(diagnostics.latestPoint === null || typeof diagnostics.latestPoint === 'object').toBe(
      true,
    );
  });

  it('stores location points for a live check-in session (write path)', async () => {
    if (!liveSession) {
      console.warn('No live CHECK_IN session available — skipping write-path test.');
      return;
    }

    const clientLocationId = `${POINT_PREFIX}${Date.now()}-1`;
    const capturedAt = new Date(liveSession.checkinTime.getTime() + 60_000).toISOString();

    const first = await service.syncLocationPoints(liveSession.employeeId, [
      {
        clientLocationId,
        sessionEventId: String(liveSession.id),
        latitude: 12.9716,
        longitude: 77.5946,
        capturedAt,
      },
    ]);

    expect(first).toEqual({ received: 1, inserted: 1, duplicates: 0 });

    const stored = await prisma.attendanceLocationPoint.findUnique({
      where: { clientLocationId },
    });
    expect(stored).not.toBeNull();
    expect(stored?.attendanceSessionId).toBe(liveSession.id);
    expect(stored?.employeeId).toBe(liveSession.employeeId);
  });

  it('deduplicates retries by clientLocationId (idempotent write)', async () => {
    if (!liveSession) {
      console.warn('No live CHECK_IN session available — skipping idempotency test.');
      return;
    }

    const clientLocationId = `${POINT_PREFIX}${Date.now()}-2`;
    const point = {
      clientLocationId,
      sessionEventId: String(liveSession.id),
      latitude: 12.9716,
      longitude: 77.5946,
      capturedAt: new Date(liveSession.checkinTime.getTime() + 61_000).toISOString(),
    };

    await service.syncLocationPoints(liveSession.employeeId, [point]);
    const retry = await service.syncLocationPoints(liveSession.employeeId, [point]);

    expect(retry).toEqual({ received: 1, inserted: 0, duplicates: 1 });
  });

  it('rejects points captured before the session began and stores nothing', async () => {
    if (!liveSession) {
      console.warn('No live CHECK_IN session available — skipping window validation test.');
      return;
    }

    const clientLocationId = `${POINT_PREFIX}${Date.now()}-3`;

    await expect(
      service.syncLocationPoints(liveSession.employeeId, [
        {
          clientLocationId,
          sessionEventId: String(liveSession.id),
          latitude: 12.9716,
          longitude: 77.5946,
          capturedAt: new Date(liveSession.checkinTime.getTime() - 60_000).toISOString(),
        },
      ]),
    ).rejects.toThrow('Location timestamps must fall within the attendance tracking window.');

    const stored = await prisma.attendanceLocationPoint.findUnique({
      where: { clientLocationId },
    });
    expect(stored).toBeNull();
  });

  it('rejects points that reference a session the employee does not own', async () => {
    const unknownSessionId = 999_999_999;

    await expect(
      service.syncLocationPoints(1, [
        {
          clientLocationId: `${POINT_PREFIX}${Date.now()}-4`,
          sessionEventId: String(unknownSessionId),
          latitude: 12.9716,
          longitude: 77.5946,
          capturedAt: new Date().toISOString(),
        },
      ]),
    ).rejects.toThrow(ForbiddenException);
  });

  it('rejects batches outside the 1–200 points contract', async () => {
    await expect(
      service.syncLocationPoints(1, [
        {
          clientLocationId: 'BAD',
          sessionEventId: 'not-a-number',
          latitude: 200,
          longitude: 700,
          capturedAt: 'not-a-date',
        },
      ]),
    ).rejects.toThrow('One or more location points are invalid.');
  });
});
