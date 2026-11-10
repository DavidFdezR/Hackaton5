/** CALHACK T-122 proposed change: same with sharing controller but WITH SYSTEM_MODE (sharing still applies, CRUD/FLS do not). */
public with sharing class CalMK4_InvoiceCtrlSys {
    @AuraEnabled(cacheable=true)
    public static List<CalMK4_DemoInvoice__c> getInvoices() {
        return [SELECT Id, Name, Status__c, Amount__c FROM CalMK4_DemoInvoice__c WITH SYSTEM_MODE];
    }
}