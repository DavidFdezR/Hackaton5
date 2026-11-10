// CALHACK-103 R-08 shared test: partial-success update must leave one audit row per invoice that saved.
@isTest
private class CalMG_DemoInvoiceBulkUpdateTest {
    private static List<CalMG_Demo_Invoice__c> makeInvoices() {
        List<CalMG_Demo_Invoice__c> rows = new List<CalMG_Demo_Invoice__c>{
            new CalMG_Demo_Invoice__c(Name = 'CalMG Demo INV-1', Amount__c = 100),
            new CalMG_Demo_Invoice__c(Name = 'CalMG Demo INV-2', Amount__c = 100),
            new CalMG_Demo_Invoice__c(Name = 'CalMG Demo INV-3', Amount__c = 100)
        };
        insert rows;
        return rows;
    }

    @isTest
    static void partialSuccessAuditsEverySavedInvoice() {
        List<CalMG_Demo_Invoice__c> rows = makeInvoices();
        Map<Id, Decimal> amounts = new Map<Id, Decimal>{
            rows[0].Id => 200, rows[1].Id => 300, rows[2].Id => -5 // third one breaks the validation rule
        };
        Test.startTest();
        List<Database.SaveResult> results = CalMG_DemoInvoiceBulkUpdate.applyAmounts(amounts);
        Test.stopTest();

        Set<Id> saved = new Set<Id>();
        Integer failed = 0;
        for (Database.SaveResult r : results) {
            if (r.isSuccess()) { saved.add(r.getId()); } else { failed++; }
        }
        Assert.areEqual(2, saved.size(), 'two invoices should save');
        Assert.areEqual(1, failed, 'one invoice should fail the validation rule');
        Integer committedAudits = [SELECT COUNT() FROM CalMG_Demo_Invoice_Audit__c WHERE Invoice__c IN :saved];
        Assert.areEqual(2, committedAudits,
            'audit rows for the 2 saved invoices; trigger invocations in this transaction = '
            + CalMG_DemoInvoiceTriggerHandler.invocations);
    }

    @isTest
    static void allValidUpdateAuditsEveryInvoice() {
        List<CalMG_Demo_Invoice__c> rows = makeInvoices();
        Map<Id, Decimal> amounts = new Map<Id, Decimal>{ rows[0].Id => 10, rows[1].Id => 20, rows[2].Id => 30 };
        Test.startTest();
        CalMG_DemoInvoiceBulkUpdate.applyAmounts(amounts);
        Test.stopTest();
        Assert.areEqual(3, [SELECT COUNT() FROM CalMG_Demo_Invoice_Audit__c], 'one audit row per invoice');
    }
}