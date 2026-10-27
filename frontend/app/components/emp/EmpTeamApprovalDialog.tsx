"use client";

import { EmpLeaveApprovalSheet } from "./EmpLeaveApprovalSheet";
import { EmpReimbursementApprovalSheet } from "./EmpReimbursementApprovalSheet";
import type { LeaveAppRow } from "./EmpLeaveMobile";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "../ui/dialog";

export type TeamApprovalType = "leave" | "reimbursement";

export function EmpTeamApprovalDialog({
  open,
  onClose,
  type,
  leaveApplication,
  reimbursementId,
  onDone,
}: {
  open: boolean;
  onClose: () => void;
  type: TeamApprovalType;
  leaveApplication: LeaveAppRow | null;
  reimbursementId: string | null;
  onDone: () => void;
}) {
  return (
    <Dialog open={open} onOpenChange={(v) => !v && onClose()}>
      <DialogContent className="emp-team-approval-dialog sm:max-w-2xl max-h-[92vh] overflow-hidden flex flex-col p-0 gap-0">
        <DialogHeader className="px-6 pt-6 pb-2 shrink-0">
          <DialogTitle>Review approval</DialogTitle>
        </DialogHeader>

        <div className="flex-1 min-h-0 overflow-y-auto border-t border-border">
          {type === "leave" && leaveApplication ? (
            <EmpLeaveApprovalSheet
              embedded
              open={open}
              onClose={onClose}
              application={leaveApplication}
              onDone={onDone}
            />
          ) : null}

          {type === "reimbursement" && reimbursementId ? (
            <EmpReimbursementApprovalSheet
              embedded
              open={open}
              onClose={onClose}
              reimbursementId={reimbursementId}
              onDone={onDone}
            />
          ) : null}

          {type === "leave" && !leaveApplication ? (
            <p className="p-6 text-sm text-muted-foreground">
              Select a leave request to review.
            </p>
          ) : null}

          {type === "reimbursement" && !reimbursementId ? (
            <p className="p-6 text-sm text-muted-foreground">
              Select a reimbursement claim to review.
            </p>
          ) : null}
        </div>
      </DialogContent>
    </Dialog>
  );
}
  