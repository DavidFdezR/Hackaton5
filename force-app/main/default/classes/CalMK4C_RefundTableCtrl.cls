/** CALHACK T-179: configurable datatable; the LWC sends the column list. Input is "sanitized" with escapeSingleQuotes. */
public with sharing class CalMK4C_RefundTableCtrl {
    @AuraEnabled
    public static List<SObject> getRows(String columns) {
        String soql = 'SELECT Id, ' + String.escapeSingleQuotes(columns) + ' FROM CalMK4C_DemoRefund__c ORDER BY Name';
        return Database.query(soql);
    }
}