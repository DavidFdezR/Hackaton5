@IsTest
private class CalMK1_TaxServiceTest {
    // Custom metadata records are visible to tests without SeeAllData, so this asserts the live rule.
    @IsTest static void germanStandardRate() {
        System.assertEquals(119.00, CalMK1_TaxService.grossFor(100, 'CalMK1_DE_Standard'));
    }
    @IsTest static void invoiceTotals() {
        List<CalMK1_Invoice__c> rows = new List<CalMK1_Invoice__c>{ new CalMK1_Invoice__c(CalMK1_Amount__c = 200) };
        System.assertEquals(238.00, CalMK1_InvoiceTotals.grossTotal(rows));
    }
}