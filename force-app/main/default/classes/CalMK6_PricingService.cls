/** Starting state for Q-036: reads the reference customer 'CalMK6_Demo Gold Reference' for the default Gold discount. */
public with sharing class CalMK6_PricingService {
    public static Decimal goldDefaultDiscount() {
        CalMK6_Customer__c ref = [SELECT Default_Discount__c FROM CalMK6_Customer__c WHERE Name = 'CalMK6_Demo Gold Reference' LIMIT 1];
        return ref.Default_Discount__c;
    }
}