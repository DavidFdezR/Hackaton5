/** CALHACK agent A (T-146/T-147). Controller for calMK4P_quoteSummaryCard / calMK4P_quoteDemoCard. */
public with sharing class CalMK4P_QuoteCardCtrl {
    @AuraEnabled(cacheable=true)
    public static CalMK4P_Quote__c getQuote(Id quoteId) {
        List<CalMK4P_Quote__c> rows = [SELECT Id, Name, Amount__c, Discount_Pct__c FROM CalMK4P_Quote__c WHERE Id = :quoteId WITH USER_MODE LIMIT 1];
        return rows.isEmpty() ? null : rows[0];
    }
}