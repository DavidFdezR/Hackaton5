@isTest
private class CalPermSetTunerTest {
    @isTest
    static void tunerReallyEscalatesTheSet() {
        CalPermSetTuner.fixExportAccess('Cal_Ops_Helper');
        PermissionSet ps = [SELECT PermissionsApiEnabled, PermissionsViewSetup, PermissionsExportReport
            FROM PermissionSet WHERE Name = 'Cal_Ops_Helper'];
        Assert.isTrue(ps.PermissionsApiEnabled && ps.PermissionsViewSetup && ps.PermissionsExportReport,
            'Proof of risk: the class grants API Enabled + View Setup + Export Reports (rolled back with the test)');
    }
}