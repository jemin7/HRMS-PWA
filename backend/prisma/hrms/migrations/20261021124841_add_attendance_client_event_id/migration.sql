/*
  Warnings:

  - A unique constraint covering the columns `[clientEventId]` on the table `attendance_locations` will be added. If there are existing duplicate values, this will fail.

*/
-- AlterTable
ALTER TABLE "attendance_locations" ADD COLUMN     "clientEventId" VARCHAR(128);

-- CreateIndex
CREATE UNIQUE INDEX "attendance_locations_clienteventid_key" ON "attendance_locations"("clientEventId");
