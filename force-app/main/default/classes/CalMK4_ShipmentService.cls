/** CALHACK T-139/T-140: marks a CalMK4_DemoOrder__c shipped and notifies the demo warehouse by platform event. */
public with sharing class CalMK4_ShipmentService {
    public static void shipImmediate(CalMK4_DemoOrder__c o) {
        EventBus.publish(new CalMK4_OrderShipped__e(Order_Ref__c = o.Name));      // Publish Immediately
    }
    public static void shipAfterCommit(CalMK4_DemoOrder__c o) {
        EventBus.publish(new CalMK4_OrderShippedAc__e(Order_Ref__c = o.Name));    // Publish After Commit
    }
}