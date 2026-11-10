@IsTest
private class CalMK4_ViewAllUsersTest {
    @IsTest static void viewAllUsersAddsNothingWhileInternalUserOwdIsPublicRead() {
        Integer total = [SELECT COUNT() FROM User];
        Integer internalActive = [SELECT COUNT() FROM User WHERE UserType = 'Standard'];
        User hd;
        System.runAs(CalMK4_TestUsers.me()) {
            hd = CalMK4_TestUsers.make('helpdsk', null, 'Standard User'); // View All Users needs a Salesforce licence
            CalMK4_TestUsers.grant(hd.Id, 'CalMK4_DemoHelpdesk_PS');
        }
        Integer before; Integer beforeInternal;
        System.runAs(hd) {
            before = [SELECT COUNT() FROM User WITH USER_MODE];
            beforeInternal = [SELECT COUNT() FROM User WHERE UserType = 'Standard' WITH USER_MODE];
        }
        System.runAs(CalMK4_TestUsers.me()) {
            PermissionSet v = new PermissionSet(Name = 'CalMK4_RT_ViewAllUsers', Label = 'CalMK4 RT View All Users', PermissionsViewAllUsers = true);
            insert v;
            insert new PermissionSetAssignment(AssigneeId = hd.Id, PermissionSetId = v.Id);
        }
        Integer after; Integer afterInternal;
        System.runAs(hd) {
            after = [SELECT COUNT() FROM User WITH USER_MODE];
            afterInternal = [SELECT COUNT() FROM User WHERE UserType = 'Standard' WITH USER_MODE];
        }
        System.debug('CALMK4_EVIDENCE users total=' + total + ' internal=' + internalActive + ' | helpdesk sees before=' + before + ' (internal ' + beforeInternal + ') after View All Users=' + after + ' (internal ' + afterInternal + ')');
        System.assertEquals(beforeInternal, afterInternal, 'internal user visibility unchanged');
    }
}