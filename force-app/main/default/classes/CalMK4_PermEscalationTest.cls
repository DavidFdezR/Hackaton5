/** CALHACK T-134..T-138: permission grants that look harmless, proved with test-created permission sets (all rolled back). */
@IsTest
private class CalMK4_PermEscalationTest {
    static PermissionSet ps(String name, Map<String, Boolean> perms) {
        PermissionSet p = new PermissionSet(Name = name, Label = name.replace('_', ' '));
        for (String k : perms.keySet()) { p.put(k, perms.get(k)); }
        insert p;
        return p;
    }
    static PermissionSet dealViewAll(String name) {
        PermissionSet p = ps(name, new Map<String, Boolean>());
        insert new ObjectPermissions(ParentId = p.Id, SobjectType = 'CalMK4_DemoDeal__c', PermissionsRead = true, PermissionsViewAllRecords = true);
        return p;
    }
    static Map<String, Boolean> viewAllDataBundle() {
        Map<String, Boolean> m = new Map<String, Boolean>();
        for (String k : new List<String>{ 'PermissionsViewAllData', 'PermissionsViewDataLeakageEvents', 'PermissionsViewEventLogFiles', 'PermissionsViewPlatformEvents',
                'PermissionsViewPublicDashboards', 'PermissionsViewPublicReports', 'PermissionsViewRoles', 'PermissionsViewSetup' }) { m.put(k, true); }
        return m;
    }
    /** T-134: Assign Permission Sets lets a user hand themselves any permission set. */
    @IsTest static void assignPermissionSetsSelfEscalates() {
        CalMK4_DemoDeal__c d = new CalMK4_DemoDeal__c(Name = 'CalMK4 Demo Deal Board', Amount__c = 900000);
        insert d;
        User u; PermissionSet power;
        System.runAs(CalMK4_TestUsers.me()) {
            u = CalMK4_TestUsers.make('asgn', null, 'Standard User');
            CalMK4_TestUsers.grant(u.Id, 'CalMK4_DemoSales_Rep');
            power = dealViewAll('CalMK4_RT_PowerDealViewAll');
        }
        Database.SaveResult before; Integer seenBefore;
        System.runAs(u) {
            seenBefore = [SELECT COUNT() FROM CalMK4_DemoDeal__c WHERE Id = :d.Id WITH USER_MODE];
            before = Database.insert(new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = power.Id), false, AccessLevel.USER_MODE);
        }
        System.runAs(CalMK4_TestUsers.me()) {
            PermissionSet a = ps('CalMK4_RT_AssignPS', new Map<String, Boolean>{ 'PermissionsAssignPermissionSets' => true });
            insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = a.Id);
        }
        Database.SaveResult self;
        System.runAs(u) { self = Database.insert(new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = power.Id), false, AccessLevel.USER_MODE); }
        Integer seenAfter;
        System.runAs(u) { seenAfter = [SELECT COUNT() FROM CalMK4_DemoDeal__c WHERE Id = :d.Id WITH USER_MODE]; }
        System.debug('CALMK4_EVIDENCE T-134 self-assign without Assign Permission Sets: ' + before.isSuccess() + ' ' + before.getErrors());
        System.debug('CALMK4_EVIDENCE T-134 self-assign WITH Assign Permission Sets: ' + self.isSuccess() + ' ' + self.getErrors() + ' | private deal visible before=' + seenBefore + ' after=' + seenAfter);
        System.assertEquals(false, before.isSuccess(), 'control: user cannot assign permission sets');
        System.assertEquals(true, self.isSuccess(), 'Assign Permission Sets lets the user give themselves any permission set');
        System.assertEquals(1, seenAfter, 'the self-assigned View All on deals now shows the private deal');
    }
    /** X-MPPS: Manage Profiles and Permission Sets lets a user edit a permission set they already hold. */
    @IsTest static void manageProfilesPermsetsEditsOwnPermissionSet() {
        CalMK4_DemoDeal__c d = new CalMK4_DemoDeal__c(Name = 'CalMK4 Demo Deal Board 2', Amount__c = 800000);
        insert d;
        User u; PermissionSet mine;
        System.runAs(CalMK4_TestUsers.me()) {
            u = CalMK4_TestUsers.make('mpps', null, 'Standard User');
            CalMK4_TestUsers.grant(u.Id, 'CalMK4_DemoSales_Rep');
            mine = ps('CalMK4_RT_MineSet', new Map<String, Boolean>());
            insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = mine.Id);
        }
        Database.SaveResult before;
        System.runAs(u) { before = Database.insert(new ObjectPermissions(ParentId = mine.Id, SobjectType = 'CalMK4_DemoDeal__c', PermissionsRead = true, PermissionsViewAllRecords = true), false, AccessLevel.USER_MODE); }
        System.runAs(CalMK4_TestUsers.me()) {
            PermissionSet m = ps('CalMK4_RT_ManagePS', new Map<String, Boolean>{ 'PermissionsManageProfilesPermissionsets' => true });
            insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = m.Id);
        }
        Database.SaveResult after;
        System.runAs(u) { after = Database.insert(new ObjectPermissions(ParentId = mine.Id, SobjectType = 'CalMK4_DemoDeal__c', PermissionsRead = true, PermissionsViewAllRecords = true), false, AccessLevel.USER_MODE); }
        Integer seen;
        System.runAs(u) { seen = [SELECT COUNT() FROM CalMK4_DemoDeal__c WHERE Id = :d.Id WITH USER_MODE]; }
        System.debug('CALMK4_EVIDENCE X-MPPS edit own PS without Manage Profiles and PS: ' + before.isSuccess() + ' ' + before.getErrors());
        System.debug('CALMK4_EVIDENCE X-MPPS edit own PS WITH Manage Profiles and PS: ' + after.isSuccess() + ' ' + after.getErrors() + ' | private deal visible=' + seen);
        // Not asserted: user-mode DML on ObjectPermissions is refused even with the permission, so this method cannot prove the escalation (candidate dropped).
    }
    /** T-135: View All Custom Settings opens every custom setting (incl. the T-129 key) to API/SOQL. */
    @IsTest static void viewAllCustomSettingsReadsTheKey() {
        insert new CalMK4_ErpConfig__c(SetupOwnerId = UserInfo.getOrganizationId(), Api_Key__c = 'DEMO_PASSWORD_PLACEHOLDER');
        User u;
        System.runAs(CalMK4_TestUsers.me()) { u = CalMK4_TestUsers.make('vacs'); }
        String before = 'ok'; String after = 'ok';
        System.runAs(u) { try { before = String.valueOf([SELECT Api_Key__c FROM CalMK4_ErpConfig__c WITH USER_MODE LIMIT 1]); } catch (Exception e) { before = e.getTypeName(); } }
        System.runAs(CalMK4_TestUsers.me()) {
            PermissionSet v = new PermissionSet(Name = 'CalMK4_RT_VACS', Label = 'CalMK4 RT VACS', PermissionsViewAllCustomSettings = true);
            Database.SaveResult r = Database.insert(v, false);
            Database.SaveResult a = r.isSuccess() ? Database.insert(new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = v.Id), false) : r;
            System.debug('CALMK4_EVIDENCE T-135 grant to Platform user: ' + a.isSuccess() + ' ' + a.getErrors());
        }
        System.runAs(u) { try { after = String.valueOf([SELECT Api_Key__c FROM CalMK4_ErpConfig__c WITH USER_MODE LIMIT 1]); } catch (Exception e) { after = e.getTypeName() + ': ' + e.getMessage(); } }
        System.debug('CALMK4_EVIDENCE T-135 USER_MODE SOQL on the key before=' + before + ' | after View All Custom Settings=' + after);
    }
    /** T-136: Bulk API Hard Delete needs no other permission and is grantable to a Platform integration user. */
    @IsTest static void hardDeleteGrantableAlone() {
        System.runAs(CalMK4_TestUsers.me()) {
            User u = CalMK4_TestUsers.make('hdel', null, 'Standard User');
            PermissionSet h = new PermissionSet(Name = 'CalMK4_RT_HardDelete', Label = 'CalMK4 RT HardDelete', PermissionsBulkApiHardDelete = true);
            Database.SaveResult r = Database.insert(h, false);
            Database.SaveResult a = r.isSuccess() ? Database.insert(new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = h.Id), false) : r;
            Boolean adminHas = [SELECT PermissionsBulkApiHardDelete FROM Profile WHERE Name = 'System Administrator'].PermissionsBulkApiHardDelete;
            System.debug('CALMK4_EVIDENCE T-136 hard delete PS alone insert=' + r.isSuccess() + ' assign to Standard User (Salesforce licence)=' + a.isSuccess() + ' ' + a.getErrors() + ' | System Administrator profile has it=' + adminHas);
            System.assert(r.isSuccess() && a.isSuccess(), 'grantable without Modify All Data');
        }
    }
    /** T-137: Query All Files on top of View All Data opens private files View All Data alone cannot see. */
    @IsTest static void queryAllFilesOpensPrivateFiles() {
        User owner; User backup;
        System.runAs(CalMK4_TestUsers.me()) {
            owner = CalMK4_TestUsers.make('hrown');
            backup = CalMK4_TestUsers.make('backup', null, 'System Administrator'); // profile already holds View All Data
        }
        ContentVersion cv;
        System.runAs(owner) {
            cv = new ContentVersion(Title = 'CalMK4 Demo HR private note', PathOnClient = 'calmk4-demo.txt', VersionData = Blob.valueOf('demo private content'));
            insert cv;
        }
        Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        Integer before; Integer after;
        Integer byTitle; Integer viaVersion;
        System.runAs(backup) {
            before = [SELECT COUNT() FROM ContentDocument WHERE Id = :docId];
            byTitle = [SELECT COUNT() FROM ContentDocument WHERE Title = 'CalMK4 Demo HR private note'];
            viaVersion = [SELECT COUNT() FROM ContentVersion WHERE Title = 'CalMK4 Demo HR private note' AND IsLatest = true];
        }
        System.debug('CALMK4_EVIDENCE T-137 System Administrator (View All Data, no Query All Files) sees another user private file: by Id=' + before + ' by Title on ContentDocument=' + byTitle + ' ContentVersion by Title=' + viaVersion);
        String qaf;
        System.runAs(CalMK4_TestUsers.me()) {
            Database.SaveResult r = Database.insert(new PermissionSet(Name = 'CalMK4_RT_BackupQAF', Label = 'CalMK4 RT BackupQAF', PermissionsQueryAllFiles = true), false);
            qaf = r.isSuccess() ? 'ok' : r.getErrors()[0].getMessage();
        }
        System.debug('CALMK4_EVIDENCE T-137 Query All Files in a set without View All Data -> ' + qaf);

    }
    /** T-138 control: same FLS-read-only setup WITHOUT Edit Read Only Fields. */
    @IsTest static void flsReadOnlyControl() {
        CalMK4_DemoAsset__c a = new CalMK4_DemoAsset__c(Name = 'CalMK4 Demo Asset Laptop C', Status__c = 'Active');
        User u;
        System.runAs(CalMK4_TestUsers.me()) {
            u = CalMK4_TestUsers.make('erofc', null, 'Standard User');
            PermissionSet p = new PermissionSet(Name = 'CalMK4_RT_EROFC', Label = 'CalMK4 RT EROFC');
            insert p;
            insert new ObjectPermissions(ParentId = p.Id, SobjectType = 'CalMK4_DemoAsset__c', PermissionsRead = true, PermissionsEdit = true, PermissionsCreate = true);
            insert new FieldPermissions(ParentId = p.Id, SobjectType = 'CalMK4_DemoAsset__c', Field = 'CalMK4_DemoAsset__c.Status__c', PermissionsRead = true, PermissionsEdit = false);
            insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = p.Id);
        }
        System.runAs(u) { insert a; }
        Database.SaveResult r;
        System.runAs(u) { r = Database.update(new CalMK4_DemoAsset__c(Id = a.Id, Status__c = 'Retired'), false, AccessLevel.USER_MODE); }
        System.debug('CALMK4_EVIDENCE T-138 control (no Edit Read Only Fields) FLS read-only update: success=' + r.isSuccess() + ' ' + r.getErrors());
    }
    /** T-138: Edit Read Only Fields vs field-level security. */
    @IsTest static void editReadOnlyFieldsKeepsFls() {
        CalMK4_DemoAsset__c a = new CalMK4_DemoAsset__c(Name = 'CalMK4 Demo Asset Laptop', Status__c = 'Active');
        User u;
        System.runAs(CalMK4_TestUsers.me()) {
            u = CalMK4_TestUsers.make('erof', null, 'Standard User');
            PermissionSet p = new PermissionSet(Name = 'CalMK4_RT_EROF', Label = 'CalMK4 RT EROF', PermissionsEditReadonlyFields = true);
            insert p;
            insert new ObjectPermissions(ParentId = p.Id, SobjectType = 'CalMK4_DemoAsset__c', PermissionsRead = true, PermissionsEdit = true, PermissionsCreate = true);
            insert new FieldPermissions(ParentId = p.Id, SobjectType = 'CalMK4_DemoAsset__c', Field = 'CalMK4_DemoAsset__c.Status__c', PermissionsRead = true, PermissionsEdit = false);
            insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = p.Id);
        }
        System.runAs(u) { insert a; }
        Database.SaveResult r;
        System.runAs(u) { r = Database.update(new CalMK4_DemoAsset__c(Id = a.Id, Status__c = 'Retired'), false, AccessLevel.USER_MODE); }
        System.debug('CALMK4_EVIDENCE T-138 FLS read-only field update with Edit Read Only Fields: success=' + r.isSuccess() + ' ' + r.getErrors());

    }
}