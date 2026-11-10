/**
 * CALHACK-101 D2 (Harshit's B-1xx/B-2xx rows): run-as proofs for the screen claims.
 * Every user and record here is created inside the test and rolled back; nothing is committed.
 */
@IsTest
private class CalTD_D2_BrowserProofs_Test {
    private static Integer seq = 0;
    private static User mkUser(String profileName, String email) {
        seq++;
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName];
        String suffix = String.valueOf(Crypto.getRandomInteger()).replace('-', '') + seq;
        User u = new User(ProfileId = p.Id, LastName = 'CalTD D2 ' + seq, Alias = 'ctd2' + seq,
            Email = email, Username = 'caltd.d2.' + suffix + '@calhk-d2.example',
            TimeZoneSidKey = 'America/Chicago', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US');
        insert u;
        return u;
    }
    private static void assignPs(Id userId, String psName) {
        insert new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = :psName].Id);
    }

    // B-101 / B-102: CalHK_Demo_Sales grants Read on Region Present, not on Region Absent.
    @IsTest static void b101_b102_fieldLevelSecurity() {
        User u = mkUser('Minimum Access - Salesforce', 'caltd.d2@calhk-d2.example');
        assignPs(u.Id, 'CalHK_Demo_Sales');
        System.runAs(u) {
            Boolean present = Schema.SObjectType.CalHK_Contract__c.fields.Region_Present__c.isAccessible();
            Boolean absent = Schema.SObjectType.CalHK_Contract__c.fields.Region_Absent__c.isAccessible();
            System.debug('CALTD B-101 Region_Present__c accessible=' + present + ' | B-102 Region_Absent__c accessible=' + absent);
            System.assertEquals(true, present, 'B-101: Region Present must be readable via CalHK_Demo_Sales');
            System.assertEquals(false, absent, 'B-102: Region Absent must stay hidden by FLS');
        }
    }

    // B-201 / B-202: default record type per profile.
    @IsTest static void b201_b202_recordTypeDefault() {
        User pres = mkUser('CalHK Contract Ops Present', 'caltd.d2@calhk-d2.example');
        User abs = mkUser('CalHK Contract Ops Absent', 'caltd.d2@calhk-d2.example');
        System.runAs(pres) {
            Map<String, Schema.RecordTypeInfo> m = Schema.SObjectType.CalHK_Contract__c.getRecordTypeInfosByDeveloperName();
            System.debug('CALTD B-201 Renewal available=' + m.get('CalHK_Renewal').isAvailable() + ' default=' + m.get('CalHK_Renewal').isDefaultRecordTypeMapping());
            System.assert(m.get('CalHK_Renewal').isAvailable() && m.get('CalHK_Renewal').isDefaultRecordTypeMapping());
        }
        System.runAs(abs) {
            Map<String, Schema.RecordTypeInfo> m = Schema.SObjectType.CalHK_Contract__c.getRecordTypeInfosByDeveloperName();
            System.debug('CALTD B-202 Renewal available=' + m.get('CalHK_Renewal').isAvailable() + ' default=' + m.get('CalHK_Renewal').isDefaultRecordTypeMapping()
                + ' | Standard default=' + m.get('CalHK_Standard').isDefaultRecordTypeMapping());
            System.assert(m.get('CalHK_Renewal').isAvailable());
            System.assertEquals(false, m.get('CalHK_Renewal').isDefaultRecordTypeMapping());
            System.assertEquals(true, m.get('CalHK_Standard').isDefaultRecordTypeMapping());
        }
    }

    // B-215 / B-216: muting set removes Delete only in the Present group.
    @IsTest static void b215_b216_muting() {
        Map<String, Id> g = new Map<String, Id>();
        for (PermissionSetGroup x : [SELECT Id, DeveloperName FROM PermissionSetGroup WHERE DeveloperName IN ('CalHK_Mute_Present_PSG', 'CalHK_Mute_Absent_PSG')]) g.put(x.DeveloperName, x.Id);
        Test.calculatePermissionSetGroup(g.values());
        User pres = mkUser('Standard Platform User', 'caltd.d2@calhk-d2.example');
        User abs = mkUser('Standard Platform User', 'caltd.d2@calhk-d2.example');
        insert new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = pres.Id, PermissionSetGroupId = g.get('CalHK_Mute_Present_PSG')),
            new PermissionSetAssignment(AssigneeId = abs.Id, PermissionSetGroupId = g.get('CalHK_Mute_Absent_PSG')) };
        Boolean pDel, pRead, aDel;
        System.runAs(pres) { pDel = Schema.SObjectType.CalHK_Invoice__c.isDeletable(); pRead = Schema.SObjectType.CalHK_Invoice__c.isAccessible(); }
        System.runAs(abs) { aDel = Schema.SObjectType.CalHK_Invoice__c.isDeletable(); }
        System.debug('CALTD B-215 Present PSG deletable=' + pDel + ' readable=' + pRead + ' | B-216 Absent PSG deletable=' + aDel);
        System.assertEquals(false, pDel, 'B-215: Delete muted');
        System.assertEquals(true, pRead, 'B-215: Read still granted');
        System.assertEquals(true, aDel, 'B-216: nothing muted, Delete still granted');
    }

    // B-211 / B-212: Demo Case Routing (inactive) routes High to CalHK_Escalations only when invoked by id; the default rule does not.
    @IsTest static void b211_b212_assignmentRule() {
        AssignmentRule r = [SELECT Id, Active FROM AssignmentRule WHERE SobjectType = 'Case' AND Name = 'Demo Case Routing'];
        Group q = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'CalHK_Escalations'];
        Database.DMLOptions byId = new Database.DMLOptions();
        byId.assignmentRuleHeader.assignmentRuleId = r.Id;
        Case c1 = new Case(Subject = 'CalTD D2 High via Demo Case Routing', Priority = 'High');
        c1.setOptions(byId); insert c1;
        Database.DMLOptions useDefault = new Database.DMLOptions();
        useDefault.assignmentRuleHeader.useDefaultRule = true;
        Case c2 = new Case(Subject = 'CalTD D2 High via active (default) rule', Priority = 'High');
        c2.setOptions(useDefault); insert c2;
        Map<Id, Case> got = new Map<Id, Case>([SELECT Id, OwnerId FROM Case WHERE Id IN :new List<Id>{ c1.Id, c2.Id }]);
        System.debug('CALTD B-211/B-212 rule active=' + r.Active + ' | by-id owner is queue=' + (got.get(c1.Id).OwnerId == q.Id)
            + ' | default-rule owner is queue=' + (got.get(c2.Id).OwnerId == q.Id));
        System.assertEquals(false, r.Active);
        System.assertEquals(q.Id, got.get(c1.Id).OwnerId);
        System.assertNotEquals(q.Id, got.get(c2.Id).OwnerId);
    }

    // B-111 / B-112: what an admin-context API/Apex email update does (no UI, no verification mail in tests).
    @IsTest static void b111_b112_emailChange() {
        User u = mkUser('Standard Platform User', 'demo.deploy@calhk-d2.example.invalid');
        u.Email = 'team-test-inbox@calhk-d2.example';
        update u;
        String now = [SELECT Email FROM User WHERE Id = :u.Id].Email;
        System.debug('CALTD B-111/B-112 Email after Apex update by admin=' + now);
        System.assertEquals('team-test-inbox@calhk-d2.example', now, 'B-111/B-112: Email after admin Apex update');
    }

    // B-214: right after a component is added the group is not Updated, and assigning it then fails.
    @IsTest static void b214_assignWhileNotUpdated() {
        PermissionSetGroup g = [SELECT Id FROM PermissionSetGroup WHERE DeveloperName = 'CalTD_Ops_Probe_PSG'];
        insert new PermissionSetGroupComponent(PermissionSetGroupId = g.Id, PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'CalHK_Invoice_Admin'].Id);
        String st = [SELECT Status FROM PermissionSetGroup WHERE Id = :g.Id].Status;
        User u = mkUser('Standard Platform User', 'caltd.d2@calhk-d2.example');
        String err = 'none';
        try { insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetGroupId = g.Id); }
        catch (DmlException e) { err = e.getMessage(); }
        System.debug('CALTD B-214 status after component insert=' + st + ' | assignment result=' + err);
        System.assertEquals('Outdated', st, 'B-214 status after component insert');
        System.assert(err.contains('You can only assign users to permission set groups that have the "Updated" status'), 'B-214 assignment while not Updated: ' + err);
    }

    // B-219 / B-220 coverage: both batches run; only a System.schedule call creates a CronTrigger.
    @IsTest static void b219_b220_batches() {
        Test.startTest();
        Database.executeBatch(new CalHK_OnceBatch());
        String jobId = System.schedule('CalTD D2 test schedule', '0 0 2 * * ?', new CalHK_NightlyBatch());
        new CalHK_OnceBatch().execute((SchedulableContext) null);
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM CronTrigger WHERE Id = :jobId]);
    }
}