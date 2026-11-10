/** CALHACK T-097 (planted, bad on purpose): user input concatenated into dynamic SOQL, without sharing. */
public without sharing class CalMK4_AccountSearch {
    @AuraEnabled
    public static List<CalMK4_DemoAccount__c> find(String term) {
        String q = 'SELECT Id, Name FROM CalMK4_DemoAccount__c WHERE Name LIKE \'%' + term + '%\'';
        return Database.query(q);
    }
}