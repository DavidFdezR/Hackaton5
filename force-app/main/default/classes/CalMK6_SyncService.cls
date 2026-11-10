/** Starting state for Q-027/Q-028. Ticket: "marking 60 orders Ready at once fails: Too many future calls: 51". */
public with sharing class CalMK6_SyncService {
    public static void notifyReady(List<CalMK6_Order__c> orders) {
        for (CalMK6_Order__c o : orders) { sendOne(o.Id); }
    }
    @future
    public static void sendOne(Id orderId) {
        update new CalMK6_Order__c(Id = orderId, Sync_Status__c = 'Sent');
    }
}