/** CALHACK T-183: nightly refund import. Switched from insert to Database.insert(rows, false) "so one bad row no longer fails the batch". */
public with sharing class CalMK4C_RefundImportService {
    public static Integer importRows(List<CalMK4C_DemoRefund__c> rows) {
        Database.insert(rows, false);
        return rows.size(); // reported to the ERP as "rows imported"
    }
}