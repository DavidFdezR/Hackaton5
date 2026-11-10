/** Q-027 agent outcome: keep one @future per record but stop before the limit so nothing throws. */
public with sharing class CalMK6_Q027_SyncService {
    public static void notifyReady(List<CalMK6_Order__c> orders) {
        for (CalMK6_Order__c o : orders) {
            if (Limits.getFutureCalls() < Limits.getLimitFutureCalls()) { sendOne(o.Id); }
        }
    }
    @future
    public static void sendOne(Id orderId) {
        update new CalMK6_Order__c(Id = orderId, Sync_Status__c = 'Sent');
    }
}