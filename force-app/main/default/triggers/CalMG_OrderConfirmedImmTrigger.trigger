// CALHACK-103 X-03 subscriber for the Publish Immediately event.
trigger CalMG_OrderConfirmedImmTrigger on CalMG_Order_Confirmed_Imm__e (after insert) {
    CalMG_DemoEventLogWriter.write(Trigger.new, 'Imm');
}