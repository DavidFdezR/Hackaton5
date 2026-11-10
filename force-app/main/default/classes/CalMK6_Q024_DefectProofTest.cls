/** Q-024 reviewer evidence: 250-row update arrives as trigger chunks of 200 + 50; the static Boolean skips chunk 2.
    This test PASSES by asserting the defect (200 raised, 50 untouched). */
@IsTest
private class CalMK6_Q024_DefectProofTest {
    @IsTest static void chunkTwoIsSilentlySkipped() {
        List<CalMK6_Order__c> rows = new List<CalMK6_Order__c>();
        for (Integer i = 0; i < 250; i++) { rows.add(new CalMK6_Order__c(Name = 'CalMK6_Rev' + i, Revision__c = 0)); }
        insert rows;
        for (CalMK6_Order__c o : rows) { o.Status__c = 'Edited'; }
        CalMK6_OrderTriggerRouter.mode = 'Q024';
        update rows;
        Integer raised = [SELECT COUNT() FROM CalMK6_Order__c WHERE Revision__c = 1];
        Integer untouched = [SELECT COUNT() FROM CalMK6_Order__c WHERE Revision__c = 0];
        System.debug('CALMK6_Q024 raised=' + raised + ' untouched=' + untouched);
        Assert.areEqual(200, raised);
        Assert.areEqual(50, untouched);
    }
}