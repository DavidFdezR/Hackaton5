// CALHACK-103 Q-058/Q-059 (CalMQ): subscriber used only while reproducing the real event-timing runs; kept Inactive otherwise.
// Reuses CalMG_DemoEventLogWriter (Madhusudhan's) unchanged; writes one CalMG_Demo_Event_Log__c row per delivered event.
trigger CalMQ_OrderConfirmedCmtSub on CalMG_Order_Confirmed_Cmt__e (after insert) {
    CalMG_DemoEventLogWriter.write(Trigger.new, 'Cmt');
}