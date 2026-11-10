public with sharing class CalMK1_InvoiceController {
    @AuraEnabled(cacheable=true)
    public static List<CalMK1_Invoice__c> getOpenInvoices(String region) {
        return [SELECT Id, Name, CalMK1_Amount__c FROM CalMK1_Invoice__c WHERE CalMK1_Region__c = :region ORDER BY Name LIMIT 200];
    }
    @AuraEnabled(cacheable=true)
    public static Integer countInvoices() {
        return [SELECT COUNT() FROM CalMK1_Invoice__c WITH USER_MODE];
    }
}