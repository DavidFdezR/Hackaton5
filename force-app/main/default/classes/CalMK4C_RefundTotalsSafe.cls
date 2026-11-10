/** CALHACK T-189: same total, but already explicit: with sharing + WITH USER_MODE. apiVersion 66.0 in the org. */
public with sharing class CalMK4C_RefundTotalsSafe {
    public static Decimal pendingTotal() {
        Decimal total = 0;
        for (CalMK4C_DemoRefund__c r : [SELECT Amount__c FROM CalMK4C_DemoRefund__c WITH USER_MODE]) { total += r.Amount__c; }
        return total;
    }
}