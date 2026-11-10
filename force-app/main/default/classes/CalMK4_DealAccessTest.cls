@IsTest
private class CalMK4_DealAccessTest {
    @IsTest static void repCannotSeeOtherTeamsDealWithoutModifyAll() {
        CalMK4_DemoDeal__c d = new CalMK4_DemoDeal__c(Name = 'CalMK4 Demo Deal EMEA', Amount__c = 50000);
        insert d; // owned by the running admin
        User rep;
        System.runAs(CalMK4_TestUsers.me()) {
            rep = CalMK4_TestUsers.make('rep');
            CalMK4_TestUsers.grant(rep.Id, 'CalMK4_DemoSales_Rep');
        }
        System.runAs(rep) {
            Integer seen = [SELECT COUNT() FROM CalMK4_DemoDeal__c WHERE Id = :d.Id WITH USER_MODE];
            System.debug('CALMK4_EVIDENCE pre-change rep sees=' + seen);
            System.assertEquals(0, seen, 'Private OWD hides other owners deals');
        }
    }
}