// CALHACK-103 lab trigger (manoj.kumar). Inert by default: it only dispatches when a test or a
// reproduction script sets CalMK6_OrderTriggerRouter.mode, so normal saves are untouched.
trigger CalMK6_OrderTrigger on CalMK6_Order__c (before update, after update) {
    CalMK6_OrderTriggerRouter.run();
}