/**
 * CALHACK Friday (CalMK2_) demo. "with sharing" controller used by an invoice LWC.
 * Planted gap: the query returns Internal_Margin__c with no CRUD/FLS check. with sharing enforces
 * record sharing only, not field-level security.
 */
public with sharing class CalMK2_InvoiceService {
    @AuraEnabled(cacheable=true)
    public static List<CalMK2_Invoice__c> getInvoicesWithMargin() {
        return [SELECT Id, Name, Amount__c, Internal_Margin__c FROM CalMK2_Invoice__c ORDER BY Name LIMIT 200];
    }

    public static Integer countVisible() {
        return [SELECT COUNT() FROM CalMK2_Invoice__c];
    }
}