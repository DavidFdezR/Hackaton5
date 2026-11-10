// CalMG demo: account-opening integration creates the customer profile.
public with sharing class CalMG_DemoOnboardingService {
    public static Id createCustomer(String name, String nationalId, String email) {
        CalMG_Demo_Customer__c c = new CalMG_Demo_Customer__c(Name = name, National_Id__c = nationalId, Email__c = email);
        insert c;
        return c.Id;
    }
}