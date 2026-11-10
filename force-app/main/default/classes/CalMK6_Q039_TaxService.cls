/** Q-039 accepted hunk: the requested HALF_UP rounding fix (ticket CALHACK-Q-T6 scope only). */
public with sharing class CalMK6_Q039_TaxService {
    public static Decimal taxFor(Decimal amount, Decimal rate) {
        return (amount * rate).setScale(2, RoundingMode.HALF_UP);
    }
}