/**
 * CALHACK agent A (T-148/T-149/T-150). Stands in for a class inside a 2GP managed package.
 * Pre-change state: PUBLIC (not global, no @NamespaceAccessible). Subscribers cannot see or call it.
 */
public with sharing class CalMK4P_QuotePricingService {
    public static Decimal netPrice(Decimal amount, Decimal discountPct) {
        if (amount == null) { return 0; }
        Decimal pct = discountPct == null ? 0 : discountPct;
        return (amount * (1 - pct / 100)).setScale(2);
    }
}