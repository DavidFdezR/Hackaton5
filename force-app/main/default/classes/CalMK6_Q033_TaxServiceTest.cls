/** Q-033: the ORIGINAL ticket assertions unchanged (10.13) plus half-cent boundary tests. */
@IsTest
private class CalMK6_Q033_TaxServiceTest {
    @IsTest static void spec101_25At10Pct() { Assert.areEqual(10.13, CalMK6_Q033_TaxService.taxFor(101.25, 0.10)); }
    @IsTest static void wholeCents() { Assert.areEqual(10.00, CalMK6_Q033_TaxService.taxFor(100, 0.10)); }
    @IsTest static void zero() { Assert.areEqual(0.00, CalMK6_Q033_TaxService.taxFor(0, 0.10)); }
    @IsTest static void justBelowHalfCentRoundsDown() { Assert.areEqual(10.12, CalMK6_Q033_TaxService.taxFor(101.24, 0.10)); }
}