trigger CalCaseStatusStampTrigger on Case (after insert, after update) {
    CalCaseStatusStamp.afterSave(Trigger.new);
}