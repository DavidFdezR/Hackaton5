// CALHACK-103 X-08 shared test: one in-test user in Pacific/Kiritimati (UTC+14).
@isTest
private class CalMG_DemoDueDateServiceTest {
    @isTest
    static void dueDateUsesUsersLocalDay() {
        User u;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Profile p = [SELECT Id FROM Profile WHERE Name = 'Minimum Access - Salesforce' LIMIT 1];
            String stamp = String.valueOf(Datetime.now().getTime());
            u = new User(
                LastName = 'CalMG Demo Kiritimati', Alias = 'calmgx08', Email = 'calmg.x08@demo.example',
                Username = 'calmg.x08.' + stamp + '@demo.example', ProfileId = p.Id,
                TimeZoneSidKey = 'Pacific/Kiritimati', LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US');
            insert u;
        }
        Datetime createdAt = Datetime.newInstanceGmt(2026, 3, 16, 12, 0, 0);
        System.runAs(u) {
            Assert.areNotEqual(createdAt.dateGmt(), createdAt.date(),
                'boundary exercised: local day ' + createdAt.date() + ' vs GMT day ' + createdAt.dateGmt());
            Assert.areEqual(Date.newInstance(2026, 4, 16), CalMG_DemoDueDateService.dueDate(createdAt),
                'due date for a record created on local ' + createdAt.format('yyyy-MM-dd HH:mm') + ' (Kiritimati)');
        }
    }
}