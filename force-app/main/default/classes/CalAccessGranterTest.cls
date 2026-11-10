@isTest
private class CalAccessGranterTest {
    @isTest
    static void granterReallyAssignsTheSet() {
        Id me = UserInfo.getUserId();
        CalAccessGranter.onboard(me, 'Cal_Ops_Helper');
        Assert.areEqual(1, [SELECT COUNT() FROM PermissionSetAssignment
            WHERE AssigneeId = :me AND PermissionSet.Name = 'Cal_Ops_Helper'],
            'Proof of risk: the class assigns the set (rolled back with the test)');
    }
}