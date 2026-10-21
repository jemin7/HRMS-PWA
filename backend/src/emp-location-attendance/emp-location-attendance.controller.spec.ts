import { ForbiddenException, UnauthorizedException } from '@nestjs/common';
import { EmpLocationAttendanceController } from './emp-location-attendance.controller';

describe('EmpLocationAttendanceController employee identity guard', () => {
  let controller: EmpLocationAttendanceController;

  beforeEach(() => {
    controller = new EmpLocationAttendanceController({} as any, {} as any);
  });

  const getEmployeeId = (user: unknown): number =>
    (controller as any).getEmployeeId({ user });

  it('accepts a valid employee token', () => {
    expect(
      getEmployeeId({
        type: 'employee',
        role: 'EMPLOYEE',
        employeeId: 17,
        sub: 17,
      }),
    ).toBe(17);
  });

  it('rejects an ordinary user token even if its ID matches an employee ID', () => {
    expect(() =>
      getEmployeeId({
        type: 'user',
        role: 'ADMIN',
        sub: 17,
      }),
    ).toThrow(ForbiddenException);
  });

  it('rejects an employee token without an explicit employeeId', () => {
    expect(() =>
      getEmployeeId({
        type: 'employee',
        role: 'EMPLOYEE',
        sub: 17,
      }),
    ).toThrow(UnauthorizedException);
  });

  it.each([0, -1, 1.5, 'invalid', null, undefined])(
    'rejects an invalid employeeId: %s',
    (employeeId) => {
      expect(() =>
        getEmployeeId({
          type: 'employee',
          role: 'EMPLOYEE',
          employeeId,
        }),
      ).toThrow(UnauthorizedException);
    },
  );
});
