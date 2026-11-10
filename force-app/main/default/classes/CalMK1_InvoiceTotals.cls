public with sharing class CalMK1_InvoiceTotals {
    public static Decimal grossTotal(List<CalMK1_Invoice__c> rows) {
        Decimal total = 0;
        for (CalMK1_Invoice__c r : rows) { total += CalMK1_TaxService.grossFor(r.CalMK1_Amount__c, 'CalMK1_DE_Standard'); }
        return total;
    }
}