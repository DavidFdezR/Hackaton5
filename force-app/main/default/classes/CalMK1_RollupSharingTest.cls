@IsTest
private class CalMK1_RollupSharingTest {
    // Entry point = the Queueable itself (as when the scheduler enqueues it as the integration user).
    @IsTest static void apiVersionBumpChangesVisibilityAsEntryPoint() {
        User u = CalMK1_TestData.platformUser('rollq');
        CalMK1_TestData.invoices(5, 'EMEA'); // owned by the running admin; OWD Private
        System.runAs(u) {
            Test.startTest();
            System.enqueueJob(new CalMK1_InvoiceRollupService());
            System.enqueueJob(new CalMK1_InvoiceRollupServiceV67());
            Test.stopTest();
        }
        System.debug(LoggingLevel.ERROR, 'CALMK1_RESULT queueable v62=' + CalMK1_InvoiceRollupService.lastCount + ' v67=' + CalMK1_InvoiceRollupServiceV67.lastCount);
        System.assertEquals(5, CalMK1_InvoiceRollupService.lastCount, 'v62 entry point with no sharing keyword runs without sharing');
        System.assertEquals(0, CalMK1_InvoiceRollupServiceV67.lastCount, 'v67 entry point with no sharing keyword runs with sharing');
    }
    // Called from an explicit without-sharing caller.
    @IsTest static void apiVersionBumpUnderWithoutSharingCaller() {
        User u = CalMK1_TestData.platformUser('rollc');
        CalMK1_TestData.invoices(5, 'EMEA');
        Integer v62; Integer v67;
        System.runAs(u) { v62 = CalMK1_RollupCaller.viaV62(); v67 = CalMK1_RollupCaller.viaV67(); }
        System.debug(LoggingLevel.ERROR, 'CALMK1_RESULT caller v62=' + v62 + ' v67=' + v67);
        System.assertEquals(5, v62, 'v62 inherits the without-sharing caller');
        System.assertEquals(0, v67, 'v67 ignores the caller and runs with sharing');
    }
}