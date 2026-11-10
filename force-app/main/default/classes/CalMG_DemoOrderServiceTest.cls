// CALHACK-103 X-03 shared test: the ordinary checks a developer would write. Both versions should pass.
@isTest
private class CalMG_DemoOrderServiceTest {
    @isTest
    static void confirmSavesOrderAndLogsOnce() {
        Test.startTest();
        CalMG_DemoOrderService.confirm('CALMG-T-1', false);
        Test.stopTest();
        Assert.areEqual(1, [SELECT COUNT() FROM CalMG_Demo_Order__c WHERE Name = 'CALMG-T-1'], 'order saved');
        Assert.areEqual(1, [SELECT COUNT() FROM CalMG_Demo_Event_Log__c WHERE Ref__c = 'CALMG-T-1'], 'one log row');
    }

    @isTest
    static void failedConfirmThrows() {
        try {
            CalMG_DemoOrderService.confirm('CALMG-T-2', true);
            Assert.fail('expected DemoFailure');
        } catch (CalMG_DemoOrderService.DemoFailureException e) {
            Assert.isTrue(e.getMessage().contains('CALMG-T-2'), e.getMessage());
        }
    }
}