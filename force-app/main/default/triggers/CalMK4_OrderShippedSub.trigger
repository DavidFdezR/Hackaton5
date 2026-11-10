/** CALHACK T-139/T-140 subscriber (immediate): logs each shipment notice the warehouse would act on. */
trigger CalMK4_OrderShippedSub on CalMK4_OrderShipped__e (after insert) {
    List<CalMK4_DemoTicket__c> notes = new List<CalMK4_DemoTicket__c>();
    for (CalMK4_OrderShipped__e e : Trigger.new) { notes.add(new CalMK4_DemoTicket__c(Name = 'CalMK4 Shipment notice immediate ' + e.Order_Ref__c)); }
    insert notes;
}