/** Starting state for Q-024..Q-026: after-update re-updates the same rows -> recursion. */
public with sharing class CalMK6_RevisionNaive {
    public static void handle(List<CalMK6_Order__c> rows) {
        List<CalMK6_Order__c> upd = new List<CalMK6_Order__c>();
        for (CalMK6_Order__c o : rows) { upd.add(new CalMK6_Order__c(Id = o.Id, Revision__c = (o.Revision__c == null ? 0 : o.Revision__c) + 1)); }
        update upd;
    }
}