/** Q-035 agent outcome as submitted: partial success (allOrNone=false), but the SaveResults are thrown away. */
public with sharing class CalMK6_Q035_ImportAgent {
    public static void importRows(List<CalMK6_Order__c> rows) {
        Database.insert(rows, false);
    }
}