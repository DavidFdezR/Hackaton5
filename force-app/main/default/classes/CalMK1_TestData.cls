@IsTest
public class CalMK1_TestData {
    public static List<CalMK1_Invoice__c> invoices(Integer n, String region) {
        List<CalMK1_Invoice__c> rows = new List<CalMK1_Invoice__c>();
        for (Integer i = 0; i < n; i++) {
            rows.add(new CalMK1_Invoice__c(Name = 'CalMK1 Demo Invoice ' + i, CalMK1_Region__c = region,
                CalMK1_Amount__c = 100, CalMK1_PromoCode__c = 'DEMO-PROMO-' + i));
        }
        insert rows;
        return rows;
    }
    // Platform-licence user (Standard Platform User profile). Counts against the 3 Salesforce Platform licences.
    public static User platformUser(String tag) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard Platform User' LIMIT 1];
        String u = 'calmk1.' + tag + '.' + String.valueOf(Crypto.getRandomInteger()).replace('-', '') + '@calmk1.demo.example';
        User usr = new User(Alias = 'cmk1' + tag.left(3), Email = 'calmk1.' + tag + '@calmk1.demo.example', EmailEncodingKey = 'UTF-8',
            LastName = 'CalMK1 Demo ' + tag, LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = p.Id,
            TimeZoneSidKey = 'America/Chicago', UserName = u);
        // setup-object DML isolated in its own runAs block to avoid MIXED_DML_OPERATION
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert usr;
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CalMK1_InvoiceReader' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr.Id, PermissionSetId = ps.Id);
        }
        return usr;
    }
}