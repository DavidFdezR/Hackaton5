@IsTest
private class CalMK4_OrderPushBatchTest {
    private class OkMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest r) { HttpResponse s = new HttpResponse(); s.setStatusCode(200); return s; }
    }
    static void orders(Integer n) {
        List<CalMK4_DemoOrder__c> rows = new List<CalMK4_DemoOrder__c>();
        for (Integer i = 0; i < n; i++) { rows.add(new CalMK4_DemoOrder__c(Name = 'CalMK4 Demo Order B' + i, Status__c = 'New')); }
        insert rows;
    }
    /** T-125: scope 200 -> 200 callouts in one execute (designed to fail: Too many callouts: 101). */
    @IsTest static void scope200OneCalloutPerRecord() {
        orders(200);
        Test.setMock(HttpCalloutMock.class, new OkMock());
        Test.startTest();
        Database.executeBatch(new CalMK4_OrderPushBatch(), 200);
        Test.stopTest();
        System.assertEquals(200, [SELECT COUNT() FROM CalMK4_DemoOrder__c WHERE Status__c = 'Pushed']);
    }
    /** T-126 twin: scope 50 -> 50 callouts per execute, stays under the 100-callout limit. */
    @IsTest static void scope50StaysUnderCalloutLimit() {
        orders(50);
        Test.setMock(HttpCalloutMock.class, new OkMock());
        Test.startTest();
        Database.executeBatch(new CalMK4_OrderPushBatch(), 50);
        Test.stopTest();
        System.assertEquals(50, [SELECT COUNT() FROM CalMK4_DemoOrder__c WHERE Status__c = 'Pushed']);
    }
}