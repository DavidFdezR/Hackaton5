public without sharing class CalMK1_InvoiceExport {
    public static List<CalMK1_Invoice__c> rowsForRegion(String region) {
        return [SELECT Id, Name, CalMK1_Amount__c FROM CalMK1_Invoice__c WHERE CalMK1_Region__c = :region ORDER BY Name LIMIT 500];
    }
}