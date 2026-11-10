/** Q-038: tests the UNCHANGED production class CalMK6_ShipmentClient through Test.setMock (200, 500, blank status). */
@IsTest
private class CalMK6_Q038_ShipmentClientTest {
    @IsTest static void ok200() {
        Test.setMock(HttpCalloutMock.class, new CalMK6_Q038_ShipmentMock(200, '{"status":"in_transit"}'));
        Test.startTest();
        String s = CalMK6_ShipmentClient.getStatus('CALMK6-TRK-1');
        Test.stopTest();
        Assert.areEqual('IN_TRANSIT', s);
    }
    @IsTest static void serverError() {
        Test.setMock(HttpCalloutMock.class, new CalMK6_Q038_ShipmentMock(500, 'oops'));
        Assert.areEqual('ERROR_500', CalMK6_ShipmentClient.getStatus('CALMK6-TRK-2'));
    }
    @IsTest static void blankStatus() {
        Test.setMock(HttpCalloutMock.class, new CalMK6_Q038_ShipmentMock(200, '{"status":""}'));
        Assert.areEqual('UNKNOWN', CalMK6_ShipmentClient.getStatus('CALMK6-TRK-3'));
    }
}