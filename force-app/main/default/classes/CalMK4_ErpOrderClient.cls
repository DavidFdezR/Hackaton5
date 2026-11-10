/** CALHACK T-094 (planted, bad on purpose): resends the same order POST up to 5 times on timeout or ANY non-200. No idempotency key. */
public with sharing class CalMK4_ErpOrderClient {
    public static Integer attempts = 0;
    public static Integer postOrder(String orderJson) {
        Integer status = -1;
        for (Integer i = 0; i < 5; i++) {
            attempts++;
            try {
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:CalMK4_DemoERP_NC/orders');
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                req.setBody(orderJson);
                req.setTimeout(10000);
                HttpResponse res = new Http().send(req);
                status = res.getStatusCode();
                if (status == 200) { return status; }
            } catch (CalloutException e) {
                status = -1; // read timeout: the ERP may already have booked the order
            }
        }
        return status;
    }
}