/** CALHACK T-177: custom Apex save replacing lightning-record-edit-form. The LWC only shows Amount and Notes. */
public with sharing class CalMK4C_RefundFormCtrl {
    @AuraEnabled
    public static void saveRefund(CalMK4C_DemoRefund__c refund) {
        update refund;   // system-mode DML: whatever fields the client sends are written
    }
}