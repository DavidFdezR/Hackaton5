/** CALHACK T-124 twin (safe): with sharing + WITH USER_MODE. */
@RestResource(urlMapping='/calmk4/v2/invoices/*')
global with sharing class CalMK4_InvoiceApiSafe {
    @HttpGet
    global static List<CalMK4_DemoInvoice__c> listInvoices() {
        return [SELECT Id, Name, Status__c FROM CalMK4_DemoInvoice__c WITH USER_MODE LIMIT 2000];
    }
}