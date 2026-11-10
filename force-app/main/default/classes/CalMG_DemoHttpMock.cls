// CALHACK-103 R-05 demo: mocked ERP response; no external system is contacted.
@isTest
public class CalMG_DemoHttpMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"erpRef":"ERP-DEMO-001"}');
        return res;
    }
}