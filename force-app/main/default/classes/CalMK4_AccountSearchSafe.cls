/** CALHACK T-098 twin (safe): bind variable + WITH USER_MODE in a with sharing class. */
public with sharing class CalMK4_AccountSearchSafe {
    @AuraEnabled
    public static List<CalMK4_DemoAccount__c> find(String term) {
        String pattern = '%' + term + '%';
        return [SELECT Id, Name FROM CalMK4_DemoAccount__c WHERE Name LIKE :pattern WITH USER_MODE];
    }
}