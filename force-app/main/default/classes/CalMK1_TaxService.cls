public with sharing class CalMK1_TaxService {
    public static Decimal grossFor(Decimal net, String ruleName) {
        CalMK1_TaxRule__mdt rule = CalMK1_TaxRule__mdt.getInstance(ruleName);
        return (net * (1 + rule.CalMK1_RatePct__c / 100)).setScale(2);
    }
}