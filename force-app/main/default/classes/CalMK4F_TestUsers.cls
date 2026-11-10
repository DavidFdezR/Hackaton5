/** CALHACK round3 B (CalMK4F_) test helper: demo users and test-only permission sets, all rolled back with the test. */
@IsTest
public class CalMK4F_TestUsers {
    public static User make(String tag) { return make(tag, null); }
    public static User make(String tag, Id roleId) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard Platform User' LIMIT 1];
        String rnd = String.valueOf(Math.abs(Crypto.getRandomInteger()));
        User u = new User(Alias = ('mk4f' + tag).left(8), Email = 'demo.' + tag + '@calmk4f.example',
            EmailEncodingKey = 'UTF-8', LastName = 'CalMK4F Demo ' + tag, LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', ProfileId = p.Id, TimeZoneSidKey = 'America/Chicago',
            UserName = 'calmk4f.' + tag + '.' + rnd + '@calmk4f.example', UserRoleId = roleId);
        insert u;
        return u;
    }
    public static void grant(Id userId, String permSetName) {
        insert new PermissionSetAssignment(AssigneeId = userId,
            PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = :permSetName LIMIT 1].Id);
    }
    /** Test-only permission set (rolled back) */
    public static PermissionSet testSet(String name) {
        PermissionSet ps = new PermissionSet(Name = name, Label = name.replace('_', ' '));
        insert ps;
        return ps;
    }
    public static void objRead(Id psId, String obj) {
        insert new ObjectPermissions(ParentId = psId, SobjectType = obj, PermissionsRead = true);
    }
    public static void fieldRead(Id psId, String obj, String fld) {
        insert new FieldPermissions(ParentId = psId, SobjectType = obj, Field = obj + '.' + fld, PermissionsRead = true);
    }
    public static void assign(Id userId, Id psId) {
        insert new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = psId);
    }
    public static User me() { return new User(Id = UserInfo.getUserId()); }
    public static void ev(String s) { System.debug('CALMK4F_EVIDENCE ' + s); }
}