public with sharing class CalMK1_InvoiceSummaryCtrl {
    public Integer getVisibleCount() { return [SELECT COUNT() FROM CalMK1_Invoice__c WITH USER_MODE]; }
}