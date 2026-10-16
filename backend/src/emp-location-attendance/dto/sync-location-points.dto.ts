import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsISO8601,
  IsLatitude,
  IsLongitude,
  IsString,
  Length,
  Matches,
  ValidateNested,
} from 'class-validator';

export class LocationPointInputDto {
  @IsString()
  @Length(1, 128)
  clientLocationId: string;

  // String representation of the CHECK_IN attendance record ID.
  @IsString()
  @Matches(/^[1-9]\d*$/)
  sessionEventId: string;

  @Type(() => Number)
  @IsLatitude()
  latitude: number;

  @Type(() => Number)
  @IsLongitude()
  longitude: number;

  @IsISO8601()
  capturedAt: string;
}

export class SyncLocationPointsDto {
  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(200)
  @ValidateNested({ each: true })
  @Type(() => LocationPointInputDto)
  points: LocationPointInputDto[];
}
