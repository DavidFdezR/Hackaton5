@IsTest
private class CalMK1_TruncationProbeTest {
    // Short values only: the twin field is 20 chars in the org after the S-051 experiment.
    @IsTest static void probe() {
        insert new CalMK1_Invoice__c(Name = CalMK1_TruncationProbe.NAME, CalMK1_PromoTwin__c = 'DEMO-SHORT', CalMK1_PromoCode__c = 'DEMO-SHORT');
        System.assert(CalMK1_TruncationProbe.describe().contains('len='));
        System.assert(CalMK1_TruncationProbe.touch().startsWith('update'));
        System.assert(CalMK1_TruncationProbe.rewriteTwin().startsWith('rewrite'));
        System.assert(CalMK1_TruncationProbe.insertLong().startsWith('insert'));
    }
}