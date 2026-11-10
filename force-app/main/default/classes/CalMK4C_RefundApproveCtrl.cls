/** CALHACK T-176 (and RESERVE-1): approves the refund named in ?id= as soon as the page loads (apex:page action=). */
public with sharing class CalMK4C_RefundApproveCtrl {
    public CalMK4C_DemoRefund__c refund { get; private set; }
    public PageReference approve() {
        Id refundId = ApexPages.currentPage().getParameters().get('id');
        refund = [SELECT Id, Name, Status__c FROM CalMK4C_DemoRefund__c WHERE Id = :refundId];
        refund.Status__c = 'Approved via page load';
        update refund;
        return null;
    }
}