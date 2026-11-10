public without sharing class CalMK1_RollupCaller {
    public static Integer viaV62() { return CalMK1_InvoiceRollupService.countAllInvoices(); }
    public static Integer viaV67() { return CalMK1_InvoiceRollupServiceV67.countAllInvoices(); }
}