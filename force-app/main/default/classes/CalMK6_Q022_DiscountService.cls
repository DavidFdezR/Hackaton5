/** Q-022 agent outcome: "fix" caches each customer after its first query. Still one SOQL per DISTINCT customer. */
public with sharing class CalMK6_Q022_DiscountService {
    private static Map<Id, CalMK6_Customer__c> cache = new Map<Id, CalMK6_Customer__c>();
    public static void applyTierDiscount(List<CalMK6_Order__c> orders) {
        for (CalMK6_Order__c o : orders) {
            if (!cache.containsKey(o.Customer__c)) {
                cache.put(o.Customer__c, [SELECT Id, Tier__c FROM CalMK6_Customer__c WHERE Id = :o.Customer__c]);
            }
            o.Discount__c = (cache.get(o.Customer__c).Tier__c == 'Gold') ? 10 : 0;
        }
    }
}