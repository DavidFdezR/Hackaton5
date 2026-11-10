// CALHACK-103 R-09 demo: copy the employee email onto the profile before save.
trigger CalMG_DemoProfileTrigger on CalMG_Demo_Profile__c (before insert, before update) {
    CalMG_DemoProfileTriggerHandler.beforeSave(Trigger.new);
}