@IsTest
private class CalMK4_StaleClaimSweepTest {
    static List<CalMK4_DemoClaim__c> claims() {
        List<CalMK4_DemoClaim__c> rows = new List<CalMK4_DemoClaim__c>();
        for (Integer i = 0; i < 4; i++) { rows.add(new CalMK4_DemoClaim__c(Name = 'CalMK4 Demo Claim ' + i, Status__c = 'Open')); }
        return rows;
    }
    /** T-141: scheduled from an adjuster's own login -> runs as that adjuster and only sweeps what they can see. */
    @IsTest static void scheduledByAdjusterSweepsOnlyTheirRows() {
        insert claims(); // 4 claims owned by admin
        User adj;
        System.runAs(CalMK4_TestUsers.me()) { adj = CalMK4_TestUsers.make('adjust'); CalMK4_TestUsers.grant(adj.Id, 'CalMK4_DemoClaimAdjuster_PS'); }
        System.runAs(adj) { insert new CalMK4_DemoClaim__c(Name = 'CalMK4 Demo Claim Mine', Status__c = 'Open'); }
        System.runAs(adj) {
            Test.startTest();
            Id jobId = System.schedule('CalMK4 Demo Stale Claim Sweep (adjuster)', '0 0 2 * * ?', new CalMK4_StaleClaimSweep());
            Test.stopTest();
        }
        Integer stale = [SELECT COUNT() FROM CalMK4_DemoClaim__c WHERE Status__c = 'Stale'];
        Integer open = [SELECT COUNT() FROM CalMK4_DemoClaim__c WHERE Status__c = 'Open'];
        Id owner = [SELECT OwnerId FROM CronTrigger WHERE CronJobDetail.Name = 'CalMK4 Demo Stale Claim Sweep (adjuster)' LIMIT 1].OwnerId;
        System.debug('CALMK4_EVIDENCE T-141 job owner is the adjuster=' + (owner == adj.Id) + ' ran as adjuster=' + (CalMK4_StaleClaimSweep.lastRunAs == adj.Id) + ' | swept=' + stale + ' still open=' + open + ' of 5');
        System.assertEquals(1, stale, 'restriction rule + with sharing: the job only sees the adjuster own claim');
    }
    /** T-142 twin: scheduled by a dedicated integration user with View All on claims -> sweeps every row. */
    @IsTest static void scheduledByIntegrationUserSweepsAll() {
        insert claims();
        User integ;
        System.runAs(CalMK4_TestUsers.me()) {
            integ = CalMK4_TestUsers.make('integsw');
            PermissionSet p = new PermissionSet(Name = 'CalMK4_RT_ClaimIntegration', Label = 'CalMK4 RT Claim Integration');
            insert p;
            insert new ObjectPermissions(ParentId = p.Id, SobjectType = 'CalMK4_DemoClaim__c', PermissionsRead = true, PermissionsEdit = true, PermissionsViewAllRecords = true, PermissionsModifyAllRecords = true, PermissionsDelete = true);
            insert new FieldPermissions(ParentId = p.Id, SobjectType = 'CalMK4_DemoClaim__c', Field = 'CalMK4_DemoClaim__c.Status__c', PermissionsRead = true, PermissionsEdit = true);
            insert new PermissionSetAssignment(AssigneeId = integ.Id, PermissionSetId = p.Id);
        }
        System.runAs(integ) {
            Test.startTest();
            System.schedule('CalMK4 Demo Stale Claim Sweep (integration)', '0 0 2 * * ?', new CalMK4_StaleClaimSweep());
            Test.stopTest();
        }
        Integer stale = [SELECT COUNT() FROM CalMK4_DemoClaim__c WHERE Status__c = 'Stale'];
        System.debug('CALMK4_EVIDENCE T-142 integration-user schedule swept=' + stale + ' of 4');
        System.assertEquals(4, stale);
    }
}