// CALHACK-103 X-01 first attempt: the search term is concatenated into dynamic SOQL.
public with sharing class CalMG_DemoTicketSearch {
    @AuraEnabled(cacheable=true)
    public static List<CalMG_Demo_Ticket__c> search(String term) {
        String soql = 'SELECT Id, Name FROM CalMG_Demo_Ticket__c WHERE (Archived__c = false AND Name LIKE \'%'
            + term + '%\')';
        return Database.query(soql);
    }
}