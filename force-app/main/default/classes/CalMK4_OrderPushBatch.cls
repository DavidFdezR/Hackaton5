/** CALHACK T-125/T-126: pushes each new CalMK4_DemoOrder__c to the demo ERP, ONE callout per record. Safe only with scope <= 100 (we use 50). */
public with sharing class CalMK4_OrderPushBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, Name FROM CalMK4_DemoOrder__c WHERE Status__c = 'New']);
    }
    public void execute(Database.BatchableContext bc, List<CalMK4_DemoOrder__c> scope) {
        for (CalMK4_DemoOrder__c o : scope) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:CalMK4_DemoERP_NC/orders');
            req.setMethod('POST');
            req.setBody('{"name":"' + o.Name + '"}');
            new Http().send(req);
            o.Status__c = 'Pushed';
        }
        update scope;
    }
    public void finish(Database.BatchableContext bc) {}
}