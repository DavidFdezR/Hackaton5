@IsTest
private class CalMK4C_RefundMathTest {
    @IsTest static void roundFeeDirectly() {
        System.assertEquals(1.24, CalMK4C_RefundMath.roundFee(1.235));
        System.assertEquals(98.50, CalMK4C_RefundMath.netRefund(100));
    }
}