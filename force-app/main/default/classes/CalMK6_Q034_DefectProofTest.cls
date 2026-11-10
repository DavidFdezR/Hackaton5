/** Q-034 reviewer evidence: all-or-nothing insert inside the empty catch means 0 of 10 rows saved and no error reported. PASSES by asserting that. */
@IsTest
private class CalMK6_Q034_DefectProofTest {
    @IsTest static void zeroOfTenSavedSilently() {
        CalMK6_Q034_OrderImportService.importRows(CalMK6_ImportTestData.tenRowsOneBad());
        Integer saved = [SELECT COUNT() FROM CalMK6_Order__c WHERE Name LIKE 'CalMK6_Imp%'];
        System.debug('CALMK6_Q034 saved=' + saved);
        Assert.areEqual(0, saved);
    }
}