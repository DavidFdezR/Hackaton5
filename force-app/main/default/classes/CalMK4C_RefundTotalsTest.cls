@IsTest
private class CalMK4C_RefundTotalsTest {
    @IsTest static void apiVersionBumpChangesWhatTheSameCodeSees() {
        User agent = CalMK4C_TestUsers.agentWithOneOwnRefund();
        System.runAs(agent) {
            // called from the without sharing export job, as in production
            Decimal v66 = CalMK4C_RefundExportJob.totalV66();
            Decimal v67 = CalMK4C_RefundExportJob.totalV67();
            Decimal safe66 = CalMK4C_RefundExportJob.safeV66();
            Decimal safe67 = CalMK4C_RefundExportJob.safeV67();
            System.debug('CALMK4C_EVIDENCE no-keyword class via without sharing job: apiVersion 66.0 total=' + v66 + ' | apiVersion 67.0 total=' + v67);
            System.debug('CALMK4C_EVIDENCE explicit with sharing + USER_MODE via same job: 66.0 total=' + safe66 + ' | 67.0 total=' + safe67);
            System.assertEquals(1045, v66, 'v66: no keyword inherits the job\'s without sharing: all 4 refunds');
            System.assertEquals(25, v67, 'v67: no keyword now means with sharing: only the running user\'s refund');
            System.assertEquals(safe66, safe67, 'explicit class is unaffected by the bump');
        }
    }
}