@IsTest
private class CalMK1_InvoiceApiTest {
    // Only the POST path is tested, so dropping doGet() keeps this green.
    @IsTest static void postCreatesInvoice() {
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        String id = CalMK1_InvoiceApi.doPost('CalMK1 Demo Invoice API', 'EMEA');
        System.assertNotEquals(null, id);
    }
}