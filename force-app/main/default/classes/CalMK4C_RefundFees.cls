/** CALHACK T-185: refund processing fee. HOTFIX in org (INC demo): 1.5% (was 2.5%). */
public with sharing class CalMK4C_RefundFees {
    public static final Decimal FEE_RATE = 0.015;
    public static Decimal fee(Decimal gross) { return (gross * FEE_RATE).setScale(2); }
}