public with sharing class CalMK1_TruncationProbe {
    public static final String NAME = 'CalMK1 Demo Invoice Truncation';
    public static String seed() {
        CalMK1_Invoice__c inv = new CalMK1_Invoice__c(Name = NAME, CalMK1_Region__c = 'EMEA',
            CalMK1_PromoTwin__c = 'DEMO-WINTER-BUNDLE-2026-PARTNER-TIER-GOLD', CalMK1_PromoCode__c = 'DEMO-WINTER-BUNDLE-2026-PARTNER-TIER-GOLD');
        insert inv;
        return describe();
    }
    public static String describe() {
        CalMK1_Invoice__c r = [SELECT Id, CalMK1_PromoTwin__c, CalMK1_PromoCode__c FROM CalMK1_Invoice__c WHERE Name = :NAME ORDER BY CreatedDate DESC LIMIT 1];
        return 'twin=' + r.CalMK1_PromoTwin__c + ' len=' + (r.CalMK1_PromoTwin__c == null ? 0 : r.CalMK1_PromoTwin__c.length())
            + ' | hotFieldLen=' + (r.CalMK1_PromoCode__c == null ? 0 : r.CalMK1_PromoCode__c.length())
            + ' | twinDescribeLength=' + CalMK1_Invoice__c.CalMK1_PromoTwin__c.getDescribe().getLength();
    }
    public static String rewriteTwin() { // what the hot field's before-save flow does on every save: re-assign the same value
        CalMK1_Invoice__c r = [SELECT Id, CalMK1_PromoTwin__c FROM CalMK1_Invoice__c WHERE Name = :NAME ORDER BY CreatedDate DESC LIMIT 1];
        r.CalMK1_PromoTwin__c = r.CalMK1_PromoTwin__c.toUpperCase();
        try { update r; return 'rewrite ok'; } catch (Exception e) { return 'rewrite failed: ' + e.getMessage(); }
    }
    public static String insertLong() {
        Savepoint sp = Database.setSavepoint();
        try { insert new CalMK1_Invoice__c(Name = NAME + ' new', CalMK1_PromoTwin__c = 'DEMO-WINTER-BUNDLE-2026-PARTNER-TIER-GOLD'); Database.rollback(sp); return 'insert ok'; }
        catch (Exception e) { return 'insert failed: ' + e.getMessage(); }
    }
    public static String touch() {
        CalMK1_Invoice__c r = [SELECT Id FROM CalMK1_Invoice__c WHERE Name = :NAME ORDER BY CreatedDate DESC LIMIT 1];
        r.CalMK1_Region__c = 'EMEA-2';
        try { update r; return 'update ok'; } catch (Exception e) { return 'update failed: ' + e.getMessage(); }
    }
}