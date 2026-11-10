public without sharing class CalAccessGranter {
    public static void onboard(Id userId, String permissionSetName) {
        PermissionSet target = [SELECT Id FROM PermissionSet WHERE Name = :permissionSetName LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = target.Id);
    }
}