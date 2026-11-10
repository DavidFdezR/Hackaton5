/** CALHACK T-123 (planted, bad on purpose): Apex REST without sharing returns every invoice incl. amounts and billing contacts. */
@RestResource(urlMapping='/calmk4/invoices/*')
global without sharing class CalMK4_InvoiceApi {
    @HttpGet
    global static List<CalMK4_DemoInvoice__c> listInvoices() {
        return [SELECT Id, Name, Status__c, Amount__c, Billing_Contact__c FROM CalMK4_DemoInvoice__c LIMIT 2000];
    }
}