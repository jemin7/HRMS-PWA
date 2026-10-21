-- CreateTable
CREATE TABLE "mobile_push_tokens" (
    "id" SERIAL NOT NULL,
    "employeeID" INTEGER NOT NULL,
    "expoPushToken" VARCHAR(255) NOT NULL,
    "platform" VARCHAR(16) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "lastSeenAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "mobile_push_tokens_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "mobile_push_tokens_expoPushToken_key"
ON "mobile_push_tokens"("expoPushToken");

-- CreateIndex
CREATE INDEX "mobile_push_tokens_employeeID_idx"
ON "mobile_push_tokens"("employeeID");

-- AddForeignKey
ALTER TABLE "mobile_push_tokens"
ADD CONSTRAINT "mobile_push_tokens_employeeID_fkey"
FOREIGN KEY ("employeeID")
REFERENCES "ManageEmployee"("id")
ON DELETE CASCADE
ON UPDATE CASCADE;