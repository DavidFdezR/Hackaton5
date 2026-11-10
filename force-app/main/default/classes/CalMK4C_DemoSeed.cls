/** CALHACK round 3 C: seeds and reads demo refunds in system mode (the admin running anonymous Apex has no FLS on the demo fields). */
public without sharing class CalMK4C_DemoSeed {
    public static void run() {
        Set<String> have = new Set<String>();
        for (CalMK4C_DemoRefund__c r : [SELECT Name FROM CalMK4C_DemoRefund__c]) have.add(r.Name);
        List<CalMK4C_DemoRefund__c> toAdd = new List<CalMK4C_DemoRefund__c>();
        for (Integer i = 1; i <= 3; i++) {
            String n = 'CalMK4C Demo Refund 00' + i;
            if (!have.contains(n)) toAdd.add(new CalMK4C_DemoRefund__c(Name = n, Amount__c = 100 * i, Status__c = 'Pending', Bank_Account__c = 'DEMO-ACCT-100' + i));
        }
        insert toAdd;
        show();
    }
    public static void show() {
        for (CalMK4C_DemoRefund__c r : [SELECT Id, Name, Status__c, Notes__c, Approved__c FROM CalMK4C_DemoRefund__c ORDER BY Name])
            System.debug('CALMK4C_SEED ' + r.Name + ' ' + r.Id + ' status=' + r.Status__c + ' notes=' + r.Notes__c + ' approved=' + r.Approved__c);
    }
    public static void resetStatus(String name) {
        CalMK4C_DemoRefund__c r = [SELECT Id FROM CalMK4C_DemoRefund__c WHERE Name = :name];
        r.Status__c = 'Pending';
        update r;
        show();
    }
    public static void seedSecret() {
        CalMK4C_ErpSecret__c cfg = CalMK4C_ErpSecret__c.getOrgDefaults();
        cfg.Api_Key__c = 'DEMO_PASSWORD_PLACEHOLDER';
        upsert cfg;
    }
    /** T-183 committed demo: 5 import rows, the 4th has a negative amount (blocked by CalMK4C_AmountPositive). */
    public static void seedImport() {
        if ([SELECT COUNT() FROM CalMK4C_DemoRefund__c WHERE Name LIKE 'CalMK4C Import Demo %'] > 0) { showImport(); return; }
        List<CalMK4C_DemoRefund__c> rows = new List<CalMK4C_DemoRefund__c>();
        for (Integer i = 1; i <= 5; i++) rows.add(new CalMK4C_DemoRefund__c(Name = 'CalMK4C Import Demo ' + i, Amount__c = (i == 4 ? -5 : 10 * i), Status__c = 'Pending'));
        Integer reported = CalMK4C_RefundImportService.importRows(rows);
        System.debug('CALMK4C_SEED import reported=' + reported);
        showImport();
    }
    public static void showImport() {
        System.debug('CALMK4C_SEED import saved=' + [SELECT COUNT() FROM CalMK4C_DemoRefund__c WHERE Name LIKE 'CalMK4C Import Demo %'] + ' names=' + [SELECT Name FROM CalMK4C_DemoRefund__c WHERE Name LIKE 'CalMK4C Import Demo %' ORDER BY Name]);
    }
    /** extra pre-state record for T-181 / T-178 counts. */
    public static void seedExtra() {
        if ([SELECT COUNT() FROM CalMK4C_DemoRefund__c WHERE Name = 'CalMK4C Demo Refund 004'] == 0)
            insert new CalMK4C_DemoRefund__c(Name = 'CalMK4C Demo Refund 004', Amount__c = 400, Status__c = 'Paid', Bank_Account__c = 'DEMO-ACCT-1004');
        show();
    }
}