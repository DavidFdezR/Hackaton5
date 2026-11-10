/** Q-025 reviewer's added test (the human edit): 250 rows across the 200 chunk boundary, exact revision asserted. */
@IsTest
private class CalMK6_Q025_ReviewerBulkTest {
    @IsTest static void all250RaisedExactlyOnce() {
        List<CalMK6_Order__c> rows = new List<CalMK6_Order__c>();
        for (Integer i = 0; i < 250; i++) { rows.add(new CalMK6_Order__c(Name = 'CalMK6_Rev' + i, Revision__c = 0)); }
        insert rows;
        for (CalMK6_Order__c o : rows) { o.Status__c = 'Edited'; }
        CalMK6_OrderTriggerRouter.mode = 'Q025';
        update rows;
        Assert.areEqual(250, [SELECT COUNT() FROM CalMK6_Order__c WHERE Revision__c = 1]);
        Assert.areEqual(0, [SELECT COUNT() FROM CalMK6_Order__c WHERE Revision__c != 1]);
    }
}