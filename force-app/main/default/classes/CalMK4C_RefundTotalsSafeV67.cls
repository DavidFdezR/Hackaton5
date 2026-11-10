/** CALHACK T-189: same total, but already explicit: with sharing + WITH USER_MODE. evidence copy bumped to apiVersion 67.0, body unchanged. */
public with sharing class CalMK4C_RefundTotalsSafeV67 {
    public static Decimal pendingTotal() {
        Decimal total = 0;
        for (CalMK4C_DemoRefund__c r : [SELECT Amount__c FROM CalMK4C_DemoRefund__c WITH USER_MODE]) { total += r.Amount__c; }
        return total;
    }
}