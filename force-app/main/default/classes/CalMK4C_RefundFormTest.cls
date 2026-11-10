@IsTest
private class CalMK4C_RefundFormTest {
    @IsTest static void clientCanWriteFieldsTheFormNeverShowed() {
        User agent = CalMK4C_TestUsers.agentWithOneOwnRefund();
        Id mineId = [SELECT Id FROM CalMK4C_DemoRefund__c WHERE Name = 'CalMK4C Demo Refund Mine'].Id;
        String safeOutcome = 'no exception';
        System.runAs(agent) {
            System.assert(!Schema.sObjectType.CalMK4C_DemoRefund__c.fields.Approved__c.isUpdateable(), 'agent has read-only FLS on Approved__c');
            // payload a browser console could send: the form only shows Amount/Notes
            CalMK4C_RefundFormCtrl.saveRefund(new CalMK4C_DemoRefund__c(Id = mineId, Notes__c = 'edited', Approved__c = true, Amount__c = 9999));
            try {
                CalMK4C_RefundFormCtrlSafe.saveRefund(new CalMK4C_DemoRefund__c(Id = mineId, Approved__c = false));
            } catch (Exception e) { safeOutcome = e.getTypeName() + ': ' + e.getMessage(); }
        }
        CalMK4C_DemoRefund__c after = [SELECT Approved__c, Amount__c FROM CalMK4C_DemoRefund__c WHERE Id = :mineId];
        System.debug('CALMK4C_EVIDENCE custom Apex save -> Approved__c=' + after.Approved__c + ' Amount__c=' + after.Amount__c);
        System.debug('CALMK4C_EVIDENCE update as user outcome=' + safeOutcome);
        System.assertEquals(true, after.Approved__c, 'system-mode DML wrote a field the agent cannot edit');
        System.assert(safeOutcome.contains('Exception'), 'user-mode DML rejects the read-only field');
    }
}