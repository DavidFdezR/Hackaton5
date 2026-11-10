/** Q-023 agent outcome: collect Ids, one query, map lookup. */
public with sharing class CalMK6_Q023_DiscountService {
    public static void applyTierDiscount(List<CalMK6_Order__c> orders) {
        Set<Id> customerIds = new Set<Id>();
        for (CalMK6_Order__c o : orders) { if (o.Customer__c != null) { customerIds.add(o.Customer__c); } }
        Map<Id, CalMK6_Customer__c> byId = new Map<Id, CalMK6_Customer__c>(
            [SELECT Id, Tier__c FROM CalMK6_Customer__c WHERE Id IN :customerIds]);
        for (CalMK6_Order__c o : orders) {
            CalMK6_Customer__c c = byId.get(o.Customer__c);
            o.Discount__c = (c != null && c.Tier__c == 'Gold') ? 10 : 0;
        }
    }
}