// CALHACK-103 X-10 shared test: 199 contacts on child accounts plus 1 on an account with no parent, one insert.
@isTest
private class CalMG_DemoContactHandlerTest {
    @isTest
    static void bulkInsertWithOneOrphan() {
        Account parent = new Account(Name = 'CalMG Demo Parent');
        insert parent;
        List<Account> accts = new List<Account>();
        for (Integer i = 1; i <= 3; i++) {
            accts.add(new Account(Name = 'CalMG Demo Child ' + i, ParentId = parent.Id));
        }
        Account orphan = new Account(Name = 'CalMG Demo Orphan');
        accts.add(orphan);
        insert accts;

        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 199; i++) {
            contacts.add(new Contact(LastName = 'CalMG Demo Contact ' + i, AccountId = accts[Math.mod(i, 3)].Id));
        }
        contacts.add(new Contact(LastName = 'CalMG Demo Orphan Contact', AccountId = orphan.Id));

        Test.startTest();
        try {
            insert contacts;
        } catch (DmlException e) {
            Integer saved = [SELECT COUNT() FROM Contact WHERE LastName LIKE 'CalMG Demo%'];
            Assert.fail('insert of 200 failed, contacts saved = ' + saved + ': ' + e.getMessage());
        }
        Test.stopTest();

        Assert.areEqual(200, [SELECT COUNT() FROM Contact WHERE LastName LIKE 'CalMG Demo%'], 'all 200 saved');
        Assert.areEqual(199, [SELECT COUNT() FROM Contact WHERE CalMG_Group__c = 'CALMG DEMO PARENT'], '199 stamped');
        Assert.isNull([SELECT CalMG_Group__c FROM Contact WHERE LastName = 'CalMG Demo Orphan Contact'].CalMG_Group__c,
            'orphan group stays blank');
    }
}