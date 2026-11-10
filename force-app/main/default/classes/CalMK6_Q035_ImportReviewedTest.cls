/** Q-035 reviewer's added assertions: 9 saved AND exactly one error naming row 4 and the validation message. */
@IsTest
private class CalMK6_Q035_ImportReviewedTest {
    @IsTest static void nineSavedOneErrorReturned() {
        List<String> errs = CalMK6_Q035_ImportReviewed.importRows(CalMK6_ImportTestData.tenRowsOneBad());
        Assert.areEqual(9, [SELECT COUNT() FROM CalMK6_Order__c WHERE Name LIKE 'CalMK6_Imp%']);
        Assert.areEqual(1, errs.size());
        Assert.isTrue(errs[0].startsWith('row 4: '), errs[0]);
        Assert.isTrue(errs[0].contains('Amount must not be negative'), errs[0]);
    }
}