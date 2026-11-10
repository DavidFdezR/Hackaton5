// CALHACK-103 R-04 FIRST ATTEMPT: first job inserts a demo account and always chains the contact job.
public with sharing class CalMG_DemoAccountQueueable implements Queueable {
    public void execute(QueueableContext ctx) {
        Account acc = new Account(Name = 'CalMG Demo Queue Account', AnnualRevenue = 2250);
        insert acc;
        System.enqueueJob(new CalMG_DemoContactQueueable(acc.Id));
    }
}