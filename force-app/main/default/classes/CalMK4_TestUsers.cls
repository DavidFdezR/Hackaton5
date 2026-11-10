/** CALHACK CalMK4 test helper: creates Standard Platform User demo users (rolled back with the test). */
@IsTest
public class CalMK4_TestUsers {
    public static User make(String tag) { return make(tag, null); }
    public static User make(String tag, Id roleId) { return make(tag, roleId, 'Standard Platform User'); }
    public static User make(String tag, Id roleId, String profileName) {
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        String rnd = String.valueOf(Math.abs(Crypto.getRandomInteger()));
        User u = new User(Alias = ('mk4' + tag).left(8), Email = 'demo.' + tag + '@calmk4.example',
            EmailEncodingKey = 'UTF-8', LastName = 'CalMK4 Demo ' + tag, LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', ProfileId = p.Id, TimeZoneSidKey = 'America/Chicago',
            UserName = 'calmk4.' + tag + '.' + rnd + '@calmk4.example', UserRoleId = roleId);
        insert u;
        return u;
    }
    public static void grant(Id userId, String permSetName) {
        insert new PermissionSetAssignment(AssigneeId = userId,
            PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = :permSetName LIMIT 1].Id);
    }
    public static User me() { return new User(Id = UserInfo.getUserId()); }
}