/** CALHACK T-122 pre-change: with sharing @AuraEnabled controller, WITH USER_MODE (sharing + CRUD + FLS enforced). */
public with sharing class CalMK4_InvoiceCtrl {
    @AuraEnabled(cacheable=true)
    public static List<CalMK4_DemoInvoice__c> getInvoices() {
        return [SELECT Id, Name, Status__c, Amount__c FROM CalMK4_DemoInvoice__c WITH USER_MODE];
    }
}