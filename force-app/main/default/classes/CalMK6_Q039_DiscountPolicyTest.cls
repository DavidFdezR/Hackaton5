@IsTest
private class CalMK6_Q039_DiscountPolicyTest {
    @IsTest static void goldIsTen() { Assert.areEqual(10, CalMK6_Q039_DiscountPolicy.pctFor('Gold')); }
    @IsTest static void otherIsZero() { Assert.areEqual(0, CalMK6_Q039_DiscountPolicy.pctFor('Silver')); }
}