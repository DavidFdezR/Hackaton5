trigger CalAccountContactsTrigger on Account (before update) {
    CalAccountContactsHandler.summarize(Trigger.new);
}