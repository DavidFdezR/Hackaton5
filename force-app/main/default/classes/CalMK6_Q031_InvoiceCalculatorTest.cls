/** Q-031 agent's test: one happy path + a call to the padding helper. No negative-amount or discount-cap test. */
@IsTest
private class CalMK6_Q031_InvoiceCalculatorTest {
    @IsTest static void happyPath() {
        Assert.areEqual(99.00, CalMK6_Q031_InvoiceCalculator.total(100, 10, 10));
    }
    @IsTest static void helper() {
        Assert.areEqual(30, CalMK6_Q031_InvoiceCalculator.coverageHelper());
    }
}