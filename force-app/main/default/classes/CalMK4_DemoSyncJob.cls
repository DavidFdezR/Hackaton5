/** CALHACK T-116 (planted, bad on purpose; NEVER enqueue in the org): re-enqueues itself on every run, no stop condition, no AsyncOptions depth. */
public with sharing class CalMK4_DemoSyncJob implements Queueable {
    public void execute(QueueableContext ctx) {
        List<CalMK4_DemoOrder__c> rows = [SELECT Id FROM CalMK4_DemoOrder__c WHERE Status__c = 'New' LIMIT 200];
        for (CalMK4_DemoOrder__c r : rows) { r.Status__c = 'Synced'; }
        update rows;
        System.enqueueJob(new CalMK4_DemoSyncJob());
    }
}