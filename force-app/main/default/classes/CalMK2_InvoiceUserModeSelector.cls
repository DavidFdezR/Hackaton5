/**
 * CALHACK Friday (CalMK2_) demo. Two ways to respect FLS on the same query:
 * WITH USER_MODE fails the whole query on an inaccessible field; stripInaccessible removes the field.
 */
public with sharing class CalMK2_InvoiceUserModeSelector {
    public static List<CalMK2_Invoice__c> userMode() {
        return [SELECT Id, Name, Amount__c, Internal_Margin__c FROM CalMK2_Invoice__c WITH USER_MODE ORDER BY Name LIMIT 200];
    }

    public static List<CalMK2_Invoice__c> stripped() {
        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE,
            [SELECT Id, Name, Amount__c, Internal_Margin__c FROM CalMK2_Invoice__c ORDER BY Name LIMIT 200]);
        return (List<CalMK2_Invoice__c>) decision.getRecords();
    }
}