/** CALHACK T-118 twin: sends order ids to callout:CalMK4_DemoERP_NC in chunks of 100 (2 callouts for 200 rows). */
public with sharing class CalMK4_DemoOrderPushQueueable implements Queueable, Database.AllowsCallouts {
    private List<Id> ids;
    public CalMK4_DemoOrderPushQueueable(List<Id> ids) { this.ids = ids; }
    public void execute(QueueableContext ctx) {
        List<Id> chunk = new List<Id>();
        for (Integer i = 0; i < ids.size(); i++) {
            chunk.add(ids[i]);
            if (chunk.size() == 100 || i == ids.size() - 1) {
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:CalMK4_DemoERP_NC/orders/bulk');
                req.setMethod('POST');
                req.setBody(JSON.serialize(chunk));
                new Http().send(req);
                chunk = new List<Id>();
            }
        }
    }
}