@RestResource(urlMapping='/calmk1/invoices/*')
global with sharing class CalMK1_InvoiceApi {
    @HttpGet
    global static Integer doGet() {
        return [SELECT COUNT() FROM CalMK1_Invoice__c WITH USER_MODE];
    }
    @HttpPost
    global static String doPost(String name, String region) {
        CalMK1_Invoice__c inv = new CalMK1_Invoice__c(Name = name, CalMK1_Region__c = region);
        insert inv;
        return inv.Id;
    }
}