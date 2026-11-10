/** Q-028 queueable: marks every order in the batch as Sent in one DML. */
public with sharing class CalMK6_Q028_SyncJob implements Queueable {
    private Set<Id> orderIds;
    public CalMK6_Q028_SyncJob(Set<Id> orderIds) { this.orderIds = orderIds; }
    public void execute(QueueableContext ctx) {
        List<CalMK6_Order__c> upd = new List<CalMK6_Order__c>();
        for (Id i : orderIds) { upd.add(new CalMK6_Order__c(Id = i, Sync_Status__c = 'Sent')); }
        update upd;
    }
}