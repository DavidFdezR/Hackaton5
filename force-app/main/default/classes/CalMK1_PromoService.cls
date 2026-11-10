public with sharing class CalMK1_PromoService {
    public static String normalize(CalMK1_Invoice__c inv) {
        return buildKey(inv.CalMK1_Region__c, inv.CalMK1_PromoCode__c);
    }
    public static Boolean hasPromo(CalMK1_Invoice__c inv) {
        return String.isNotBlank(inv.CalMK1_PromoCode__c);
    }
    private static String buildKey(String region, String code) {
        return (region == null ? 'NA' : region) + ':' + (code == null ? '' : code.trim().toUpperCase());
    }
}