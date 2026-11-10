/** Starting state for Q-031: new invoice calculator, only a happy-path test exists. */
public with sharing class CalMK6_InvoiceCalculator {
    public static Decimal total(Decimal amount, Decimal discountPct, Decimal taxPct) {
        if (amount == null || amount < 0) {
            throw new IllegalArgumentException('CalMK6: amount must be zero or positive');
        }
        Decimal d = (discountPct == null) ? 0 : discountPct;
        if (d > 50) {
            d = 50;
        }
        Decimal net = amount - (amount * d / 100);
        Decimal tax = (taxPct == null) ? 0 : (net * taxPct / 100);
        return (net + tax).setScale(2, RoundingMode.HALF_UP);
    }
}