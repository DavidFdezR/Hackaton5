/** CALHACK T-188: month-end refund total for the finance export. No sharing keyword, no access mode. apiVersion 66.0 in the org. */
public class CalMK4C_RefundTotals {
    public static Decimal pendingTotal() {
        Decimal total = 0;
        for (CalMK4C_DemoRefund__c r : [SELECT Amount__c FROM CalMK4C_DemoRefund__c]) { total += r.Amount__c; }
        return total;
    }
}