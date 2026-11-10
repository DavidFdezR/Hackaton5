@IsTest
private class CalMK4_DemoOppCloserTest {
    @IsTest static void monthEndCloseOf200() {
        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < 200; i++) {
            opps.add(new Opportunity(Name = 'CalMK4 Demo Opp ' + i, StageName = 'Prospecting', CloseDate = Date.today()));
        }
        insert opps;
        Test.startTest();
        CalMK4_DemoOppCloser.closeAll(opps);
        Test.stopTest();
        System.assertEquals(200, [SELECT COUNT() FROM Opportunity WHERE Id IN :opps AND StageName = 'Closed Won']);
    }
}