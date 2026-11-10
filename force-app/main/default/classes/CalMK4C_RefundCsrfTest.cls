@IsTest
private class CalMK4C_RefundCsrfTest {
    @IsTest static void pageLoadActionWritesOnGet() {
        CalMK4C_DemoRefund__c r = new CalMK4C_DemoRefund__c(Name = 'CalMK4C Demo Refund CSRF', Amount__c = 10, Status__c = 'Pending');
        insert r;
        PageReference pg = Page.CalMK4C_RefundApprove;
        pg.getParameters().put('id', r.Id);
        Test.setCurrentPage(pg);
        new CalMK4C_RefundApproveCtrl().approve();   // what <apex:page action="{!approve}"> runs on every GET
        String st = [SELECT Status__c FROM CalMK4C_DemoRefund__c WHERE Id = :r.Id].Status__c;
        System.debug('CALMK4C_EVIDENCE page-load action status=' + st);
        System.assertEquals('Approved via page load', st);
    }
}