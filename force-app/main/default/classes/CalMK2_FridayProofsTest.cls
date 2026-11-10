/**
 * CALHACK Friday (CalMK2_) proofs. Every method asserts the Salesforce behaviour a Friday case relies on.
 * Users and permission set assignments exist only inside the test and roll back.
 * At most 2 users per method (Standard Platform User profile, Salesforce Platform licence).
 */
@IsTest
private class CalMK2_FridayProofsTest {

    private static User mkUser(String alias) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard Platform User' LIMIT 1];
        String uniq = String.valueOf(Math.abs(Crypto.getRandomInteger()));
        User u = new User(Alias = alias, Email = 'calmk2.' + alias + '@demo.example', EmailEncodingKey = 'UTF-8',
            LastName = 'CalMK2_' + alias, LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = p.Id,
            TimeZoneSidKey = 'America/Chicago', Username = 'calmk2.' + alias + '.' + uniq + '@demo.example');
        insert u;
        return u;
    }

    private static void assign(Id userId, String psName) {
        insert new PermissionSetAssignment(AssigneeId = userId,
            PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = :psName LIMIT 1].Id);
    }

    private static User admin() {
        return new User(Id = UserInfo.getUserId());
    }

    // F-032: object Read via permission set does not widen record visibility under a Private OWD.
    @IsTest
    static void permSetReadDoesNotWidenVisibility() {
        User fin;
        System.runAs(admin()) {
            fin = mkUser('cmk2fin');
            assign(fin.Id, 'CalMK2_Invoice_Read');
        }
        List<CalMK2_Invoice__c> invs = new List<CalMK2_Invoice__c>();
        for (Integer i = 0; i < 5; i++) {
            invs.add(new CalMK2_Invoice__c(Name = 'CalMK2_INV-T' + i, Amount__c = 1000 + i));
        }
        insert invs; // owned by the admin running the test
        Integer seen;
        Boolean objReadable;
        System.runAs(fin) {
            objReadable = Schema.sObjectType.CalMK2_Invoice__c.isAccessible();
            seen = CalMK2_InvoiceService.countVisible();
        }
        Assert.isTrue(objReadable, 'permission set gives object Read');
        Assert.areEqual(0, seen, 'Private OWD: object Read alone shows none of the 5 records');

        // Same group-based share a sharing rule would create: grant Read to the CalMK2 Finance Group.
        Group g = [SELECT Id FROM Group WHERE DeveloperName = 'CalMK2_Finance_Group' LIMIT 1];
        System.runAs(admin()) {
            insert new GroupMember(GroupId = g.Id, UserOrGroupId = fin.Id);
        }
        List<CalMK2_Invoice__Share> shares = new List<CalMK2_Invoice__Share>();
        for (CalMK2_Invoice__c inv : invs) {
            shares.add(new CalMK2_Invoice__Share(ParentId = inv.Id, UserOrGroupId = g.Id, AccessLevel = 'Read',
                RowCause = Schema.CalMK2_Invoice__Share.RowCause.CalMK2_Finance_Review__c));
        }
        insert shares;
        System.runAs(fin) {
            seen = CalMK2_InvoiceService.countVisible();
        }
        Assert.areEqual(5, seen, 'Group-level Read share makes the records visible');
    }

    // F-034: with sharing does not enforce FLS: user without FLS on Internal_Margin__c still gets the value.
    @IsTest
    static void withSharingDoesNotEnforceFls() {
        User rep;
        System.runAs(admin()) {
            rep = mkUser('cmk2rep');
            assign(rep.Id, 'CalMK2_Invoice_Read');
        }
        CalMK2_Invoice__c inv = new CalMK2_Invoice__c(Name = 'CalMK2_INV-FLS', Amount__c = 5000, Internal_Margin__c = 37.5);
        insert inv;
        insert new CalMK2_Invoice__Share(ParentId = inv.Id, UserOrGroupId = rep.Id, AccessLevel = 'Read', RowCause = 'Manual');
        Boolean fieldReadable;
        List<CalMK2_Invoice__c> rows;
        System.runAs(rep) {
            fieldReadable = Schema.sObjectType.CalMK2_Invoice__c.fields.Internal_Margin__c.isAccessible();
            rows = CalMK2_InvoiceService.getInvoicesWithMargin();
        }
        Assert.isFalse(fieldReadable, 'user has no FLS on Internal_Margin__c');
        Assert.areEqual(1, rows.size());
        Assert.areEqual(37.5, rows[0].Internal_Margin__c, 'with sharing class still returns the hidden field value');
    }

    // F-035: WITH USER_MODE throws on the inaccessible field; stripInaccessible removes it instead.
    @IsTest
    static void userModeThrowsStripInaccessibleRemoves() {
        User rep;
        System.runAs(admin()) {
            rep = mkUser('cmk2um');
            assign(rep.Id, 'CalMK2_Invoice_Read');
        }
        CalMK2_Invoice__c inv = new CalMK2_Invoice__c(Name = 'CalMK2_INV-UM', Amount__c = 5000, Internal_Margin__c = 12.5);
        insert inv;
        insert new CalMK2_Invoice__Share(ParentId = inv.Id, UserOrGroupId = rep.Id, AccessLevel = 'Read', RowCause = 'Manual');
        String err;
        Set<String> inaccessible;
        List<CalMK2_Invoice__c> stripped;
        System.runAs(rep) {
            try {
                CalMK2_InvoiceUserModeSelector.userMode();
            } catch (QueryException e) {
                err = e.getMessage();
                inaccessible = e.getInaccessibleFields().get('CalMK2_Invoice__c');
            }
            stripped = CalMK2_InvoiceUserModeSelector.stripped();
        }
        System.debug('CALMK2 USER_MODE error: ' + err + ' fields=' + inaccessible);
        Assert.isNotNull(err, 'WITH USER_MODE must throw, not silently drop the field');
        Assert.isTrue(inaccessible.contains('Internal_Margin__c'));
        Assert.areEqual(1, stripped.size(), 'stripInaccessible still returns the record');
        Assert.isFalse(stripped[0].isSet('Internal_Margin__c'), 'stripInaccessible removed the field');
        Assert.areEqual(5000, stripped[0].Amount__c);
    }

    // F-036: manual share disappears on owner change; Apex managed share with a sharing reason stays.
    @IsTest
    static void manualShareRemovedOnOwnerChange() {
        User reviewer;
        User newOwner;
        System.runAs(admin()) {
            reviewer = mkUser('cmk2rv');
            newOwner = mkUser('cmk2no');
            assign(reviewer.Id, 'CalMK2_Invoice_Read');
            assign(newOwner.Id, 'CalMK2_Invoice_Read');
        }
        CalMK2_Invoice__c manualInv = new CalMK2_Invoice__c(Name = 'CalMK2_INV-MAN');
        CalMK2_Invoice__c apexInv = new CalMK2_Invoice__c(Name = 'CalMK2_INV-APX');
        insert new List<CalMK2_Invoice__c>{ manualInv, apexInv };
        insert new List<CalMK2_Invoice__Share>{
            new CalMK2_Invoice__Share(ParentId = manualInv.Id, UserOrGroupId = reviewer.Id, AccessLevel = 'Read', RowCause = 'Manual'),
            new CalMK2_Invoice__Share(ParentId = apexInv.Id, UserOrGroupId = reviewer.Id, AccessLevel = 'Read',
                RowCause = Schema.CalMK2_Invoice__Share.RowCause.CalMK2_Finance_Review__c)
        };
        Integer before;
        System.runAs(reviewer) { before = CalMK2_InvoiceService.countVisible(); }
        Assert.areEqual(2, before, 'reviewer sees both before the transfer');

        manualInv.OwnerId = newOwner.Id;
        apexInv.OwnerId = newOwner.Id;
        update new List<CalMK2_Invoice__c>{ manualInv, apexInv };

        Integer manualLeft = [SELECT COUNT() FROM CalMK2_Invoice__Share WHERE ParentId = :manualInv.Id AND UserOrGroupId = :reviewer.Id];
        Integer apexLeft = [SELECT COUNT() FROM CalMK2_Invoice__Share WHERE ParentId = :apexInv.Id AND UserOrGroupId = :reviewer.Id];
        Integer after;
        System.runAs(reviewer) { after = CalMK2_InvoiceService.countVisible(); }
        Assert.areEqual(0, manualLeft, 'Manual share row removed by owner change');
        Assert.areEqual(1, apexLeft, 'Apex managed share row (sharing reason) kept');
        Assert.areEqual(1, after, 'reviewer lost the manually shared invoice');
    }

    // F-037: permission sets are additive. Edit removed from Clerk set, but Legacy Edit set still grants it.
    @IsTest
    static void permissionSetsAreAdditive() {
        User clerkOnly;
        User clerkPlusLegacy;
        System.runAs(admin()) {
            clerkOnly = mkUser('cmk2c1');
            clerkPlusLegacy = mkUser('cmk2c2');
            assign(clerkOnly.Id, 'CalMK2_Invoice_Clerk');
            assign(clerkPlusLegacy.Id, 'CalMK2_Invoice_Clerk');
            assign(clerkPlusLegacy.Id, 'CalMK2_Invoice_Legacy_Edit');
        }
        CalMK2_Invoice__c a = new CalMK2_Invoice__c(Name = 'CalMK2_INV-ADD1', OwnerId = clerkOnly.Id, Status__c = 'Draft');
        CalMK2_Invoice__c b = new CalMK2_Invoice__c(Name = 'CalMK2_INV-ADD2', OwnerId = clerkPlusLegacy.Id, Status__c = 'Draft');
        insert new List<CalMK2_Invoice__c>{ a, b };

        Boolean onlyCanEdit;
        Boolean bothCanEdit;
        Database.SaveResult onlyRes;
        Database.SaveResult bothRes;
        System.runAs(clerkOnly) {
            onlyCanEdit = Schema.sObjectType.CalMK2_Invoice__c.isUpdateable();
            onlyRes = Database.update(new CalMK2_Invoice__c(Id = a.Id, Status__c = 'Paid'), false, AccessLevel.USER_MODE);
        }
        System.runAs(clerkPlusLegacy) {
            bothCanEdit = Schema.sObjectType.CalMK2_Invoice__c.isUpdateable();
            bothRes = Database.update(new CalMK2_Invoice__c(Id = b.Id, Status__c = 'Paid'), false, AccessLevel.USER_MODE);
        }
        System.debug('CALMK2 clerkOnly update errors: ' + onlyRes.getErrors());
        Assert.isFalse(onlyCanEdit, 'Clerk set alone: no Edit');
        Assert.isFalse(onlyRes.isSuccess(), 'Clerk-only user cannot edit');
        Assert.isTrue(bothCanEdit, 'Legacy Edit set still grants Edit');
        Assert.isTrue(bothRes.isSuccess(), 'user with both sets can still edit after Edit was removed from Clerk');
    }

    // F-038: GroupMember (setup) + invoice (non-setup) DML in one transaction -> MIXED_DML_OPERATION.
    @IsTest
    static void mixedDmlIsRejected() {
        String err;
        try {
            CalMK2_OnboardingService.addApproverAndLog(UserInfo.getUserId());
        } catch (DmlException e) {
            err = e.getMessage();
        }
        System.debug('CALMK2 mixed DML: ' + err);
        Assert.isNotNull(err);
        Assert.isTrue(err.contains('MIXED_DML_OPERATION'), err);
    }

    private class ErpMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse r = new HttpResponse();
            r.setStatusCode(200);
            r.setBody('{"ok":true}');
            return r;
        }
    }

    // F-039 (a): DML then callout fails.
    @IsTest
    static void calloutAfterDmlFails() {
        Test.setMock(HttpCalloutMock.class, new ErpMock());
        String err;
        try {
            CalMK2_ErpSyncService.insertThenCallout('none');
        } catch (CalloutException e) {
            err = e.getMessage();
        }
        System.debug('CALMK2 callout none: ' + err);
        Assert.isNotNull(err, 'DML before callout must fail');
    }

    // F-039 (b): rollback to savepoint WITHOUT releasing it still fails.
    @IsTest
    static void calloutAfterRollbackOnlyFails() {
        Test.setMock(HttpCalloutMock.class, new ErpMock());
        String err;
        try {
            CalMK2_ErpSyncService.insertThenCallout('rollback');
        } catch (CalloutException e) {
            err = e.getMessage();
        }
        System.debug('CALMK2 callout rollback-only: ' + err);
        Assert.isNotNull(err, 'rollback alone is not enough; savepoint must be released');
    }

    // F-039 (c): rollback + Database.releaseSavepoint, then callout works (API 60.0+).
    @IsTest
    static void calloutAfterRollbackAndReleaseWorks() {
        Test.setMock(HttpCalloutMock.class, new ErpMock());
        Integer code = CalMK2_ErpSyncService.insertThenCallout('rollbackRelease');
        Assert.areEqual(200, code);
        Assert.areEqual(0, [SELECT COUNT() FROM CalMK2_Invoice__c WHERE Name = 'CalMK2_ERP_Pending'], 'insert was rolled back');
    }

    // F-044: org-default custom setting is invisible to a test without SeeAllData; CMT record is visible.
    @IsTest
    static void customSettingInvisibleCmtVisible() {
        CalMK2_Settings__c cs = CalMK2_Settings__c.getOrgDefaults();
        CalMK2_Config__mdt cfg = CalMK2_Config__mdt.getInstance('Default');
        System.debug('CALMK2 custom setting in test: ' + cs + ' / CMT: ' + cfg);
        Assert.isNull(cs.Endpoint_Label__c, 'org default custom setting data is not visible without SeeAllData');
        Assert.isNotNull(cfg, 'custom metadata record is visible');
        Assert.areEqual('erp.demo.example', cfg.Value__c);
    }

    // F-045: unique, case-insensitive external ID: keys differing only by case match the same record.
    @IsTest
    static void caseInsensitiveExternalIdUpsertMatches() {
        CalMK2_Invoice__c first = new CalMK2_Invoice__c(Name = 'CalMK2_INV-EXT1', External_Key__c = 'CALMK2-inv-a1', Amount__c = 10);
        upsert first CalMK2_Invoice__c.External_Key__c;
        CalMK2_Invoice__c second = new CalMK2_Invoice__c(Name = 'CalMK2_INV-EXT2', External_Key__c = 'CALMK2-INV-A1', Amount__c = 20);
        Database.UpsertResult r = Database.upsert(second, CalMK2_Invoice__c.External_Key__c, false);
        Assert.isTrue(r.isSuccess(), String.valueOf(r.getErrors()));
        Assert.isFalse(r.isCreated(), 'second key matched the first record (case-insensitive)');
        Assert.areEqual(1, [SELECT COUNT() FROM CalMK2_Invoice__c WHERE Name LIKE 'CalMK2_INV-EXT%']);
        Assert.areEqual(20, [SELECT Amount__c FROM CalMK2_Invoice__c WHERE Id = :first.Id].Amount__c);
    }

    // Coverage for the planted schedulable (no real schedule is created by the test).
    @IsTest
    static void nightlyJobSchedules() {
        Test.startTest();
        String jobId = System.schedule('CalMK2_Test_Job', '0 0 3 1 1 ? 2099', new CalMK2_NightlyInvoiceJob());
        Test.stopTest();
        Assert.areEqual(1, [SELECT COUNT() FROM CronTrigger WHERE Id = :jobId]);
    }
}