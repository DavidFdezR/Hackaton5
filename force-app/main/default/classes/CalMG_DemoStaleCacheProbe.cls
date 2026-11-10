// CALHACK-103 R-09 read-back probe: runs insert -> change employee email -> update profile in ONE real transaction
// (no test context) and reports what the profile ends up with. Rolls back to a savepoint, so nothing persists.
public with sharing class CalMG_DemoStaleCacheProbe {
    public static String run() {
        Savepoint sp = Database.setSavepoint();
        String facts;
        try {
            CalMG_Demo_Employee__c emp = new CalMG_Demo_Employee__c(Name = 'CalMG Demo Employee RB', Email__c = 'old.calmg@demo.example');
            insert emp;
            CalMG_Demo_Profile__c prof = new CalMG_Demo_Profile__c(Name = 'CalMG Demo Profile RB', Employee__c = emp.Id);
            insert prof;
            String afterInsert = [SELECT Email__c FROM CalMG_Demo_Profile__c WHERE Id = :prof.Id].Email__c;
            emp.Email__c = 'new.calmg@demo.example';
            update emp;
            update prof;
            String empNow = [SELECT Email__c FROM CalMG_Demo_Employee__c WHERE Id = :emp.Id].Email__c;
            String afterUpdate = [SELECT Email__c FROM CalMG_Demo_Profile__c WHERE Id = :prof.Id].Email__c;
            facts = 'profileEmailAfterInsert=' + afterInsert + ' employeeEmailNow=' + empNow + ' profileEmailAfterUpdate=' + afterUpdate;
        } finally {
            Database.rollback(sp);
        }
        Integer left = [SELECT COUNT() FROM CalMG_Demo_Profile__c WHERE Name = 'CalMG Demo Profile RB'];
        return facts + ' rolledBackRowsLeft=' + left;
    }
}