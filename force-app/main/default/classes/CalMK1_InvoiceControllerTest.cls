@IsTest
private class CalMK1_InvoiceControllerTest {
    // Deliberately never calls getOpenInvoices: mirrors a suite that stays green when that member is dropped.
    @IsTest static void countsInvoices() {
        CalMK1_TestData.invoices(3, 'EMEA');
        System.assertEquals(3, CalMK1_InvoiceController.countInvoices());
    }
}