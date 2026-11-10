// CALHACK-103 R-09 FIRST ATTEMPT: employee rows cached in a static map on first use and reused for the rest of the transaction.
public with sharing class CalMG_DemoProfileTriggerHandler {
    @TestVisible static Map<Id, CalMG_Demo_Employee__c> employeeCache;
    @TestVisible static Integer employeeQueries = 0;

    public static void beforeSave(List<CalMG_Demo_Profile__c> rows) {
        if (employeeCache == null) {
            Set<Id> ids = new Set<Id>();
            for (CalMG_Demo_Profile__c p : rows) {
                ids.add(p.Employee__c);
            }
            employeeCache = new Map<Id, CalMG_Demo_Employee__c>([SELECT Id, Email__c FROM CalMG_Demo_Employee__c WHERE Id IN :ids]);
            employeeQueries++;
        }
        for (CalMG_Demo_Profile__c p : rows) {
            CalMG_Demo_Employee__c emp = employeeCache.get(p.Employee__c);
            if (emp != null) {
                p.Email__c = emp.Email__c;
            }
        }
    }
}