@IsTest
private class CalMK4_TransferRecordTest {
    @IsTest static void readOnlyUserTakesOwnershipOnceTransferRecordIsGranted() {
        CalMK4_DemoAsset__c a = new CalMK4_DemoAsset__c(Name = 'CalMK4 Demo Asset Finance', Status__c = 'Active');
        insert a; // owned by admin; OWD Public Read Only
        User sup;
        System.runAs(CalMK4_TestUsers.me()) {
            sup = CalMK4_TestUsers.make('support');
            CalMK4_TestUsers.grant(sup.Id, 'CalMK4_DemoSupport_PS');
        }
        Database.SaveResult before;
        System.runAs(sup) {
            before = Database.update(new CalMK4_DemoAsset__c(Id = a.Id, OwnerId = sup.Id), false, AccessLevel.USER_MODE);
            System.debug('CALMK4_EVIDENCE without Transfer Record: success=' + before.isSuccess() + ' ' + before.getErrors());
        }
        System.runAs(CalMK4_TestUsers.me()) {
            PermissionSet tr = new PermissionSet(Name = 'CalMK4_RT_TransferRecord', Label = 'CalMK4 RT Transfer Record', PermissionsTransferAnyEntity = true);
            insert tr;
            insert new PermissionSetAssignment(AssigneeId = sup.Id, PermissionSetId = tr.Id);
        }
        System.runAs(sup) {
            Database.SaveResult take = Database.update(new CalMK4_DemoAsset__c(Id = a.Id, OwnerId = sup.Id), false, AccessLevel.USER_MODE);
            System.debug('CALMK4_EVIDENCE with Transfer Record: take ownership success=' + take.isSuccess() + ' ' + take.getErrors());
            Database.SaveResult edit = Database.update(new CalMK4_DemoAsset__c(Id = a.Id, Status__c = 'Retired'), false, AccessLevel.USER_MODE);
            System.debug('CALMK4_EVIDENCE after taking ownership: edit success=' + edit.isSuccess() + ' ' + edit.getErrors());
            System.assertEquals(false, before.isSuccess(), 'read-only sharing blocks the owner change');
            System.assertEquals(true, take.isSuccess(), 'Transfer Record lets a read-only user move the record to themselves');
            System.assertEquals(true, edit.isSuccess(), 'new owner now has full access');
        }
    }
}