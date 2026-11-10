/** Q-035 agent's test: 9 of 10 saved. Passes. Nothing checks that the bad row's error reaches the caller. */
@IsTest
private class CalMK6_Q035_ImportAgentTest {
    @IsTest static void nineOfTenSaved() {
        CalMK6_Q035_ImportAgent.importRows(CalMK6_ImportTestData.tenRowsOneBad());
        Assert.areEqual(9, [SELECT COUNT() FROM CalMK6_Order__c WHERE Name LIKE 'CalMK6_Imp%']);
    }
}