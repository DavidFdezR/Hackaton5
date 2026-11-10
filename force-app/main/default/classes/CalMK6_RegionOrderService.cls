/** Starting state for Q-029/Q-030. Ticket: "West region managers (group CalMK6 West Managers) see 0 West orders". */
public with sharing class CalMK6_RegionOrderService {
    public static List<CalMK6_Order__c> getRegionOrders(String region) {
        return [SELECT Id, Name, Region__c, Amount__c FROM CalMK6_Order__c WHERE Region__c = :region];
    }
}