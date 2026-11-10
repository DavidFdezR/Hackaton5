@IsTest
private class CalMK4_ErpOrderClientTest {
    private class CountingMock implements HttpCalloutMock {
        Integer code; Boolean timeout; public Integer posts = 0;
        CountingMock(Integer code, Boolean timeout) { this.code = code; this.timeout = timeout; }
        public HttpResponse respond(HttpRequest req) {
            posts++;
            if (timeout) { throw new CalloutException('Read timed out'); }
            HttpResponse r = new HttpResponse(); r.setStatusCode(code); r.setBody('{}'); return r;
        }
    }
    @IsTest static void readTimeoutResendsSameOrderFiveTimes() {
        CountingMock m = new CountingMock(200, true);
        Test.setMock(HttpCalloutMock.class, m);
        CalMK4_ErpOrderClient.postOrder('{"orderRef":"CalMK4-ORD-1","amount":10}');
        System.debug('CALMK4_EVIDENCE timeout posts=' + m.posts);
        System.assertEquals(5, m.posts, 'same order POSTed 5 times after read timeouts');
    }
    @IsTest static void badRequest400IsRetriedFiveTimes() {
        CountingMock m = new CountingMock(400, false);
        Test.setMock(HttpCalloutMock.class, m);
        Integer s = CalMK4_ErpOrderClient.postOrder('{"orderRef":"CalMK4-ORD-2"}');
        System.debug('CALMK4_EVIDENCE 400 posts=' + m.posts);
        System.assertEquals(5, m.posts, 'a 4xx can never succeed but is retried 5 times');
        System.assertEquals(400, s);
    }
}