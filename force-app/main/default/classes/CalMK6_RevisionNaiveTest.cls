/** Proves the starting-state defect: one user update of one order hits the trigger depth limit. Passes by asserting the error. */
@IsTest
private class CalMK6_RevisionNaiveTest {
    @IsTest static void singleUpdateHitsTriggerDepthLimit() {
        CalMK6_Order__c o = new CalMK6_Order__c(Name = 'CalMK6_Rev0', Revision__c = 0);
        insert o;
        CalMK6_OrderTriggerRouter.mode = 'NAIVE';
        String msg = '';
        try { update new CalMK6_Order__c(Id = o.Id, Status__c = 'Edited'); } catch (DmlException e) { msg = e.getMessage(); }
        System.debug('CALMK6_NAIVE_ERROR ' + msg);
        Assert.isTrue(msg.contains('maximum trigger depth exceeded'), msg);
    }
}