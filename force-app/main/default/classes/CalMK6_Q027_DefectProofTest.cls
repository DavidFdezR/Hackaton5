/** Q-027 reviewer evidence: the guard silently drops every order after the 50th. PASSES by asserting 50 sent / 10 never sent. */
@IsTest
private class CalMK6_Q027_DefectProofTest {
    @IsTest static void tenOfSixtyNeverSent() {
        List<CalMK6_Order__c> rows = new List<CalMK6_Order__c>();
        for (Integer i = 0; i < 60; i++) { rows.add(new CalMK6_Order__c(Name = 'CalMK6_Sync' + i)); }
        insert rows;
        Test.startTest();
        CalMK6_Q027_SyncService.notifyReady(rows);
        Test.stopTest();
        Integer sent = [SELECT COUNT() FROM CalMK6_Order__c WHERE Sync_Status__c = 'Sent'];
        Integer lost = [SELECT COUNT() FROM CalMK6_Order__c WHERE Sync_Status__c = null];
        System.debug('CALMK6_Q027 sent=' + sent + ' lost=' + lost);
        Assert.areEqual(50, sent);
        Assert.areEqual(10, lost);
    }
}