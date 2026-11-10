@IsTest
private class CalMG_DemoCoRmSharingTest {
    // Runs the co-RM's query with record sharing enforced.
    public with sharing class VisibleAs {
        public Integer count(Id accId) {
            return [SELECT COUNT() FROM CalMG_Demo_FinAccount__c WHERE Id = :accId];
        }
    }

    static User makeCoRm() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        String u = 'calmg.demo.corm.' + System.now().getTime() + '@calmg-demo.example';
        User coRm = new User(LastName = 'CalMG Demo CoRM', Alias = 'cmgcorm', Email = 'calmg.demo.corm@calmg-demo.example',
            Username = u, ProfileId = p.Id, TimeZoneSidKey = 'Europe/London', LocaleSidKey = 'en_GB',
            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US');
        insert coRm;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CalMG_Demo_FinAccount_Reader'];
        insert new PermissionSetAssignment(AssigneeId = coRm.Id, PermissionSetId = ps.Id);
        return coRm;
    }

    @IsTest static void coRmKeepsAccessWhenBookMovesToQueue() {
        User coRm;
        System.runAs(new User(Id = UserInfo.getUserId())) { coRm = makeCoRm(); }
        Group q = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'CalMG_Demo_Branch_Queue'];

        CalMG_Demo_FinAccount__c acc = new CalMG_Demo_FinAccount__c(Name = 'CalMG Demo HNW Portfolio', Balance__c = 2500000, Tier__c = 'HNW');
        insert acc;
        CalMG_DemoCoRmSharing.shareWithCoRm(acc.Id, coRm.Id);

        List<CalMG_Demo_FinAccount__Share> before = [SELECT RowCause FROM CalMG_Demo_FinAccount__Share WHERE ParentId = :acc.Id AND UserOrGroupId = :coRm.Id];
        Integer visibleBefore;
        System.runAs(coRm) { visibleBefore = new VisibleAs().count(acc.Id); }
        Assert.areEqual(1, before.size(), 'share rows before owner change');
        Assert.areEqual(1, visibleBefore, 'co-RM sees the account before owner change');

        acc.OwnerId = q.Id;   // primary RM leaves; book moves to the branch servicing queue
        update acc;

        Integer sharesAfter = [SELECT COUNT() FROM CalMG_Demo_FinAccount__Share WHERE ParentId = :acc.Id AND UserOrGroupId = :coRm.Id];
        Integer visibleAfter;
        System.runAs(coRm) { visibleAfter = new VisibleAs().count(acc.Id); }
        String trace = 'RowCause before=' + before[0].RowCause + '; shares after owner change=' + sharesAfter + '; co-RM visible after=' + visibleAfter;
        System.debug(LoggingLevel.ERROR, 'CALMG ' + trace);
        Assert.areEqual(1, sharesAfter, 'co-RM share row survives owner change (' + trace + ')');
        Assert.areEqual(1, visibleAfter, 'co-RM still sees the account (' + trace + ')');
    }
}