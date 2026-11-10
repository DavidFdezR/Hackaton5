/** CALHACK T-117 (planted, bad on purpose): one @future callout per order. */
public with sharing class CalMK4_DemoOrderSyncService {
    @future(callout=true)
    public static void pushOne(Id orderId) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:CalMK4_DemoERP_NC/orders');
        req.setMethod('POST');
        req.setBody('{"id":"' + orderId + '"}');
        new Http().send(req);
    }
}