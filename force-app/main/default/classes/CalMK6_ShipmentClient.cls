/** Starting state for Q-037/Q-038. Ticket: "CalMK6_ShipmentClient has no passing test: Methods defined as TestMethod do not support Web service callouts". */
public with sharing class CalMK6_ShipmentClient {
    public static String getStatus(String trackingId) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://shipping.calmk6.example/api/track/' + EncodingUtil.urlEncode(trackingId, 'UTF-8'));
        req.setMethod('GET');
        req.setTimeout(10000);
        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() != 200) {
            return 'ERROR_' + res.getStatusCode();
        }
        Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        String status = (String) body.get('status');
        return String.isBlank(status) ? 'UNKNOWN' : status.toUpperCase();
    }
}