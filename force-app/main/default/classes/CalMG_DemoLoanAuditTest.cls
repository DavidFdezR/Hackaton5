@IsTest
private class CalMG_DemoLoanAuditTest {
    @IsTest static void integrationChangeIsAudited() {
        CalMG_Demo_Loan__c l = new CalMG_Demo_Loan__c(Name = 'CalMG Demo Loan Audit Test', Amount__c = 300000,
            Interest_Rate__c = 5.25, Collateral_Value__c = 450000, Credit_Memo__c = 'CalMG demo memo v1: income verified.');
        insert l;
        l.Collateral_Value__c = 380000;
        l.Credit_Memo__c = 'CalMG demo memo v2: collateral revalued after desk review.';
        update l;

        Map<String, CalMG_Demo_Loan_Audit__c> byField = new Map<String, CalMG_Demo_Loan_Audit__c>();
        for (CalMG_Demo_Loan_Audit__c a : [SELECT Field__c, Old__c, New__c, Changed_By__c FROM CalMG_Demo_Loan_Audit__c WHERE Loan__c = :l.Id]) {
            byField.put(a.Field__c, a);
        }
        Integer historyRows = [SELECT COUNT() FROM CalMG_Demo_Loan__History WHERE ParentId = :l.Id];
        String trace = 'audit rows=' + byField.size() + ' fields=' + byField.keySet() + '; field history rows visible in test=' + historyRows;
        System.debug(LoggingLevel.ERROR, 'CALMG ' + trace);
        Assert.areEqual(2, byField.size(), 'one audit row per changed regulated field (' + trace + ')');
        Assert.areEqual('450000.00', byField.get('Collateral_Value__c').Old__c, trace);
        Assert.areEqual('380000.00', byField.get('Collateral_Value__c').New__c, trace);
        Assert.areEqual('CalMG demo memo v1: income verified.', byField.get('Credit_Memo__c').Old__c, trace);
        Assert.areEqual(UserInfo.getUserId(), byField.get('Credit_Memo__c').Changed_By__c, trace);
    }
}