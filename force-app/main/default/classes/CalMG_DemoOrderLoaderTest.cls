// CALHACK-103 X-09 shared test: 200 rows, one with a 60-character note on a 20-character field.
@isTest
private class CalMG_DemoOrderLoaderTest {
    @isTest
    static void batchWithOneLongNote() {
        List<CalMG_Demo_Order__c> rows = new List<CalMG_Demo_Order__c>();
        for (Integer i = 0; i < 200; i++) {
            rows.add(new CalMG_Demo_Order__c(Name = 'CALMG-LOAD-' + i, ExternalNote__c = 'ok ' + i));
        }
        String longNote = 'CalMG demo note '.repeat(4).left(60);
        rows[57].ExternalNote__c = longNote;

        Test.startTest();
        try {
            CalMG_DemoOrderLoader.load(rows);
        } catch (DmlException e) {
            Integer saved = [SELECT COUNT() FROM CalMG_Demo_Order__c WHERE Name LIKE 'CALMG-LOAD-%'];
            Assert.fail('load failed, rows saved = ' + saved + ': ' + e.getMessage());
        }
        Test.stopTest();

        Integer saved = [SELECT COUNT() FROM CalMG_Demo_Order__c WHERE Name LIKE 'CALMG-LOAD-%'];
        CalMG_Demo_Order__c longRow = null;
        for (CalMG_Demo_Order__c o : [SELECT ExternalNote__c FROM CalMG_Demo_Order__c WHERE Name = 'CALMG-LOAD-57']) {
            longRow = o;
        }
        Assert.areEqual(200, saved, 'rows saved; long row present = ' + (longRow != null));
        Assert.areEqual(longNote.left(20), longRow.ExternalNote__c, 'long note truncated to 20');
    }
}