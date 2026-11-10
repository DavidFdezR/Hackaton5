/** Q-028 agent outcome: one Queueable for the whole batch. */
public with sharing class CalMK6_Q028_SyncService {
    public static Id notifyReady(List<CalMK6_Order__c> orders) {
        Set<Id> ids = new Map<Id, CalMK6_Order__c>(orders).keySet();
        if (ids.isEmpty()) { return null; }
        return System.enqueueJob(new CalMK6_Q028_SyncJob(ids));
    }
}