/** Starting state for Q-034/Q-035. Story: "import a CSV batch of orders; one bad row (negative Amount) must not block the
    good rows, and the caller must get the bad row's error back". Today one bad row fails the whole batch with a DmlException. */
public with sharing class CalMK6_OrderImportService {
    public static void importRows(List<CalMK6_Order__c> rows) {
        insert rows;
    }
}