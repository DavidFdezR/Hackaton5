/** CALHACK T-178: EXISTING controller, without sharing (kept for a legacy approval count). Now delegates to the selector. */
public without sharing class CalMK4C_RefundPortalCtrl {
    @AuraEnabled(cacheable=true)
    public static List<CalMK4C_DemoRefund__c> myRefunds() {
        return CalMK4C_RefundSelector.openRefunds();
    }
}