/** Q-023 tests: 200 orders across 200 distinct customers (100 Gold, 100 Silver) + an order with no customer. */
@IsTest
private class CalMK6_Q023_DiscountServiceTest {
    @IsTest static void bulk200DistinctCustomersOneQuery() {
        List<CalMK6_Customer__c> cs = new List<CalMK6_Customer__c>();
        for (Integer i = 0; i < 200; i++) { cs.add(new CalMK6_Customer__c(Name = 'CalMK6_Demo C' + i, Tier__c = Math.mod(i, 2) == 0 ? 'Gold' : 'Silver')); }
        insert cs;
        List<CalMK6_Order__c> orders = new List<CalMK6_Order__c>();
        for (Integer i = 0; i < 200; i++) { orders.add(new CalMK6_Order__c(Name = 'CalMK6_O' + i, Customer__c = cs[i].Id)); }
        Test.startTest();
        CalMK6_Q023_DiscountService.applyTierDiscount(orders);
        Integer used = Limits.getQueries();
        Test.stopTest();
        Assert.areEqual(1, used, 'exactly one SOQL regardless of customer count');
        Integer gold = 0;
        for (CalMK6_Order__c o : orders) { if (o.Discount__c == 10) { gold++; } }
        Assert.areEqual(100, gold);
    }
    @IsTest static void orderWithoutCustomerGetsZero() {
        List<CalMK6_Order__c> orders = new List<CalMK6_Order__c>{ new CalMK6_Order__c(Name = 'CalMK6_Orphan') };
        CalMK6_Q023_DiscountService.applyTierDiscount(orders);
        Assert.areEqual(0, orders[0].Discount__c);
    }
}