// CALHACK-103 X-02 first attempt (saved at apiVersion 66.0): plain SOQL in an @AuraEnabled getter.
public with sharing class CalMG_DemoEmployeeController {
    @AuraEnabled
    public static Decimal getSalary(Id recordId) {
        return [SELECT Salary__c FROM CalMG_Demo_Staff__c WHERE Id = :recordId].Salary__c;
    }
}