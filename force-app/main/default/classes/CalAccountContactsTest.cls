@isTest
private class CalAccountContactsTest {
    @testSetup
    static void seed() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            accounts.add(new Account(Name = 'Cal Bulk ' + i));
        }
        insert accounts;
        List<Contact> contacts = new List<Contact>();
        for (Account a : accounts) {
            contacts.add(new Contact(LastName = 'One', AccountId = a.Id));
            contacts.add(new Contact(LastName = 'Two', AccountId = a.Id));
        }
        insert contacts;
    }

    @isTest
    static void bulkUpdateStaysWithinQueryLimits() {
        List<Account> accounts = [SELECT Id FROM Account WHERE Name LIKE 'Cal Bulk %'];
        Test.startTest();
        update accounts;
        Integer queries = Limits.getQueries();
        Test.stopTest();
        Assert.isTrue(queries <= 5, 'Expected a bulkified trigger, but it used ' + queries + ' queries');
        for (Account a : [SELECT Description FROM Account WHERE Id IN :accounts]) {
            Assert.areEqual('Contacts: 2', a.Description);
        }
    }

    @isTest
    static void accountWithoutContactsGetsZero() {
        Account a = new Account(Name = 'Cal Solo');
        insert a;
        a.Phone = '555-0100';
        update a;
        Assert.areEqual('Contacts: 0', [SELECT Description FROM Account WHERE Id = :a.Id].Description);
    }
}