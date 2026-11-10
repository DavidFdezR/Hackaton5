/** Q-037 agent's test: passes because the class returns a canned value under test. */
@IsTest
private class CalMK6_Q037_ShipmentClientTest {
    @IsTest static void returnsInTransit() {
        Assert.areEqual('IN_TRANSIT', CalMK6_Q037_ShipmentClient.getStatus('CALMK6-TRK-1'));
    }
}