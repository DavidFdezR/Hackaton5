// CALHACK-103 X-10 demo trigger: stamps CalMG_Group__c on new demo contacts.
trigger CalMG_DemoContactTrigger on Contact (after insert) {
    CalMG_DemoContactHandler.stampGroup(Trigger.new);
}