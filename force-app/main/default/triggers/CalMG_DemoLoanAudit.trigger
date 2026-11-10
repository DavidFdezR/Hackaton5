trigger CalMG_DemoLoanAudit on CalMG_Demo_Loan__c (after update) {
    CalMG_DemoLoanAuditHandler.audit(Trigger.new, Trigger.oldMap);
}