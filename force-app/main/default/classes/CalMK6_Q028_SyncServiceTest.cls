/** Q-028 tests: 200 orders -> exactly 1 queueable, all 200 Sent; empty input enqueues nothing. */
@IsTest
private class CalMK6_Q028_SyncServiceTest {
    @IsTest static void twoHundredOrdersOneJobAllSent() {
        List<CalMK6_Order__c> rows = new List<CalMK6_Order__c>();
        for (Integer i = 0; i < 200; i++) { rows.add(new CalMK6_Order__c(Name = 'CalMK6_Sync' + i)); }
        insert rows;
        Test.startTest();
        CalMK6_Q028_SyncService.notifyReady(rows);
        Assert.areEqual(1, Limits.getQueueableJobs());
        Assert.areEqual(0, Limits.getFutureCalls());
        Test.stopTest();
        Assert.areEqual(200, [SELECT COUNT() FROM CalMK6_Order__c WHERE Sync_Status__c = 'Sent']);
    }
    @IsTest static void emptyInputEnqueuesNothing() {
        Assert.isNull(CalMK6_Q028_SyncService.notifyReady(new List<CalMK6_Order__c>()));
        Assert.areEqual(0, Limits.getQueueableJobs());
    }
}