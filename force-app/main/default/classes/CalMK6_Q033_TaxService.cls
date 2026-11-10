/** Q-033 agent outcome: one-token fix, DOWN -> HALF_UP, per the spec. */
public with sharing class CalMK6_Q033_TaxService {
    public static Decimal taxFor(Decimal amount, Decimal rate) {
        return (amount * rate).setScale(2, RoundingMode.HALF_UP);
    }
}