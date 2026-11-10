/** Starting state for Q-022/Q-023. Ticket: "bulk load of 150 orders fails with Too many SOQL queries: 101". */
public with sharing class CalMK6_DiscountService {
    public static void applyTierDiscount(List<CalMK6_Order__c> orders) {
        for (CalMK6_Order__c o : orders) {
            CalMK6_Customer__c c = [SELECT Id, Tier__c FROM CalMK6_Customer__c WHERE Id = :o.Customer__c];
            o.Discount__c = (c.Tier__c == 'Gold') ? 10 : 0;
        }
    }
}