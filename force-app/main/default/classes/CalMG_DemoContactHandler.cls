// CALHACK-103 X-10 first attempt: reads the grandparent account name straight off the query result.
// Only contacts whose LastName starts with 'CalMG Demo' are touched (shared org).
public with sharing class CalMG_DemoContactHandler {
    public static void stampGroup(List<Contact> newContacts) {
        Set<Id> ids = new Set<Id>();
        for (Contact c : newContacts) {
            if (c.LastName != null && c.LastName.startsWith('CalMG Demo')) {
                ids.add(c.Id);
            }
        }
        if (ids.isEmpty()) {
            return;
        }
        List<Contact> updates = new List<Contact>();
        for (Contact c : [SELECT Id, Account.Parent.Name FROM Contact WHERE Id IN :ids]) {
            updates.add(new Contact(Id = c.Id, CalMG_Group__c = c.Account.Parent.Name.toUpperCase()));
        }
        update updates;
    }
}