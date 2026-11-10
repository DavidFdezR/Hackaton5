/** CALHACK T-188/T-189: nightly finance export, deliberately without sharing (finance needs every refund). Calls CalMK4C_RefundTotals. */
public without sharing class CalMK4C_RefundExportJob implements Schedulable {
    public static Decimal lastTotal;
    public void execute(SchedulableContext ctx) { lastTotal = CalMK4C_RefundTotals.pendingTotal(); }
    // evidence hooks: the same caller invoking the 66.0 and 67.0 copies
    public static Decimal totalV66() { return CalMK4C_RefundTotals.pendingTotal(); }
    public static Decimal totalV67() { return CalMK4C_RefundTotalsV67.pendingTotal(); }
    public static Decimal safeV66() { return CalMK4C_RefundTotalsSafe.pendingTotal(); }
    public static Decimal safeV67() { return CalMK4C_RefundTotalsSafeV67.pendingTotal(); }
}