/** Test-only helper: one Standard Platform User with CalMK6_Order_Reader, optionally in CalMK6_West_Managers,
    plus 5 West + 5 East orders owned by the running admin. Everything rolls back with the test. */
@IsTest
public class CalMK6_SharingTestKit {
    public static User westManager(Boolean inGroup) {
        User u;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard Platform User' LIMIT 1];
            String uniq = String.valueOf(Crypto.getRandomInteger()).replace('-', '7');
            u = new User(Alias = 'cmk6w', Email = 'west.manager@calmk6.example', EmailEncodingKey = 'UTF-8',
                LastName = 'CalMK6_WestManager', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US',
                ProfileId = p.Id, TimeZoneSidKey = 'America/Chicago', Username = 'calmk6.west.' + uniq + '@calmk6.example');
            insert u;
            insert new PermissionSetAssignment(AssigneeId = u.Id,
                PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'CalMK6_Order_Reader'].Id);
            if (inGroup) {
                insert new GroupMember(UserOrGroupId = u.Id,
                    GroupId = [SELECT Id FROM Group WHERE DeveloperName = 'CalMK6_West_Managers'].Id);
            }
        }
        return u;
    }
    public static void fiveWestFiveEast() {
        List<CalMK6_Order__c> rows = new List<CalMK6_Order__c>();
        for (Integer i = 0; i < 5; i++) {
            rows.add(new CalMK6_Order__c(Name = 'CalMK6_West' + i, Region__c = 'West', Amount__c = 100));
            rows.add(new CalMK6_Order__c(Name = 'CalMK6_East' + i, Region__c = 'East', Amount__c = 100));
        }
        insert rows;
    }
}