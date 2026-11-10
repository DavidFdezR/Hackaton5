/** CALHACK T-182: fee helper. roundFee is private; @TestVisible lets the unit test call it directly. */
public with sharing class CalMK4C_RefundMath {
    public static Decimal netRefund(Decimal gross) { return gross - roundFee(gross * 0.015); }
    @TestVisible
    private static Decimal roundFee(Decimal fee) { return fee.setScale(2, System.RoundingMode.HALF_UP); }
}