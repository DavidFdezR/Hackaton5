// CALHACK-103 R-07 FIRST ATTEMPT: the trigger always stamps the note.
public with sharing class CalMG_DemoExecutionHandler {
    @TestVisible static Integer invocations = 0;
    public static void beforeSave(List<CalMG_Demo_Execution__c> rows) {
        invocations++;
        for (CalMG_Demo_Execution__c r : rows) {
            r.Status_Note__c = 'Stamped by trigger';
        }
    }
}