-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "DeviceStatus" AS ENUM ('Active', 'Inactive');

-- CreateEnum
CREATE TYPE "EmployeeLifecycleStatus" AS ENUM ('ACTIVE', 'INACTIVE', 'EXITED');

-- CreateEnum
CREATE TYPE "LeaveType" AS ENUM ('SL', 'CL', 'PL', 'LOP');

-- CreateEnum
CREATE TYPE "LeaveStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED');

-- CreateEnum
CREATE TYPE "ExitType" AS ENUM ('RESIGNATION', 'TERMINATION', 'RETRENCHMENT', 'RETIREMENT', 'DEATH', 'ABSCONDING', 'CONTRACT_END');

-- CreateEnum
CREATE TYPE "ExitStatus" AS ENUM ('DRAFT', 'NOTICE_RUNNING', 'APPROVED', 'WITHDRAWN', 'CANCELLED', 'FINAL_SETTLED');

-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('SUPERADMIN', 'SERVICE_PROVIDER', 'COMPANY_ADMIN', 'MULTI_COMPANY_ADMIN', 'CONTRACTOR_ADMIN', 'ADMIN', 'BRANCH_ADMIN', 'EMPLOYEE');

-- CreateEnum
CREATE TYPE "OTStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED');

-- CreateEnum
CREATE TYPE "AttendanceStatus" AS ENUM ('LATE', 'HALFDAY', 'FULLDAY', 'ABSENT', 'LOP', 'WEEKOFF');

-- CreateEnum
CREATE TYPE "RegularizeAs" AS ENUM ('PRESENT', 'HALF_DAY', 'LATE_MARK', 'SL', 'CL', 'PL', 'LOP', 'WEEKOFF');

-- CreateEnum
CREATE TYPE "ApprovalRequirement" AS ENUM ('ANY', 'ALL');

-- CreateEnum
CREATE TYPE "SubscriptionStatus" AS ENUM ('ACTIVE', 'INACTIVE', 'EXPIRED', 'CANCELLED', 'RENEWED');

-- CreateEnum
CREATE TYPE "WorkflowConditionMatchType" AS ENUM ('ALL', 'ANY');

-- CreateEnum
CREATE TYPE "WorkflowConditionField" AS ENUM ('BRANCH', 'DEPARTMENT', 'DESIGNATION', 'EMPLOYEE', 'TOTAL_AMOUNT', 'SALARY_AMOUNT', 'LEAVE_TYPE', 'LEAVE_DAYS', 'EXIT_TYPE', 'REGULARISATION_TYPE', 'REGULARISATION_DAYS', 'REQUEST_TEXT');

-- CreateEnum
CREATE TYPE "WorkflowConditionOperator" AS ENUM ('EQUALS', 'NOT_EQUALS', 'GREATER_THAN', 'GREATER_THAN_OR_EQUAL', 'LESS_THAN', 'LESS_THAN_OR_EQUAL', 'IN', 'NOT_IN', 'CONTAINS', 'NOT_CONTAINS', 'BETWEEN', 'IS_EMPTY', 'IS_NOT_EMPTY');

-- CreateEnum
CREATE TYPE "WorkflowConditionValueType" AS ENUM ('BRANCH', 'DEPARTMENT', 'DESIGNATION', 'EMPLOYEE_LIST', 'NUMBER', 'TEXT', 'BOOLEAN', 'DATE');

-- CreateEnum
CREATE TYPE "WorkflowApproverType" AS ENUM ('DESIGNATION', 'REPORTING_MANAGER');

-- CreateEnum
CREATE TYPE "ApprovalRequestStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'SENT_BACK', 'CANCELLED');

-- CreateEnum
CREATE TYPE "ApprovalStepStatus" AS ENUM ('WAITING', 'PENDING', 'APPROVED', 'REJECTED', 'SENT_BACK', 'SKIPPED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "ApprovalApproverStatus" AS ENUM ('WAITING', 'PENDING', 'APPROVED', 'REJECTED', 'SENT_BACK', 'SKIPPED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "ApprovalActionType" AS ENUM ('SUBMITTED', 'APPROVED', 'REJECTED', 'SENT_BACK', 'STEP_ACTIVATED', 'STEP_COMPLETED', 'REQUEST_COMPLETED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "AuthOtpPurpose" AS ENUM ('FORGOT_PASSWORD', 'SUPERADMIN_LOGIN');

-- CreateEnum
CREATE TYPE "CompanyPolicyType" AS ENUM ('TERMS_OF_USE', 'PRIVACY_POLICY', 'SLA');

-- CreateTable
CREATE TABLE "AttendancePolicy" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "attendancePolicyName" VARCHAR,
    "workingHoursType" VARCHAR,
    "checkin_begin_before_min" INTEGER,
    "checkout_end_after_min" INTEGER,
    "checkin_grace_time_min" INTEGER,
    "earlyCheckoutBeforeEndMin" INTEGER,
    "min_work_hours_half_day_min" INTEGER,
    "max_late_check_in_time" INTEGER,
    "markAs" TEXT,
    "lateMarkCount" TEXT,
    "allow_self_mark_attendance" BOOLEAN DEFAULT false,
    "allow_manager_update_ot" BOOLEAN DEFAULT false,
    "max_ot_hours_per_day_min" INTEGER,
    "checkoutGracePeriodForOvertimeTrimming" INTEGER DEFAULT 0,
    "breakTimeForOT" INTEGER DEFAULT 0,
    "otMealApply" BOOLEAN DEFAULT false,
    "maxOvertimeHrs" INTEGER DEFAULT 0,
    "minOvertimeHrs" INTEGER DEFAULT 0,
    "countWorkhoursInMinutes" BOOLEAN DEFAULT false,
    "overtimeApplicable" BOOLEAN DEFAULT false,
    "overtimeTrimmingApply" BOOLEAN DEFAULT false,
    "minsForOTMealToken" INTEGER DEFAULT 0,
    "minsForBreakTimeForMeal" INTEGER DEFAULT 0,
    "leaveAroundHolidayCounted" BOOLEAN DEFAULT false,
    "lateMarkMarkAs" TEXT,
    "lateMarkMarkCount" TEXT,
    "maxLateCheckinMarkAs" TEXT,
    "trimPreshiftMin" INTEGER DEFAULT 0,
    "trimPostshiftMin" INTEGER DEFAULT 0,

    CONSTRAINT "AttendancePolicy_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BankDetails" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER NOT NULL,
    "bankName" VARCHAR,
    "bankBranchName" VARCHAR,
    "accountNo" VARCHAR,
    "ifscCode" VARCHAR,

    CONSTRAINT "BankDetails_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BonusSetup" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "bonusName" VARCHAR,
    "bonusType" VARCHAR,
    "bonusDescription" VARCHAR,
    "bonusBasedOn" VARCHAR,
    "bonusPercentage" VARCHAR,
    "bonusFixed" VARCHAR,

    CONSTRAINT "BonusSetup_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BonusAllocation" (
    "id" SERIAL NOT NULL,
    "branchesID" INTEGER,
    "departmentID" INTEGER,
    "bonusSetupID" INTEGER NOT NULL,
    "financialYear" INTEGER,
    "salaryPeriod" INTEGER,
    "employeeID" INTEGER NOT NULL,

    CONSTRAINT "BonusAllocation_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Branches" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchName" VARCHAR,
    "address" VARCHAR,
    "country" VARCHAR,
    "state" VARCHAR,
    "city" VARCHAR,
    "pincode" VARCHAR,
    "timeZone" VARCHAR,
    "currency" VARCHAR,
    "pfNo" VARCHAR,
    "tanNo" VARCHAR,
    "esiNo" VARCHAR,
    "linNo" VARCHAR,
    "gstNo" VARCHAR,
    "gstCertUrl" VARCHAR,
    "msmeNo" VARCHAR,
    "msmeCertUrl" VARCHAR,
    "shopRegNo" VARCHAR,
    "shopRegCertHistory" JSONB,
    "financialYearStart" VARCHAR,
    "contactNo" VARCHAR,
    "emailAdd" VARCHAR,
    "companyLogoUrl" VARCHAR,
    "SignatureUrl" VARCHAR,
    "branchType" VARCHAR,
    "latitude" VARCHAR,
    "longitude" VARCHAR,
    "geofenchradius" VARCHAR,
    "placeId" VARCHAR(256),
    "locationSource" VARCHAR(32),
    "locationVerified" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "Branches_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Company" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyName" VARCHAR,
    "address" VARCHAR,
    "country" VARCHAR,
    "state" VARCHAR,
    "city" VARCHAR,
    "pincode" VARCHAR,
    "timeZone" VARCHAR,
    "currency" VARCHAR,
    "pfNo" VARCHAR,
    "panNo" VARCHAR,
    "tanNo" VARCHAR,
    "esiNo" VARCHAR,
    "linNo" VARCHAR,
    "gstNo" VARCHAR,
    "gstCertUrl" VARCHAR,
    "website" VARCHAR,
    "gstRegistrationType" VARCHAR,
    "businessTradeName" VARCHAR,
    "shopRegNo" VARCHAR,
    "shopRegCertHistory" JSONB,
    "financialYearStart" VARCHAR,
    "contactNo" VARCHAR,
    "emailAdd" VARCHAR,
    "companyLogoUrl" VARCHAR,
    "SignatureUrl" VARCHAR,
    "companyType" VARCHAR,
    "legalEntityType" VARCHAR,
    "defaultOwnerTitle" VARCHAR,
    "noticePeriodDaysForResignation" VARCHAR,
    "noticePeriodDaysForTermination" VARCHAR,
    "pwaShowLeaveBalance" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "Company_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CompanyFederalDomain" (
    "id" SERIAL NOT NULL,
    "companyID" INTEGER NOT NULL,
    "code" VARCHAR(120) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CompanyFederalDomain_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Module" (
    "id" SERIAL NOT NULL,
    "moduleKey" VARCHAR(100) NOT NULL,
    "moduleName" VARCHAR(150) NOT NULL,
    "description" VARCHAR(255),
    "isActive" BOOLEAN NOT NULL DEFAULT false,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Module_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CompanyModule" (
    "id" SERIAL NOT NULL,
    "companyID" INTEGER NOT NULL,
    "moduleID" INTEGER NOT NULL,
    "isEnabled" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CompanyModule_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Contractors" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "contractorName" VARCHAR,
    "address" VARCHAR,
    "country" VARCHAR,
    "state" VARCHAR,
    "city" VARCHAR,
    "pincode" VARCHAR,
    "timeZone" VARCHAR,
    "currency" VARCHAR,
    "pfNo" VARCHAR,
    "tanNo" VARCHAR,
    "esiNo" VARCHAR,
    "linNo" VARCHAR,
    "gstNo" VARCHAR,
    "gstCertUrl" VARCHAR,
    "shopRegNo" VARCHAR,
    "shopRegCertUrl" VARCHAR,
    "financialYearStart" VARCHAR,
    "contactNo" VARCHAR,
    "emailAdd" VARCHAR,
    "companyLogoUrl" VARCHAR,
    "SignatureUrl" VARCHAR,
    "contractorType" VARCHAR,

    CONSTRAINT "Contractors_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ContractorBranch" (
    "id" SERIAL NOT NULL,
    "contractorID" INTEGER NOT NULL,
    "branchID" INTEGER NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ContractorBranch_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ComplianceRule" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "ruleText" TEXT NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ComplianceRule_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ContractorPayout" (
    "id" SERIAL NOT NULL,
    "contractorID" INTEGER NOT NULL,
    "branchID" INTEGER,
    "departmentIDs" VARCHAR,
    "designationIDs" VARCHAR,
    "employeeIDs" VARCHAR,
    "workshiftIDs" VARCHAR,
    "rateCardID" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ContractorPayout_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ContractorRateCard" (
    "id" SERIAL NOT NULL,
    "contractorID" INTEGER NOT NULL,
    "rateCardName" TEXT,
    "contractorName" VARCHAR,
    "branchName" VARCHAR,
    "departmentName" VARCHAR,
    "designation" VARCHAR,
    "workShiftName" VARCHAR,
    "payoutType" VARCHAR,
    "perMinuteRate" DOUBLE PRECISION DEFAULT 0,
    "perHourRate" DOUBLE PRECISION DEFAULT 0,
    "perDayRate" DOUBLE PRECISION DEFAULT 0,
    "perMonthRate" DOUBLE PRECISION DEFAULT 0,
    "dailyRateMinute" DOUBLE PRECISION DEFAULT 0,
    "dailyRateHour" DOUBLE PRECISION DEFAULT 0,
    "monthlyRateMinute" DOUBLE PRECISION DEFAULT 0,
    "monthlyRateHours" DOUBLE PRECISION DEFAULT 0,
    "otType" VARCHAR,
    "otPerMinuteRate" DOUBLE PRECISION DEFAULT 0,
    "otPerHourRate" DOUBLE PRECISION DEFAULT 0,
    "otRateMultiplier" DOUBLE PRECISION DEFAULT 0,
    "commissionType" VARCHAR,
    "commissionBasedOn" VARCHAR,
    "commissionValue" DOUBLE PRECISION DEFAULT 0,

    CONSTRAINT "ContractorRateCard_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Departments" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "parentDepartmentID" INTEGER,
    "departmentName" VARCHAR,

    CONSTRAINT "Departments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "DepartmentBranch" (
    "id" SERIAL NOT NULL,
    "departmentID" INTEGER NOT NULL,
    "branchesID" INTEGER NOT NULL,

    CONSTRAINT "DepartmentBranch_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Designations" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "departmentID" INTEGER,
    "parentDesignationID" INTEGER,
    "designation" VARCHAR,
    "isManager" BOOLEAN DEFAULT false,
    "maxHoursPerDay" VARCHAR,
    "nightShiftEligibility" VARCHAR,
    "noticePeriodDaysForResignation" VARCHAR,
    "noticePeriodDaysForTermination" VARCHAR,
    "shiftEligibility" VARCHAR,
    "weeklyOffPattern" VARCHAR,
    "otApplicable" VARCHAR,

    CONSTRAINT "Designations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Devices" (
    "id" SERIAL NOT NULL,
    "status" "DeviceStatus" NOT NULL DEFAULT 'Active',
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "deviceName" VARCHAR NOT NULL,
    "deviceMake" VARCHAR NOT NULL,
    "deviceModel" VARCHAR NOT NULL,
    "deviceSN" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deviceType" VARCHAR,
    "authTypes" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "latitude" DOUBLE PRECISION,
    "longitude" DOUBLE PRECISION,
    "address" TEXT,

    CONSTRAINT "Devices_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AttendanceLogs" (
    "id" SERIAL NOT NULL,
    "deviceId" INTEGER NOT NULL,
    "deviceSN" VARCHAR NOT NULL,
    "userId" VARCHAR NOT NULL,
    "logTime" VARCHAR NOT NULL,
    "status" VARCHAR NOT NULL DEFAULT '0',
    "workCode" VARCHAR NOT NULL DEFAULT '0',
    "rawData" TEXT NOT NULL,
    "authType" VARCHAR,
    "processed" VARCHAR NOT NULL DEFAULT '0',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AttendanceLogs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EmpAttendanceRegularise" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "departmentID" INTEGER,
    "manageEmployeeID" INTEGER,
    "attendanceDate" DATE,
    "day" TEXT,
    "checkInTime" TIMESTAMP(6),
    "checkOutTime" TIMESTAMP(6),
    "actualStatus" "AttendanceStatus",
    "requestedStatus" "RegularizeAs",
    "reason" VARCHAR,
    "remarks" VARCHAR,
    "status" VARCHAR DEFAULT 'Pending',
    "overtimeApplicable" BOOLEAN DEFAULT false,
    "otMealApply" BOOLEAN DEFAULT false,
    "otMealMinutes" INTEGER,
    "otBreakMinutes" INTEGER,
    "createdAt" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3),

    CONSTRAINT "EmpAttendanceRegularise_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EmpCurrentPosition" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "manageEmployeeID" INTEGER,
    "existingDepartmentID" INTEGER,
    "existingDesignationID" INTEGER,
    "existingMonthlyPayGradeID" INTEGER,
    "existingHourlyPayGradeID" INTEGER,
    "existingSalaryCtc" INTEGER,
    "existingEmploymentType" INTEGER,
    "effectiveFrom" DATE,
    "effectiveTo" DATE,
    "createdAt" TIMESTAMP(6),

    CONSTRAINT "EmpCurrentPosition_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PromotionRequest" (
    "id" SERIAL NOT NULL,
    "manageEmployeeID" INTEGER,
    "empID" VARCHAR,
    "newDepartmentID" INTEGER,
    "newDesignationID" INTEGER,
    "newMonthlyPayGradeID" INTEGER,
    "newHourlyPayGradeID" INTEGER,
    "newSalaryCtc" INTEGER,
    "newEmploymentType" INTEGER,
    "newEmployementStatus" VARCHAR,
    "proposedDepartmentID" INTEGER,
    "proposedDesignationID" INTEGER,
    "proposedMonthlyPayGradeID" INTEGER,
    "proposedHourlyPayGradeID" INTEGER,
    "proposedSalaryCtc" INTEGER,
    "proposedEmploymentType" INTEGER,
    "description" VARCHAR,
    "promotionDate" DATE,
    "status" VARCHAR,
    "applied_at" TIMESTAMPTZ(6),
    "approved_at" TIMESTAMPTZ(6),
    "updated_at" TIMESTAMPTZ(6),

    CONSTRAINT "PromotionRequest_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EmployeeDelegation" (
    "id" SERIAL NOT NULL,
    "delegatorId" INTEGER NOT NULL,
    "delegateeId" INTEGER NOT NULL,
    "delegationType" VARCHAR NOT NULL,
    "startDate" DATE,
    "endDate" DATE,
    "notification" VARCHAR NOT NULL,
    "description" VARCHAR,
    "status" VARCHAR NOT NULL DEFAULT 'ACTIVE',
    "isDeleted" BOOLEAN NOT NULL DEFAULT false,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "serviceProviderID" INTEGER,
    "createdAt" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "EmployeeDelegation_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EmpAttendanceLogs" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER NOT NULL,
    "companyID" INTEGER NOT NULL,
    "branchesID" INTEGER NOT NULL,
    "deviceID" INTEGER NOT NULL,
    "employeeID" INTEGER,
    "punchTimeStamp" VARCHAR NOT NULL,
    "latitude" INTEGER,
    "longitude" INTEGER,
    "googleMapLink" INTEGER,
    "location" INTEGER,
    "mobileDeviceID" INTEGER,
    "mobileDeviceInfo" INTEGER,
    "exported" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "EmpAttendanceLogs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EmpFieldSiteAttendance" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "manageEmployeeID" INTEGER,
    "siteName" VARCHAR,
    "address" VARCHAR,
    "latitude" VARCHAR,
    "longitude" VARCHAR,
    "fromDate" TIMESTAMP(3),
    "toDate" TIMESTAMP(3),

    CONSTRAINT "EmpFieldSiteAttendance_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "GenarateBonus" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "manageEmployeeID" INTEGER,
    "bonusSetupID" INTEGER,
    "financialYear" INTEGER,
    "salaryPeriod" INTEGER,

    CONSTRAINT "GenarateBonus_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "HourlyPayGrade" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "hourlyPayGradeName" VARCHAR,
    "hourlyRate" VARCHAR,

    CONSTRAINT "HourlyPayGrade_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "leaveApplication" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "manageEmployeeID" INTEGER,
    "remainingSickLeave" INTEGER,
    "remainingCasualLeave" INTEGER,
    "remainingEarnedLeave" INTEGER,
    "dayStatuses" JSONB,
    "revokedAt" TIMESTAMP(3),
    "revokedReason" TEXT,
    "appliedLeaveType" VARCHAR,
    "childNumber" VARCHAR,
    "birthEventDate" VARCHAR,
    "fromDate" DATE,
    "toDate" DATE,
    "purpose" VARCHAR,
    "status" VARCHAR DEFAULT 'Pending',

    CONSTRAINT "leaveApplication_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "leaveApplicationRequest" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "leaveApplicationID" INTEGER,
    "leaveApplicationStatus" VARCHAR,

    CONSTRAINT "leaveApplicationRequest_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "leavePolicy" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "leavePolicyName" VARCHAR,
    "sickLeaveCount" VARCHAR,
    "casualLeaveCount" VARCHAR,
    "maternityLeaveCount" VARCHAR,
    "paternityLeaveCount" VARCHAR,
    "earnLeaveWorkingMonths" VARCHAR,
    "earnLeaveCount" INTEGER,
    "isPrivilegedLeaveApplicable" BOOLEAN DEFAULT false,
    "privilegedLeaveRatio" VARCHAR,
    "weekOffConsideredInPL" BOOLEAN DEFAULT false,
    "holidayConsideredInPL" BOOLEAN DEFAULT false,
    "paidLeaveConsideredInPL" BOOLEAN DEFAULT false,
    "plCarryForwardLimit" INTEGER DEFAULT 0,
    "lapseEncashmentDate" DATE,

    CONSTRAINT "leavePolicy_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "leavePolicyHoliday" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "leavePolicyID" INTEGER,
    "publicHolidayID" INTEGER,

    CONSTRAINT "leavePolicyHoliday_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ManageEmployee" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "employeeFirstName" VARCHAR,
    "employeeLastName" VARCHAR,
    "employeeID" VARCHAR,
    "joiningDate" VARCHAR,
    "contractorID" INTEGER,
    "salaryPayoutTo" VARCHAR,
    "businessPhoneNo" VARCHAR,
    "businessEmail" VARCHAR,
    "personalPhoneNo" VARCHAR,
    "personalEmail" VARCHAR,
    "emergancyContact" VARCHAR,
    "emergencyContacts" JSONB,
    "presentAddress" VARCHAR,
    "permenantAddress" VARCHAR,
    "employeePhotoUrl" VARCHAR,
    "gender" VARCHAR,
    "numberOfChildren" INTEGER,
    "dateOfBirth" VARCHAR,
    "bloodGroup" VARCHAR,
    "maritalStatus" VARCHAR,
    "employeeFatherName" VARCHAR,
    "employeeMotherName" VARCHAR,
    "employeeSpouseName" VARCHAR,
    "departmentNameID" INTEGER,
    "designationID" INTEGER,
    "employmentType" VARCHAR,
    "employmentStatus" VARCHAR,
    "probationPeriod" VARCHAR,
    "workShiftID" INTEGER,
    "attendancePolicyID" INTEGER,
    "leavePolicyID" INTEGER,
    "salaryPayGradeType" VARCHAR,
    "monthlyPayGradeID" INTEGER,
    "hourlyPayGradeID" INTEGER,
    "empType" VARCHAR,
    "exitDate" TIMESTAMP(3),
    "isDeleted" BOOLEAN NOT NULL DEFAULT false,
    "isCompanyOwner" BOOLEAN NOT NULL DEFAULT false,
    "ownerTitle" VARCHAR,
    "salutation" VARCHAR,
    "lifecycleStatus" "EmployeeLifecycleStatus" NOT NULL DEFAULT 'ACTIVE',
    "onboardingApprovalStatus" "ApprovalRequestStatus" NOT NULL DEFAULT 'APPROVED',
    "maxHoursPerDay" VARCHAR,
    "nightShiftEligibility" VARCHAR,
    "noticePeriodDaysForResignation" VARCHAR,
    "noticePeriodDaysForTermination" VARCHAR,
    "pfMemberStatus" VARCHAR,
    "pfNumber" VARCHAR,
    "aadharNo" VARCHAR,
    "panNo" VARCHAR,
    "uanNo" VARCHAR,
    "esiNo" VARCHAR,
    "shiftEligibility" VARCHAR,
    "typeOfEmployee" VARCHAR,
    "weeklyOffPattern" VARCHAR,
    "salaryCycleID" INTEGER,
    "allowRotatingShift" BOOLEAN NOT NULL DEFAULT false,
    "allowCreateTaskOnMobile" BOOLEAN NOT NULL DEFAULT false,
    "pwaShowLeaveBalance" BOOLEAN NOT NULL DEFAULT true,
    "pwaShowLoanAdvances" BOOLEAN NOT NULL DEFAULT true,
    "mobileAttendanceEnabled" BOOLEAN NOT NULL DEFAULT false,
    "mobileBreakEnabled" BOOLEAN NOT NULL DEFAULT true,
    "photoPunchEnabled" BOOLEAN NOT NULL DEFAULT false,
    "wfhAllowed" BOOLEAN NOT NULL DEFAULT false,
    "wfhHomeAddress" TEXT,
    "wfhHomeLatitude" DOUBLE PRECISION,
    "wfhHomeLongitude" DOUBLE PRECISION,
    "placeId" VARCHAR(256),
    "locationSource" VARCHAR(32),
    "locationVerified" BOOLEAN NOT NULL DEFAULT false,
    "amc" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "ManageEmployee_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "employee_module_permissions" (
    "id" SERIAL NOT NULL,
    "companyID" INTEGER NOT NULL,
    "manageEmployeeID" INTEGER NOT NULL,
    "moduleKey" VARCHAR(64) NOT NULL,
    "canView" BOOLEAN NOT NULL DEFAULT false,
    "canCreate" BOOLEAN NOT NULL DEFAULT false,
    "canEdit" BOOLEAN NOT NULL DEFAULT false,
    "canDelete" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "employee_module_permissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "employee_documents" (
    "id" SERIAL NOT NULL,
    "employeeID" INTEGER NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "documentName" VARCHAR(200) NOT NULL,
    "documentCategory" VARCHAR(100) NOT NULL,
    "description" VARCHAR(500),
    "issuedDate" TIMESTAMP(3),
    "expiryDate" TIMESTAMP(3),
    "fileName" VARCHAR(255),
    "fileUrl" VARCHAR(500),
    "fileType" VARCHAR(100),
    "fileSize" INTEGER,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "employee_documents_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EmployeeFieldHistory" (
    "id" SERIAL NOT NULL,
    "employeeId" INTEGER NOT NULL,
    "fieldName" VARCHAR NOT NULL,
    "oldValue" VARCHAR,
    "newValue" VARCHAR,
    "oldLabel" VARCHAR,
    "newLabel" VARCHAR,
    "changedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "EmployeeFieldHistory_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EmployeeLink" (
    "id" SERIAL NOT NULL,
    "employeeId" INTEGER NOT NULL,
    "linkedEmployeeId" INTEGER NOT NULL,

    CONSTRAINT "EmployeeLink_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EmployeeTermination" (
    "id" SERIAL NOT NULL,
    "employeeId" INTEGER NOT NULL,
    "serviceProviderID" INTEGER NOT NULL,
    "companyID" INTEGER NOT NULL,
    "branchesID" INTEGER NOT NULL,
    "exitType" "ExitType" NOT NULL,
    "exitStatus" "ExitStatus" NOT NULL DEFAULT 'DRAFT',
    "reasonCategory" TEXT,
    "reasonNote" TEXT,
    "noticeDays" INTEGER,
    "noticeStartDate" TIMESTAMP(3),
    "lastWorkingDay" TIMESTAMP(3),
    "resignationDate" TIMESTAMP(3),
    "approvalDate" TIMESTAMP(3),
    "disableLoginOn" TIMESTAMP(3),
    "isRehireEligible" BOOLEAN NOT NULL DEFAULT true,
    "createdByUserId" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "EmployeeTermination_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EmployeeCredentials" (
    "id" SERIAL NOT NULL,
    "employeeID" INTEGER NOT NULL,
    "username" VARCHAR NOT NULL,
    "password" VARCHAR NOT NULL,
    "mustChangePassword" BOOLEAN NOT NULL DEFAULT true,
    "requireLoginOtp" BOOLEAN NOT NULL DEFAULT false,
    "passwordChangedAt" TIMESTAMP(3),
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "EmployeeCredentials_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "employee_bank_details" (
    "id" SERIAL NOT NULL,
    "employeeID" INTEGER NOT NULL,
    "bankName" VARCHAR,
    "bankBranchName" VARCHAR,
    "accNumber" VARCHAR,
    "ifscCode" VARCHAR,
    "upi" VARCHAR,

    CONSTRAINT "employee_bank_details_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EmpPromotion" (
    "id" SERIAL NOT NULL,
    "manageEmployeeID" INTEGER NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "departmentNameID" INTEGER,
    "designationID" INTEGER,
    "managerID" INTEGER,
    "employmentType" VARCHAR,
    "employmentStatus" VARCHAR,
    "probationPeriod" VARCHAR,
    "workShiftID" INTEGER,
    "attendancePolicyID" INTEGER,
    "leavePolicyID" INTEGER,
    "salaryPayGradeType" VARCHAR,
    "monthlyPayGradeID" INTEGER,
    "hourlyPayGradeID" INTEGER,
    "promotedSalaryCtc" INTEGER,
    "description" VARCHAR,
    "promotionDate" DATE,
    "status" VARCHAR,

    CONSTRAINT "EmpPromotion_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EmpEduQualification" (
    "id" SERIAL NOT NULL,
    "manageEmployeeID" INTEGER,
    "instituteType" VARCHAR,
    "instituteName" VARCHAR,
    "degree" VARCHAR,
    "pasingYear" VARCHAR,
    "marks" VARCHAR,
    "gpaCgpa" VARCHAR,
    "class" VARCHAR,

    CONSTRAINT "EmpEduQualification_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EmpProfExprience" (
    "id" SERIAL NOT NULL,
    "manageEmployeeID" INTEGER,
    "orgName" VARCHAR,
    "designation" VARCHAR,
    "fromDate" VARCHAR,
    "toDate" VARCHAR,
    "responsibility" VARCHAR,
    "skill" VARCHAR,

    CONSTRAINT "EmpProfExprience_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EmpDesignation" (
    "id" SERIAL NOT NULL,
    "manageEmployeeID" INTEGER,
    "designationID" INTEGER,
    "effectFrom" VARCHAR,

    CONSTRAINT "EmpDesignation_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EmpBranch" (
    "id" SERIAL NOT NULL,
    "manageEmployeeID" INTEGER NOT NULL,
    "branchesID" INTEGER NOT NULL,
    "effectFrom" VARCHAR,

    CONSTRAINT "EmpBranch_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EmpDepartment" (
    "id" SERIAL NOT NULL,
    "manageEmployeeID" INTEGER NOT NULL,
    "departmentNameID" INTEGER NOT NULL,
    "effectFrom" VARCHAR,

    CONSTRAINT "EmpDepartment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EmpEmploymentType" (
    "id" SERIAL NOT NULL,
    "manageEmployeeID" INTEGER NOT NULL,
    "employmentType" VARCHAR NOT NULL,
    "effectFrom" VARCHAR,

    CONSTRAINT "EmpEmploymentType_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EmpEmploymentStatus" (
    "id" SERIAL NOT NULL,
    "manageEmployeeID" INTEGER NOT NULL,
    "employmentStatus" VARCHAR NOT NULL,
    "probationPeriod" VARCHAR,
    "effectFrom" VARCHAR,

    CONSTRAINT "EmpEmploymentStatus_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EmpWorkShift" (
    "id" SERIAL NOT NULL,
    "manageEmployeeID" INTEGER NOT NULL,
    "workShiftID" INTEGER NOT NULL,
    "effectFrom" VARCHAR,

    CONSTRAINT "EmpWorkShift_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EmpAttendancePolicy" (
    "id" SERIAL NOT NULL,
    "manageEmployeeID" INTEGER NOT NULL,
    "attendancePolicyID" INTEGER NOT NULL,
    "effectFrom" VARCHAR,

    CONSTRAINT "EmpAttendancePolicy_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EmpLeavePolicy" (
    "id" SERIAL NOT NULL,
    "manageEmployeeID" INTEGER NOT NULL,
    "leavePolicyID" INTEGER NOT NULL,
    "effectFrom" VARCHAR,

    CONSTRAINT "EmpLeavePolicy_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EmpLeaveBalance" (
    "id" SERIAL NOT NULL,
    "manageEmployeeID" INTEGER NOT NULL,
    "sickUsed" INTEGER NOT NULL DEFAULT 0,
    "casualUsed" INTEGER NOT NULL DEFAULT 0,
    "privilegedUsed" INTEGER NOT NULL DEFAULT 0,
    "compOffUsed" INTEGER NOT NULL DEFAULT 0,
    "maternityUsed" INTEGER NOT NULL DEFAULT 0,
    "paternityUsed" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "EmpLeaveBalance_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EmpContractor" (
    "id" SERIAL NOT NULL,
    "manageEmployeeID" INTEGER NOT NULL,
    "contractorID" INTEGER NOT NULL,
    "effectFrom" VARCHAR,

    CONSTRAINT "EmpContractor_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EmpDeviceMapping" (
    "id" SERIAL NOT NULL,
    "manageEmployeeID" INTEGER,
    "deviceID" INTEGER NOT NULL,
    "deviceEmpCode" VARCHAR,
    "authType" VARCHAR,

    CONSTRAINT "EmpDeviceMapping_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TokenDeviceMapping" (
    "id" SERIAL NOT NULL,
    "manageEmployeeID" INTEGER,
    "deviceID" INTEGER,
    "deviceEmpCode" VARCHAR,
    "authType" VARCHAR,

    CONSTRAINT "TokenDeviceMapping_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ManageHoliday" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "holidayName" VARCHAR,
    "monthPeriod" VARCHAR,

    CONSTRAINT "ManageHoliday_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MonthlyPayGrade" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "monthlyPayGradeName" VARCHAR,
    "salType" VARCHAR,
    "grossSalary" VARCHAR,
    "percentageOfBasic" VARCHAR,
    "basicSalary" INTEGER,
    "miniOTTime" INTEGER,
    "otRate" VARCHAR,
    "otStatus" BOOLEAN,
    "payGradeType" VARCHAR,

    CONSTRAINT "MonthlyPayGrade_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MonthlyPayGradeAllowanceList" (
    "id" SERIAL NOT NULL,
    "monthlyPayGradeID" INTEGER,
    "salaryallowanceID" INTEGER,

    CONSTRAINT "MonthlyPayGradeAllowanceList_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MonthlyPayGradeDeductionList" (
    "id" SERIAL NOT NULL,
    "salaryDeductionID" INTEGER,
    "monthlyPayGradeID" INTEGER,

    CONSTRAINT "MonthlyPayGradeDeductionList_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PublicHoliday" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "manageHolidayID" INTEGER,
    "financialYear" VARCHAR,
    "startDate" DATE,
    "endDate" DATE,

    CONSTRAINT "PublicHoliday_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SalaryAllowance" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "salaryAllowanceName" VARCHAR,
    "displayName" VARCHAR,
    "salaryAllowanceType" VARCHAR,
    "salaryAllowanceValue" VARCHAR,
    "salaryAllowanceMonthLimit" VARCHAR,
    "allowanceType" VARCHAR,
    "basedOn" VARCHAR,

    CONSTRAINT "SalaryAllowance_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SalaryCycle" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "salaryCycleName" VARCHAR,
    "monthStartDay" VARCHAR,

    CONSTRAINT "SalaryCycle_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "GenerateSalary" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "employeeID" INTEGER NOT NULL,
    "monthPeriod" TEXT NOT NULL,
    "paymentMode" TEXT,
    "paymentType" TEXT,
    "paymentDate" TEXT,
    "paymentRemark" TEXT,
    "paymentProof" TEXT,
    "status" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "GenerateSalary_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SalaryDeduction" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "salaryDeductionName" VARCHAR,
    "displayName" VARCHAR,
    "deductionTypeField" VARCHAR,
    "salaryDeductionType" VARCHAR,
    "salaryDeductionValue" VARCHAR,
    "salaryDeductionMonthLimit" VARCHAR,
    "basedOn" VARCHAR,

    CONSTRAINT "SalaryDeduction_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ServiceProvider" (
    "id" SERIAL NOT NULL,
    "companyName" VARCHAR,
    "companyAddress" VARCHAR,
    "country" VARCHAR,
    "state" VARCHAR,
    "city" VARCHAR,
    "pincode" VARCHAR,
    "countryCode" VARCHAR,
    "gstNo" VARCHAR,
    "contactNo" VARCHAR,
    "emailAdd" VARCHAR,
    "website" VARCHAR,
    "companyLogoUrl" VARCHAR,
    "created_at" TIMESTAMP(6),
    "updated_at" TIMESTAMP(6),

    CONSTRAINT "ServiceProvider_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "WorkShift" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "workShiftName" VARCHAR,
    "isActive" VARCHAR,
    "workShiftType" VARCHAR,
    "isFlexible" BOOLEAN DEFAULT false,
    "isRotating" BOOLEAN DEFAULT false,
    "breakTimeMin" INTEGER DEFAULT 0,

    CONSTRAINT "WorkShift_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "WorkShiftDay" (
    "id" SERIAL NOT NULL,
    "workShiftID" INTEGER,
    "weekDay" VARCHAR,
    "shiftType" VARCHAR,
    "weeklyOff" BOOLEAN,
    "startTime" TEXT,
    "endTime" TEXT,
    "breakStart" TEXT,
    "breakEnd" TEXT,
    "totalMinutes" INTEGER,

    CONSTRAINT "WorkShiftDay_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CalendarDay" (
    "id" SERIAL NOT NULL,
    "year" INTEGER NOT NULL,
    "month" INTEGER NOT NULL,
    "day" INTEGER NOT NULL,
    "isoDate" TIMESTAMP(3) NOT NULL,
    "weekday" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CalendarDay_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Holiday" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "region" TEXT,
    "type" TEXT,
    "notes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Holiday_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "HolidayOnDay" (
    "id" SERIAL NOT NULL,
    "calendarDayId" INTEGER NOT NULL,
    "holidayId" INTEGER NOT NULL,

    CONSTRAINT "HolidayOnDay_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SalaryAdvance" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "manageEmployeeID" INTEGER,
    "previousAdvancesDue" TEXT,
    "advanceAmount" TEXT,
    "reason" TEXT,
    "status" TEXT DEFAULT 'Pending',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SalaryAdvance_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SalaryAdvanceRepayment" (
    "id" SERIAL NOT NULL,
    "salaryAdvanceID" INTEGER NOT NULL,
    "approvedAmount" TEXT NOT NULL,
    "startMonth" TIMESTAMP(3),
    "amount" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SalaryAdvanceRepayment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Reimbursement" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "departmentID" INTEGER,
    "manageEmployeeID" INTEGER,
    "taskProjectID" INTEGER,
    "date" TEXT,
    "reimbursementType" TEXT,
    "amount" TEXT,
    "description" TEXT,
    "status" TEXT DEFAULT 'Pending',
    "approvalType" TEXT,
    "salaryPeriod" TEXT,
    "voucherCode" TEXT,
    "voucherDate" TEXT,
    "paymentMode" TEXT,
    "paymentType" TEXT,
    "paymentDate" TEXT,
    "paymentRemark" TEXT,
    "paymentProof" TEXT,

    CONSTRAINT "Reimbursement_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ReimbursementItem" (
    "id" SERIAL NOT NULL,
    "reimbursementID" INTEGER NOT NULL,
    "reimbursementType" TEXT,
    "amount" TEXT,
    "description" TEXT,
    "status" TEXT DEFAULT 'Pending',
    "approvalType" TEXT,
    "paidStatus" TEXT,
    "paymentRemark" TEXT,

    CONSTRAINT "ReimbursementItem_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "User" (
    "id" SERIAL NOT NULL,
    "username" TEXT NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "role" "UserRole" NOT NULL DEFAULT 'EMPLOYEE',
    "firstName" TEXT,
    "lastName" TEXT,
    "contactNo" TEXT,
    "email" TEXT,
    "requireLoginOtp" BOOLEAN NOT NULL DEFAULT false,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "contractorID" INTEGER,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "UserCompany" (
    "id" SERIAL NOT NULL,
    "userID" INTEGER NOT NULL,
    "companyID" INTEGER NOT NULL,
    "isPrimary" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "UserCompany_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "UserProfile" (
    "id" SERIAL NOT NULL,
    "userId" INTEGER NOT NULL,
    "fullName" VARCHAR,
    "email" VARCHAR,
    "mobileNo" VARCHAR,
    "address" VARCHAR,
    "city" VARCHAR,
    "state" VARCHAR,
    "pincode" VARCHAR,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "UserProfile_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Overtime" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER NOT NULL,
    "companyID" INTEGER NOT NULL,
    "branchesID" INTEGER NOT NULL,
    "employeeID" INTEGER NOT NULL,
    "workShiftID" INTEGER NOT NULL,
    "workDate" TIMESTAMP(3) NOT NULL,
    "shiftStartTime" TIMESTAMP(3) NOT NULL,
    "shiftEndTime" TIMESTAMP(3) NOT NULL,
    "punchOutTime" TIMESTAMP(3) NOT NULL,
    "otStartTime" TIMESTAMP(3) NOT NULL,
    "otEndTime" TIMESTAMP(3) NOT NULL,
    "otMinutes" INTEGER NOT NULL,
    "otHours" DOUBLE PRECISION NOT NULL,
    "otRate" TEXT NOT NULL,
    "status" "OTStatus" NOT NULL DEFAULT 'PENDING',
    "rejectionReason" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Overtime_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Roster" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER NOT NULL,
    "companyID" INTEGER NOT NULL,
    "branchesID" INTEGER NOT NULL,
    "departmentID" INTEGER NOT NULL,
    "designationID" INTEGER,
    "fromDate" TIMESTAMP(3) NOT NULL,
    "toDate" TIMESTAMP(3) NOT NULL,
    "rosterPeriod" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'DRAFT',
    "createdBy" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Roster_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RosterEmployee" (
    "id" SERIAL NOT NULL,
    "rosterID" INTEGER NOT NULL,
    "employeeID" INTEGER NOT NULL,

    CONSTRAINT "RosterEmployee_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RosterDay" (
    "id" SERIAL NOT NULL,
    "rosterEmployeeID" INTEGER NOT NULL,
    "workDate" TIMESTAMP(3) NOT NULL,
    "workShiftID" INTEGER,
    "dayType" TEXT NOT NULL,
    "leaveType" TEXT,
    "isLocked" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "RosterDay_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PFCompliance" (
    "id" SERIAL NOT NULL,
    "companyID" INTEGER NOT NULL,
    "epfThresholdCount" INTEGER DEFAULT 20,
    "epfApplicable" BOOLEAN DEFAULT false,
    "voluntaryEnabled" BOOLEAN DEFAULT false,
    "wageCeiling" INTEGER DEFAULT 15000,
    "basicValidationPercent" DOUBLE PRECISION DEFAULT 40,
    "compulsoryForAll" BOOLEAN DEFAULT false,
    "employeeRate" DOUBLE PRECISION DEFAULT 12,
    "employerRate" DOUBLE PRECISION DEFAULT 12,
    "epsRate" DOUBLE PRECISION DEFAULT 8.33,
    "edliRate" DOUBLE PRECISION DEFAULT 0.5,
    "adminChargeRate" DOUBLE PRECISION DEFAULT 0.01,
    "edliMax" INTEGER DEFAULT 75,
    "adminChargeMax" INTEGER DEFAULT 2,
    "dueDate" INTEGER DEFAULT 15,
    "createdAt" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3),

    CONSTRAINT "PFCompliance_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ESICCompliance" (
    "id" SERIAL NOT NULL,
    "companyID" INTEGER NOT NULL,
    "esicThresholdCount" INTEGER DEFAULT 10,
    "esicApplicable" BOOLEAN DEFAULT false,
    "wageCeiling" INTEGER DEFAULT 21000,
    "disabledWageCeiling" INTEGER DEFAULT 25000,
    "employeeRate" DOUBLE PRECISION DEFAULT 0.75,
    "employerRate" DOUBLE PRECISION DEFAULT 3.25,
    "dueDate" INTEGER DEFAULT 15,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ESICCompliance_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PTCompliance" (
    "id" SERIAL NOT NULL,
    "companyID" INTEGER NOT NULL,
    "branchID" INTEGER NOT NULL,
    "ptApplicable" BOOLEAN DEFAULT false,
    "state" TEXT,
    "maxPTPersonPerYear" INTEGER DEFAULT 2500,
    "monthlyDueDate" INTEGER DEFAULT 15,
    "quarterlyDueDate" INTEGER DEFAULT 15,
    "monthlyReturnThreshold" INTEGER DEFAULT 20,
    "quarterlyReturnThreshold" INTEGER DEFAULT 19,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PTCompliance_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PTSlab" (
    "id" SERIAL NOT NULL,
    "ptComplianceID" INTEGER NOT NULL,
    "slabName" TEXT,
    "monthlyGrossFrom" INTEGER,
    "monthlyGrossTo" INTEGER,
    "amount" INTEGER,
    "applicableMonths" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PTSlab_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "essl_raw_attlog" (
    "id" SERIAL NOT NULL,
    "device_sn" TEXT NOT NULL,
    "request_path" TEXT,
    "query_params" TEXT,
    "raw_body" TEXT,
    "ip_address" TEXT,
    "is_valid" BOOLEAN,
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "log_type" VARCHAR(20),
    "user_id" VARCHAR(20),
    "punch_time" VARCHAR(50),
    "auth_type" VARCHAR(20),
    "export" INTEGER DEFAULT 0,

    CONSTRAINT "essl_raw_attlog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "process_att_logs" (
    "id" SERIAL NOT NULL,
    "device_sn" VARCHAR(100),
    "user_id" VARCHAR(50),
    "username" VARCHAR(255),
    "punch_time" TIMESTAMP(6),
    "company_name" VARCHAR(255),
    "branch_name" VARCHAR(255),
    "department_name" VARCHAR(255),
    "device_emp_code" VARCHAR(50),
    "manage_employee_id" INTEGER,
    "device_id" INTEGER,
    "raw_body" TEXT,
    "processed_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "status" VARCHAR(20) DEFAULT '0',
    "device_name" VARCHAR(100),
    "device_type" VARCHAR(10),
    "auth_type" VARCHAR(20),

    CONSTRAINT "process_att_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "canteen_setup" (
    "id" SERIAL NOT NULL,
    "default_token_enabled" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) NOT NULL,

    CONSTRAINT "canteen_setup_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "canteen_tr_logs" (
    "id" SERIAL NOT NULL,
    "device_sn" VARCHAR(100),
    "user_id" VARCHAR(50),
    "username" VARCHAR(255),
    "punch_time" TIMESTAMP(6),
    "manage_employee_id" INTEGER,
    "device_id" INTEGER,
    "default_token" BOOLEAN NOT NULL DEFAULT false,
    "auth_type" VARCHAR(20),
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "canteen_tr_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "canteen_tv_logs" (
    "id" SERIAL NOT NULL,
    "device_sn" VARCHAR(100),
    "user_id" VARCHAR(50),
    "username" VARCHAR(255),
    "punch_time" TIMESTAMP(6),
    "manage_employee_id" INTEGER,
    "device_id" INTEGER,
    "default_token" BOOLEAN NOT NULL DEFAULT false,
    "auth_type" VARCHAR(20),
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "canteen_tv_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "canteen_tv_not_logs" (
    "id" SERIAL NOT NULL,
    "device_sn" VARCHAR(100),
    "user_id" VARCHAR(50),
    "username" VARCHAR(255),
    "punch_time" TIMESTAMP(6),
    "manage_employee_id" INTEGER,
    "device_id" INTEGER,
    "default_token" BOOLEAN NOT NULL DEFAULT false,
    "auth_type" VARCHAR(20),
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "canteen_tv_not_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PrivilegedLeaveLedger" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "employeeID" INTEGER NOT NULL,
    "leavePolicyID" INTEGER NOT NULL,
    "creditedLeaves" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "usedLeaves" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "balanceLeaves" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "creditDate" DATE NOT NULL,
    "description" VARCHAR,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PrivilegedLeaveLedger_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EmployeeHolidayOverride" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "employeeID" INTEGER NOT NULL,
    "holidayId" INTEGER NOT NULL,
    "fromDate" DATE NOT NULL,
    "toDate" DATE NOT NULL,
    "reason" VARCHAR,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "EmployeeHolidayOverride_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EmployeeWeeklyOff" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "employeeID" INTEGER NOT NULL,
    "date" DATE NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "EmployeeWeeklyOff_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PrivilegedLeaveLapse" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "employeeID" INTEGER NOT NULL,
    "leavePolicyID" INTEGER NOT NULL,
    "leaveCount" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "lapseDate" DATE NOT NULL,
    "reason" VARCHAR,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PrivilegedLeaveLapse_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EmployeeMemo" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "employeeID" INTEGER,
    "employeeIDs" INTEGER[],
    "memoType" VARCHAR,
    "subject" VARCHAR,
    "description" TEXT,
    "issuedDate" DATE,
    "issuedBy" VARCHAR,
    "senderEmployeeId" INTEGER,
    "parentMemoId" INTEGER,
    "attachmentPath" VARCHAR(500),
    "undoneAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "EmployeeMemo_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FactualWorkShift" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "workShiftName" VARCHAR,
    "isActive" VARCHAR,
    "workShiftType" VARCHAR,
    "isFlexible" BOOLEAN DEFAULT false,
    "isRotating" BOOLEAN DEFAULT false,
    "breakTimeMin" INTEGER DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "FactualWorkShift_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FactualWorkShiftDay" (
    "id" SERIAL NOT NULL,
    "factualWorkShiftID" INTEGER,
    "weekDay" VARCHAR,
    "shiftType" VARCHAR,
    "weeklyOff" BOOLEAN,
    "startTime" TEXT,
    "endTime" TEXT,
    "breakStart" TEXT,
    "breakEnd" TEXT,
    "totalMinutes" INTEGER,

    CONSTRAINT "FactualWorkShiftDay_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FactualAttendancePolicy" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "attendancePolicyName" VARCHAR,
    "workingHoursType" VARCHAR,
    "checkin_begin_before_min" INTEGER,
    "checkout_end_after_min" INTEGER,
    "checkin_grace_time_min" INTEGER,
    "earlyCheckoutBeforeEndMin" INTEGER,
    "min_work_hours_half_day_min" INTEGER,
    "max_late_check_in_time" INTEGER,
    "markAs" TEXT,
    "lateMarkCount" TEXT,
    "allow_self_mark_attendance" BOOLEAN DEFAULT false,
    "allow_manager_update_ot" BOOLEAN DEFAULT false,
    "max_ot_hours_per_day_min" INTEGER,
    "checkoutGracePeriodForOvertimeTrimming" INTEGER DEFAULT 0,
    "breakTimeForOT" INTEGER DEFAULT 0,
    "otMealApply" BOOLEAN DEFAULT false,
    "maxOvertimeHrs" INTEGER DEFAULT 0,
    "minOvertimeHrs" INTEGER DEFAULT 0,
    "countWorkhoursInMinutes" BOOLEAN DEFAULT false,
    "overtimeApplicable" BOOLEAN DEFAULT false,
    "overtimeTrimmingApply" BOOLEAN DEFAULT false,
    "minsForOTMealToken" INTEGER DEFAULT 0,
    "minsForBreakTimeForMeal" INTEGER DEFAULT 0,
    "weekoffCompulsory" BOOLEAN DEFAULT false,
    "leaveAroundHolidayCounted" BOOLEAN DEFAULT false,
    "lateMarkMarkAs" TEXT,
    "lateMarkMarkCount" TEXT,
    "maxLateCheckinMarkAs" TEXT,
    "trimPreshiftMin" INTEGER DEFAULT 0,
    "trimPostshiftMin" INTEGER DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "FactualAttendancePolicy_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EmpFactualWorkShift" (
    "id" SERIAL NOT NULL,
    "manageEmployeeID" INTEGER NOT NULL,
    "factualWorkShiftID" INTEGER NOT NULL,
    "effectFrom" VARCHAR,

    CONSTRAINT "EmpFactualWorkShift_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EmpFactualAttendancePolicy" (
    "id" SERIAL NOT NULL,
    "manageEmployeeID" INTEGER NOT NULL,
    "factualAttendancePolicyID" INTEGER NOT NULL,
    "effectFrom" VARCHAR,

    CONSTRAINT "EmpFactualAttendancePolicy_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FactualRoster" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER NOT NULL,
    "companyID" INTEGER NOT NULL,
    "branchesID" INTEGER NOT NULL,
    "departmentID" INTEGER NOT NULL,
    "designationID" INTEGER,
    "fromDate" TIMESTAMP(3) NOT NULL,
    "toDate" TIMESTAMP(3) NOT NULL,
    "rosterPeriod" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'DRAFT',
    "createdBy" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "FactualRoster_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FactualRosterEmployee" (
    "id" SERIAL NOT NULL,
    "factualRosterID" INTEGER NOT NULL,
    "employeeID" INTEGER NOT NULL,

    CONSTRAINT "FactualRosterEmployee_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FactualRosterDay" (
    "id" SERIAL NOT NULL,
    "factualRosterEmployeeID" INTEGER NOT NULL,
    "workDate" TIMESTAMP(3) NOT NULL,
    "factualWorkShiftID" INTEGER,
    "dayType" TEXT NOT NULL,
    "leaveType" TEXT,
    "isLocked" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "FactualRosterDay_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "attendance_locations" (
    "id" SERIAL NOT NULL,
    "employeeId" INTEGER NOT NULL,
    "checkType" VARCHAR(20) NOT NULL,
    "latitude" DOUBLE PRECISION NOT NULL,
    "longitude" DOUBLE PRECISION NOT NULL,
    "accuracy" DOUBLE PRECISION,
    "address" TEXT,
    "ipAddress" VARCHAR(64),
    "deviceType" VARCHAR(64),
    "browser" VARCHAR(128),
    "operatingSystem" VARCHAR(128),
    "userAgent" TEXT,
    "photoUrl" VARCHAR(512),
    "fenceType" VARCHAR(16),
    "fenceSiteId" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "serviceProviderID" INTEGER,
    "checkinTime" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "attendance_locations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EmpAbsentDeclaration" (
    "id" SERIAL NOT NULL,
    "employeeId" INTEGER NOT NULL,
    "absentDate" DATE NOT NULL,
    "reason" TEXT NOT NULL,
    "leaveType" VARCHAR(32) NOT NULL,
    "leaveApplicationId" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "EmpAbsentDeclaration_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TaskCustomer" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "branchesID" INTEGER,
    "customerCode" VARCHAR(64) NOT NULL,
    "customerName" VARCHAR(255) NOT NULL,
    "addressType" VARCHAR(64),
    "address" TEXT,
    "city" VARCHAR(128),
    "state" VARCHAR(128),
    "pincode" VARCHAR(32),
    "country" VARCHAR(128),
    "gstNo" VARCHAR(32),
    "erpAddressBookId" INTEGER,
    "relationshipManagerName" VARCHAR(255),
    "relationshipManagerEmail" VARCHAR(255),
    "createdByUserID" INTEGER,
    "isDeleted" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "TaskCustomer_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TaskCustomerContact" (
    "id" SERIAL NOT NULL,
    "customerID" INTEGER NOT NULL,
    "contactPerson" VARCHAR(255) NOT NULL,
    "contactNumber" VARCHAR(64) NOT NULL,
    "designation" VARCHAR(128),
    "email" VARCHAR(255),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TaskCustomerContact_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TaskCustomerSite" (
    "id" SERIAL NOT NULL,
    "companyID" INTEGER,
    "customerID" INTEGER NOT NULL,
    "siteCode" VARCHAR(64),
    "erpSiteId" INTEGER,
    "branchName" VARCHAR(255) NOT NULL,
    "address" TEXT,
    "city" VARCHAR(128),
    "state" VARCHAR(128),
    "pincode" VARCHAR(32),
    "country" VARCHAR(128),
    "gstNo" VARCHAR(32),
    "latitude" VARCHAR(64),
    "longitude" VARCHAR(64),
    "placeId" VARCHAR(256),
    "locationSource" VARCHAR(32),
    "locationVerified" BOOLEAN NOT NULL DEFAULT false,
    "isDeleted" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "TaskCustomerSite_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TaskCustomerSiteContact" (
    "id" SERIAL NOT NULL,
    "siteID" INTEGER NOT NULL,
    "contactPerson" VARCHAR(255) NOT NULL,
    "contactNumber" VARCHAR(64) NOT NULL,
    "designation" VARCHAR(128),
    "email" VARCHAR(255),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TaskCustomerSiteContact_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TaskCustomerSiteNote" (
    "id" SERIAL NOT NULL,
    "siteID" INTEGER NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "createdBy" VARCHAR(255),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "TaskCustomerSiteNote_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EnplEntityMapping" (
    "id" SERIAL NOT NULL,
    "companyID" INTEGER NOT NULL,
    "entityType" VARCHAR(32) NOT NULL,
    "hrmsId" INTEGER NOT NULL,
    "enplId" INTEGER,
    "enplCode" VARCHAR(128),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "EnplEntityMapping_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TaskWorkscopeCategory" (
    "id" SERIAL NOT NULL,
    "companyID" INTEGER,
    "workscopeCategoryName" VARCHAR(255) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TaskWorkscopeCategory_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TaskProduct" (
    "id" SERIAL NOT NULL,
    "companyID" INTEGER,
    "productName" VARCHAR(255) NOT NULL,
    "productCode" VARCHAR(64),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TaskProduct_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TaskProject" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER,
    "taskCode" VARCHAR(64) NOT NULL,
    "erpTaskId" INTEGER,
    "departmentID" INTEGER,
    "taskType" VARCHAR(64) NOT NULL,
    "customerID" INTEGER,
    "siteID" INTEGER,
    "taskName" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "attachment" VARCHAR(512),
    "scheduleDateTime" TIMESTAMP(3),
    "priority" VARCHAR(32) NOT NULL DEFAULT 'Medium',
    "dueDateTime" TIMESTAMP(3),
    "expectedDurationMinutes" INTEGER,
    "siteVisits" JSONB,
    "siteVisitSummary" JSONB,
    "siteLatitude" VARCHAR(64),
    "siteLongitude" VARCHAR(64),
    "daySignOutSelfieRequired" BOOLEAN NOT NULL DEFAULT false,
    "status" VARCHAR(64) NOT NULL DEFAULT 'Open',
    "createdByName" VARCHAR(255),
    "createdByUserID" INTEGER,
    "createdByEmployeeID" INTEGER,
    "isDeleted" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "TaskProject_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TaskAssignment" (
    "id" SERIAL NOT NULL,
    "taskID" INTEGER NOT NULL,
    "manageEmployeeID" INTEGER NOT NULL,
    "assignedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TaskAssignment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TaskEngineerAssignment" (
    "id" SERIAL NOT NULL,
    "taskID" INTEGER NOT NULL,
    "manageEmployeeID" INTEGER,
    "engineerName" VARCHAR(255),
    "engineerEmail" VARCHAR(255),
    "engineerPhone" VARCHAR(64),
    "proposedDateTime" TIMESTAMP(3),
    "priority" VARCHAR(32),
    "status" VARCHAR(64),
    "notes" TEXT,
    "assignedDate" TIMESTAMP(3),
    "rescheduleReason" TEXT,
    "managerReason" TEXT,
    "enplAssignmentId" INTEGER,
    "visitSequence" INTEGER,
    "scheduledArrival" TIMESTAMP(3),
    "visitDate" TIMESTAMP(3),
    "allowedRadiusMeters" INTEGER,
    "graceMinutes" INTEGER,
    "visitDurationMinutes" INTEGER,
    "visitLatitude" VARCHAR(64),
    "visitLongitude" VARCHAR(64),
    "complianceStatus" VARCHAR(32),
    "exceptionStatus" VARCHAR(64),
    "signOutForTheDay" BOOLEAN,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "TaskEngineerAssignment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TaskRemark" (
    "id" SERIAL NOT NULL,
    "taskID" INTEGER NOT NULL,
    "userID" INTEGER,
    "employeeID" INTEGER,
    "authorName" VARCHAR(255),
    "createdBy" VARCHAR(255),
    "remark" TEXT NOT NULL,
    "status" VARCHAR(64),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TaskRemark_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TaskProjectContact" (
    "id" SERIAL NOT NULL,
    "taskID" INTEGER NOT NULL,
    "contactName" VARCHAR(255) NOT NULL,
    "contactNumber" VARCHAR(64) NOT NULL,
    "contactEmail" VARCHAR(255),
    "designation" VARCHAR(128),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TaskProjectContact_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TaskWorkscopeDetail" (
    "id" SERIAL NOT NULL,
    "taskID" INTEGER NOT NULL,
    "workscopeCategoryID" INTEGER,
    "workscopeDetails" TEXT,
    "extraNote" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TaskWorkscopeDetail_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TaskSchedule" (
    "id" SERIAL NOT NULL,
    "taskID" INTEGER NOT NULL,
    "proposedDateTime" TIMESTAMP(3),
    "priority" VARCHAR(32),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TaskSchedule_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TaskImage" (
    "id" SERIAL NOT NULL,
    "taskID" INTEGER NOT NULL,
    "filename" VARCHAR(255) NOT NULL,
    "filepath" VARCHAR(512),
    "fileUrl" VARCHAR(1024),
    "mimeType" VARCHAR(128),
    "fileSize" INTEGER,
    "uploadedBy" VARCHAR(255),
    "uploadedByName" VARCHAR(255),
    "uploadedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "erpFilepath" VARCHAR(512),

    CONSTRAINT "TaskImage_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TaskNote" (
    "id" SERIAL NOT NULL,
    "taskID" INTEGER NOT NULL,
    "filename" VARCHAR(255),
    "title" VARCHAR(255),
    "description" TEXT,
    "filepath" VARCHAR(512),
    "fileUrl" VARCHAR(1024),
    "mimeType" VARCHAR(128),
    "fileSize" INTEGER,
    "note" TEXT,
    "uploadedBy" VARCHAR(255),
    "uploadedByName" VARCHAR(255),
    "uploadedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "erpFilepath" VARCHAR(512),

    CONSTRAINT "TaskNote_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TaskInventory" (
    "id" SERIAL NOT NULL,
    "taskID" INTEGER NOT NULL,
    "productTypeId" INTEGER,
    "makeModel" VARCHAR(255),
    "snMac" VARCHAR(255),
    "description" TEXT,
    "purchaseDate" TIMESTAMP(3),
    "warrantyPeriod" VARCHAR(128),
    "warrantyStatus" VARCHAR(32),
    "thirdPartyPurchase" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TaskInventory_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TaskPurchase" (
    "id" SERIAL NOT NULL,
    "taskID" INTEGER NOT NULL,
    "purchaseType" VARCHAR(32),
    "customerName" VARCHAR(255),
    "address" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TaskPurchase_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TaskPurchaseProduct" (
    "id" SERIAL NOT NULL,
    "taskPurchaseID" INTEGER NOT NULL,
    "make" VARCHAR(255),
    "model" VARCHAR(255),
    "description" TEXT,
    "warranty" VARCHAR(128),
    "rate" VARCHAR(64),
    "vendor" VARCHAR(255),
    "validity" VARCHAR(128),
    "availability" VARCHAR(128),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TaskPurchaseProduct_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TaskPurchaseAttachment" (
    "id" SERIAL NOT NULL,
    "taskPurchaseID" INTEGER NOT NULL,
    "filename" VARCHAR(255) NOT NULL,
    "filepath" VARCHAR(512),
    "fileUrl" VARCHAR(1024),
    "mimeType" VARCHAR(128),
    "fileSize" INTEGER,
    "uploadedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "erpFilepath" VARCHAR(512),

    CONSTRAINT "TaskPurchaseAttachment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TaskChat" (
    "id" SERIAL NOT NULL,
    "taskID" INTEGER NOT NULL,
    "userID" INTEGER,
    "employeeID" INTEGER,
    "recipientEmployeeID" INTEGER,
    "senderName" VARCHAR(255),
    "message" TEXT NOT NULL,
    "attachmentUrl" VARCHAR(512),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TaskChat_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TaskActivityLog" (
    "id" SERIAL NOT NULL,
    "taskID" INTEGER NOT NULL,
    "userID" INTEGER,
    "employeeID" INTEGER,
    "actorName" VARCHAR(255),
    "action" VARCHAR(64) NOT NULL,
    "oldValue" VARCHAR(255),
    "newValue" VARCHAR(255),
    "remark" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TaskActivityLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EmailTemplate" (
    "id" SERIAL NOT NULL,
    "companyID" INTEGER,
    "eventType" VARCHAR NOT NULL,
    "subject" VARCHAR NOT NULL,
    "bodyHtml" TEXT NOT NULL,
    "enabled" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "EmailTemplate_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AuditLog" (
    "id" SERIAL NOT NULL,
    "userId" INTEGER,
    "companyID" INTEGER,
    "username" VARCHAR(255),
    "employeeName" VARCHAR(255),
    "userRole" VARCHAR(64),
    "action" VARCHAR(64) NOT NULL,
    "module" VARCHAR(64) NOT NULL,
    "entityId" VARCHAR(64),
    "entityName" VARCHAR(255),
    "oldData" TEXT,
    "newData" TEXT,
    "success" BOOLEAN NOT NULL DEFAULT true,
    "failureReason" VARCHAR(512),
    "ipAddress" VARCHAR(64),
    "browser" VARCHAR(128),
    "os" VARCHAR(128),
    "deviceType" VARCHAR(64),
    "location" VARCHAR(255),
    "userAgent" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BackupRestoreLog" (
    "id" SERIAL NOT NULL,
    "userId" INTEGER,
    "username" VARCHAR(255),
    "backupDate" VARCHAR(16) NOT NULL,
    "fileName" VARCHAR(255) NOT NULL,
    "fileLabel" VARCHAR(255),
    "success" BOOLEAN NOT NULL,
    "errorMessage" TEXT,
    "ipAddress" VARCHAR(64),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "BackupRestoreLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SubscriptionPlan" (
    "id" SERIAL NOT NULL,
    "planName" TEXT NOT NULL,
    "validityDays" INTEGER NOT NULL DEFAULT 30,
    "planAmount" DECIMAL(12,2) NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SubscriptionPlan_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SubscriptionPlanModule" (
    "id" SERIAL NOT NULL,
    "planID" INTEGER NOT NULL,
    "moduleID" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "SubscriptionPlanModule_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CompanySubscription" (
    "id" SERIAL NOT NULL,
    "companyID" INTEGER NOT NULL,
    "planID" INTEGER NOT NULL,
    "startDate" TIMESTAMP(3) NOT NULL,
    "endDate" TIMESTAMP(3) NOT NULL,
    "status" "SubscriptionStatus" NOT NULL DEFAULT 'ACTIVE',
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "deactivatedAt" TIMESTAMP(3),
    "deactivationWef" TIMESTAMP(3),
    "deactivationReason" TEXT,
    "renewedFromID" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CompanySubscription_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "company_modules" (
    "id" SERIAL NOT NULL,
    "moduleKey" TEXT,
    "moduleName" TEXT NOT NULL,
    "moduleDescription" TEXT,
    "moduleStatus" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "company_modules_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "approval_workflows" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER NOT NULL,
    "branchesID" INTEGER,
    "companyModuleID" INTEGER NOT NULL,
    "workflowName" TEXT NOT NULL,
    "workflowDescription" TEXT,
    "effectiveFrom" TIMESTAMP(3) NOT NULL,
    "conditionMatchType" "WorkflowConditionMatchType" NOT NULL DEFAULT 'ALL',
    "allowAnySameDesignation" BOOLEAN NOT NULL DEFAULT false,
    "workflowStatus" BOOLEAN NOT NULL DEFAULT true,
    "createdByUserID" INTEGER,
    "updatedByUserID" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "approval_workflows_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "approval_requests" (
    "id" SERIAL NOT NULL,
    "serviceProviderID" INTEGER,
    "companyID" INTEGER NOT NULL,
    "branchesID" INTEGER,
    "approvalWorkflowID" INTEGER NOT NULL,
    "companyModuleID" INTEGER NOT NULL,
    "subjectType" TEXT NOT NULL,
    "subjectID" INTEGER NOT NULL,
    "subjectEmployeeID" INTEGER,
    "status" "ApprovalRequestStatus" NOT NULL DEFAULT 'PENDING',
    "currentStepNo" INTEGER,
    "workflowNameSnapshot" TEXT NOT NULL,
    "moduleKeySnapshot" TEXT NOT NULL,
    "conditionMatchTypeSnapshot" "WorkflowConditionMatchType" NOT NULL,
    "allowAnySameDesignationSnapshot" BOOLEAN NOT NULL DEFAULT false,
    "submittedByUserID" INTEGER,
    "submittedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completedAt" TIMESTAMP(3),
    "rejectedAt" TIMESTAMP(3),
    "cancelledAt" TIMESTAMP(3),
    "finalRemark" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "approval_requests_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "approval_request_steps" (
    "id" SERIAL NOT NULL,
    "approvalRequestID" INTEGER NOT NULL,
    "approvalWorkflowStepID" INTEGER,
    "stepNo" INTEGER NOT NULL,
    "designationID" INTEGER NOT NULL,
    "stepNameSnapshot" TEXT,
    "designationNameSnapshot" TEXT NOT NULL,
    "approvalRequirementSnapshot" "ApprovalRequirement" NOT NULL DEFAULT 'ANY',
    "isMandatorySnapshot" BOOLEAN NOT NULL DEFAULT true,
    "canRejectSnapshot" BOOLEAN NOT NULL DEFAULT true,
    "canSendBackSnapshot" BOOLEAN NOT NULL DEFAULT false,
    "approvalTimeoutSnapshot" INTEGER,
    "status" "ApprovalStepStatus" NOT NULL DEFAULT 'WAITING',
    "activatedAt" TIMESTAMP(3),
    "completedAt" TIMESTAMP(3),
    "rejectedAt" TIMESTAMP(3),
    "sentBackAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "approval_request_steps_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "approval_request_approvers" (
    "id" SERIAL NOT NULL,
    "approvalRequestID" INTEGER NOT NULL,
    "approvalRequestStepID" INTEGER NOT NULL,
    "approverEmployeeID" INTEGER NOT NULL,
    "designationIDSnapshot" INTEGER NOT NULL,
    "designationNameSnapshot" TEXT NOT NULL,
    "departmentIDSnapshot" INTEGER,
    "branchesIDSnapshot" INTEGER,
    "companyIDSnapshot" INTEGER NOT NULL,
    "status" "ApprovalApproverStatus" NOT NULL DEFAULT 'WAITING',
    "activatedAt" TIMESTAMP(3),
    "actedAt" TIMESTAMP(3),
    "comment" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "approval_request_approvers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "approval_request_actions" (
    "id" SERIAL NOT NULL,
    "approvalRequestID" INTEGER NOT NULL,
    "approvalRequestStepID" INTEGER,
    "approvalRequestApproverID" INTEGER,
    "action" "ApprovalActionType" NOT NULL,
    "actedByEmployeeID" INTEGER,
    "actedByUserID" INTEGER,
    "fromStatus" TEXT,
    "toStatus" TEXT,
    "remark" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "approval_request_actions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "approval_workflow_conditions" (
    "id" SERIAL NOT NULL,
    "approvalWorkflowID" INTEGER NOT NULL,
    "conditionNo" INTEGER NOT NULL,
    "fieldKey" "WorkflowConditionField" NOT NULL,
    "operator" "WorkflowConditionOperator" NOT NULL,
    "valueType" "WorkflowConditionValueType" NOT NULL,
    "departmentID" INTEGER,
    "designationID" INTEGER,
    "branchesID" INTEGER,
    "numberValue" DECIMAL(18,2),
    "numberValueTo" DECIMAL(18,2),
    "textValue" TEXT,
    "booleanValue" BOOLEAN,
    "dateValue" TIMESTAMP(3),
    "dateValueTo" TIMESTAMP(3),
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "approval_workflow_conditions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "approval_workflow_condition_employees" (
    "id" SERIAL NOT NULL,
    "conditionID" INTEGER NOT NULL,
    "manageEmployeeID" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "approval_workflow_condition_employees_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "approval_workflow_steps" (
    "id" SERIAL NOT NULL,
    "approvalWorkflowID" INTEGER NOT NULL,
    "stepNo" INTEGER NOT NULL,
    "approverType" "WorkflowApproverType" NOT NULL DEFAULT 'DESIGNATION',
    "designationID" INTEGER,
    "approvalRequirement" "ApprovalRequirement" NOT NULL DEFAULT 'ANY',
    "stepName" TEXT,
    "isMandatory" BOOLEAN NOT NULL DEFAULT true,
    "canReject" BOOLEAN NOT NULL DEFAULT true,
    "canSendBack" BOOLEAN NOT NULL DEFAULT false,
    "approvalTimeout" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "approval_workflow_steps_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AuthOtp" (
    "id" SERIAL NOT NULL,
    "purpose" "AuthOtpPurpose" NOT NULL,
    "identifier" VARCHAR NOT NULL,
    "codeHash" VARCHAR NOT NULL,
    "pendingToken" VARCHAR NOT NULL,
    "payload" TEXT,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "consumedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AuthOtp_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CompanyPolicy" (
    "id" SERIAL NOT NULL,
    "type" "CompanyPolicyType" NOT NULL,
    "policyName" VARCHAR NOT NULL,
    "versionName" VARCHAR NOT NULL,
    "effectiveFrom" TIMESTAMP(3) NOT NULL,
    "bodyHtml" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CompanyPolicy_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "google_api_usage" (
    "id" SERIAL NOT NULL,
    "api" VARCHAR(32) NOT NULL,
    "feature" VARCHAR(16) NOT NULL,
    "httpStatus" INTEGER NOT NULL,
    "sessionToken" VARCHAR(36),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "google_api_usage_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "attendance_location_points" (
    "id" SERIAL NOT NULL,
    "clientLocationId" VARCHAR(128) NOT NULL,
    "sessionEventId" VARCHAR(128) NOT NULL,
    "attendanceSessionId" INTEGER NOT NULL,
    "employeeId" INTEGER NOT NULL,
    "latitude" DOUBLE PRECISION NOT NULL,
    "longitude" DOUBLE PRECISION NOT NULL,
    "capturedAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "attendance_location_points_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "BankDetails_branchesID_idx" ON "BankDetails"("branchesID");

-- CreateIndex
CREATE INDEX "CompanyFederalDomain_code_idx" ON "CompanyFederalDomain"("code");

-- CreateIndex
CREATE INDEX "CompanyFederalDomain_companyID_idx" ON "CompanyFederalDomain"("companyID");

-- CreateIndex
CREATE UNIQUE INDEX "CompanyFederalDomain_companyID_code_key" ON "CompanyFederalDomain"("companyID", "code");

-- CreateIndex
CREATE UNIQUE INDEX "Module_moduleKey_key" ON "Module"("moduleKey");

-- CreateIndex
CREATE INDEX "CompanyModule_companyID_idx" ON "CompanyModule"("companyID");

-- CreateIndex
CREATE INDEX "CompanyModule_moduleID_idx" ON "CompanyModule"("moduleID");

-- CreateIndex
CREATE UNIQUE INDEX "CompanyModule_companyID_moduleID_key" ON "CompanyModule"("companyID", "moduleID");

-- CreateIndex
CREATE INDEX "ContractorBranch_contractorID_idx" ON "ContractorBranch"("contractorID");

-- CreateIndex
CREATE INDEX "ContractorBranch_branchID_idx" ON "ContractorBranch"("branchID");

-- CreateIndex
CREATE UNIQUE INDEX "ContractorBranch_contractorID_branchID_key" ON "ContractorBranch"("contractorID", "branchID");

-- CreateIndex
CREATE INDEX "ComplianceRule_serviceProviderID_idx" ON "ComplianceRule"("serviceProviderID");

-- CreateIndex
CREATE INDEX "ComplianceRule_companyID_idx" ON "ComplianceRule"("companyID");

-- CreateIndex
CREATE INDEX "ContractorPayout_contractorID_idx" ON "ContractorPayout"("contractorID");

-- CreateIndex
CREATE INDEX "ContractorRateCard_contractorID_idx" ON "ContractorRateCard"("contractorID");

-- CreateIndex
CREATE INDEX "Departments_companyID_idx" ON "Departments"("companyID");

-- CreateIndex
CREATE INDEX "Departments_parentDepartmentID_idx" ON "Departments"("parentDepartmentID");

-- CreateIndex
CREATE INDEX "DepartmentBranch_departmentID_idx" ON "DepartmentBranch"("departmentID");

-- CreateIndex
CREATE INDEX "DepartmentBranch_branchesID_idx" ON "DepartmentBranch"("branchesID");

-- CreateIndex
CREATE UNIQUE INDEX "DepartmentBranch_departmentID_branchesID_key" ON "DepartmentBranch"("departmentID", "branchesID");

-- CreateIndex
CREATE INDEX "Designations_companyID_idx" ON "Designations"("companyID");

-- CreateIndex
CREATE INDEX "Designations_departmentID_idx" ON "Designations"("departmentID");

-- CreateIndex
CREATE INDEX "Designations_parentDesignationID_idx" ON "Designations"("parentDesignationID");

-- CreateIndex
CREATE UNIQUE INDEX "EmpAttendanceRegularise_manageEmployeeID_attendanceDate_key" ON "EmpAttendanceRegularise"("manageEmployeeID", "attendanceDate");

-- CreateIndex
CREATE UNIQUE INDEX "ManageEmployee_employeeID_companyID_key" ON "ManageEmployee"("employeeID", "companyID");

-- CreateIndex
CREATE INDEX "employee_module_permissions_manageEmployeeID_idx" ON "employee_module_permissions"("manageEmployeeID");

-- CreateIndex
CREATE INDEX "employee_module_permissions_companyID_idx" ON "employee_module_permissions"("companyID");

-- CreateIndex
CREATE UNIQUE INDEX "employee_module_permissions_companyID_manageEmployeeID_modu_key" ON "employee_module_permissions"("companyID", "manageEmployeeID", "moduleKey");

-- CreateIndex
CREATE INDEX "employee_documents_employeeID_idx" ON "employee_documents"("employeeID");

-- CreateIndex
CREATE INDEX "employee_documents_companyID_idx" ON "employee_documents"("companyID");

-- CreateIndex
CREATE INDEX "employee_documents_branchesID_idx" ON "employee_documents"("branchesID");

-- CreateIndex
CREATE INDEX "employee_documents_documentCategory_idx" ON "employee_documents"("documentCategory");

-- CreateIndex
CREATE INDEX "EmployeeFieldHistory_employeeId_idx" ON "EmployeeFieldHistory"("employeeId");

-- CreateIndex
CREATE INDEX "EmployeeFieldHistory_fieldName_idx" ON "EmployeeFieldHistory"("fieldName");

-- CreateIndex
CREATE INDEX "EmployeeLink_employeeId_idx" ON "EmployeeLink"("employeeId");

-- CreateIndex
CREATE INDEX "EmployeeLink_linkedEmployeeId_idx" ON "EmployeeLink"("linkedEmployeeId");

-- CreateIndex
CREATE UNIQUE INDEX "EmployeeLink_employeeId_linkedEmployeeId_key" ON "EmployeeLink"("employeeId", "linkedEmployeeId");

-- CreateIndex
CREATE INDEX "EmployeeTermination_serviceProviderID_companyID_branchesID_idx" ON "EmployeeTermination"("serviceProviderID", "companyID", "branchesID");

-- CreateIndex
CREATE INDEX "EmployeeTermination_employeeId_exitType_idx" ON "EmployeeTermination"("employeeId", "exitType");

-- CreateIndex
CREATE UNIQUE INDEX "EmployeeCredentials_employeeID_key" ON "EmployeeCredentials"("employeeID");

-- CreateIndex
CREATE UNIQUE INDEX "EmployeeCredentials_username_key" ON "EmployeeCredentials"("username");

-- CreateIndex
CREATE INDEX "EmpPromotion_manageEmployeeID_idx" ON "EmpPromotion"("manageEmployeeID");

-- CreateIndex
CREATE INDEX "EmpEduQualification_manageEmployeeID_idx" ON "EmpEduQualification"("manageEmployeeID");

-- CreateIndex
CREATE INDEX "EmpProfExprience_manageEmployeeID_idx" ON "EmpProfExprience"("manageEmployeeID");

-- CreateIndex
CREATE INDEX "EmpDesignation_manageEmployeeID_idx" ON "EmpDesignation"("manageEmployeeID");

-- CreateIndex
CREATE INDEX "EmpDesignation_designationID_idx" ON "EmpDesignation"("designationID");

-- CreateIndex
CREATE INDEX "EmpBranch_manageEmployeeID_idx" ON "EmpBranch"("manageEmployeeID");

-- CreateIndex
CREATE INDEX "EmpDepartment_manageEmployeeID_idx" ON "EmpDepartment"("manageEmployeeID");

-- CreateIndex
CREATE INDEX "EmpEmploymentType_manageEmployeeID_idx" ON "EmpEmploymentType"("manageEmployeeID");

-- CreateIndex
CREATE INDEX "EmpEmploymentStatus_manageEmployeeID_idx" ON "EmpEmploymentStatus"("manageEmployeeID");

-- CreateIndex
CREATE INDEX "EmpWorkShift_manageEmployeeID_idx" ON "EmpWorkShift"("manageEmployeeID");

-- CreateIndex
CREATE INDEX "EmpAttendancePolicy_manageEmployeeID_idx" ON "EmpAttendancePolicy"("manageEmployeeID");

-- CreateIndex
CREATE INDEX "EmpLeavePolicy_manageEmployeeID_idx" ON "EmpLeavePolicy"("manageEmployeeID");

-- CreateIndex
CREATE UNIQUE INDEX "EmpLeaveBalance_manageEmployeeID_key" ON "EmpLeaveBalance"("manageEmployeeID");

-- CreateIndex
CREATE INDEX "EmpLeaveBalance_manageEmployeeID_idx" ON "EmpLeaveBalance"("manageEmployeeID");

-- CreateIndex
CREATE INDEX "EmpContractor_manageEmployeeID_idx" ON "EmpContractor"("manageEmployeeID");

-- CreateIndex
CREATE INDEX "EmpDeviceMapping_manageEmployeeID_idx" ON "EmpDeviceMapping"("manageEmployeeID");

-- CreateIndex
CREATE INDEX "EmpDeviceMapping_deviceID_idx" ON "EmpDeviceMapping"("deviceID");

-- CreateIndex
CREATE INDEX "TokenDeviceMapping_manageEmployeeID_idx" ON "TokenDeviceMapping"("manageEmployeeID");

-- CreateIndex
CREATE INDEX "TokenDeviceMapping_deviceID_idx" ON "TokenDeviceMapping"("deviceID");

-- CreateIndex
CREATE UNIQUE INDEX "CalendarDay_isoDate_key" ON "CalendarDay"("isoDate");

-- CreateIndex
CREATE UNIQUE INDEX "Holiday_slug_key" ON "Holiday"("slug");

-- CreateIndex
CREATE UNIQUE INDEX "HolidayOnDay_calendarDayId_holidayId_key" ON "HolidayOnDay"("calendarDayId", "holidayId");

-- CreateIndex
CREATE UNIQUE INDEX "User_username_key" ON "User"("username");

-- CreateIndex
CREATE INDEX "UserCompany_userID_idx" ON "UserCompany"("userID");

-- CreateIndex
CREATE INDEX "UserCompany_companyID_idx" ON "UserCompany"("companyID");

-- CreateIndex
CREATE UNIQUE INDEX "UserCompany_userID_companyID_key" ON "UserCompany"("userID", "companyID");

-- CreateIndex
CREATE UNIQUE INDEX "UserProfile_userId_key" ON "UserProfile"("userId");

-- CreateIndex
CREATE INDEX "Overtime_employeeID_idx" ON "Overtime"("employeeID");

-- CreateIndex
CREATE INDEX "Overtime_workDate_idx" ON "Overtime"("workDate");

-- CreateIndex
CREATE INDEX "Overtime_status_idx" ON "Overtime"("status");

-- CreateIndex
CREATE UNIQUE INDEX "RosterEmployee_rosterID_employeeID_key" ON "RosterEmployee"("rosterID", "employeeID");

-- CreateIndex
CREATE UNIQUE INDEX "RosterDay_rosterEmployeeID_workDate_key" ON "RosterDay"("rosterEmployeeID", "workDate");

-- CreateIndex
CREATE UNIQUE INDEX "PFCompliance_companyID_key" ON "PFCompliance"("companyID");

-- CreateIndex
CREATE UNIQUE INDEX "ESICCompliance_companyID_key" ON "ESICCompliance"("companyID");

-- CreateIndex
CREATE UNIQUE INDEX "PTCompliance_companyID_branchID_key" ON "PTCompliance"("companyID", "branchID");

-- CreateIndex
CREATE INDEX "idx_process_att_logs_device_sn" ON "process_att_logs"("device_sn");

-- CreateIndex
CREATE INDEX "idx_process_att_logs_processed_at" ON "process_att_logs"("processed_at");

-- CreateIndex
CREATE INDEX "idx_process_att_logs_punch_time" ON "process_att_logs"("punch_time");

-- CreateIndex
CREATE INDEX "idx_process_att_logs_user_id" ON "process_att_logs"("user_id");

-- CreateIndex
CREATE INDEX "idx_canteen_tr_logs_user_id" ON "canteen_tr_logs"("user_id");

-- CreateIndex
CREATE INDEX "idx_canteen_tr_logs_punch_time" ON "canteen_tr_logs"("punch_time");

-- CreateIndex
CREATE INDEX "idx_canteen_tv_logs_user_id" ON "canteen_tv_logs"("user_id");

-- CreateIndex
CREATE INDEX "idx_canteen_tv_logs_punch_time" ON "canteen_tv_logs"("punch_time");

-- CreateIndex
CREATE INDEX "idx_canteen_tv_not_logs_user_id" ON "canteen_tv_not_logs"("user_id");

-- CreateIndex
CREATE INDEX "idx_canteen_tv_not_logs_punch_time" ON "canteen_tv_not_logs"("punch_time");

-- CreateIndex
CREATE INDEX "PrivilegedLeaveLedger_employeeID_idx" ON "PrivilegedLeaveLedger"("employeeID");

-- CreateIndex
CREATE INDEX "PrivilegedLeaveLedger_leavePolicyID_idx" ON "PrivilegedLeaveLedger"("leavePolicyID");

-- CreateIndex
CREATE INDEX "PrivilegedLeaveLedger_creditDate_idx" ON "PrivilegedLeaveLedger"("creditDate");

-- CreateIndex
CREATE INDEX "EmployeeHolidayOverride_employeeID_idx" ON "EmployeeHolidayOverride"("employeeID");

-- CreateIndex
CREATE INDEX "EmployeeHolidayOverride_holidayId_idx" ON "EmployeeHolidayOverride"("holidayId");

-- CreateIndex
CREATE INDEX "EmployeeWeeklyOff_employeeID_idx" ON "EmployeeWeeklyOff"("employeeID");

-- CreateIndex
CREATE INDEX "EmployeeWeeklyOff_date_idx" ON "EmployeeWeeklyOff"("date");

-- CreateIndex
CREATE INDEX "PrivilegedLeaveLapse_employeeID_idx" ON "PrivilegedLeaveLapse"("employeeID");

-- CreateIndex
CREATE INDEX "PrivilegedLeaveLapse_leavePolicyID_idx" ON "PrivilegedLeaveLapse"("leavePolicyID");

-- CreateIndex
CREATE INDEX "PrivilegedLeaveLapse_lapseDate_idx" ON "PrivilegedLeaveLapse"("lapseDate");

-- CreateIndex
CREATE INDEX "EmployeeMemo_employeeID_idx" ON "EmployeeMemo"("employeeID");

-- CreateIndex
CREATE INDEX "EmployeeMemo_parentMemoId_idx" ON "EmployeeMemo"("parentMemoId");

-- CreateIndex
CREATE INDEX "EmployeeMemo_senderEmployeeId_idx" ON "EmployeeMemo"("senderEmployeeId");

-- CreateIndex
CREATE INDEX "EmpFactualWorkShift_manageEmployeeID_idx" ON "EmpFactualWorkShift"("manageEmployeeID");

-- CreateIndex
CREATE INDEX "EmpFactualAttendancePolicy_manageEmployeeID_idx" ON "EmpFactualAttendancePolicy"("manageEmployeeID");

-- CreateIndex
CREATE UNIQUE INDEX "FactualRosterEmployee_factualRosterID_employeeID_key" ON "FactualRosterEmployee"("factualRosterID", "employeeID");

-- CreateIndex
CREATE UNIQUE INDEX "FactualRosterDay_factualRosterEmployeeID_workDate_key" ON "FactualRosterDay"("factualRosterEmployeeID", "workDate");

-- CreateIndex
CREATE INDEX "attendance_locations_employeeId_idx" ON "attendance_locations"("employeeId");

-- CreateIndex
CREATE INDEX "attendance_locations_checkinTime_idx" ON "attendance_locations"("checkinTime");

-- CreateIndex
CREATE INDEX "attendance_locations_checkType_idx" ON "attendance_locations"("checkType");

-- CreateIndex
CREATE INDEX "EmpAbsentDeclaration_employeeId_idx" ON "EmpAbsentDeclaration"("employeeId");

-- CreateIndex
CREATE UNIQUE INDEX "EmpAbsentDeclaration_employeeId_absentDate_key" ON "EmpAbsentDeclaration"("employeeId", "absentDate");

-- CreateIndex
CREATE UNIQUE INDEX "TaskCustomer_customerCode_key" ON "TaskCustomer"("customerCode");

-- CreateIndex
CREATE UNIQUE INDEX "TaskCustomer_erpAddressBookId_key" ON "TaskCustomer"("erpAddressBookId");

-- CreateIndex
CREATE INDEX "TaskCustomer_companyID_idx" ON "TaskCustomer"("companyID");

-- CreateIndex
CREATE INDEX "TaskCustomer_customerName_idx" ON "TaskCustomer"("customerName");

-- CreateIndex
CREATE INDEX "TaskCustomer_isDeleted_idx" ON "TaskCustomer"("isDeleted");

-- CreateIndex
CREATE INDEX "TaskCustomerContact_customerID_idx" ON "TaskCustomerContact"("customerID");

-- CreateIndex
CREATE UNIQUE INDEX "TaskCustomerSite_siteCode_key" ON "TaskCustomerSite"("siteCode");

-- CreateIndex
CREATE UNIQUE INDEX "TaskCustomerSite_erpSiteId_key" ON "TaskCustomerSite"("erpSiteId");

-- CreateIndex
CREATE INDEX "TaskCustomerSite_companyID_idx" ON "TaskCustomerSite"("companyID");

-- CreateIndex
CREATE INDEX "TaskCustomerSite_customerID_idx" ON "TaskCustomerSite"("customerID");

-- CreateIndex
CREATE INDEX "TaskCustomerSite_isDeleted_idx" ON "TaskCustomerSite"("isDeleted");

-- CreateIndex
CREATE INDEX "TaskCustomerSiteContact_siteID_idx" ON "TaskCustomerSiteContact"("siteID");

-- CreateIndex
CREATE INDEX "TaskCustomerSiteNote_siteID_idx" ON "TaskCustomerSiteNote"("siteID");

-- CreateIndex
CREATE INDEX "EnplEntityMapping_companyID_idx" ON "EnplEntityMapping"("companyID");

-- CreateIndex
CREATE INDEX "EnplEntityMapping_companyID_entityType_enplId_idx" ON "EnplEntityMapping"("companyID", "entityType", "enplId");

-- CreateIndex
CREATE INDEX "EnplEntityMapping_companyID_entityType_enplCode_idx" ON "EnplEntityMapping"("companyID", "entityType", "enplCode");

-- CreateIndex
CREATE UNIQUE INDEX "EnplEntityMapping_entityType_hrmsId_key" ON "EnplEntityMapping"("entityType", "hrmsId");

-- CreateIndex
CREATE INDEX "TaskWorkscopeCategory_companyID_idx" ON "TaskWorkscopeCategory"("companyID");

-- CreateIndex
CREATE UNIQUE INDEX "TaskWorkscopeCategory_companyID_workscopeCategoryName_key" ON "TaskWorkscopeCategory"("companyID", "workscopeCategoryName");

-- CreateIndex
CREATE INDEX "TaskProduct_companyID_idx" ON "TaskProduct"("companyID");

-- CreateIndex
CREATE UNIQUE INDEX "TaskProduct_companyID_productName_key" ON "TaskProduct"("companyID", "productName");

-- CreateIndex
CREATE UNIQUE INDEX "TaskProject_taskCode_key" ON "TaskProject"("taskCode");

-- CreateIndex
CREATE UNIQUE INDEX "TaskProject_erpTaskId_key" ON "TaskProject"("erpTaskId");

-- CreateIndex
CREATE INDEX "TaskProject_companyID_idx" ON "TaskProject"("companyID");

-- CreateIndex
CREATE INDEX "TaskProject_status_idx" ON "TaskProject"("status");

-- CreateIndex
CREATE INDEX "TaskProject_customerID_idx" ON "TaskProject"("customerID");

-- CreateIndex
CREATE INDEX "TaskProject_siteID_idx" ON "TaskProject"("siteID");

-- CreateIndex
CREATE INDEX "TaskProject_createdByEmployeeID_idx" ON "TaskProject"("createdByEmployeeID");

-- CreateIndex
CREATE INDEX "TaskProject_isDeleted_idx" ON "TaskProject"("isDeleted");

-- CreateIndex
CREATE INDEX "TaskAssignment_manageEmployeeID_idx" ON "TaskAssignment"("manageEmployeeID");

-- CreateIndex
CREATE UNIQUE INDEX "TaskAssignment_taskID_manageEmployeeID_key" ON "TaskAssignment"("taskID", "manageEmployeeID");

-- CreateIndex
CREATE INDEX "TaskEngineerAssignment_taskID_idx" ON "TaskEngineerAssignment"("taskID");

-- CreateIndex
CREATE INDEX "TaskEngineerAssignment_manageEmployeeID_idx" ON "TaskEngineerAssignment"("manageEmployeeID");

-- CreateIndex
CREATE INDEX "TaskRemark_taskID_idx" ON "TaskRemark"("taskID");

-- CreateIndex
CREATE INDEX "TaskProjectContact_taskID_idx" ON "TaskProjectContact"("taskID");

-- CreateIndex
CREATE INDEX "TaskWorkscopeDetail_taskID_idx" ON "TaskWorkscopeDetail"("taskID");

-- CreateIndex
CREATE INDEX "TaskSchedule_taskID_idx" ON "TaskSchedule"("taskID");

-- CreateIndex
CREATE INDEX "TaskImage_taskID_idx" ON "TaskImage"("taskID");

-- CreateIndex
CREATE INDEX "TaskNote_taskID_idx" ON "TaskNote"("taskID");

-- CreateIndex
CREATE INDEX "TaskInventory_taskID_idx" ON "TaskInventory"("taskID");

-- CreateIndex
CREATE UNIQUE INDEX "TaskPurchase_taskID_key" ON "TaskPurchase"("taskID");

-- CreateIndex
CREATE INDEX "TaskPurchaseProduct_taskPurchaseID_idx" ON "TaskPurchaseProduct"("taskPurchaseID");

-- CreateIndex
CREATE INDEX "TaskPurchaseAttachment_taskPurchaseID_idx" ON "TaskPurchaseAttachment"("taskPurchaseID");

-- CreateIndex
CREATE INDEX "TaskChat_taskID_idx" ON "TaskChat"("taskID");

-- CreateIndex
CREATE INDEX "TaskChat_createdAt_idx" ON "TaskChat"("createdAt");

-- CreateIndex
CREATE INDEX "TaskChat_recipientEmployeeID_idx" ON "TaskChat"("recipientEmployeeID");

-- CreateIndex
CREATE INDEX "TaskActivityLog_taskID_idx" ON "TaskActivityLog"("taskID");

-- CreateIndex
CREATE INDEX "TaskActivityLog_createdAt_idx" ON "TaskActivityLog"("createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "EmailTemplate_companyID_eventType_key" ON "EmailTemplate"("companyID", "eventType");

-- CreateIndex
CREATE INDEX "AuditLog_module_createdAt_idx" ON "AuditLog"("module", "createdAt");

-- CreateIndex
CREATE INDEX "AuditLog_userId_createdAt_idx" ON "AuditLog"("userId", "createdAt");

-- CreateIndex
CREATE INDEX "AuditLog_action_createdAt_idx" ON "AuditLog"("action", "createdAt");

-- CreateIndex
CREATE INDEX "AuditLog_username_createdAt_idx" ON "AuditLog"("username", "createdAt");

-- CreateIndex
CREATE INDEX "AuditLog_companyID_createdAt_idx" ON "AuditLog"("companyID", "createdAt");

-- CreateIndex
CREATE INDEX "AuditLog_createdAt_idx" ON "AuditLog"("createdAt");

-- CreateIndex
CREATE INDEX "BackupRestoreLog_createdAt_idx" ON "BackupRestoreLog"("createdAt");

-- CreateIndex
CREATE INDEX "BackupRestoreLog_username_idx" ON "BackupRestoreLog"("username");

-- CreateIndex
CREATE INDEX "SubscriptionPlan_isActive_idx" ON "SubscriptionPlan"("isActive");

-- CreateIndex
CREATE UNIQUE INDEX "SubscriptionPlan_planName_key" ON "SubscriptionPlan"("planName");

-- CreateIndex
CREATE INDEX "SubscriptionPlanModule_planID_idx" ON "SubscriptionPlanModule"("planID");

-- CreateIndex
CREATE INDEX "SubscriptionPlanModule_moduleID_idx" ON "SubscriptionPlanModule"("moduleID");

-- CreateIndex
CREATE UNIQUE INDEX "SubscriptionPlanModule_planID_moduleID_key" ON "SubscriptionPlanModule"("planID", "moduleID");

-- CreateIndex
CREATE INDEX "CompanySubscription_companyID_idx" ON "CompanySubscription"("companyID");

-- CreateIndex
CREATE INDEX "CompanySubscription_planID_idx" ON "CompanySubscription"("planID");

-- CreateIndex
CREATE INDEX "CompanySubscription_status_idx" ON "CompanySubscription"("status");

-- CreateIndex
CREATE INDEX "CompanySubscription_startDate_idx" ON "CompanySubscription"("startDate");

-- CreateIndex
CREATE INDEX "CompanySubscription_endDate_idx" ON "CompanySubscription"("endDate");

-- CreateIndex
CREATE INDEX "approval_workflows_companyID_idx" ON "approval_workflows"("companyID");

-- CreateIndex
CREATE INDEX "approval_workflows_branchesID_idx" ON "approval_workflows"("branchesID");

-- CreateIndex
CREATE INDEX "approval_workflows_companyModuleID_idx" ON "approval_workflows"("companyModuleID");

-- CreateIndex
CREATE INDEX "approval_workflows_workflowStatus_idx" ON "approval_workflows"("workflowStatus");

-- CreateIndex
CREATE INDEX "approval_workflows_effectiveFrom_idx" ON "approval_workflows"("effectiveFrom");

-- CreateIndex
CREATE UNIQUE INDEX "approval_workflows_companyID_branchesID_companyModuleID_wor_key" ON "approval_workflows"("companyID", "branchesID", "companyModuleID", "workflowName");

-- CreateIndex
CREATE INDEX "approval_requests_serviceProviderID_companyID_branchesID_idx" ON "approval_requests"("serviceProviderID", "companyID", "branchesID");

-- CreateIndex
CREATE INDEX "approval_requests_approvalWorkflowID_idx" ON "approval_requests"("approvalWorkflowID");

-- CreateIndex
CREATE INDEX "approval_requests_companyModuleID_idx" ON "approval_requests"("companyModuleID");

-- CreateIndex
CREATE INDEX "approval_requests_subjectType_subjectID_idx" ON "approval_requests"("subjectType", "subjectID");

-- CreateIndex
CREATE INDEX "approval_requests_subjectEmployeeID_idx" ON "approval_requests"("subjectEmployeeID");

-- CreateIndex
CREATE INDEX "approval_requests_status_idx" ON "approval_requests"("status");

-- CreateIndex
CREATE INDEX "approval_requests_currentStepNo_idx" ON "approval_requests"("currentStepNo");

-- CreateIndex
CREATE INDEX "approval_request_steps_approvalRequestID_idx" ON "approval_request_steps"("approvalRequestID");

-- CreateIndex
CREATE INDEX "approval_request_steps_designationID_idx" ON "approval_request_steps"("designationID");

-- CreateIndex
CREATE INDEX "approval_request_steps_status_idx" ON "approval_request_steps"("status");

-- CreateIndex
CREATE UNIQUE INDEX "approval_request_steps_approvalRequestID_stepNo_key" ON "approval_request_steps"("approvalRequestID", "stepNo");

-- CreateIndex
CREATE INDEX "approval_request_approvers_approvalRequestID_idx" ON "approval_request_approvers"("approvalRequestID");

-- CreateIndex
CREATE INDEX "approval_request_approvers_approvalRequestStepID_idx" ON "approval_request_approvers"("approvalRequestStepID");

-- CreateIndex
CREATE INDEX "approval_request_approvers_approverEmployeeID_idx" ON "approval_request_approvers"("approverEmployeeID");

-- CreateIndex
CREATE INDEX "approval_request_approvers_status_idx" ON "approval_request_approvers"("status");

-- CreateIndex
CREATE UNIQUE INDEX "approval_request_approvers_approvalRequestStepID_approverEm_key" ON "approval_request_approvers"("approvalRequestStepID", "approverEmployeeID");

-- CreateIndex
CREATE INDEX "approval_request_actions_approvalRequestID_idx" ON "approval_request_actions"("approvalRequestID");

-- CreateIndex
CREATE INDEX "approval_request_actions_approvalRequestStepID_idx" ON "approval_request_actions"("approvalRequestStepID");

-- CreateIndex
CREATE INDEX "approval_request_actions_approvalRequestApproverID_idx" ON "approval_request_actions"("approvalRequestApproverID");

-- CreateIndex
CREATE INDEX "approval_request_actions_actedByEmployeeID_idx" ON "approval_request_actions"("actedByEmployeeID");

-- CreateIndex
CREATE INDEX "approval_request_actions_createdAt_idx" ON "approval_request_actions"("createdAt");

-- CreateIndex
CREATE INDEX "approval_workflow_conditions_approvalWorkflowID_idx" ON "approval_workflow_conditions"("approvalWorkflowID");

-- CreateIndex
CREATE INDEX "approval_workflow_conditions_fieldKey_idx" ON "approval_workflow_conditions"("fieldKey");

-- CreateIndex
CREATE INDEX "approval_workflow_conditions_departmentID_idx" ON "approval_workflow_conditions"("departmentID");

-- CreateIndex
CREATE INDEX "approval_workflow_conditions_designationID_idx" ON "approval_workflow_conditions"("designationID");

-- CreateIndex
CREATE INDEX "approval_workflow_conditions_branchesID_idx" ON "approval_workflow_conditions"("branchesID");

-- CreateIndex
CREATE UNIQUE INDEX "approval_workflow_conditions_approvalWorkflowID_conditionNo_key" ON "approval_workflow_conditions"("approvalWorkflowID", "conditionNo");

-- CreateIndex
CREATE INDEX "approval_workflow_condition_employees_conditionID_idx" ON "approval_workflow_condition_employees"("conditionID");

-- CreateIndex
CREATE INDEX "approval_workflow_condition_employees_manageEmployeeID_idx" ON "approval_workflow_condition_employees"("manageEmployeeID");

-- CreateIndex
CREATE UNIQUE INDEX "approval_workflow_condition_employees_conditionID_manageEmp_key" ON "approval_workflow_condition_employees"("conditionID", "manageEmployeeID");

-- CreateIndex
CREATE INDEX "approval_workflow_steps_approvalWorkflowID_idx" ON "approval_workflow_steps"("approvalWorkflowID");

-- CreateIndex
CREATE INDEX "approval_workflow_steps_designationID_idx" ON "approval_workflow_steps"("designationID");

-- CreateIndex
CREATE INDEX "approval_workflow_steps_approverType_idx" ON "approval_workflow_steps"("approverType");

-- CreateIndex
CREATE INDEX "approval_workflow_steps_approvalRequirement_idx" ON "approval_workflow_steps"("approvalRequirement");

-- CreateIndex
CREATE UNIQUE INDEX "approval_workflow_steps_approvalWorkflowID_stepNo_key" ON "approval_workflow_steps"("approvalWorkflowID", "stepNo");

-- CreateIndex
CREATE UNIQUE INDEX "AuthOtp_pendingToken_key" ON "AuthOtp"("pendingToken");

-- CreateIndex
CREATE INDEX "AuthOtp_purpose_identifier_idx" ON "AuthOtp"("purpose", "identifier");

-- CreateIndex
CREATE INDEX "AuthOtp_expiresAt_idx" ON "AuthOtp"("expiresAt");

-- CreateIndex
CREATE INDEX "CompanyPolicy_type_effectiveFrom_idx" ON "CompanyPolicy"("type", "effectiveFrom");

-- CreateIndex
CREATE INDEX "google_api_usage_createdAt_idx" ON "google_api_usage"("createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "attendance_location_points_clientlocationid_key" ON "attendance_location_points"("clientLocationId");

-- CreateIndex
CREATE INDEX "attendance_location_points_attendancesessionid_capturedat_idx" ON "attendance_location_points"("attendanceSessionId", "capturedAt");

-- CreateIndex
CREATE INDEX "attendance_location_points_employeeid_capturedat_idx" ON "attendance_location_points"("employeeId", "capturedAt");

-- AddForeignKey
ALTER TABLE "AttendancePolicy" ADD CONSTRAINT "AttendancePolicy_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "AttendancePolicy" ADD CONSTRAINT "AttendancePolicy_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "AttendancePolicy" ADD CONSTRAINT "AttendancePolicy_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "BankDetails" ADD CONSTRAINT "BankDetails_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "BankDetails" ADD CONSTRAINT "BankDetails_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "BankDetails" ADD CONSTRAINT "BankDetails_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "BonusSetup" ADD CONSTRAINT "BonusSetup_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "BonusSetup" ADD CONSTRAINT "BonusSetup_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "BonusSetup" ADD CONSTRAINT "BonusSetup_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "BonusAllocation" ADD CONSTRAINT "BonusAllocation_bonusSetupID_fkey" FOREIGN KEY ("bonusSetupID") REFERENCES "BonusSetup"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "BonusAllocation" ADD CONSTRAINT "BonusAllocation_employeeID_fkey" FOREIGN KEY ("employeeID") REFERENCES "ManageEmployee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "BonusAllocation" ADD CONSTRAINT "BonusAllocation_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "BonusAllocation" ADD CONSTRAINT "BonusAllocation_departmentID_fkey" FOREIGN KEY ("departmentID") REFERENCES "Departments"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "Branches" ADD CONSTRAINT "Branches_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "Branches" ADD CONSTRAINT "Branches_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "Company" ADD CONSTRAINT "Company_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "CompanyFederalDomain" ADD CONSTRAINT "CompanyFederalDomain_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CompanyModule" ADD CONSTRAINT "CompanyModule_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CompanyModule" ADD CONSTRAINT "CompanyModule_moduleID_fkey" FOREIGN KEY ("moduleID") REFERENCES "Module"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Contractors" ADD CONSTRAINT "Contractors_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "Contractors" ADD CONSTRAINT "Contractors_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "ContractorBranch" ADD CONSTRAINT "ContractorBranch_contractorID_fkey" FOREIGN KEY ("contractorID") REFERENCES "Contractors"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ContractorBranch" ADD CONSTRAINT "ContractorBranch_branchID_fkey" FOREIGN KEY ("branchID") REFERENCES "Branches"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ComplianceRule" ADD CONSTRAINT "ComplianceRule_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "ComplianceRule" ADD CONSTRAINT "ComplianceRule_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "ContractorPayout" ADD CONSTRAINT "ContractorPayout_contractorID_fkey" FOREIGN KEY ("contractorID") REFERENCES "Contractors"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "ContractorRateCard" ADD CONSTRAINT "ContractorRateCard_contractorID_fkey" FOREIGN KEY ("contractorID") REFERENCES "Contractors"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "Departments" ADD CONSTRAINT "Departments_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "Departments" ADD CONSTRAINT "Departments_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "Departments" ADD CONSTRAINT "Departments_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "Departments" ADD CONSTRAINT "Departments_parentDepartmentID_fkey" FOREIGN KEY ("parentDepartmentID") REFERENCES "Departments"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "DepartmentBranch" ADD CONSTRAINT "DepartmentBranch_departmentID_fkey" FOREIGN KEY ("departmentID") REFERENCES "Departments"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DepartmentBranch" ADD CONSTRAINT "DepartmentBranch_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Designations" ADD CONSTRAINT "Designations_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "Designations" ADD CONSTRAINT "Designations_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "Designations" ADD CONSTRAINT "Designations_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "Designations" ADD CONSTRAINT "Designations_departmentID_fkey" FOREIGN KEY ("departmentID") REFERENCES "Departments"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "Designations" ADD CONSTRAINT "Designations_parentDesignationID_fkey" FOREIGN KEY ("parentDesignationID") REFERENCES "Designations"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "Devices" ADD CONSTRAINT "Devices_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE SET NULL ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "Devices" ADD CONSTRAINT "Devices_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE SET NULL ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "Devices" ADD CONSTRAINT "Devices_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE SET NULL ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "AttendanceLogs" ADD CONSTRAINT "AttendanceLogs_deviceId_fkey" FOREIGN KEY ("deviceId") REFERENCES "Devices"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EmpAttendanceRegularise" ADD CONSTRAINT "EmpAttendanceRegularise_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpAttendanceRegularise" ADD CONSTRAINT "EmpAttendanceRegularise_departmentID_fkey" FOREIGN KEY ("departmentID") REFERENCES "Departments"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpAttendanceRegularise" ADD CONSTRAINT "EmpAttendanceRegularise_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpAttendanceRegularise" ADD CONSTRAINT "EmpAttendanceRegularise_manageEmployeeID_fkey" FOREIGN KEY ("manageEmployeeID") REFERENCES "ManageEmployee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpAttendanceRegularise" ADD CONSTRAINT "EmpAttendanceRegularise_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpCurrentPosition" ADD CONSTRAINT "EmpCurrentPosition_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpCurrentPosition" ADD CONSTRAINT "EmpCurrentPosition_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpCurrentPosition" ADD CONSTRAINT "EmpCurrentPosition_existingDepartmentID_fkey" FOREIGN KEY ("existingDepartmentID") REFERENCES "Departments"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpCurrentPosition" ADD CONSTRAINT "EmpCurrentPosition_existingDesignationID_fkey" FOREIGN KEY ("existingDesignationID") REFERENCES "Designations"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpCurrentPosition" ADD CONSTRAINT "EmpCurrentPosition_existingHourlyPayGradeID_fkey" FOREIGN KEY ("existingHourlyPayGradeID") REFERENCES "HourlyPayGrade"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpCurrentPosition" ADD CONSTRAINT "EmpCurrentPosition_existingMonthlyPayGradeID_fkey" FOREIGN KEY ("existingMonthlyPayGradeID") REFERENCES "MonthlyPayGrade"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpCurrentPosition" ADD CONSTRAINT "EmpCurrentPosition_manageEmployeeID_fkey" FOREIGN KEY ("manageEmployeeID") REFERENCES "ManageEmployee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpCurrentPosition" ADD CONSTRAINT "EmpCurrentPosition_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "PromotionRequest" ADD CONSTRAINT "PromotionRequest_manageEmployeeID_fkey" FOREIGN KEY ("manageEmployeeID") REFERENCES "ManageEmployee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "PromotionRequest" ADD CONSTRAINT "PromotionRequest_newDepartmentID_fkey" FOREIGN KEY ("newDepartmentID") REFERENCES "Departments"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "PromotionRequest" ADD CONSTRAINT "PromotionRequest_newDesignationID_fkey" FOREIGN KEY ("newDesignationID") REFERENCES "Designations"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "PromotionRequest" ADD CONSTRAINT "PromotionRequest_newHourlyPayGradeID_fkey" FOREIGN KEY ("newHourlyPayGradeID") REFERENCES "HourlyPayGrade"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "PromotionRequest" ADD CONSTRAINT "PromotionRequest_newMonthlyPayGradeID_fkey" FOREIGN KEY ("newMonthlyPayGradeID") REFERENCES "MonthlyPayGrade"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "PromotionRequest" ADD CONSTRAINT "PromotionRequest_proposedDepartmentID_fkey" FOREIGN KEY ("proposedDepartmentID") REFERENCES "Departments"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "PromotionRequest" ADD CONSTRAINT "PromotionRequest_proposedDesignationID_fkey" FOREIGN KEY ("proposedDesignationID") REFERENCES "Designations"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "PromotionRequest" ADD CONSTRAINT "PromotionRequest_proposedHourlyPayGradeID_fkey" FOREIGN KEY ("proposedHourlyPayGradeID") REFERENCES "HourlyPayGrade"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "PromotionRequest" ADD CONSTRAINT "PromotionRequest_proposedMonthlyPayGradeID_fkey" FOREIGN KEY ("proposedMonthlyPayGradeID") REFERENCES "MonthlyPayGrade"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmployeeDelegation" ADD CONSTRAINT "EmployeeDelegation_delegatorId_fkey" FOREIGN KEY ("delegatorId") REFERENCES "ManageEmployee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmployeeDelegation" ADD CONSTRAINT "EmployeeDelegation_delegateeId_fkey" FOREIGN KEY ("delegateeId") REFERENCES "ManageEmployee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpFieldSiteAttendance" ADD CONSTRAINT "EmpFieldSiteAttendance_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpFieldSiteAttendance" ADD CONSTRAINT "EmpFieldSiteAttendance_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpFieldSiteAttendance" ADD CONSTRAINT "EmpFieldSiteAttendance_manageEmployeeID_fkey" FOREIGN KEY ("manageEmployeeID") REFERENCES "ManageEmployee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpFieldSiteAttendance" ADD CONSTRAINT "EmpFieldSiteAttendance_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "GenarateBonus" ADD CONSTRAINT "GenarateBonus_bonusSetupID_fkey" FOREIGN KEY ("bonusSetupID") REFERENCES "BonusSetup"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "GenarateBonus" ADD CONSTRAINT "GenarateBonus_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "GenarateBonus" ADD CONSTRAINT "GenarateBonus_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "GenarateBonus" ADD CONSTRAINT "GenarateBonus_manageEmployeeID_fkey" FOREIGN KEY ("manageEmployeeID") REFERENCES "leaveApplication"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "GenarateBonus" ADD CONSTRAINT "GenarateBonus_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "HourlyPayGrade" ADD CONSTRAINT "HourlyPayGrade_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "HourlyPayGrade" ADD CONSTRAINT "HourlyPayGrade_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "HourlyPayGrade" ADD CONSTRAINT "HourlyPayGrade_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "leaveApplication" ADD CONSTRAINT "leaveApplication_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "leaveApplication" ADD CONSTRAINT "leaveApplication_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "leaveApplication" ADD CONSTRAINT "leaveApplication_manageEmployeeID_fkey" FOREIGN KEY ("manageEmployeeID") REFERENCES "ManageEmployee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "leaveApplication" ADD CONSTRAINT "leaveApplication_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "leaveApplicationRequest" ADD CONSTRAINT "leaveApplicationRequest_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "leaveApplicationRequest" ADD CONSTRAINT "leaveApplicationRequest_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "leaveApplicationRequest" ADD CONSTRAINT "leaveApplicationRequest_leaveApplicationID_fkey" FOREIGN KEY ("leaveApplicationID") REFERENCES "leaveApplication"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "leaveApplicationRequest" ADD CONSTRAINT "leaveApplicationRequest_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "leavePolicy" ADD CONSTRAINT "leavePolicy_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "leavePolicy" ADD CONSTRAINT "leavePolicy_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "leavePolicy" ADD CONSTRAINT "leavePolicy_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "leavePolicyHoliday" ADD CONSTRAINT "leavePolicyHoliday_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "leavePolicyHoliday" ADD CONSTRAINT "leavePolicyHoliday_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "leavePolicyHoliday" ADD CONSTRAINT "leavePolicyHoliday_leavePolicyID_fkey" FOREIGN KEY ("leavePolicyID") REFERENCES "leavePolicy"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "leavePolicyHoliday" ADD CONSTRAINT "leavePolicyHoliday_publicHolidayID_fkey" FOREIGN KEY ("publicHolidayID") REFERENCES "PublicHoliday"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "leavePolicyHoliday" ADD CONSTRAINT "leavePolicyHoliday_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "ManageEmployee" ADD CONSTRAINT "ManageEmployee_attendancePolicyID_fkey" FOREIGN KEY ("attendancePolicyID") REFERENCES "AttendancePolicy"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "ManageEmployee" ADD CONSTRAINT "ManageEmployee_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "ManageEmployee" ADD CONSTRAINT "ManageEmployee_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "ManageEmployee" ADD CONSTRAINT "ManageEmployee_contractorID_fkey" FOREIGN KEY ("contractorID") REFERENCES "Contractors"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "ManageEmployee" ADD CONSTRAINT "ManageEmployee_departmentNameID_fkey" FOREIGN KEY ("departmentNameID") REFERENCES "Departments"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "ManageEmployee" ADD CONSTRAINT "ManageEmployee_designationID_fkey" FOREIGN KEY ("designationID") REFERENCES "Designations"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "ManageEmployee" ADD CONSTRAINT "ManageEmployee_hourlyPayGradeID_fkey" FOREIGN KEY ("hourlyPayGradeID") REFERENCES "HourlyPayGrade"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "ManageEmployee" ADD CONSTRAINT "ManageEmployee_leavePolicyID_fkey" FOREIGN KEY ("leavePolicyID") REFERENCES "leavePolicy"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "ManageEmployee" ADD CONSTRAINT "ManageEmployee_monthlyPayGradeID_fkey" FOREIGN KEY ("monthlyPayGradeID") REFERENCES "MonthlyPayGrade"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "ManageEmployee" ADD CONSTRAINT "ManageEmployee_salaryCycleID_fkey" FOREIGN KEY ("salaryCycleID") REFERENCES "SalaryCycle"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "ManageEmployee" ADD CONSTRAINT "ManageEmployee_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "ManageEmployee" ADD CONSTRAINT "ManageEmployee_workShiftID_fkey" FOREIGN KEY ("workShiftID") REFERENCES "WorkShift"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "employee_module_permissions" ADD CONSTRAINT "employee_module_permissions_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "employee_module_permissions" ADD CONSTRAINT "employee_module_permissions_manageEmployeeID_fkey" FOREIGN KEY ("manageEmployeeID") REFERENCES "ManageEmployee"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "employee_documents" ADD CONSTRAINT "employee_documents_employeeID_fkey" FOREIGN KEY ("employeeID") REFERENCES "ManageEmployee"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "employee_documents" ADD CONSTRAINT "employee_documents_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "employee_documents" ADD CONSTRAINT "employee_documents_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "employee_documents" ADD CONSTRAINT "employee_documents_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EmployeeFieldHistory" ADD CONSTRAINT "EmployeeFieldHistory_employeeId_fkey" FOREIGN KEY ("employeeId") REFERENCES "ManageEmployee"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EmployeeLink" ADD CONSTRAINT "EmployeeLink_employeeId_fkey" FOREIGN KEY ("employeeId") REFERENCES "ManageEmployee"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EmployeeLink" ADD CONSTRAINT "EmployeeLink_linkedEmployeeId_fkey" FOREIGN KEY ("linkedEmployeeId") REFERENCES "ManageEmployee"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EmployeeTermination" ADD CONSTRAINT "EmployeeTermination_employeeId_fkey" FOREIGN KEY ("employeeId") REFERENCES "ManageEmployee"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EmployeeCredentials" ADD CONSTRAINT "EmployeeCredentials_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmployeeCredentials" ADD CONSTRAINT "EmployeeCredentials_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmployeeCredentials" ADD CONSTRAINT "EmployeeCredentials_employeeID_fkey" FOREIGN KEY ("employeeID") REFERENCES "ManageEmployee"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EmployeeCredentials" ADD CONSTRAINT "EmployeeCredentials_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "employee_bank_details" ADD CONSTRAINT "employee_bank_details_employeeID_fkey" FOREIGN KEY ("employeeID") REFERENCES "ManageEmployee"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpPromotion" ADD CONSTRAINT "EmpPromotion_attendancePolicyID_fkey" FOREIGN KEY ("attendancePolicyID") REFERENCES "AttendancePolicy"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpPromotion" ADD CONSTRAINT "EmpPromotion_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpPromotion" ADD CONSTRAINT "EmpPromotion_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpPromotion" ADD CONSTRAINT "EmpPromotion_departmentNameID_fkey" FOREIGN KEY ("departmentNameID") REFERENCES "Departments"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpPromotion" ADD CONSTRAINT "EmpPromotion_designationID_fkey" FOREIGN KEY ("designationID") REFERENCES "Designations"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpPromotion" ADD CONSTRAINT "EmpPromotion_hourlyPayGradeID_fkey" FOREIGN KEY ("hourlyPayGradeID") REFERENCES "HourlyPayGrade"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpPromotion" ADD CONSTRAINT "EmpPromotion_leavePolicyID_fkey" FOREIGN KEY ("leavePolicyID") REFERENCES "leavePolicy"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpPromotion" ADD CONSTRAINT "EmpPromotion_manageEmployeeID_fkey" FOREIGN KEY ("manageEmployeeID") REFERENCES "ManageEmployee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpPromotion" ADD CONSTRAINT "EmpPromotion_monthlyPayGradeID_fkey" FOREIGN KEY ("monthlyPayGradeID") REFERENCES "MonthlyPayGrade"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpPromotion" ADD CONSTRAINT "EmpPromotion_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpPromotion" ADD CONSTRAINT "EmpPromotion_workShiftID_fkey" FOREIGN KEY ("workShiftID") REFERENCES "WorkShift"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpEduQualification" ADD CONSTRAINT "EmpEduQualification_manageEmployeeID_fkey" FOREIGN KEY ("manageEmployeeID") REFERENCES "ManageEmployee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpProfExprience" ADD CONSTRAINT "EmpProfExprience_manageEmployeeID_fkey" FOREIGN KEY ("manageEmployeeID") REFERENCES "ManageEmployee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpDesignation" ADD CONSTRAINT "EmpDesignation_manageEmployeeID_fkey" FOREIGN KEY ("manageEmployeeID") REFERENCES "ManageEmployee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpDesignation" ADD CONSTRAINT "EmpDesignation_designationID_fkey" FOREIGN KEY ("designationID") REFERENCES "Designations"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpBranch" ADD CONSTRAINT "EmpBranch_manageEmployeeID_fkey" FOREIGN KEY ("manageEmployeeID") REFERENCES "ManageEmployee"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EmpBranch" ADD CONSTRAINT "EmpBranch_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpDepartment" ADD CONSTRAINT "EmpDepartment_manageEmployeeID_fkey" FOREIGN KEY ("manageEmployeeID") REFERENCES "ManageEmployee"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EmpDepartment" ADD CONSTRAINT "EmpDepartment_departmentNameID_fkey" FOREIGN KEY ("departmentNameID") REFERENCES "Departments"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpEmploymentType" ADD CONSTRAINT "EmpEmploymentType_manageEmployeeID_fkey" FOREIGN KEY ("manageEmployeeID") REFERENCES "ManageEmployee"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EmpEmploymentStatus" ADD CONSTRAINT "EmpEmploymentStatus_manageEmployeeID_fkey" FOREIGN KEY ("manageEmployeeID") REFERENCES "ManageEmployee"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EmpWorkShift" ADD CONSTRAINT "EmpWorkShift_manageEmployeeID_fkey" FOREIGN KEY ("manageEmployeeID") REFERENCES "ManageEmployee"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EmpWorkShift" ADD CONSTRAINT "EmpWorkShift_workShiftID_fkey" FOREIGN KEY ("workShiftID") REFERENCES "WorkShift"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpAttendancePolicy" ADD CONSTRAINT "EmpAttendancePolicy_manageEmployeeID_fkey" FOREIGN KEY ("manageEmployeeID") REFERENCES "ManageEmployee"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EmpAttendancePolicy" ADD CONSTRAINT "EmpAttendancePolicy_attendancePolicyID_fkey" FOREIGN KEY ("attendancePolicyID") REFERENCES "AttendancePolicy"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpLeavePolicy" ADD CONSTRAINT "EmpLeavePolicy_manageEmployeeID_fkey" FOREIGN KEY ("manageEmployeeID") REFERENCES "ManageEmployee"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EmpLeavePolicy" ADD CONSTRAINT "EmpLeavePolicy_leavePolicyID_fkey" FOREIGN KEY ("leavePolicyID") REFERENCES "leavePolicy"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpLeaveBalance" ADD CONSTRAINT "EmpLeaveBalance_manageEmployeeID_fkey" FOREIGN KEY ("manageEmployeeID") REFERENCES "ManageEmployee"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EmpContractor" ADD CONSTRAINT "EmpContractor_manageEmployeeID_fkey" FOREIGN KEY ("manageEmployeeID") REFERENCES "ManageEmployee"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EmpContractor" ADD CONSTRAINT "EmpContractor_contractorID_fkey" FOREIGN KEY ("contractorID") REFERENCES "Contractors"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpDeviceMapping" ADD CONSTRAINT "EmpDeviceMapping_deviceID_fkey" FOREIGN KEY ("deviceID") REFERENCES "Devices"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpDeviceMapping" ADD CONSTRAINT "EmpDeviceMapping_manageEmployeeID_fkey" FOREIGN KEY ("manageEmployeeID") REFERENCES "ManageEmployee"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "TokenDeviceMapping" ADD CONSTRAINT "TokenDeviceMapping_deviceID_fkey" FOREIGN KEY ("deviceID") REFERENCES "Devices"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "TokenDeviceMapping" ADD CONSTRAINT "TokenDeviceMapping_manageEmployeeID_fkey" FOREIGN KEY ("manageEmployeeID") REFERENCES "ManageEmployee"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "ManageHoliday" ADD CONSTRAINT "ManageHoliday_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "ManageHoliday" ADD CONSTRAINT "ManageHoliday_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "ManageHoliday" ADD CONSTRAINT "ManageHoliday_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "MonthlyPayGrade" ADD CONSTRAINT "MonthlyPayGrade_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "MonthlyPayGrade" ADD CONSTRAINT "MonthlyPayGrade_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "MonthlyPayGrade" ADD CONSTRAINT "MonthlyPayGrade_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "MonthlyPayGradeAllowanceList" ADD CONSTRAINT "MonthlyPayGradeAllowanceList_monthlyPayGradeID_fkey" FOREIGN KEY ("monthlyPayGradeID") REFERENCES "MonthlyPayGrade"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "MonthlyPayGradeAllowanceList" ADD CONSTRAINT "MonthlyPayGradeAllowanceList_salaryallowanceID_fkey" FOREIGN KEY ("salaryallowanceID") REFERENCES "SalaryAllowance"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "MonthlyPayGradeDeductionList" ADD CONSTRAINT "MonthlyPayGradeDeductionList_monthlyPayGradeID_fkey" FOREIGN KEY ("monthlyPayGradeID") REFERENCES "MonthlyPayGrade"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "MonthlyPayGradeDeductionList" ADD CONSTRAINT "MonthlyPayGradeDeductionList_salaryDeductionID_fkey" FOREIGN KEY ("salaryDeductionID") REFERENCES "SalaryDeduction"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "PublicHoliday" ADD CONSTRAINT "PublicHoliday_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "PublicHoliday" ADD CONSTRAINT "PublicHoliday_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "PublicHoliday" ADD CONSTRAINT "PublicHoliday_manageHolidayID_fkey" FOREIGN KEY ("manageHolidayID") REFERENCES "ManageHoliday"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "PublicHoliday" ADD CONSTRAINT "PublicHoliday_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "SalaryAllowance" ADD CONSTRAINT "SalaryAllowance_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "SalaryAllowance" ADD CONSTRAINT "SalaryAllowance_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "SalaryAllowance" ADD CONSTRAINT "SalaryAllowance_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "SalaryCycle" ADD CONSTRAINT "SalaryCycle_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "SalaryCycle" ADD CONSTRAINT "SalaryCycle_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "SalaryCycle" ADD CONSTRAINT "SalaryCycle_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "GenerateSalary" ADD CONSTRAINT "GenerateSalary_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "GenerateSalary" ADD CONSTRAINT "GenerateSalary_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "GenerateSalary" ADD CONSTRAINT "GenerateSalary_employeeID_fkey" FOREIGN KEY ("employeeID") REFERENCES "ManageEmployee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "GenerateSalary" ADD CONSTRAINT "GenerateSalary_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "SalaryDeduction" ADD CONSTRAINT "SalaryDeduction_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "SalaryDeduction" ADD CONSTRAINT "SalaryDeduction_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "SalaryDeduction" ADD CONSTRAINT "SalaryDeduction_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "WorkShift" ADD CONSTRAINT "WorkShift_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "WorkShift" ADD CONSTRAINT "WorkShift_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "WorkShift" ADD CONSTRAINT "WorkShift_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "WorkShiftDay" ADD CONSTRAINT "WorkShiftDay_workShiftID_fkey" FOREIGN KEY ("workShiftID") REFERENCES "WorkShift"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "HolidayOnDay" ADD CONSTRAINT "HolidayOnDay_calendarDayId_fkey" FOREIGN KEY ("calendarDayId") REFERENCES "CalendarDay"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "HolidayOnDay" ADD CONSTRAINT "HolidayOnDay_holidayId_fkey" FOREIGN KEY ("holidayId") REFERENCES "Holiday"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SalaryAdvance" ADD CONSTRAINT "SalaryAdvance_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "SalaryAdvance" ADD CONSTRAINT "SalaryAdvance_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "SalaryAdvance" ADD CONSTRAINT "SalaryAdvance_manageEmployeeID_fkey" FOREIGN KEY ("manageEmployeeID") REFERENCES "ManageEmployee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "SalaryAdvance" ADD CONSTRAINT "SalaryAdvance_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "SalaryAdvanceRepayment" ADD CONSTRAINT "SalaryAdvanceRepayment_salaryAdvanceID_fkey" FOREIGN KEY ("salaryAdvanceID") REFERENCES "SalaryAdvance"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Reimbursement" ADD CONSTRAINT "Reimbursement_departmentID_fkey" FOREIGN KEY ("departmentID") REFERENCES "Departments"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "Reimbursement" ADD CONSTRAINT "Reimbursement_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "Reimbursement" ADD CONSTRAINT "Reimbursement_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "Reimbursement" ADD CONSTRAINT "Reimbursement_manageEmployeeID_fkey" FOREIGN KEY ("manageEmployeeID") REFERENCES "ManageEmployee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "Reimbursement" ADD CONSTRAINT "Reimbursement_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "ReimbursementItem" ADD CONSTRAINT "ReimbursementItem_reimbursementID_fkey" FOREIGN KEY ("reimbursementID") REFERENCES "Reimbursement"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "User" ADD CONSTRAINT "User_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "User" ADD CONSTRAINT "User_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "User" ADD CONSTRAINT "User_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "User" ADD CONSTRAINT "User_contractorID_fkey" FOREIGN KEY ("contractorID") REFERENCES "Contractors"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "UserCompany" ADD CONSTRAINT "UserCompany_userID_fkey" FOREIGN KEY ("userID") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "UserCompany" ADD CONSTRAINT "UserCompany_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "UserProfile" ADD CONSTRAINT "UserProfile_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "Overtime" ADD CONSTRAINT "Overtime_employeeID_fkey" FOREIGN KEY ("employeeID") REFERENCES "ManageEmployee"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Overtime" ADD CONSTRAINT "Overtime_workShiftID_fkey" FOREIGN KEY ("workShiftID") REFERENCES "WorkShift"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Roster" ADD CONSTRAINT "Roster_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Roster" ADD CONSTRAINT "Roster_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Roster" ADD CONSTRAINT "Roster_departmentID_fkey" FOREIGN KEY ("departmentID") REFERENCES "Departments"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Roster" ADD CONSTRAINT "Roster_designationID_fkey" FOREIGN KEY ("designationID") REFERENCES "Designations"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Roster" ADD CONSTRAINT "Roster_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RosterEmployee" ADD CONSTRAINT "RosterEmployee_employeeID_fkey" FOREIGN KEY ("employeeID") REFERENCES "ManageEmployee"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RosterEmployee" ADD CONSTRAINT "RosterEmployee_rosterID_fkey" FOREIGN KEY ("rosterID") REFERENCES "Roster"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RosterDay" ADD CONSTRAINT "RosterDay_rosterEmployeeID_fkey" FOREIGN KEY ("rosterEmployeeID") REFERENCES "RosterEmployee"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RosterDay" ADD CONSTRAINT "RosterDay_workShiftID_fkey" FOREIGN KEY ("workShiftID") REFERENCES "WorkShift"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PFCompliance" ADD CONSTRAINT "PFCompliance_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ESICCompliance" ADD CONSTRAINT "ESICCompliance_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PTCompliance" ADD CONSTRAINT "PTCompliance_branchID_fkey" FOREIGN KEY ("branchID") REFERENCES "Branches"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PTCompliance" ADD CONSTRAINT "PTCompliance_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PTSlab" ADD CONSTRAINT "PTSlab_ptComplianceID_fkey" FOREIGN KEY ("ptComplianceID") REFERENCES "PTCompliance"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PrivilegedLeaveLedger" ADD CONSTRAINT "PrivilegedLeaveLedger_employeeID_fkey" FOREIGN KEY ("employeeID") REFERENCES "ManageEmployee"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PrivilegedLeaveLedger" ADD CONSTRAINT "PrivilegedLeaveLedger_leavePolicyID_fkey" FOREIGN KEY ("leavePolicyID") REFERENCES "leavePolicy"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EmployeeHolidayOverride" ADD CONSTRAINT "EmployeeHolidayOverride_employeeID_fkey" FOREIGN KEY ("employeeID") REFERENCES "ManageEmployee"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EmployeeHolidayOverride" ADD CONSTRAINT "EmployeeHolidayOverride_holidayId_fkey" FOREIGN KEY ("holidayId") REFERENCES "PublicHoliday"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EmployeeWeeklyOff" ADD CONSTRAINT "EmployeeWeeklyOff_employeeID_fkey" FOREIGN KEY ("employeeID") REFERENCES "ManageEmployee"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PrivilegedLeaveLapse" ADD CONSTRAINT "PrivilegedLeaveLapse_employeeID_fkey" FOREIGN KEY ("employeeID") REFERENCES "ManageEmployee"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PrivilegedLeaveLapse" ADD CONSTRAINT "PrivilegedLeaveLapse_leavePolicyID_fkey" FOREIGN KEY ("leavePolicyID") REFERENCES "leavePolicy"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EmployeeMemo" ADD CONSTRAINT "EmployeeMemo_employeeID_fkey" FOREIGN KEY ("employeeID") REFERENCES "ManageEmployee"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FactualWorkShiftDay" ADD CONSTRAINT "FactualWorkShiftDay_factualWorkShiftID_fkey" FOREIGN KEY ("factualWorkShiftID") REFERENCES "FactualWorkShift"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpFactualWorkShift" ADD CONSTRAINT "EmpFactualWorkShift_manageEmployeeID_fkey" FOREIGN KEY ("manageEmployeeID") REFERENCES "ManageEmployee"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EmpFactualWorkShift" ADD CONSTRAINT "EmpFactualWorkShift_factualWorkShiftID_fkey" FOREIGN KEY ("factualWorkShiftID") REFERENCES "FactualWorkShift"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "EmpFactualAttendancePolicy" ADD CONSTRAINT "EmpFactualAttendancePolicy_manageEmployeeID_fkey" FOREIGN KEY ("manageEmployeeID") REFERENCES "ManageEmployee"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EmpFactualAttendancePolicy" ADD CONSTRAINT "EmpFactualAttendancePolicy_factualAttendancePolicyID_fkey" FOREIGN KEY ("factualAttendancePolicyID") REFERENCES "FactualAttendancePolicy"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "FactualRosterEmployee" ADD CONSTRAINT "FactualRosterEmployee_factualRosterID_fkey" FOREIGN KEY ("factualRosterID") REFERENCES "FactualRoster"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FactualRosterDay" ADD CONSTRAINT "FactualRosterDay_factualRosterEmployeeID_fkey" FOREIGN KEY ("factualRosterEmployeeID") REFERENCES "FactualRosterEmployee"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FactualRosterDay" ADD CONSTRAINT "FactualRosterDay_factualWorkShiftID_fkey" FOREIGN KEY ("factualWorkShiftID") REFERENCES "FactualWorkShift"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "attendance_locations" ADD CONSTRAINT "attendance_locations_employeeId_fkey" FOREIGN KEY ("employeeId") REFERENCES "ManageEmployee"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EmpAbsentDeclaration" ADD CONSTRAINT "EmpAbsentDeclaration_employeeId_fkey" FOREIGN KEY ("employeeId") REFERENCES "ManageEmployee"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TaskCustomer" ADD CONSTRAINT "TaskCustomer_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "TaskCustomer" ADD CONSTRAINT "TaskCustomer_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "TaskCustomer" ADD CONSTRAINT "TaskCustomer_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "TaskCustomerContact" ADD CONSTRAINT "TaskCustomerContact_customerID_fkey" FOREIGN KEY ("customerID") REFERENCES "TaskCustomer"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TaskCustomerSite" ADD CONSTRAINT "TaskCustomerSite_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "TaskCustomerSite" ADD CONSTRAINT "TaskCustomerSite_customerID_fkey" FOREIGN KEY ("customerID") REFERENCES "TaskCustomer"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TaskCustomerSiteContact" ADD CONSTRAINT "TaskCustomerSiteContact_siteID_fkey" FOREIGN KEY ("siteID") REFERENCES "TaskCustomerSite"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TaskCustomerSiteNote" ADD CONSTRAINT "TaskCustomerSiteNote_siteID_fkey" FOREIGN KEY ("siteID") REFERENCES "TaskCustomerSite"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TaskWorkscopeCategory" ADD CONSTRAINT "TaskWorkscopeCategory_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "TaskProduct" ADD CONSTRAINT "TaskProduct_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "TaskProject" ADD CONSTRAINT "TaskProject_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "TaskProject" ADD CONSTRAINT "TaskProject_serviceProviderID_fkey" FOREIGN KEY ("serviceProviderID") REFERENCES "ServiceProvider"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "TaskProject" ADD CONSTRAINT "TaskProject_departmentID_fkey" FOREIGN KEY ("departmentID") REFERENCES "Departments"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "TaskProject" ADD CONSTRAINT "TaskProject_customerID_fkey" FOREIGN KEY ("customerID") REFERENCES "TaskCustomer"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TaskProject" ADD CONSTRAINT "TaskProject_siteID_fkey" FOREIGN KEY ("siteID") REFERENCES "TaskCustomerSite"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TaskProject" ADD CONSTRAINT "TaskProject_createdByEmployeeID_fkey" FOREIGN KEY ("createdByEmployeeID") REFERENCES "ManageEmployee"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TaskAssignment" ADD CONSTRAINT "TaskAssignment_taskID_fkey" FOREIGN KEY ("taskID") REFERENCES "TaskProject"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TaskAssignment" ADD CONSTRAINT "TaskAssignment_manageEmployeeID_fkey" FOREIGN KEY ("manageEmployeeID") REFERENCES "ManageEmployee"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TaskEngineerAssignment" ADD CONSTRAINT "TaskEngineerAssignment_taskID_fkey" FOREIGN KEY ("taskID") REFERENCES "TaskProject"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TaskEngineerAssignment" ADD CONSTRAINT "TaskEngineerAssignment_manageEmployeeID_fkey" FOREIGN KEY ("manageEmployeeID") REFERENCES "ManageEmployee"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TaskRemark" ADD CONSTRAINT "TaskRemark_taskID_fkey" FOREIGN KEY ("taskID") REFERENCES "TaskProject"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TaskProjectContact" ADD CONSTRAINT "TaskProjectContact_taskID_fkey" FOREIGN KEY ("taskID") REFERENCES "TaskProject"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TaskWorkscopeDetail" ADD CONSTRAINT "TaskWorkscopeDetail_taskID_fkey" FOREIGN KEY ("taskID") REFERENCES "TaskProject"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TaskWorkscopeDetail" ADD CONSTRAINT "TaskWorkscopeDetail_workscopeCategoryID_fkey" FOREIGN KEY ("workscopeCategoryID") REFERENCES "TaskWorkscopeCategory"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TaskSchedule" ADD CONSTRAINT "TaskSchedule_taskID_fkey" FOREIGN KEY ("taskID") REFERENCES "TaskProject"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TaskImage" ADD CONSTRAINT "TaskImage_taskID_fkey" FOREIGN KEY ("taskID") REFERENCES "TaskProject"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TaskNote" ADD CONSTRAINT "TaskNote_taskID_fkey" FOREIGN KEY ("taskID") REFERENCES "TaskProject"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TaskInventory" ADD CONSTRAINT "TaskInventory_taskID_fkey" FOREIGN KEY ("taskID") REFERENCES "TaskProject"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TaskInventory" ADD CONSTRAINT "TaskInventory_productTypeId_fkey" FOREIGN KEY ("productTypeId") REFERENCES "TaskProduct"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TaskPurchase" ADD CONSTRAINT "TaskPurchase_taskID_fkey" FOREIGN KEY ("taskID") REFERENCES "TaskProject"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TaskPurchaseProduct" ADD CONSTRAINT "TaskPurchaseProduct_taskPurchaseID_fkey" FOREIGN KEY ("taskPurchaseID") REFERENCES "TaskPurchase"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TaskPurchaseAttachment" ADD CONSTRAINT "TaskPurchaseAttachment_taskPurchaseID_fkey" FOREIGN KEY ("taskPurchaseID") REFERENCES "TaskPurchase"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TaskChat" ADD CONSTRAINT "TaskChat_taskID_fkey" FOREIGN KEY ("taskID") REFERENCES "TaskProject"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TaskActivityLog" ADD CONSTRAINT "TaskActivityLog_taskID_fkey" FOREIGN KEY ("taskID") REFERENCES "TaskProject"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SubscriptionPlanModule" ADD CONSTRAINT "SubscriptionPlanModule_planID_fkey" FOREIGN KEY ("planID") REFERENCES "SubscriptionPlan"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SubscriptionPlanModule" ADD CONSTRAINT "SubscriptionPlanModule_moduleID_fkey" FOREIGN KEY ("moduleID") REFERENCES "Module"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CompanySubscription" ADD CONSTRAINT "CompanySubscription_renewedFromID_fkey" FOREIGN KEY ("renewedFromID") REFERENCES "CompanySubscription"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CompanySubscription" ADD CONSTRAINT "CompanySubscription_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CompanySubscription" ADD CONSTRAINT "CompanySubscription_planID_fkey" FOREIGN KEY ("planID") REFERENCES "SubscriptionPlan"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_workflows" ADD CONSTRAINT "approval_workflows_companyID_fkey" FOREIGN KEY ("companyID") REFERENCES "Company"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_workflows" ADD CONSTRAINT "approval_workflows_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_workflows" ADD CONSTRAINT "approval_workflows_companyModuleID_fkey" FOREIGN KEY ("companyModuleID") REFERENCES "company_modules"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_requests" ADD CONSTRAINT "approval_requests_approvalWorkflowID_fkey" FOREIGN KEY ("approvalWorkflowID") REFERENCES "approval_workflows"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_requests" ADD CONSTRAINT "approval_requests_companyModuleID_fkey" FOREIGN KEY ("companyModuleID") REFERENCES "company_modules"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_requests" ADD CONSTRAINT "approval_requests_subjectEmployeeID_fkey" FOREIGN KEY ("subjectEmployeeID") REFERENCES "ManageEmployee"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_request_steps" ADD CONSTRAINT "approval_request_steps_approvalRequestID_fkey" FOREIGN KEY ("approvalRequestID") REFERENCES "approval_requests"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_request_approvers" ADD CONSTRAINT "approval_request_approvers_approvalRequestID_fkey" FOREIGN KEY ("approvalRequestID") REFERENCES "approval_requests"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_request_approvers" ADD CONSTRAINT "approval_request_approvers_approvalRequestStepID_fkey" FOREIGN KEY ("approvalRequestStepID") REFERENCES "approval_request_steps"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_request_approvers" ADD CONSTRAINT "approval_request_approvers_approverEmployeeID_fkey" FOREIGN KEY ("approverEmployeeID") REFERENCES "ManageEmployee"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_request_actions" ADD CONSTRAINT "approval_request_actions_approvalRequestID_fkey" FOREIGN KEY ("approvalRequestID") REFERENCES "approval_requests"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_request_actions" ADD CONSTRAINT "approval_request_actions_approvalRequestStepID_fkey" FOREIGN KEY ("approvalRequestStepID") REFERENCES "approval_request_steps"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_request_actions" ADD CONSTRAINT "approval_request_actions_approvalRequestApproverID_fkey" FOREIGN KEY ("approvalRequestApproverID") REFERENCES "approval_request_approvers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_request_actions" ADD CONSTRAINT "approval_request_actions_actedByEmployeeID_fkey" FOREIGN KEY ("actedByEmployeeID") REFERENCES "ManageEmployee"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_workflow_conditions" ADD CONSTRAINT "approval_workflow_conditions_approvalWorkflowID_fkey" FOREIGN KEY ("approvalWorkflowID") REFERENCES "approval_workflows"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_workflow_conditions" ADD CONSTRAINT "approval_workflow_conditions_departmentID_fkey" FOREIGN KEY ("departmentID") REFERENCES "Departments"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_workflow_conditions" ADD CONSTRAINT "approval_workflow_conditions_designationID_fkey" FOREIGN KEY ("designationID") REFERENCES "Designations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_workflow_conditions" ADD CONSTRAINT "approval_workflow_conditions_branchesID_fkey" FOREIGN KEY ("branchesID") REFERENCES "Branches"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_workflow_condition_employees" ADD CONSTRAINT "approval_workflow_condition_employees_conditionID_fkey" FOREIGN KEY ("conditionID") REFERENCES "approval_workflow_conditions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_workflow_condition_employees" ADD CONSTRAINT "approval_workflow_condition_employees_manageEmployeeID_fkey" FOREIGN KEY ("manageEmployeeID") REFERENCES "ManageEmployee"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_workflow_steps" ADD CONSTRAINT "approval_workflow_steps_approvalWorkflowID_fkey" FOREIGN KEY ("approvalWorkflowID") REFERENCES "approval_workflows"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_workflow_steps" ADD CONSTRAINT "approval_workflow_steps_designationID_fkey" FOREIGN KEY ("designationID") REFERENCES "Designations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "attendance_location_points" ADD CONSTRAINT "attendance_location_points_attendancesessionid_fkey" FOREIGN KEY ("attendanceSessionId") REFERENCES "attendance_locations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "attendance_location_points" ADD CONSTRAINT "attendance_location_points_employeeid_fkey" FOREIGN KEY ("employeeId") REFERENCES "ManageEmployee"("id") ON DELETE CASCADE ON UPDATE CASCADE;
