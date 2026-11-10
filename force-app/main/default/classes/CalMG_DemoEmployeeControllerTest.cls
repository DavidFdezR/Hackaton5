// CALHACK-103 X-02 shared test: one in-test Minimum Access user per method, owning one private staff record.
@isTest
private class CalMG_DemoEmployeeControllerTest {
    private static User makeUser(String permSetName, String tag) {
        User u;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Profile p = [SELECT Id FROM Profile WHERE Name = 'Minimum Access - Salesforce' LIMIT 1];
            String stamp = String.valueOf(Datetime.now().getTime());
            u = new User(
                LastName = 'CalMG Demo ' + tag, Alias = 'calmgx02', Email = 'calmg.x02@demo.example',
                Username = 'calmg.x02.' + tag + '.' + stamp + '@demo.example', ProfileId = p.Id,
                TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US');
            insert u;
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = :permSetName];
            insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
        }
        return u;
    }

    private static Id makeRecord(User owner) {
        CalMG_Demo_Staff__c s = new CalMG_Demo_Staff__c(Name = 'CalMG Demo Staff 1', Salary__c = 85000, OwnerId = owner.Id);
        insert s;
        return s.Id;
    }

    @isTest
    static void restrictedUserGetsNoSalary() {
        User u = makeUser('CalMG_Demo_Employee_Reader', 'Reader');
        Id recId = makeRecord(u);
        Decimal salary = null;
        String denied = 'no exception';
        System.runAs(u) {
            try {
                salary = CalMG_DemoEmployeeController.getSalary(recId);
            } catch (QueryException e) {
                denied = e.getMessage();
            }
        }
        Assert.isNull(salary, 'restricted user (no FLS on Salary__c) received the salary; exception: ' + denied);
    }

    @isTest
    static void salaryUserStillGetsValue() {
        User u = makeUser('CalMG_Demo_Employee_Salary', 'Payroll');
        Id recId = makeRecord(u);
        Decimal salary;
        System.runAs(u) {
            salary = CalMG_DemoEmployeeController.getSalary(recId);
        }
        Assert.areEqual(85000, salary, 'user with FLS read on Salary__c');
    }
}