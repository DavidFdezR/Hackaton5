@IsTest
private class CalMK4_OrderRestrictionOffTest {
    @IsTest static void repSeesEveryOrderOnceRuleDeactivated() {
        List<CalMK4_DemoOrder__c> others = new List<CalMK4_DemoOrder__c>();
        for (Integer i = 0; i < 3; i++) { others.add(new CalMK4_DemoOrder__c(Name = 'CalMK4 Demo Order Other ' + i, Status__c = 'Done')); }
        insert others; // owned by the running admin
        User rep;
        Integer existing;
        System.runAs(CalMK4_TestUsers.me()) {
            rep = CalMK4_TestUsers.make('ordrep');
            CalMK4_TestUsers.grant(rep.Id, 'CalMK4_DemoOrderViewer_PS');
        }
        System.runAs(rep) {
            insert new CalMK4_DemoOrder__c(Name = 'CalMK4 Demo Order Mine', Status__c = 'Done');
        }
        existing = [SELECT COUNT() FROM CalMK4_DemoOrder__c];
        System.runAs(rep) {
            Integer seen = [SELECT COUNT() FROM CalMK4_DemoOrder__c WITH USER_MODE];
            System.debug('CALMK4_EVIDENCE restriction rule DEACTIVATED: ' + existing + ' rows exist; rep sees=' + seen);
            System.assertEquals(existing, seen, 'with the rule off, Public Read Only OWD shows every order to the rep');
        }
    }
}