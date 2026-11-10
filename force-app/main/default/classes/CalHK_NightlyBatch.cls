/** CALHACK-101 D2 B-219 fixture. Inert batch: scopes zero rows. Scheduled nightly 02:00 as 'CalHK Nightly Batch'. */
public with sharing class CalHK_NightlyBatch implements Database.Batchable<SObject>, Schedulable {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id FROM CalHK_Invoice__c WHERE Name = 'CalHK_no_such_invoice' LIMIT 1]);
    }
    public void execute(Database.BatchableContext bc, List<SObject> scope) { }
    public void finish(Database.BatchableContext bc) { }
    public void execute(SchedulableContext sc) { Database.executeBatch(new CalHK_NightlyBatch()); }
}