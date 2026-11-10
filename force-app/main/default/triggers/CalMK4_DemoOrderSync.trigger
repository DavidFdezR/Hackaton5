/** CALHACK T-117 (planted, bad on purpose; kept INACTIVE): calls an @future method per record inside the loop. */
trigger CalMK4_DemoOrderSync on CalMK4_DemoOrder__c (after insert) {
    for (CalMK4_DemoOrder__c o : Trigger.new) {
        CalMK4_DemoOrderSyncService.pushOne(o.Id);
    }
}