/** CALHACK T-177 contrast: the same save in user mode (what lightning-record-edit-form / LDS would enforce). */
public with sharing class CalMK4C_RefundFormCtrlSafe {
    @AuraEnabled
    public static void saveRefund(CalMK4C_DemoRefund__c refund) {
        update as user refund;
    }
}