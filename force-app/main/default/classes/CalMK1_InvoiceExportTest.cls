@IsTest
private class CalMK1_InvoiceExportTest {
    @IsTest static void exportsOwnRegion() {
        CalMK1_TestData.invoices(2, 'NA');
        System.assertEquals(2, CalMK1_InvoiceExport.rowsForRegion('NA').size());
    }
}