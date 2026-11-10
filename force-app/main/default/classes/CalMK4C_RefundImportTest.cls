@IsTest
private class CalMK4C_RefundImportTest {
    @IsTest static void partialSuccessDropsRowsSilently() {
        List<CalMK4C_DemoRefund__c> rows = new List<CalMK4C_DemoRefund__c>();
        for (Integer i = 0; i < 200; i++) {
            // rows 10, 70 and 150 carry a negative amount (blocked by validation rule CalMK4C_AmountPositive)
            Decimal amt = (i == 10 || i == 70 || i == 150) ? -5 : 20;
            rows.add(new CalMK4C_DemoRefund__c(Name = 'CalMK4C Import ' + i, Amount__c = amt, Status__c = 'Pending'));
        }
        Integer reported;
        Test.startTest();
        reported = CalMK4C_RefundImportService.importRows(rows);
        Test.stopTest();
        Integer saved = [SELECT COUNT() FROM CalMK4C_DemoRefund__c WHERE Name LIKE 'CalMK4C Import %'];
        System.debug('CALMK4C_EVIDENCE allOrNone=false reported=' + reported + ' saved=' + saved + ' exceptionThrown=false');
        System.assertEquals(200, reported);
        System.assertEquals(197, saved);
        // contrast: the old all-or-nothing insert
        List<CalMK4C_DemoRefund__c> again = rows.deepClone(false, false, false);
        String old = 'no exception';
        try { insert again; } catch (DmlException e) { old = e.getDmlType(0) + ' row ' + e.getDmlIndex(0); }
        System.debug('CALMK4C_EVIDENCE old insert outcome=' + old);
        System.assert(old.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    }
}