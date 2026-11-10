/** CALHACK round 2 probe: which prerequisites does Salesforce demand for each permission (all rolled back). */
@IsTest
private class CalMK4_PermPrereqProbeTest {
    @IsTest static void probe() {
        List<String> perms = new List<String>{ 'PermissionsAssignPermissionSets', 'PermissionsViewAllData', 'PermissionsBulkApiHardDelete',
            'PermissionsQueryAllFiles', 'PermissionsViewAllCustomSettings', 'PermissionsManageProfilesPermissionsets', 'PermissionsEditReadonlyFields', 'PermissionsManageSharing' };
        Integer i = 0;
        for (String p : perms) {
            PermissionSet ps = new PermissionSet(Name = 'CalMK4_RT_Probe' + (i++), Label = 'CalMK4 RT Probe ' + i);
            ps.put(p, true);
            Database.SaveResult r = Database.insert(ps, false);
            System.debug('CALMK4_EVIDENCE prereq ' + p + ' -> ' + (r.isSuccess() ? 'insert ok alone' : String.valueOf(r.getErrors()[0].getMessage())));
        }
    }
}