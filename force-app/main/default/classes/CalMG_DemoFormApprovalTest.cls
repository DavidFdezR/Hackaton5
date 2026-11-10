// CALHACK-103 R-05 shared test: a second user approves a form created by the running user.
@isTest
private class CalMG_DemoFormApprovalTest {
    private static User makeApprover() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        String stamp = String.valueOf(Datetime.now().getTime());
        User u = new User(
            LastName = 'CalMG Demo Approver', Alias = 'calmgr05', Email = 'calmg.r05@demo.example',
            Username = 'calmg.r05.' + stamp + '@demo.example', ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US');
        insert u;
        return u;
    }

    // FIRST ATTEMPT: the form is created after Test.startTest(), in the same block as the callout.
    @isTest
    static void secondUserApprovesForm() {
        User approver;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            approver = makeApprover();
        }
        Test.startTest();
        CalMG_Demo_Form__c form = new CalMG_Demo_Form__c(Name = 'CalMG Demo Form R05', Status__c = 'Submitted');
        insert form;
        Test.setMock(HttpCalloutMock.class, new CalMG_DemoHttpMock());
        CalMG_Demo_Form__c result;
        System.runAs(approver) {
            result = CalMG_DemoFormApprovalController.approve(form.Id);
        }
        Test.stopTest();
        CalMG_Demo_Form__c got = [SELECT Status__c, Erp_Ref__c FROM CalMG_Demo_Form__c WHERE Id = :form.Id];
        Assert.areEqual('Approved', got.Status__c);
        Assert.areEqual('ERP-DEMO-001', got.Erp_Ref__c, 'mocked ERP reference applied');
    }
}