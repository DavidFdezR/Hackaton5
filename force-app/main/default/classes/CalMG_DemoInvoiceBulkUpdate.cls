// CALHACK-103 R-08 demo: applies new amounts with partial success allowed.
public with sharing class CalMG_DemoInvoiceBulkUpdate {
    public static List<Database.SaveResult> applyAmounts(Map<Id, Decimal> amountById) {
        List<CalMG_Demo_Invoice__c> rows = new List<CalMG_Demo_Invoice__c>();
        for (Id invoiceId : amountById.keySet()) {
            rows.add(new CalMG_Demo_Invoice__c(Id = invoiceId, Amount__c = amountById.get(invoiceId)));
        }
        return Database.update(rows, false);
    }
}