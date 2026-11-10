@IsTest
private class CalMK4C_RefundTableTest {
    @IsTest static void escapedColumnListStillReadsHiddenField() {
        User agent = CalMK4C_TestUsers.agentWithOneOwnRefund();
        System.runAs(agent) {
            System.assert(!Schema.sObjectType.CalMK4C_DemoRefund__c.fields.Bank_Account__c.isAccessible(), 'agent has no FLS on Bank_Account__c');
            List<SObject> rows = CalMK4C_RefundTableCtrl.getRows('Name, Bank_Account__c');
            String userMode = 'no exception';
            try { Database.query('SELECT Id, Name, Bank_Account__c FROM CalMK4C_DemoRefund__c WITH USER_MODE'); }
            catch (Exception e) { userMode = e.getTypeName() + ': ' + e.getMessage(); }
            System.debug('CALMK4C_EVIDENCE escaped columns rows=' + rows.size() + ' Bank_Account__c=' + rows[0].get('Bank_Account__c'));
            System.debug('CALMK4C_EVIDENCE same query WITH USER_MODE=' + userMode);
            System.assertEquals(1, rows.size(), 'with sharing still limits rows to the agent\'s own refund');
            System.assertEquals('DEMO-ACCT-0099', rows[0].get('Bank_Account__c'), 'FLS-hidden field returned');
            System.assert(userMode.contains('QueryException'));
        }
    }
}