/** CALHACK T-178: new selector, declared inherited sharing ("secure by default"). */
public inherited sharing class CalMK4C_RefundSelector {
    public static List<CalMK4C_DemoRefund__c> openRefunds() {
        return [SELECT Id, Name, Amount__c, Status__c FROM CalMK4C_DemoRefund__c ORDER BY Name];
    }
}