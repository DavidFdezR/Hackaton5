// CALHACK-103 X-09 first attempt: plain all-or-none insert of an integration batch.
public with sharing class CalMG_DemoOrderLoader {
    public static void load(List<CalMG_Demo_Order__c> rows) {
        insert rows;
    }
}