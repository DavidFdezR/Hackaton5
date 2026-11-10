// CALHACK-103 R-02 FIRST ATTEMPT: user-mode query of the item (including its master-detail parent),
// bump the order, then save the same sObject back in user mode.
public with sharing class CalMG_DemoRuleOrderService {
    public static void moveDown(Id itemId) {
        CalMG_Demo_Rule_Item__c item = [
            SELECT Id, Order__c, CalMG_Demo_Rule__c
            FROM CalMG_Demo_Rule_Item__c
            WHERE Id = :itemId
            WITH USER_MODE
        ];
        item.Order__c = item.Order__c + 1;
        Database.update(item, AccessLevel.USER_MODE);
    }
}