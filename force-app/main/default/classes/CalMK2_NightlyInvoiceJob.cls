/**
 * CALHACK Friday (CalMK2_) demo schedulable. execute() only writes a debug line (no DML, no chaining).
 * Scheduled once in the hack org as 'CalMK2_Nightly_Invoice_Job' for 2099 so its CronTrigger exists.
 */
public with sharing class CalMK2_NightlyInvoiceJob implements Schedulable {
    public static final String VERSION = 'v1';
    public void execute(SchedulableContext ctx) {
        System.debug('CalMK2_NightlyInvoiceJob ' + VERSION + ' ran');
    }
}