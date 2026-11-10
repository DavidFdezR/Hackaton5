/** Q-022 agent's own test: 150 orders, but all for ONE customer. Passes. */
@IsTest
private class CalMK6_Q022_DiscountServiceTest {
    @IsTest static void bulk150OrdersOneCustomer() {
        CalMK6_Customer__c c = new CalMK6_Customer__c(Name = 'CalMK6_Demo Gold A', Tier__c = 'Gold');
        insert c;
        List<CalMK6_Order__c> orders = new List<CalMK6_Order__c>();
        for (Integer i = 0; i < 150; i++) { orders.add(new CalMK6_Order__c(Name = 'CalMK6_O' + i, Customer__c = c.Id)); }
        Test.startTest();
        CalMK6_Q022_DiscountService.applyTierDiscount(orders);
        Integer used = Limits.getQueries();
        Test.stopTest();
        Assert.areEqual(1, used, 'one query for one customer');
        for (CalMK6_Order__c o : orders) { Assert.areEqual(10, o.Discount__c); }
    }
}