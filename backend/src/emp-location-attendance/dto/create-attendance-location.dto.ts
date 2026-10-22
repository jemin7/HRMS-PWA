export class CreateAttendanceLocationDto {
  checkType: 'CHECK_IN' | 'CHECK_OUT' | 'BREAK_IN' | 'BREAK_OUT';
  clientEventId?: string;
  referenceEventId?: string;
  punchTime?: string;
  latitude: number;
  longitude: number;
  accuracy?: number;
  address?: string;
  deviceType?: string;
  browser?: string;
  operatingSystem?: string;
  userAgent?: string;
  photoUrl?: string;
}
