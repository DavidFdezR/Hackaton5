public with sharing class CalAccountContactsHandler {
    public static void summarize(List<Account> accounts) {
        for (Account a : accounts) {
            Integer contactCount = [SELECT COUNT() FROM Contact WHERE AccountId = :a.Id];
            a.Description = 'Contacts: ' + contactCount;
        }
    }
}