/** Starting state for Q-032/Q-033/Q-039. Spec CALHACK-Q-T6: tax is rounded HALF_UP to cents (101.25 @ 10% = 10.13). Bug: rounds DOWN. */
public with sharing class CalMK6_TaxService {
    public static Decimal taxFor(Decimal amount, Decimal rate) {
        return (amount * rate).setScale(2, RoundingMode.DOWN);
    }
}