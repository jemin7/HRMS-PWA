"use client";

import { useCallback, useEffect, useState } from "react";
import { toast } from "sonner";
import { Button } from "../ui/button";

const BACKEND =
  process.env.NEXT_PUBLIC_BACKEND_URL || "https://hrms-api-test.onrender.com";

type ApprovalRow = {
  id: string;
  approvalRequestID: number;
  employeeName: string;
  attendanceDate: string;
  actualStatus: string;
  requestedStatus: string;
  reason: string;
  stepName: string;
  canReject: boolean;
  canApprove: boolean;
};

function authHeaders(): Record<string, string> {
  const token =
    typeof window !== "undefined"
      ? localStorage.getItem("token") ||
        localStorage.getItem("accessToken") ||
        ""
      : "";

  return token ? { Authorization: `Bearer ${token}` } : {};
}

export function EmpRegularisationApprovals({
  showEmptyState = true,
}: { showEmptyState?: boolean } = {}) {
  const [rows, setRows] = useState<ApprovalRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [actingId, setActingId] = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);

    try {
      const headers = authHeaders();

      const [regularisationRes, pendingRes, assignedRes] = await Promise.all([
        fetch(`${BACKEND}/emp-attendance-regularise`, {
          headers,
          credentials: "include",
          cache: "no-store",
        }),
        fetch(`${BACKEND}/approval-requests/my-pending`, {
          headers,
          credentials: "include",
          cache: "no-store",
        }),
        fetch(`${BACKEND}/approval-requests/my-assigned`, {
          headers,
          credentials: "include",
          cache: "no-store",
        }),
      ]);

      if (!regularisationRes.ok) {
        throw new Error(
          `Could not load regularisations (${regularisationRes.status})`,
        );
      }

      if (!pendingRes.ok) {
        throw new Error(
          `Could not load actionable approvals (${pendingRes.status})`,
        );
      }

      if (!assignedRes.ok) {
        throw new Error(
          `Could not load assigned approvals (${assignedRes.status})`,
        );
      }

      const [rawRegularisations, rawPending, rawAssigned] = await Promise.all([
        regularisationRes.json(),
        pendingRes.json(),
        assignedRes.json(),
      ]);

      const toArray = (value: any): any[] =>
        Array.isArray(value)
          ? value
          : Array.isArray(value?.data)
            ? value.data
            : [];

      const regularisations = toArray(rawRegularisations);
      const pendingApprovals = toArray(rawPending);
      const assignedApprovals = toArray(rawAssigned);

      const regularisationTypes = new Set([
        "ATTENDANCE_REGULARISATION",
        "ATTENDANCE_REGULARIZATION",
        "ATTENDANCE_REGULARISE",
      ]);

      const isRegularisationAssignment = (assignment: any) => {
        const request = assignment?.approvalRequest;

        return (
          regularisationTypes.has(
            String(request?.subjectType ?? "")
              .trim()
              .toUpperCase(),
          ) &&
          String(request?.status ?? "").toUpperCase() === "PENDING" &&
          Number(request?.id) > 0
        );
      };

      // Track actionable requests separately from visible assignments.
      const actionableRequestIDs = new Set<number>(
        pendingApprovals
          .filter(isRegularisationAssignment)
          .map((assignment: any) => Number(assignment.approvalRequest.id)),
      );

      // Keep assigned requests visible, even when the employee
      // cannot act on the current approval step yet.
      const assignmentsByRequest = new Map<number, any>();

      for (const assignment of assignedApprovals) {
        if (!isRegularisationAssignment(assignment)) continue;

        assignmentsByRequest.set(
          Number(assignment.approvalRequest.id),
          assignment,
        );
      }

      // Prefer the actionable assignment when it exists.
      for (const assignment of pendingApprovals) {
        if (!isRegularisationAssignment(assignment)) continue;

        assignmentsByRequest.set(
          Number(assignment.approvalRequest.id),
          assignment,
        );
      }

      const assignedRows = Array.from(assignmentsByRequest.values())
        .map((assignment): ApprovalRow | null => {
          const request = assignment.approvalRequest;

          const record = regularisations.find(
            (item: any) => Number(item.id) === Number(request.subjectID),
          );

          if (!record) return null;

          const employee = record.manageEmployee;

          const employeeName = [
            employee?.employeeFirstName,
            employee?.employeeLastName,
          ]
            .filter(Boolean)
            .join(" ")
            .trim();

          const canApprove = actionableRequestIDs.has(Number(request.id));

          return {
            id: String(record.id),
            approvalRequestID: Number(request.id),
            employeeName:
              employeeName ||
              employee?.employeeID ||
              `Employee ${record.manageEmployeeID ?? ""}`,
            attendanceDate: String(record.attendanceDate ?? "").slice(0, 10),
            actualStatus: record.actualStatus || "—",
            requestedStatus: record.requestedStatus || "—",
            reason: record.reason || "",
            stepName: assignment.approvalRequestStep?.stepNameSnapshot || "",
            canReject:
              assignment.approvalRequestStep?.canRejectSnapshot !== false,
            canApprove,
          };
        })
        .filter((row): row is ApprovalRow => row !== null);

      console.info("[Regularisation approvals diagnostics]", {
        regularisationRecords: regularisations.length,
        pendingAssignments: pendingApprovals.length,
        assignedApprovals: assignedApprovals.length,
        matchingVisibleRows: assignedRows.length,
      });

      setRows(assignedRows);
    } catch (error) {
      console.error("Failed to load regularisation approvals:", error);

      toast.error(
        error instanceof Error
          ? error.message
          : "Could not load regularisation approvals.",
      );

      setRows([]);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  const decide = async (row: ApprovalRow, action: "approve" | "reject") => {
    let remark = "Attendance regularisation approved";

    if (action === "reject") {
      const entered = window.prompt(
        "Enter the reason for rejecting this regularisation:",
      );

      if (entered === null) return;

      remark = entered.trim();

      if (!remark) {
        toast.error("A rejection reason is required.");
        return;
      }
    }

    setActingId(row.id);

    try {
      const response = await fetch(
        `${BACKEND}/approval-requests/${row.approvalRequestID}/${action}`,
        {
          method: "POST",
          headers: {
            ...authHeaders(),
            "Content-Type": "application/json",
          },
          credentials: "include",
          body: JSON.stringify({ remark }),
        },
      );

      const result = await response.json().catch(() => ({}));

      if (!response.ok) {
        throw new Error(
          result?.message ||
            `Failed to ${action} regularisation (${response.status})`,
        );
      }

      toast.success(
        action === "approve"
          ? result?.completed
            ? "Regularisation fully approved"
            : "Approval recorded"
          : "Regularisation rejected",
      );

      await load();

      if (typeof window !== "undefined") {
        window.dispatchEvent(new Event("emp-sidebar-badges-changed"));
      }
    } catch (error) {
      console.error("Regularisation decision failed:", error);

      toast.error(
        error instanceof Error
          ? error.message
          : "Could not update regularisation approval.",
      );
    } finally {
      setActingId(null);
    }
  };

  if (loading) {
    return (
      <p className="py-8 text-center text-sm text-muted-foreground">
        Loading regularisation approvals…
      </p>
    );
  }

  if (rows.length === 0) {
    if (!showEmptyState) return null;

    return (
      <div className="rounded-xl border border-border bg-card p-8 text-center text-sm text-muted-foreground">
        No pending regularisation approvals assigned to you.
      </div>
    );
  }

  return (
    <div className="space-y-2">
      {rows.map((row) => (
        <div
          key={row.id}
          className="rounded-xl border border-border bg-card p-4 flex flex-col gap-3 sm:flex-row sm:items-center"
        >
          <div className="min-w-0 flex-1">
            <p className="font-semibold text-foreground">{row.employeeName}</p>

            <p className="mt-1 text-xs text-muted-foreground">
              Date: {row.attendanceDate || "—"}
            </p>

            <p className="mt-1 text-sm text-foreground">
              {row.actualStatus} → {row.requestedStatus}
            </p>

            {row.reason ? (
              <p className="mt-1 text-xs text-muted-foreground">
                Reason: {row.reason}
              </p>
            ) : null}

            {row.stepName ? (
              <p className="mt-1 text-xs text-muted-foreground">
                Approval step: {row.stepName}
              </p>
            ) : null}
          </div>

          <div className="flex shrink-0 gap-2">
            {row.canApprove ? (
              <>
                {row.canReject ? (
                  <Button
                    type="button"
                    size="sm"
                    variant="outline"
                    disabled={actingId !== null}
                    onClick={() => void decide(row, "reject")}
                  >
                    {actingId === row.id ? "Processing…" : "Reject"}
                  </Button>
                ) : null}

                <Button
                  type="button"
                  size="sm"
                  disabled={actingId !== null}
                  onClick={() => void decide(row, "approve")}
                >
                  {actingId === row.id ? "Processing…" : "Approve"}
                </Button>
              </>
            ) : (
              <span className="text-xs text-muted-foreground">
                Waiting for your approval step
              </span>
            )}
          </div>
        </div>
      ))}
    </div>
  );
}
