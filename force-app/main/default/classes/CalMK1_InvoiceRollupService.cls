// No sharing keyword on purpose (as written years ago). Queued nightly by the region rollup scheduler.
public class CalMK1_InvoiceRollupService implements Queueable {
    public static Integer lastCount;
    public void execute(QueueableContext ctx) {
        lastCount = [SELECT COUNT() FROM CalMK1_Invoice__c];
    }
    public static Integer countAllInvoices() {
        return [SELECT COUNT() FROM CalMK1_Invoice__c];
    }
}