@IsTest
private class CalMK4_TierRuleTest {
    @IsTest static void blankTierBlockedForIntegrationUserBeforeBypass() {
        User u;
        System.runAs(CalMK4_TestUsers.me()) {
            u = CalMK4_TestUsers.make('integ');
            CalMK4_TestUsers.grant(u.Id, 'CalMK4_DemoIntegration_PS');
        }
        System.runAs(u) {
            Database.SaveResult r = Database.insert(new CalMK4_DemoAccount__c(Name = 'CalMK4 Demo Load 1'), false);
            System.debug('CALMK4_EVIDENCE pre-change insert success=' + r.isSuccess() + ' errors=' + r.getErrors());
            System.assertEquals(false, r.isSuccess(), 'CalMK4_TierRequired blocks blank Tier before the bypass exists');
        }
    }
}