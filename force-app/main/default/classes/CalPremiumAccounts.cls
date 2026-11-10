public with sharing class CalPremiumAccounts {
    public static Integer contactCount(String accountName) {
        return [SELECT COUNT() FROM Contact WHERE Account.Name = :accountName];
    }
}