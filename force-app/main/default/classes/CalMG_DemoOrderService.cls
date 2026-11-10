// CALHACK-103 X-03 first attempt (Publish Immediately event): saves the order, publishes the confirmation event, then a later step may fail.
public with sharing class CalMG_DemoOrderService {
    public class DemoFailureException extends Exception {}

    public static Id confirm(String ref, Boolean failAfter) {
        CalMG_Demo_Order__c order = new CalMG_Demo_Order__c(Name = ref);
        insert order;
        EventBus.publish(new CalMG_Order_Confirmed_Imm__e(OrderRef__c = ref));
        if (failAfter) {
            throw new DemoFailureException('CalMG demo: later step failed after publishing for ' + ref);
        }
        return order.Id;
    }
}