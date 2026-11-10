// CALHACK-103 R-07 demo: before-save stamp on CalMG Demo Execution records.
trigger CalMG_DemoExecutionTrigger on CalMG_Demo_Execution__c (before insert, before update) {
    CalMG_DemoExecutionHandler.beforeSave(Trigger.new);
}