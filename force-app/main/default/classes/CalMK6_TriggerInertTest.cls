/** Safety proof for the shared org: with CalMK6_OrderTriggerRouter.mode unset (every real transaction), the Active
    CalMK6_OrderTrigger changes nothing and issues no DML or SOQL of its own. */
@IsTest
private class CalMK6_TriggerInertTest {
    @IsTest static void liveTriggerIsANoOp() {
        List<CalMK6_Order__c> rows = new List<CalMK6_Order__c>();
        for (Integer i = 0; i < 250; i++) { rows.add(new CalMK6_Order__c(Name = 'CalMK6_Inert' + i, Revision__c = 0)); }
        insert rows;
        for (CalMK6_Order__c o : rows) { o.Status__c = 'Edited'; }
        Assert.isNull(CalMK6_OrderTriggerRouter.mode);
        Test.startTest();
        update rows;
        Integer dml = Limits.getDmlStatements(); Integer soql = Limits.getQueries();
        Test.stopTest();
        Assert.areEqual(1, dml);
        Assert.areEqual(0, soql);
        Assert.areEqual(250, [SELECT COUNT() FROM CalMK6_Order__c WHERE Revision__c = 0]);
    }
}