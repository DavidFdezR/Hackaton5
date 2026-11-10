/** Q-026 agent outcome: move the write into before update; no DML, so no recursion and no guard needed. */
public with sharing class CalMK6_Q026_RevisionHandler {
    public static void handle(List<CalMK6_Order__c> rows, Map<Id, CalMK6_Order__c> oldMap) {
        for (CalMK6_Order__c o : rows) {
            Decimal prev = oldMap.get(o.Id).Revision__c;
            o.Revision__c = (prev == null ? 0 : prev) + 1;
        }
    }
}