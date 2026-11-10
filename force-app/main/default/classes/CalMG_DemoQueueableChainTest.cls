// CALHACK-103 R-04 FIRST ATTEMPT test: enqueue the first job and expect the whole chain to run at stopTest.
@isTest
private class CalMG_DemoQueueableChainTest {
    @isTest
    static void chainCreatesAccountAndContact() {
        Test.startTest();
        System.enqueueJob(new CalMG_DemoAccountQueueable());
        Test.stopTest();
        Assert.areEqual(1, [SELECT COUNT() FROM Account WHERE Name = 'CalMG Demo Queue Account'], 'account job ran');
        Assert.areEqual(1, [SELECT COUNT() FROM Contact WHERE LastName = 'CalMG Demo Contact'], 'contact job ran');
    }
}