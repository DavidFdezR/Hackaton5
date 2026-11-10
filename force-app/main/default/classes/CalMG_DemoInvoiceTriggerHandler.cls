// CALHACK-103 R-08 FIRST ATTEMPT: "already processed" guard keyed on record Id in a static set.
public with sharing class CalMG_DemoInvoiceTriggerHandler {
    @TestVisible static Set<Id> processedIds = new Set<Id>();
    @TestVisible static Integer invocations = 0;

    public static void afterUpdate(List<CalMG_Demo_Invoice__c> newList, Map<Id, CalMG_Demo_Invoice__c> oldMap) {
        invocations++;
        List<CalMG_Demo_Invoice_Audit__c> audits = new List<CalMG_Demo_Invoice_Audit__c>();
        for (CalMG_Demo_Invoice__c inv : newList) {
            if (processedIds.contains(inv.Id)) {
                continue; // skip records this transaction has already handled
            }
            processedIds.add(inv.Id);
            audits.add(new CalMG_Demo_Invoice_Audit__c(
                Invoice__c = inv.Id,
                Note__c = 'Amount ' + oldMap.get(inv.Id).Amount__c + ' -> ' + inv.Amount__c));
        }
        if (!audits.isEmpty()) {
            insert audits;
        }
    }
}