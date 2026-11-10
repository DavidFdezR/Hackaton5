// CALHACK-103 X-03 probe (undocumented behaviour): roll back to a savepoint after a failed confirm,
// then deliver test events. Records what the test event bus does; not the main evidence.
@isTest
private class CalMG_DemoOrderRollbackProbeTest {
    @isTest
    static void rolledBackConfirmLeavesNoLog() {
        Savepoint sp = Database.setSavepoint();
        try {
            CalMG_DemoOrderService.confirm('CALMG-T-3', true);
        } catch (CalMG_DemoOrderService.DemoFailureException e) {
            Database.rollback(sp);
        }
        Test.getEventBus().deliver();
        Integer orders = [SELECT COUNT() FROM CalMG_Demo_Order__c WHERE Name = 'CALMG-T-3'];
        Integer logs = [SELECT COUNT() FROM CalMG_Demo_Event_Log__c WHERE Ref__c = 'CALMG-T-3'];
        Assert.areEqual(0, logs, 'probe after rollback: orders=' + orders + ' logs=' + logs);
    }
}