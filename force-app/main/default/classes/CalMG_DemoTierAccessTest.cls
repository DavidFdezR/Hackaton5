// CALHACK-103 X-05 shared test: a Minimum Access in-test user gets CalMG_Demo_Tier_Access if it exists,
// then must be able to see and read CalMG_Demo_Tier__c.
@isTest
private class CalMG_DemoTierAccessTest {
    @isTest
    static void tierFieldIsUsable() {
        User u;
        Integer permSets = 0;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Profile p = [SELECT Id FROM Profile WHERE Name = 'Minimum Access - Salesforce' LIMIT 1];
            u = new User(
                LastName = 'CalMG Demo Tier User', Alias = 'calmgx05', Email = 'calmg.x05@demo.example',
                Username = 'calmg.x05.' + Datetime.now().getTime() + '@demo.example', ProfileId = p.Id,
                TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US');
            insert u;
            for (PermissionSet ps : [SELECT Id FROM PermissionSet WHERE Name = 'CalMG_Demo_Tier_Access']) {
                insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
                permSets++;
            }
        }
        CalMG_Demo_Client__c c = new CalMG_Demo_Client__c(Name = 'CalMG Demo Client 1', CalMG_Demo_Tier__c = 'Gold', OwnerId = u.Id);
        insert c;
        System.runAs(u) {
            Boolean visible = Schema.SObjectType.CalMG_Demo_Client__c.fields.CalMG_Demo_Tier__c.isAccessible();
            Assert.isTrue(visible, 'CalMG_Demo_Tier__c isAccessible() for the user; CalMG_Demo_Tier_Access found = ' + permSets);
            CalMG_Demo_Client__c row = [SELECT CalMG_Demo_Tier__c FROM CalMG_Demo_Client__c WHERE Id = :c.Id WITH USER_MODE];
            Assert.areEqual('Gold', row.CalMG_Demo_Tier__c, 'user reads the tier');
        }
    }
}