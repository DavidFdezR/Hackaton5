/** Q-026 tests: single, 250-row bulk across the chunk boundary, and a second update raising to 2. */
@IsTest
private class CalMK6_Q026_RevisionHandlerTest {
    @IsTest static void bulk250RaisedExactlyOnce() {
        List<CalMK6_Order__c> rows = new List<CalMK6_Order__c>();
        for (Integer i = 0; i < 250; i++) { rows.add(new CalMK6_Order__c(Name = 'CalMK6_Rev' + i, Revision__c = 0)); }
        insert rows;
        for (CalMK6_Order__c o : rows) { o.Status__c = 'Edited'; }
        CalMK6_OrderTriggerRouter.mode = 'Q026';
        Test.startTest();
        update rows;
        Integer dml = Limits.getDmlStatements();
        Test.stopTest();
        Assert.areEqual(1, dml, 'only the caller DML, handler does none');
        Assert.areEqual(250, [SELECT COUNT() FROM CalMK6_Order__c WHERE Revision__c = 1]);
    }
    @IsTest static void secondUpdateRaisesToTwo() {
        CalMK6_Order__c o = new CalMK6_Order__c(Name = 'CalMK6_Rev1', Revision__c = 0);
        insert o;
        CalMK6_OrderTriggerRouter.mode = 'Q026';
        update new CalMK6_Order__c(Id = o.Id, Status__c = 'A');
        update new CalMK6_Order__c(Id = o.Id, Status__c = 'B');
        Assert.areEqual(2, [SELECT Revision__c FROM CalMK6_Order__c WHERE Id = :o.Id].Revision__c);
    }
}