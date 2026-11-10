@IsTest
private class CalMK1_InvoiceSummaryCtrlTest {
    @IsTest static void counts() {
        CalMK1_TestData.invoices(1, 'NA');
        System.assertEquals(1, new CalMK1_InvoiceSummaryCtrl().getVisibleCount());
    }
}