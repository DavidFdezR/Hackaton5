/** CALHACK T-181: credit check before a refund is created. Planted INACTIVE. */
trigger CalMK4C_RefundCreditTrigger on CalMK4C_DemoRefund__c (before insert) {
    for (CalMK4C_DemoRefund__c r : Trigger.new) {
        if (!CalMK4C_RefundCreditCheck.isApproved(r.Amount__c)) {
            r.addError('Credit bureau declined this refund.');
        }
    }
}