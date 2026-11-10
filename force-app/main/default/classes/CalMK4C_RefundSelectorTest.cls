@IsTest
private class CalMK4C_RefundSelectorTest {
    @IsTest static void inheritedSharingTakesTheCallersMode() {
        User agent = CalMK4C_TestUsers.agentWithOneOwnRefund();
        System.runAs(agent) {
            Integer viaWithout = CalMK4C_RefundPortalCtrl.myRefunds().size();
            Integer viaWith = CalMK4C_RefundListCtrl.myRefunds().size();
            System.debug('CALMK4C_EVIDENCE selector via without sharing caller rows=' + viaWithout + ' | via with sharing caller rows=' + viaWith);
            System.assertEquals(4, viaWithout, 'inherited sharing ran without sharing: 3 refunds owned by others leak');
            System.assertEquals(1, viaWith, 'same selector from a with sharing caller returns only the agent\'s own refund');
        }
    }
}