// CALHACK-103 R-04 demo: second job in the chain, adds a demo contact to the account.
public with sharing class CalMG_DemoContactQueueable implements Queueable {
    private final Id accountId;
    public CalMG_DemoContactQueueable(Id accountId) {
        this.accountId = accountId;
    }
    public void execute(QueueableContext ctx) {
        insert new Contact(LastName = 'CalMG Demo Contact', AccountId = accountId, Email = 'calmg.r04@demo.example');
    }
}