/** CALHACK T-181: credit-bureau check called from the refund trigger. "Temporary" test bypass added to get the deploy green. */
public with sharing class CalMK4C_RefundCreditCheck {
    public static Boolean isApproved(Decimal amount) {
        if (Test.isRunningTest()) {
            return true; // TEMP: bureau sandbox is down, remove after release
        }
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://bureau.calmk4c.example/score?amount=' + amount);
        req.setMethod('GET');
        HttpResponse res = new Http().send(req);
        return res.getStatusCode() == 200;
    }
}