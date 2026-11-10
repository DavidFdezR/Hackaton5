@IsTest
private class CalMK4_AccountSearchTest {
    static final String PAYLOAD = 'x\' OR Name != \'x';
    @TestSetup static void data() {
        insert new List<CalMK4_DemoAccount__c>{
            new CalMK4_DemoAccount__c(Name = 'CalMK4 Demo Alpha', Tier__c = 'Gold'),
            new CalMK4_DemoAccount__c(Name = 'CalMK4 Demo Beta', Tier__c = 'Silver'),
            new CalMK4_DemoAccount__c(Name = 'CalMK4 Demo Gamma', Tier__c = 'Bronze') };
    }
    @IsTest static void injectionReturnsEveryRow() {
        Integer n = CalMK4_AccountSearch.find(PAYLOAD).size();
        System.debug('CALMK4_EVIDENCE unsafe rows=' + n);
        System.assertEquals(3, n, 'injected OR clause returns all rows');
    }
    @IsTest static void bindVariableReturnsNone() {
        Integer n = CalMK4_AccountSearchSafe.find(PAYLOAD).size();
        System.debug('CALMK4_EVIDENCE safe rows=' + n);
        System.assertEquals(0, n, 'payload is treated as a literal search term');
        System.assertEquals(1, CalMK4_AccountSearchSafe.find('Beta').size());
    }
}