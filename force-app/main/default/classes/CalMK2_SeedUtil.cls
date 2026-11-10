/**
 * CALHACK Friday (CalMK2_) seed utility. Runs in system mode so the demo data can be planted without granting
 * the shared admin user any FLS. Demo data only. Idempotent by Name.
 */
public with sharing class CalMK2_SeedUtil {
    public static Integer seedInvoices() {
        Set<String> have = new Set<String>();
        for (CalMK2_Invoice__c i : [SELECT Name FROM CalMK2_Invoice__c WHERE Name LIKE 'CalMK2_INV-00%']) {
            have.add(i.Name);
        }
        List<String> statuses = new List<String>{ 'Draft', 'Approved', 'Approved', 'Sent', 'Paid', 'Approved' };
        List<CalMK2_Invoice__c> rows = new List<CalMK2_Invoice__c>();
        for (Integer n = 1; n <= 6; n++) {
            String nm = 'CalMK2_INV-000' + n;
            if (!have.contains(nm)) {
                rows.add(new CalMK2_Invoice__c(Name = nm, Amount__c = 1000 * n, Status__c = statuses[n - 1],
                    Internal_Margin__c = 10 + n, External_Key__c = 'CALMK2-INV-000' + n));
            }
        }
        insert rows;
        return rows.size();
    }

    /** Changes Amount__c (not history-tracked) and Status__c (tracked) on CalMK2_INV-0003. */
    public static void changeInvoice3() {
        CalMK2_Invoice__c inv = [SELECT Id FROM CalMK2_Invoice__c WHERE Name = 'CalMK2_INV-0003' LIMIT 1];
        inv.Amount__c = 2400;
        inv.Status__c = 'On Hold';
        update inv;
    }

    /** Read-only: history rows for one invoice, read from class (system) context. */
    public static List<String> historyFor(String invoiceName) {
        List<String> out = new List<String>();
        for (CalMK2_Invoice__History h : [SELECT Field, OldValue, NewValue, CreatedDate FROM CalMK2_Invoice__History
                WHERE Parent.Name = :invoiceName ORDER BY CreatedDate, Field]) {
            out.add(h.Field + ': ' + h.OldValue + ' -> ' + h.NewValue + ' @ ' + h.CreatedDate);
        }
        return out;
    }

    public static String describeInvoice3() {
        CalMK2_Invoice__c inv = [SELECT Name, Amount__c, Status__c, LastModifiedDate FROM CalMK2_Invoice__c WHERE Name = 'CalMK2_INV-0003' LIMIT 1];
        return inv.Name + ' Amount=' + inv.Amount__c + ' Status=' + inv.Status__c;
    }
}