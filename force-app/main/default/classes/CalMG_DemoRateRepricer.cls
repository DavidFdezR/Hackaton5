// CalMG demo: nightly base-rate change job (stands in for the rate-feed integration).
public with sharing class CalMG_DemoRateRepricer {
    // Returns ids of loans that could not be repriced now (none in this version).
    public static List<Id> reprice(Set<Id> loanIds, Decimal newRate) {
        List<CalMG_Demo_Loan__c> loans = [SELECT Id, Interest_Rate__c FROM CalMG_Demo_Loan__c WHERE Id IN :loanIds];
        for (CalMG_Demo_Loan__c l : loans) {
            l.Interest_Rate__c = newRate;
        }
        update loans;
        return new List<Id>();
    }
}