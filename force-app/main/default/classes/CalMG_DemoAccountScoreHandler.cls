// CALHACK-103 R-06 FIRST ATTEMPT: trigger computes the score only; the before-save flow derives the tier.
public with sharing class CalMG_DemoAccountScoreHandler {
    public static void beforeSave(List<Account> rows) {
        for (Account a : rows) {
            if (a.Name == null || !a.Name.startsWith('CalMG Demo') || a.AnnualRevenue == null) {
                continue;
            }
            a.CalMG_Score__c = a.AnnualRevenue >= 1000000 ? 80 : 40;
        }
    }
}