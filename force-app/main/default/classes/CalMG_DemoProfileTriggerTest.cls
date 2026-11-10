// CALHACK-103 R-09 shared test (first attempt shape): insert, change the employee email, update the profile, all in one method.
@isTest
private class CalMG_DemoProfileTriggerTest {
    @isTest
    static void profilePicksUpChangedEmployeeEmail() {
        CalMG_Demo_Employee__c emp = new CalMG_Demo_Employee__c(Name = 'CalMG Demo Employee', Email__c = 'old.calmg@demo.example');
        insert emp;
        CalMG_Demo_Profile__c prof = new CalMG_Demo_Profile__c(Name = 'CalMG Demo Profile', Employee__c = emp.Id);
        insert prof;
        Assert.areEqual('old.calmg@demo.example', [SELECT Email__c FROM CalMG_Demo_Profile__c WHERE Id = :prof.Id].Email__c);

        emp.Email__c = 'new.calmg@demo.example';
        update emp;
        Test.startTest();
        update prof;
        Test.stopTest();

        String got = [SELECT Email__c FROM CalMG_Demo_Profile__c WHERE Id = :prof.Id].Email__c;
        Assert.areEqual('new.calmg@demo.example', got,
            'profile email after update; employee queries this transaction = ' + CalMG_DemoProfileTriggerHandler.employeeQueries);
    }
}