// CALHACK-103 X-03 demo: one CalMG_Demo_Event_Log__c row per delivered order-confirmed event.
public without sharing class CalMG_DemoEventLogWriter {
    public static void write(List<SObject> events, String source) {
        List<CalMG_Demo_Event_Log__c> logs = new List<CalMG_Demo_Event_Log__c>();
        for (SObject e : events) {
            String ref = (String) e.get('OrderRef__c');
            logs.add(new CalMG_Demo_Event_Log__c(Name = ref + ' ' + source, Ref__c = ref, Source__c = source));
        }
        insert logs;
    }
}