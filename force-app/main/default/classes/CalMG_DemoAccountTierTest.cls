// CALHACK-103 R-06 shared test: tier must match the score written on the same save.
@isTest
private class CalMG_DemoAccountTierTest {
    private static Account readBack(Id accountId) {
        return [SELECT CalMG_Score__c, CalMG_Tier__c FROM Account WHERE Id = :accountId];
    }

    @isTest
    static void insertHighRevenueIsGoldOnSameSave() {
        Account a = new Account(Name = 'CalMG Demo R06 Insert', AnnualRevenue = 2000000);
        Test.startTest();
        insert a;
        Test.stopTest();
        Account got = readBack(a.Id);
        Assert.areEqual(80, got.CalMG_Score__c, 'score from trigger');
        Assert.areEqual('Gold', got.CalMG_Tier__c,
            'tier after insert; read back Score=' + got.CalMG_Score__c + ' Tier=' + got.CalMG_Tier__c);
    }

    @isTest
    static void updateLowerRevenueIsSilverOnSameSave() {
        Account a = new Account(Name = 'CalMG Demo R06 Update', AnnualRevenue = 2000000);
        insert a;
        Account afterInsert = readBack(a.Id);
        Test.startTest();
        a.AnnualRevenue = 100;
        update a;
        Test.stopTest();
        Account got = readBack(a.Id);
        Assert.areEqual(40, got.CalMG_Score__c, 'score from trigger');
        Assert.areEqual('Silver', got.CalMG_Tier__c,
            'tier after update; after insert Score=' + afterInsert.CalMG_Score__c + ' Tier=' + afterInsert.CalMG_Tier__c
            + '; after update Score=' + got.CalMG_Score__c + ' Tier=' + got.CalMG_Tier__c);
    }
}