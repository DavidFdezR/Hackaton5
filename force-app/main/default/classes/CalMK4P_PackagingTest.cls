@isTest
private class CalMK4P_PackagingTest {
    @isTest static void netPriceAppliesDiscount() {
        System.assertEquals(90.00, CalMK4P_QuotePricingService.netPrice(100, 10));
        System.assertEquals(0, CalMK4P_QuotePricingService.netPrice(null, 10));
    }
    @isTest static void controllerReturnsOwnQuote() {
        CalMK4P_Quote__c q = new CalMK4P_Quote__c(Name = 'CalMK4P Demo Quote Test', Amount__c = 100, Discount_Pct__c = 5);
        insert q;
        // running user gets the packaged perm set only inside the (rolled-back) test
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CalMK4P_QuoteAdmin'];
        insert new PermissionSetAssignment(AssigneeId = UserInfo.getUserId(), PermissionSetId = ps.Id);
        System.runAs(new User(Id = UserInfo.getUserId())) {
            System.assertEquals(q.Id, CalMK4P_QuoteCardCtrl.getQuote(q.Id).Id);
        }
    }
}