@IsTest
private class CalMK4_SalaryHierarchyTest {
    @IsTest static void managerSeesSubordinateSalaryViaHierarchy() {
        User mgr; User staff;
        System.runAs(CalMK4_TestUsers.me()) {
            UserRole top = new UserRole(Name = 'CalMK4 Demo HR Manager', DeveloperName = 'CalMK4_Demo_Mgr_' + String.valueOf(Math.abs(Crypto.getRandomInteger())).left(6));
            insert top;
            UserRole sub = new UserRole(Name = 'CalMK4 Demo HR Staff', DeveloperName = 'CalMK4_Demo_Staff_' + String.valueOf(Math.abs(Crypto.getRandomInteger())).left(6), ParentRoleId = top.Id);
            insert sub;
            mgr = CalMK4_TestUsers.make('mgr', top.Id);
            staff = CalMK4_TestUsers.make('staff', sub.Id);
            CalMK4_TestUsers.grant(mgr.Id, 'CalMK4_DemoSalaryViewer_PS');
            CalMK4_TestUsers.grant(staff.Id, 'CalMK4_DemoSalaryViewer_PS');
        }
        CalMK4_DemoSalary__c s;
        System.runAs(staff) { s = new CalMK4_DemoSalary__c(Name = 'CalMK4 Demo Salary Staff', Amount__c = 70000); insert s; }
        System.runAs(mgr) {
            Integer seen = [SELECT COUNT() FROM CalMK4_DemoSalary__c WHERE Id = :s.Id WITH USER_MODE];
            System.debug('CALMK4_EVIDENCE manager sees subordinate salary=' + seen);
            System.assertEquals(1, seen, 'Grant Access Using Hierarchies (ON) gives the manager the row');
        }
    }
}