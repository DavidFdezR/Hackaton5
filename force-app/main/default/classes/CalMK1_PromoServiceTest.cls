@IsTest
private class CalMK1_PromoServiceTest {
    @IsTest static void normalizes() {
        CalMK1_Invoice__c inv = new CalMK1_Invoice__c(CalMK1_Region__c = 'EMEA', CalMK1_PromoCode__c = ' demo-10 ');
        System.assertEquals('EMEA:DEMO-10', CalMK1_PromoService.normalize(inv));
        System.assert(CalMK1_PromoService.hasPromo(inv));
        System.assertEquals('NA:', CalMK1_PromoService.normalize(new CalMK1_Invoice__c()));
    }
}