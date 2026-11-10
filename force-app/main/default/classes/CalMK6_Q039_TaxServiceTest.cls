@IsTest
private class CalMK6_Q039_TaxServiceTest {
    @IsTest static void spec101_25At10Pct() { Assert.areEqual(10.13, CalMK6_Q039_TaxService.taxFor(101.25, 0.10)); }
    @IsTest static void wholeCents() { Assert.areEqual(10.00, CalMK6_Q039_TaxService.taxFor(100, 0.10)); }
}