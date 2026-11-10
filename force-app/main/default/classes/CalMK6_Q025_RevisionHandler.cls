/** Q-025 agent outcome: static Set<Id> of processed rows (record-level guard). */
public with sharing class CalMK6_Q025_RevisionHandler {
    private static Set<Id> processed = new Set<Id>();
    public static void handle(List<CalMK6_Order__c> rows) {
        List<CalMK6_Order__c> upd = new List<CalMK6_Order__c>();
        for (CalMK6_Order__c o : rows) {
            if (processed.contains(o.Id)) { continue; }
            processed.add(o.Id);
            upd.add(new CalMK6_Order__c(Id = o.Id, Revision__c = (o.Revision__c == null ? 0 : o.Revision__c) + 1));
        }
        if (!upd.isEmpty()) { update upd; }
    }
}