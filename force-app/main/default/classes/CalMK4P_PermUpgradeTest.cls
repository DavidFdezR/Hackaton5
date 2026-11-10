/**
 * CALHACK T-154/T-155: what the Modify All grant does for an EXISTING assignee of the packaged
 * perm set (T-154) vs a NEW, unassigned perm set (T-155). Rolled back; one Platform user.
 */
@isTest
private class CalMK4P_PermUpgradeTest {
    @isTest static void modifyAllWidensExistingAssigneesOnly() {
        CalMK4P_Quote__c other = new CalMK4P_Quote__c(Name = 'CalMK4P Quote Owned By Someone Else', Amount__c = 5000, Discount_Pct__c = 35);
        insert other;
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard Platform User' LIMIT 1];
        User rep = new User(Alias = 'cmk4p', Email = 'calmk4p.rep@demo.example', EmailEncodingKey = 'UTF-8',
            LastName = 'CalMK4P Rep', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles', Username = 'calmk4p.rep.' + System.now().getTime() + '@demo.example');
        Id adminPs = [SELECT Id FROM PermissionSet WHERE Name = 'CalMK4P_QuoteAdmin'].Id;
        Id bulkPs = [SELECT Id FROM PermissionSet WHERE Name = 'CalMK4P_QuoteBulkEditor'].Id;
        User me = new User(Id = UserInfo.getUserId());
        System.runAs(me) {
            insert rep;
            insert new PermissionSetAssignment(AssigneeId = rep.Id, PermissionSetId = adminPs);
        }
        Integer before;
        System.runAs(rep) { before = [SELECT COUNT() FROM CalMK4P_Quote__c]; }
        // the new perm set exists in the org but nobody holds it yet
        Integer bulkHolders = [SELECT COUNT() FROM PermissionSetAssignment WHERE PermissionSetId = :bulkPs];
        // simulate the upgrade outcome: the existing assignee now also holds Modify All
        System.runAs(me) { insert new PermissionSetAssignment(AssigneeId = rep.Id, PermissionSetId = bulkPs); }
        Integer afterGrant;
        System.runAs(rep) { afterGrant = [SELECT COUNT() FROM CalMK4P_Quote__c]; }
        System.debug('CALMK4P_EVIDENCE quoteAdminOnly=' + before + ' bulkEditorHoldersBefore=' + bulkHolders + ' withModifyAll=' + afterGrant);
        System.assertEquals(0, before, 'QuoteAdmin alone must not see quotes it does not own (Private OWD)');
        System.assertEquals(0, bulkHolders, 'new perm set is unassigned until an admin assigns it');
        System.assertEquals(1, afterGrant, 'Modify All bypasses sharing');
    }
}