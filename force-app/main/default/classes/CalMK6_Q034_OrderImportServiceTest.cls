/** Q-034 agent's own test: asserts only that no exception escapes. Passes. */
@IsTest
private class CalMK6_Q034_OrderImportServiceTest {
    @IsTest static void badRowDoesNotThrow() {
        Boolean threw = false;
        try { CalMK6_Q034_OrderImportService.importRows(CalMK6_ImportTestData.tenRowsOneBad()); } catch (Exception e) { threw = true; }
        Assert.isFalse(threw);
    }
}