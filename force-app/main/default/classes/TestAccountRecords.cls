@IsTest(SeeAllData=true)
public with sharing class TestAccountRecords {
    @IsTest
    static void testExposeLiveAccountRecords() {
        List<Account> liveAccounts = [SELECT Id, Name FROM Account];
        System.assert(liveAccounts.size() > 0, 'live records');
    }
}