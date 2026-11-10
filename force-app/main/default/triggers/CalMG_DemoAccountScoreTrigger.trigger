// CALHACK-103 R-06 demo: before-save scoring on CalMG Demo accounts.
trigger CalMG_DemoAccountScoreTrigger on Account (before insert, before update) {
    CalMG_DemoAccountScoreHandler.beforeSave(Trigger.new);
}