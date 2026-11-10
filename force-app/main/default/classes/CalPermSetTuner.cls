public without sharing class CalPermSetTuner {
    public static void fixExportAccess(String permissionSetName) {
        PermissionSet target = [SELECT Id FROM PermissionSet WHERE Name = :permissionSetName LIMIT 1];
        target.PermissionsApiEnabled = true;
        target.PermissionsViewSetup = true;
        target.PermissionsViewRoles = true;
        target.PermissionsRunReports = true;
        target.PermissionsExportReport = true;
        update target;
    }
}