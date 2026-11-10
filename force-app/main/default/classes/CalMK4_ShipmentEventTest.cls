@IsTest
private class CalMK4_ShipmentEventTest {
    static Integer notices(String kind) { return [SELECT COUNT() FROM CalMK4_DemoTicket__c WHERE Name LIKE :('CalMK4 Shipment notice ' + kind + '%')]; }
    /** T-139: the order save fails and is rolled back, but the Publish Immediately event is still delivered. */
    @IsTest static void immediateEventSurvivesRollback() {
        Savepoint sp = Database.setSavepoint();
        CalMK4_DemoOrder__c o = new CalMK4_DemoOrder__c(Name = 'CalMK4 Demo Order PE1', Status__c = 'Shipped');
        insert o;
        CalMK4_ShipmentService.shipImmediate(o);
        Database.rollback(sp); // e.g. a later validation failure in the same transaction
        Test.getEventBus().deliver();
        Integer orders = [SELECT COUNT() FROM CalMK4_DemoOrder__c WHERE Name = 'CalMK4 Demo Order PE1'];
        System.debug('CALMK4_EVIDENCE T-139 Publish Immediately: order rows after rollback=' + orders + ' | shipment notices delivered=' + notices('immediate'));
        System.assertEquals(0, orders);
        System.assertEquals(1, notices('immediate'), 'warehouse is told to ship an order that no longer exists');
    }
    /** T-140 twin: same flow with Publish After Commit. */
    @IsTest static void afterCommitEventDroppedOnRollback() {
        Savepoint sp = Database.setSavepoint();
        CalMK4_DemoOrder__c o = new CalMK4_DemoOrder__c(Name = 'CalMK4 Demo Order PE2', Status__c = 'Shipped');
        insert o;
        CalMK4_ShipmentService.shipAfterCommit(o);
        Database.rollback(sp);
        Test.getEventBus().deliver();
        System.debug('CALMK4_EVIDENCE T-140 Publish After Commit: shipment notices delivered after rollback=' + notices('after-commit'));
        // committed path
        CalMK4_DemoOrder__c o2 = new CalMK4_DemoOrder__c(Name = 'CalMK4 Demo Order PE3', Status__c = 'Shipped');
        insert o2;
        CalMK4_ShipmentService.shipAfterCommit(o2);
        Test.getEventBus().deliver();
        System.debug('CALMK4_EVIDENCE T-140 Publish After Commit: notices after a kept save=' + notices('after-commit'));
    }
}