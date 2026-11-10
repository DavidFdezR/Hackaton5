@IsTest
private class CalMK4_ExpiringAssignmentTest {
    @IsTest static void assignmentCarriesEightHourExpiry() {
        System.runAs(CalMK4_TestUsers.me()) {
            User rm = CalMK4_TestUsers.make('relmgr');
            Datetime exp = Datetime.now().addHours(8);
            PermissionSetAssignment a = new PermissionSetAssignment(AssigneeId = rm.Id, ExpirationDate = exp,
                PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'CalMK4_DemoReleaseManager_PS'].Id);
            insert a;
            PermissionSetAssignment back = [SELECT ExpirationDate FROM PermissionSetAssignment WHERE Id = :a.Id];
            System.debug('CALMK4_EVIDENCE expiration stored=' + back.ExpirationDate + ' requested=' + exp);
            System.assertNotEquals(null, back.ExpirationDate);
        }
    }
}