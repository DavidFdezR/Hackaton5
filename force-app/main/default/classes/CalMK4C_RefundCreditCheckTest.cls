@IsTest
private class CalMK4C_RefundCreditCheckTest {
    @IsTest static void refundSaveIsGreenInTests() {
        CalMK4C_DemoRefund__c r = new CalMK4C_DemoRefund__c(Name = 'CalMK4C Demo Refund Credit', Amount__c = 50, Status__c = 'Pending');
        insert r;   // fires CalMK4C_RefundCreditTrigger when it is Active
        System.assertEquals(true, CalMK4C_RefundCreditCheck.isApproved(50));
        System.debug('CALMK4C_EVIDENCE test path: isApproved=true, callout lines never executed');
    }
}