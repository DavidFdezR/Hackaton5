@IsTest
private class CalMG_DemoRateRepricerTest {
    static User makeIntegrationUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(LastName = 'CalMG Demo RateFeed', Alias = 'cmgrate', Email = 'calmg.demo.ratefeed@calmg-demo.example',
            Username = 'calmg.demo.ratefeed.' + System.now().getTime() + '@calmg-demo.example', ProfileId = p.Id,
            TimeZoneSidKey = 'Europe/London', LocaleSidKey = 'en_GB', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US');
        insert u;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CalMG_Demo_Loan_Editor'];
        insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
        return u;
    }

    // Admin inserts two loans and submits one for credit approval (record locked on submit).
    static List<CalMG_Demo_Loan__c> makeLoans() {
        CalMG_Demo_Loan__c inReview = new CalMG_Demo_Loan__c(Name = 'CalMG Demo Loan In Review', Amount__c = 250000, Interest_Rate__c = 5.25, Status__c = 'Submitted');
        CalMG_Demo_Loan__c open = new CalMG_Demo_Loan__c(Name = 'CalMG Demo Loan Open', Amount__c = 120000, Interest_Rate__c = 5.25, Status__c = 'Draft');
        insert new List<CalMG_Demo_Loan__c>{ inReview, open };
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(inReview.Id);
        req.setComments('CalMG demo credit review');
        req.setNextApproverIds(new List<Id>{ UserInfo.getUserId() });
        Approval.ProcessResult pr = Approval.process(req);
        Assert.isTrue(pr.isSuccess(), 'submission succeeded');
        Assert.areEqual(1, [SELECT COUNT() FROM ProcessInstance WHERE TargetObjectId = :inReview.Id AND Status = 'Pending'], 'pending approval');
        return new List<CalMG_Demo_Loan__c>{ inReview, open };
    }

    // Approval.isLocked is not used here: in this org it throws NoAccessException
    // ("Apex approval lock/unlock api preference not enabled"), see evidence 02b.
    @IsTest static void nightlyRepriceAsIntegrationUser() {
        User integ;
        System.runAs(new User(Id = UserInfo.getUserId())) { integ = makeIntegrationUser(); }
        List<CalMG_Demo_Loan__c> loans = makeLoans();
        Id inReviewId = loans[0].Id, openId = loans[1].Id;

        String err = 'none';
        List<Id> pending;
        Test.startTest();
        System.runAs(integ) {
            try {
                pending = CalMG_DemoRateRepricer.reprice(new Set<Id>{ inReviewId, openId }, 4.75);
            } catch (Exception e) {
                err = e.getTypeName() + ': ' + e.getMessage();
            }
        }
        Test.stopTest();

        Map<Id, CalMG_Demo_Loan__c> after = new Map<Id, CalMG_Demo_Loan__c>([SELECT Id, Interest_Rate__c FROM CalMG_Demo_Loan__c]);
        String trace = 'exception=' + err + '; open rate=' + after.get(openId).Interest_Rate__c + '; in-review rate=' + after.get(inReviewId).Interest_Rate__c
            + '; in-review pending approvals=' + [SELECT COUNT() FROM ProcessInstance WHERE TargetObjectId = :inReviewId AND Status = 'Pending'] + '; pending=' + (pending == null ? 'n/a' : String.valueOf(pending.size()));
        System.debug(LoggingLevel.ERROR, 'CALMG ' + trace);
        Assert.areEqual('none', err, 'reprice must not throw (' + trace + ')');
        Assert.areEqual(4.75, after.get(openId).Interest_Rate__c, 'open loan repriced (' + trace + ')');
        Assert.areEqual(5.25, after.get(inReviewId).Interest_Rate__c, 'loan in credit review keeps its rate (' + trace + ')');
        Assert.areEqual(new List<Id>{ inReviewId }, pending, 'locked loan returned as pending (' + trace + ')');
    }

    // Why it passes when an admin tries it: the running admin can update the locked loan directly.
    @IsTest static void adminCanEditLockedLoan() {
        List<CalMG_Demo_Loan__c> loans = makeLoans();
        update new CalMG_Demo_Loan__c(Id = loans[0].Id, Interest_Rate__c = 4.75);
        Assert.areEqual(4.75, [SELECT Interest_Rate__c FROM CalMG_Demo_Loan__c WHERE Id = :loans[0].Id].Interest_Rate__c, 'admin edit on locked loan');
        Assert.areEqual(1, [SELECT COUNT() FROM ProcessInstance WHERE TargetObjectId = :loans[0].Id AND Status = 'Pending'], 'still in approval after admin edit');
    }
}