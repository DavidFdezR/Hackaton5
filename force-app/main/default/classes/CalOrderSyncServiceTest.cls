@isTest
private class CalOrderSyncServiceTest {
    private class ScriptedErp implements HttpCalloutMock {
        private final List<Object> script;
        public Integer calls = 0;
        public ScriptedErp(List<Object> script) { this.script = script; }
        public HttpResponse respond(HttpRequest request) {
            Object step = script[Math.min(calls, script.size() - 1)];
            calls++;
            if (step instanceof String) {
                throw new CalloutException('Read timed out');
            }
            HttpResponse response = new HttpResponse();
            response.setStatusCode((Integer) step);
            response.setBody('{"ok":' + (((Integer) step) == 200) + '}');
            return response;
        }
    }

    @isTest
    static void transientFailureIsRetried() {
        ScriptedErp erp = new ScriptedErp(new List<Object>{ 503, 200 });
        Test.setMock(HttpCalloutMock.class, erp);
        CalOrderSyncService.Result result = CalOrderSyncService.sendOrder('{"order":"DEMO-1"}');
        Assert.areEqual('SENT', result.status);
        Assert.areEqual(2, erp.calls);
    }

    @isTest
    static void nonRetryableErrorIsNotRetried() {
        ScriptedErp erp = new ScriptedErp(new List<Object>{ 400 });
        Test.setMock(HttpCalloutMock.class, erp);
        CalOrderSyncService.Result result = CalOrderSyncService.sendOrder('{"order":"DEMO-2"}');
        Assert.areEqual('REJECTED', result.status);
        Assert.areEqual(1, erp.calls);
    }

    @isTest
    static void slowEndpointStopsAfterBoundedRetries() {
        ScriptedErp erp = new ScriptedErp(new List<Object>{ 'TIMEOUT' });
        Test.setMock(HttpCalloutMock.class, erp);
        CalOrderSyncService.Result result = CalOrderSyncService.sendOrder('{"order":"DEMO-3"}');
        Assert.areEqual('RETRY_EXHAUSTED', result.status);
        Assert.areEqual(CalOrderSyncService.MAX_ATTEMPTS, erp.calls);
    }

    @isTest
    static void triggerContextGoesAsync() {
        ScriptedErp erp = new ScriptedErp(new List<Object>{ 200 });
        Test.setMock(HttpCalloutMock.class, erp);
        Test.startTest();
        CalOrderSyncService.sendOrderLater('{"order":"DEMO-4"}');
        Test.stopTest();
        Assert.areEqual(1, [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'Queueable'], 'Expected a Queueable, not a synchronous callout');
        Assert.areEqual(1, erp.calls);
    }
}