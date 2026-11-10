// CalMG demo probe (CALHACK-103 B-08): the "integration" that changes a demo loan, plus a system-mode
// read of the field history and custom audit rows (the CLI admin has no FLS on these demo fields).
public without sharing class CalMG_DemoLoanHistoryProbe {
    public static Id createLoan() {
        CalMG_Demo_Loan__c l = new CalMG_Demo_Loan__c(Name = 'CalMG Demo Loan B-08', Amount__c = 300000, Interest_Rate__c = 5.25,
            Status__c = 'Draft', Collateral_Value__c = 450000, Credit_Memo__c = 'CalMG demo memo v1: income verified.');
        insert l;
        return l.Id;
    }

    public static void integrationUpdate(Id loanId, Decimal collateral, String memo) {
        update new CalMG_Demo_Loan__c(Id = loanId, Collateral_Value__c = collateral, Credit_Memo__c = memo);
    }

    public static String report(Id loanId) {
        List<String> out = new List<String>();
        for (CalMG_Demo_Loan__History h : [SELECT Field, OldValue, NewValue, CreatedDate FROM CalMG_Demo_Loan__History WHERE ParentId = :loanId ORDER BY CreatedDate, Field]) {
            out.add('history ' + h.Field + ' old=' + h.OldValue + ' new=' + h.NewValue);
        }
        for (CalMG_Demo_Loan_Audit__c a : [SELECT Field__c, Old__c, New__c FROM CalMG_Demo_Loan_Audit__c WHERE Loan__c = :loanId]) {
            out.add('audit ' + a.Field__c + ' old=' + a.Old__c + ' new=' + a.New__c);
        }
        CalMG_Demo_Loan__c l = [SELECT Collateral_Value__c, Credit_Memo__c FROM CalMG_Demo_Loan__c WHERE Id = :loanId];
        out.add('now collateral=' + l.Collateral_Value__c + ' memo=' + l.Credit_Memo__c);
        return String.join(out, ' | ');
    }
}