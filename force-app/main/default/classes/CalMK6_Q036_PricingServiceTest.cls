/** Q-036 agent outcome: test fixed by turning on SeeAllData so it can read the org's reference record. */
@IsTest(SeeAllData=true)
private class CalMK6_Q036_PricingServiceTest {
    @IsTest static void goldDefaultIsTwelve() {
        Assert.areEqual(12, CalMK6_PricingService.goldDefaultDiscount());
    }
}