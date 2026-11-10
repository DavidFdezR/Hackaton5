/** CALHACK T-107/T-108 probe: proves the risky permissions can be put in a permission set and assigned (rolled back). */
@IsTest
private class CalMK4_PermGrantProbeTest {
    static String tryGrant(String label, PermissionSet ps, Id userId) {
        Database.SaveResult s = Database.insert(ps, false);
        if (!s.isSuccess()) { return label + ' PS insert FAILED ' + s.getErrors(); }
        Database.SaveResult a = Database.insert(new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = ps.Id), false);
        return label + ' PS insert ok; assign ' + (a.isSuccess() ? 'ok' : 'FAILED ' + a.getErrors());
    }
    @IsTest static void riskyPermissionsAreGrantable() {
        System.runAs(CalMK4_TestUsers.me()) {
            User u = CalMK4_TestUsers.make('ops', null, 'Standard User');
            String e1 = tryGrant('Weekly Export Data', new PermissionSet(Name = 'CalMK4_RT_Export', Label = 'CalMK4 RT Export', PermissionsDataExport = true), u.Id);
            String e2 = tryGrant('Modify Metadata', new PermissionSet(Name = 'CalMK4_RT_ModMeta', Label = 'CalMK4 RT ModMeta', PermissionsModifyMetadata = true, PermissionsViewSetup = true, PermissionsViewRoles = true), u.Id);
            System.debug('CALMK4_EVIDENCE probe ' + e1);
            System.debug('CALMK4_EVIDENCE probe ' + e2);
            System.assert(e1.contains('assign ok'), e1);
            System.assert(e2.contains('assign ok'), e2);
        }
    }
}