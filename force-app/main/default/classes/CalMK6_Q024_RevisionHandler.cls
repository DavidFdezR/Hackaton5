/** Q-024 agent outcome: static Boolean recursion guard. */
public with sharing class CalMK6_Q024_RevisionHandler {
    public static Boolean alreadyRan = false;
    public static void handle(List<CalMK6_Order__c> rows) {
        if (alreadyRan) { return; }
        alreadyRan = true;
        List<CalMK6_Order__c> upd = new List<CalMK6_Order__c>();
        for (CalMK6_Order__c o : rows) { upd.add(new CalMK6_Order__c(Id = o.Id, Revision__c = (o.Revision__c == null ? 0 : o.Revision__c) + 1)); }
        update upd;
    }
}