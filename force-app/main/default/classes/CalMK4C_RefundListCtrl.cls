/** CALHACK T-178 contrast: a with sharing caller of the same selector. */
public with sharing class CalMK4C_RefundListCtrl {
    @AuraEnabled(cacheable=true)
    public static List<CalMK4C_DemoRefund__c> myRefunds() {
        return CalMK4C_RefundSelector.openRefunds();
    }
}