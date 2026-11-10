@IsTest
private class CalMG_DemoOnboardingServiceTest {
    @IsTest static void knownDuplicateIsSavedAndFlagged() {
        CalMG_Demo_Customer__c existing = new CalMG_Demo_Customer__c(Name = 'CalMG Demo Customer A', National_Id__c = 'DEMO-NID-0001', Email__c = 'a@calmg-demo.example');
        insert existing;

        String err = 'none';
        Id secondId;
        try {
            secondId = CalMG_DemoOnboardingService.createCustomer('CalMG Demo Customer A2', 'DEMO-NID-0001', 'a2@calmg-demo.example');
        } catch (Exception e) {
            err = e.getTypeName() + ': ' + e.getMessage();
        }
        Integer rows = [SELECT COUNT() FROM CalMG_Demo_Customer__c WHERE National_Id__c = 'DEMO-NID-0001'];
        String trace = 'exception=' + err + '; rows with DEMO-NID-0001=' + rows;
        Assert.areEqual('none', err, 'duplicate applicant must be saved (' + trace + ')');
        CalMG_Demo_Customer__c second = [SELECT Possible_Duplicate_Of__c FROM CalMG_Demo_Customer__c WHERE Id = :secondId];
        Assert.areEqual(existing.Id, second.Possible_Duplicate_Of__c, 'linked to the matched customer (' + trace + ')');

        Id thirdId = CalMG_DemoOnboardingService.createCustomer('CalMG Demo Customer B', 'DEMO-NID-0002', 'b@calmg-demo.example');
        Assert.isNull([SELECT Possible_Duplicate_Of__c FROM CalMG_Demo_Customer__c WHERE Id = :thirdId].Possible_Duplicate_Of__c, 'non-matching customer not flagged');
    }
}