@IsTest
private class CalMK4_ErpConfigTest {
    @IsTest static void anyUserCodePathReadsTheKey() {
        insert new CalMK4_ErpConfig__c(SetupOwnerId = UserInfo.getOrganizationId(), Api_Key__c = 'DEMO_PASSWORD_PLACEHOLDER');
        User u;
        System.runAs(CalMK4_TestUsers.me()) { u = CalMK4_TestUsers.make('nobody'); }
        System.runAs(u) {
            String viaApex = CalMK4_ErpConfig__c.getOrgDefaults().Api_Key__c;
            String viaUserMode = 'no exception';
            try { viaUserMode = String.valueOf([SELECT Api_Key__c FROM CalMK4_ErpConfig__c WITH USER_MODE LIMIT 1]); }
            catch (Exception e) { viaUserMode = e.getTypeName() + ': ' + e.getMessage(); }
            System.debug('CALMK4_EVIDENCE plain user getOrgDefaults=' + viaApex + ' | USER_MODE SOQL=' + viaUserMode);
            System.assertEquals('DEMO_PASSWORD_PLACEHOLDER', viaApex, 'any Apex running for any user returns the key');
        }
    }
}