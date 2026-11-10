@IsTest
private class CalMK1_FlowRunModeTest {
    @IsTest static void runModeChangesVisibility() {
        User u = CalMK1_TestData.platformUser('flow');
        CalMK1_TestData.invoices(4, 'APAC'); // owned by admin, OWD Private
        Integer dflt; Integer sysNoShare;
        System.runAs(u) {
            Flow.Interview a = Flow.Interview.createInterview('CalMK1_InvoiceCount', new Map<String, Object>());
            a.start();
            dflt = Integer.valueOf(a.getVariableValue('invoiceCount'));
            Flow.Interview b = Flow.Interview.createInterview('CalMK1_InvoiceCount_SysNoShare', new Map<String, Object>());
            b.start();
            sysNoShare = Integer.valueOf(b.getVariableValue('invoiceCount'));
        }
        System.debug(LoggingLevel.ERROR, 'CALMK1_RESULT default=' + dflt + ' sysNoShare=' + sysNoShare);
        System.assertEquals(0, dflt, 'default run mode respects sharing for this caller');
        System.assertEquals(4, sysNoShare, 'System Context Without Sharing returns every record');
    }
}