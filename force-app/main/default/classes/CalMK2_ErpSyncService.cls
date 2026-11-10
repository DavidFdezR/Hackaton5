/**
 * CALHACK Friday (CalMK2_) demo. Inserts an invoice and then calls the demo ERP (erp.demo.example).
 * mode: 'none' = DML then callout; 'rollback' = rollback to savepoint then callout;
 * 'rollbackRelease' = rollback, Database.releaseSavepoint, then callout (API 60.0+ pattern).
 * Only ever exercised from tests with an HttpCalloutMock. No remote site is registered.
 */
public with sharing class CalMK2_ErpSyncService {
    public static Integer insertThenCallout(String mode) {
        Savepoint sp = Database.setSavepoint();
        insert new CalMK2_Invoice__c(Name = 'CalMK2_ERP_Pending');
        if (mode == 'rollback' || mode == 'rollbackRelease') {
            Database.rollback(sp);
        }
        if (mode == 'rollbackRelease') {
            Database.releaseSavepoint(sp);
        }
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://erp.demo.example/invoices');
        req.setMethod('POST');
        req.setTimeout(10000);
        req.setBody('{"invoice":"CalMK2_ERP_Pending"}');
        return new Http().send(req).getStatusCode();
    }
}