/** Q-038 agent outcome: HttpCalloutMock for the demo shipping API (no real network). */
@IsTest
public class CalMK6_Q038_ShipmentMock implements HttpCalloutMock {
    private Integer code; private String body;
    public CalMK6_Q038_ShipmentMock(Integer code, String body) { this.code = code; this.body = body; }
    public HttpResponse respond(HttpRequest req) {
        Assert.areEqual('GET', req.getMethod());
        Assert.isTrue(req.getEndpoint().startsWith('https://shipping.calmk6.example/api/track/'), req.getEndpoint());
        HttpResponse res = new HttpResponse();
        res.setStatusCode(code); res.setBody(body);
        return res;
    }
}