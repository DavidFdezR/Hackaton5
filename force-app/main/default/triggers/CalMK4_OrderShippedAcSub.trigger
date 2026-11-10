/** CALHACK T-139/T-140 subscriber (after-commit): logs each shipment notice the warehouse would act on. */
trigger CalMK4_OrderShippedAcSub on CalMK4_OrderShippedAc__e (after insert) {
    List<CalMK4_DemoTicket__c> notes = new List<CalMK4_DemoTicket__c>();
    for (CalMK4_OrderShippedAc__e e : Trigger.new) { notes.add(new CalMK4_DemoTicket__c(Name = 'CalMK4 Shipment notice after-commit ' + e.Order_Ref__c)); }
    insert notes;
}