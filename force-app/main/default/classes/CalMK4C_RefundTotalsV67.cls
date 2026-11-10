/** CALHACK T-188: month-end refund total for the finance export. No sharing keyword, no access mode. evidence copy of CalMK4C_RefundTotals bumped to apiVersion 67.0, body unchanged. */
public class CalMK4C_RefundTotalsV67 {
    public static Decimal pendingTotal() {
        Decimal total = 0;
        for (CalMK4C_DemoRefund__c r : [SELECT Amount__c FROM CalMK4C_DemoRefund__c]) { total += r.Amount__c; }
        return total;
    }
}