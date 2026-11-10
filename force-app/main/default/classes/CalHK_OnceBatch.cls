/** CALHACK-101 D2 B-220 fixture. Inert batch: scopes zero rows. Run once via Database.executeBatch; never scheduled. */
public with sharing class CalHK_OnceBatch implements Database.Batchable<SObject>, Schedulable {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id FROM CalHK_Invoice__c WHERE Name = 'CalHK_no_such_invoice' LIMIT 1]);
    }
    public void execute(Database.BatchableContext bc, List<SObject> scope) { }
    public void finish(Database.BatchableContext bc) { }
    public void execute(SchedulableContext sc) { Database.executeBatch(new CalHK_OnceBatch()); }
}