// CALHACK-103 R-08 demo: after-update trigger that writes one audit row per changed invoice.
trigger CalMG_DemoInvoiceTrigger on CalMG_Demo_Invoice__c (after update) {
    CalMG_DemoInvoiceTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
}