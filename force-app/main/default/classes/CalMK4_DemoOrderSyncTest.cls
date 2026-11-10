@IsTest
private class CalMK4_DemoOrderSyncTest {
    private class OkMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest r) { HttpResponse s = new HttpResponse(); s.setStatusCode(200); return s; }
    }
    @IsTest static void integrationInserts200Orders() {
        Test.setMock(HttpCalloutMock.class, new OkMock());
        List<CalMK4_DemoOrder__c> rows = new List<CalMK4_DemoOrder__c>();
        for (Integer i = 0; i < 200; i++) { rows.add(new CalMK4_DemoOrder__c(Name = 'CalMK4 Demo Order ' + i, Status__c = 'New')); }
        Test.startTest();
        insert rows;
        Test.stopTest();
        System.assertEquals(200, [SELECT COUNT() FROM CalMK4_DemoOrder__c]);
    }
}