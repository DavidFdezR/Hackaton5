// CALHACK-103 R-02 shared test: a user holding only CalMG_Demo_Rule_Editor moves an item down one place.
@isTest
private class CalMG_DemoRuleOrderServiceTest {
    private static User makeEditor() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Minimum Access - Salesforce' LIMIT 1];
        String stamp = String.valueOf(Datetime.now().getTime());
        User u = new User(
            LastName = 'CalMG Demo Editor', Alias = 'calmgr02', Email = 'calmg.r02@demo.example',
            Username = 'calmg.r02.' + stamp + '@demo.example', ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US');
        insert u;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CalMG_Demo_Rule_Editor'];
        insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
        return u;
    }

    @isTest
    static void editorMovesItemDown() {
        User editor;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            editor = makeEditor();
        }
        CalMG_Demo_Rule__c rule = new CalMG_Demo_Rule__c(Name = 'CalMG Demo Rule R02');
        insert rule;
        CalMG_Demo_Rule_Item__c item = new CalMG_Demo_Rule_Item__c(
            Name = 'CalMG Demo Item 1', CalMG_Demo_Rule__c = rule.Id, Order__c = 1);
        insert item;

        Test.startTest();
        System.runAs(editor) {
            CalMG_DemoRuleOrderService.moveDown(item.Id);
        }
        Test.stopTest();

        Assert.areEqual(2, [SELECT Order__c FROM CalMG_Demo_Rule_Item__c WHERE Id = :item.Id].Order__c,
            'order should increase by one');
    }

    @isTest
    static void masterDetailFieldIsNotUpdateable() {
        Assert.isFalse(CalMG_Demo_Rule_Item__c.CalMG_Demo_Rule__c.getDescribe().isUpdateable(),
            'non-reparentable master-detail must report isUpdateable() = false');
    }
}