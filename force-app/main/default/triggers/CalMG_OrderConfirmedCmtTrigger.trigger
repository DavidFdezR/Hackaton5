// CALHACK-103 X-03 subscriber for the Publish After Commit event.
trigger CalMG_OrderConfirmedCmtTrigger on CalMG_Order_Confirmed_Cmt__e (after insert) {
    CalMG_DemoEventLogWriter.write(Trigger.new, 'Cmt');
}