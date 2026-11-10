@IsTest
private class CalMK4_DemoSyncJobTest {
    @IsTest static void firstRunSyncsAndChains() {
        List<CalMK4_DemoOrder__c> rows = new List<CalMK4_DemoOrder__c>();
        for (Integer i = 0; i < 5; i++) { rows.add(new CalMK4_DemoOrder__c(Name = 'CalMK4 Demo Order Q' + i, Status__c = 'Synced')); }
        insert rows; // nothing left to sync: the job still chains itself
        String outcome = 'no exception';
        try {
            Test.startTest();
            System.enqueueJob(new CalMK4_DemoSyncJob());
            Test.stopTest();
        } catch (Exception e) { outcome = e.getTypeName() + ': ' + e.getMessage(); }
        System.debug('CALMK4_EVIDENCE chain-in-test outcome=' + outcome);
        System.debug('CALMK4_EVIDENCE queued jobs=' + [SELECT COUNT() FROM AsyncApexJob WHERE ApexClass.Name = 'CalMK4_DemoSyncJob']);
    }
}