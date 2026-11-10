/** Q-024 agent's own test: one record. Passes. */
@IsTest
private class CalMK6_Q024_RevisionHandlerTest {
    @IsTest static void singleUpdateRaisesRevisionOnce() {
        CalMK6_Order__c o = new CalMK6_Order__c(Name = 'CalMK6_Rev1', Revision__c = 0);
        insert o;
        CalMK6_OrderTriggerRouter.mode = 'Q024';
        update new CalMK6_Order__c(Id = o.Id, Status__c = 'Edited');
        Assert.areEqual(1, [SELECT Revision__c FROM CalMK6_Order__c WHERE Id = :o.Id].Revision__c);
    }
}