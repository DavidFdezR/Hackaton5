@IsTest
private class CalMK4_PricingConfigTest {
    @IsTest static void protectedTypeIsReadableOutsideAPackage() {
        CalMK4_PricingConfig__mdt c = CalMK4_PricingConfig__mdt.getInstance('CalMK4_Default');
        System.debug('CALMK4_EVIDENCE protected CMT read in same (unpackaged) org=' + c.Discount_Ceiling__c);
        System.assertEquals(15.0, c.Discount_Ceiling__c);
    }
}