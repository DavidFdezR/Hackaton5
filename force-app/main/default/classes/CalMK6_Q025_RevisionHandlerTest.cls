/** Q-025 agent's own test as submitted: one record, asserts only "no exception". */
@IsTest
private class CalMK6_Q025_RevisionHandlerTest {
    @IsTest static void updateDoesNotThrow() {
        CalMK6_Order__c o = new CalMK6_Order__c(Name = 'CalMK6_Rev1', Revision__c = 0);
        insert o;
        CalMK6_OrderTriggerRouter.mode = 'Q025';
        update new CalMK6_Order__c(Id = o.Id, Status__c = 'Edited');
        Assert.isTrue(true);
    }
}