/** Q-027 agent's own test: 60 orders, asserts no exception and that some orders were sent. Passes. */
@IsTest
private class CalMK6_Q027_SyncServiceTest {
    @IsTest static void sixtyOrdersDoNotThrow() {
        List<CalMK6_Order__c> rows = new List<CalMK6_Order__c>();
        for (Integer i = 0; i < 60; i++) { rows.add(new CalMK6_Order__c(Name = 'CalMK6_Sync' + i)); }
        insert rows;
        Test.startTest();
        CalMK6_Q027_SyncService.notifyReady(rows);
        Test.stopTest();
        Assert.isTrue([SELECT COUNT() FROM CalMK6_Order__c WHERE Sync_Status__c = 'Sent'] > 0);
    }
}