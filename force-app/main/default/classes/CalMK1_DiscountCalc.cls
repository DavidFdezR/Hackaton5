public with sharing class CalMK1_DiscountCalc {
    public static Decimal apply(Decimal amount, Decimal pct) {
        if (amount == null || pct == null) { return amount; }
        if (pct > 50) { pct = 50; }
        return (amount * (1 - pct / 100)).setScale(2);
    }
}