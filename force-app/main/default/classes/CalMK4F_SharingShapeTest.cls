/**
 * CALHACK round3 B (T-166, T-167, T-169, T-170). Sharing-shape illusions: controlled-by-parent children,
 * master-detail "Read Only" sharing setting, public group "Grant Access Using Hierarchies", record types.
 */
@IsTest
private class CalMK4F_SharingShapeTest {
    static CalMK4F_DemoProject__c project() {
        CalMK4F_DemoProject__c p = new CalMK4F_DemoProject__c(Name = 'CalMK4F Demo Project Atlas');
        insert p;  // Private, owned by the admin
        insert new List<CalMK4F_DemoCost__c>{
            new CalMK4F_DemoCost__c(Name = 'CalMK4F Demo Cost 1', Project__c = p.Id, Amount__c = 180000, Payee__c = 'CalMK4F Demo Contractor A'),
            new CalMK4F_DemoCost__c(Name = 'CalMK4F Demo Cost 2', Project__c = p.Id, Amount__c = 95000, Payee__c = 'CalMK4F Demo Severance B')};
        return p;
    }

    /** T-166: sharing the master (to the PMO group) silently shares every detail row. */
    @IsTest static void t166_parentShareExposesAllCosts() {
        CalMK4F_DemoProject__c p = project();
        User u; Group g;
        System.runAs(CalMK4F_TestUsers.me()) {
            u = CalMK4F_TestUsers.make('pmo');
            CalMK4F_TestUsers.grant(u.Id, 'CalMK4F_DemoPMO_PS');
            g = [SELECT Id FROM Group WHERE DeveloperName = 'CalMK4F_DemoPMO'];
            insert new GroupMember(GroupId = g.Id, UserOrGroupId = u.Id);
        }
        Integer pb; Integer cb;
        System.runAs(u) { pb = [SELECT count() FROM CalMK4F_DemoProject__c]; cb = [SELECT count() FROM CalMK4F_DemoCost__c]; }
        // what the proposed sharing rule produces: Read on the project for group CalMK4F_DemoPMO
        insert new CalMK4F_DemoProject__Share(ParentId = p.Id, UserOrGroupId = g.Id, AccessLevel = 'Read', RowCause = 'Manual');
        System.runAs(u) {
            List<CalMK4F_DemoCost__c> cs = Database.query('SELECT Name, Payee__c, Amount__c FROM CalMK4F_DemoCost__c ORDER BY Name', AccessLevel.USER_MODE);
            CalMK4F_TestUsers.ev('T-166 PMO member before: projects=' + pb + ' costs=' + cb + ' | after Read share on the project only: projects='
                + [SELECT count() FROM CalMK4F_DemoProject__c] + ' costs=' + cs.size() + ' ' + cs[0].Payee__c + '=' + cs[0].Amount__c + ', ' + cs[1].Payee__c + '=' + cs[1].Amount__c);
            System.assertEquals(0, cb);
            System.assertEquals(2, cs.size());
        }
    }

    /** T-167: with the master-detail sharing setting "Read Only" (writeRequiresMasterRead=true), Read on the master is enough to create/edit/delete details. */
    @IsTest static void t167_readOnlySettingLetsMasterReadersWriteDetails() {
        CalMK4F_DemoProject__c p = project();
        CalMK4F_DemoCostProbe__c existing = new CalMK4F_DemoCostProbe__c(Name = 'CalMK4F Demo Probe Cost', Project__c = p.Id, Amount__c = 180000);
        insert existing;
        User u;
        System.runAs(CalMK4F_TestUsers.me()) {
            u = CalMK4F_TestUsers.make('pmo2');
            CalMK4F_TestUsers.grant(u.Id, 'CalMK4F_DemoPMO_PS');   // Create/Edit/Delete on CalMK4F_DemoCost__c
            PermissionSet ps = CalMK4F_TestUsers.testSet('CalMK4F_RT_CostProbeCrud');
            CalMK4F_TestUsers.objRead(ps.Id, 'CalMK4F_DemoProject__c');
            insert new ObjectPermissions(ParentId = ps.Id, SobjectType = 'CalMK4F_DemoCostProbe__c', PermissionsRead = true, PermissionsCreate = true, PermissionsEdit = true, PermissionsDelete = true);
            insert new FieldPermissions(ParentId = ps.Id, SobjectType = 'CalMK4F_DemoCostProbe__c', Field = 'CalMK4F_DemoCostProbe__c.Amount__c', PermissionsRead = true, PermissionsEdit = true);
            CalMK4F_TestUsers.assign(u.Id, ps.Id);
        }
        insert new CalMK4F_DemoProject__Share(ParentId = p.Id, UserOrGroupId = u.Id, AccessLevel = 'Read', RowCause = 'Manual');
        System.runAs(u) {
            Database.SaveResult rw = Database.insert(new CalMK4F_DemoCost__c(Name = 'CalMK4F Demo Cost X', Project__c = p.Id), false, AccessLevel.USER_MODE);
            Database.SaveResult ro = Database.insert(new CalMK4F_DemoCostProbe__c(Name = 'CalMK4F Demo Probe X', Project__c = p.Id), false, AccessLevel.USER_MODE);
            Database.SaveResult ed = Database.update(new CalMK4F_DemoCostProbe__c(Id = existing.Id, Name = 'CalMK4F Demo Probe Cost renamed'), false, AccessLevel.USER_MODE);
            Database.DeleteResult de = Database.delete(existing.Id, false, AccessLevel.USER_MODE);
            CalMK4F_TestUsers.ev('T-167 user with only Read on the project: create detail under Read/Write setting success=' + rw.isSuccess() + ' ' + (rw.isSuccess() ? '' : rw.getErrors()[0].getStatusCode() + ' ' + rw.getErrors()[0].getMessage())
                + ' | under Read Only setting: create=' + ro.isSuccess() + ' edit=' + ed.isSuccess() + ' delete=' + de.isSuccess());
            System.assertEquals(false, rw.isSuccess());
            System.assert(ro.isSuccess() && ed.isSuccess() && de.isSuccess());
        }
    }

    /** T-169: a group with Grant Access Using Hierarchies also shares with every role above its members. */
    @IsTest static void t169_groupHierarchyFlagReachesManagers() {
        UserRole dir; UserRole invRole; User inv; User mgr; Group planted; Group withBosses;
        System.runAs(CalMK4F_TestUsers.me()) {
            dir = new UserRole(Name = 'CalMK4F RT Ops Director', DeveloperName = 'CalMK4F_RT_OpsDirector'); insert dir;
            invRole = new UserRole(Name = 'CalMK4F RT Investigator', DeveloperName = 'CalMK4F_RT_Investigator', ParentRoleId = dir.Id); insert invRole;
            inv = CalMK4F_TestUsers.make('inv', invRole.Id);
            mgr = CalMK4F_TestUsers.make('opsdir', dir.Id);
            CalMK4F_TestUsers.grant(inv.Id, 'CalMK4F_DemoInvestigator_PS');
            CalMK4F_TestUsers.grant(mgr.Id, 'CalMK4F_DemoInvestigator_PS');
            planted = [SELECT Id, DoesIncludeBosses FROM Group WHERE DeveloperName = 'CalMK4F_DemoEthicsTeam'];
            insert new GroupMember(GroupId = planted.Id, UserOrGroupId = inv.Id);
            withBosses = new Group(Name = 'CalMK4F RT Ethics With Bosses', DeveloperName = 'CalMK4F_RT_EthicsBosses', DoesIncludeBosses = true); insert withBosses;
            insert new GroupMember(GroupId = withBosses.Id, UserOrGroupId = inv.Id);
        }
        CalMK4F_DemoGrievance__c a = new CalMK4F_DemoGrievance__c(Name = 'CalMK4F Demo Grievance A', Accused_Manager__c = 'CalMK4F Demo Ops Director');
        CalMK4F_DemoGrievance__c b = new CalMK4F_DemoGrievance__c(Name = 'CalMK4F Demo Grievance B', Accused_Manager__c = 'CalMK4F Demo Ops Director');
        insert new List<CalMK4F_DemoGrievance__c>{ a, b };
        insert new List<CalMK4F_DemoGrievance__Share>{
            new CalMK4F_DemoGrievance__Share(ParentId = a.Id, UserOrGroupId = planted.Id, AccessLevel = 'Read', RowCause = 'Manual'),
            new CalMK4F_DemoGrievance__Share(ParentId = b.Id, UserOrGroupId = withBosses.Id, AccessLevel = 'Read', RowCause = 'Manual')};
        Set<String> invSees = new Set<String>(); Set<String> mgrSees = new Set<String>();
        System.runAs(inv) { for (CalMK4F_DemoGrievance__c g : [SELECT Name FROM CalMK4F_DemoGrievance__c]) invSees.add(g.Name); }
        System.runAs(mgr) { for (CalMK4F_DemoGrievance__c g : [SELECT Name FROM CalMK4F_DemoGrievance__c]) mgrSees.add(g.Name); }
        CalMK4F_TestUsers.ev('T-169 planted group DoesIncludeBosses=' + planted.DoesIncludeBosses + ' | investigator (member of both groups) sees ' + invSees
            + ' | ops director (role above, not a member) sees ' + mgrSees + ' (A shared to the planted group, B to the same membership with Grant Access Using Hierarchies)');
        System.assertEquals(2, invSees.size());
        System.assert(!mgrSees.contains('CalMK4F Demo Grievance A'));
        System.assert(mgrSees.contains('CalMK4F Demo Grievance B'));
    }

    /** T-170: record type assignment changes picklists/layouts/create options, not which records a user can read. */
    @IsTest static void t170_recordTypeAssignmentDoesNotChangeVisibility() {
        Id conf = Schema.SObjectType.CalMK4F_DemoEmployee__c.getRecordTypeInfosByDeveloperName().get('Confidential').getRecordTypeId();
        insert new CalMK4F_DemoEmployee__c(Name = 'CalMK4F Demo Employee Exec', RecordTypeId = conf, Salary__c = 410000);
        User u;
        System.runAs(CalMK4F_TestUsers.me()) { u = CalMK4F_TestUsers.make('rtcheck'); CalMK4F_TestUsers.grant(u.Id, 'CalMK4F_DemoRecruiter_PS'); }
        Integer before; Boolean availBefore; Integer after; Boolean availAfter; String salAfter;
        System.runAs(u) {
            before = [SELECT count() FROM CalMK4F_DemoEmployee__c WHERE RecordType.DeveloperName = 'Confidential'];
            availBefore = Schema.SObjectType.CalMK4F_DemoEmployee__c.getRecordTypeInfosByDeveloperName().get('Confidential').isAvailable();
        }
        System.runAs(CalMK4F_TestUsers.me()) {
            CalMK4F_TestUsers.grant(u.Id, 'CalMK4F_DemoConfidentialRTProbe_PS');   // record type visibility only (the proposed change)
        }
        System.runAs(u) {
            after = [SELECT count() FROM CalMK4F_DemoEmployee__c WHERE RecordType.DeveloperName = 'Confidential'];
            availAfter = Schema.SObjectType.CalMK4F_DemoEmployee__c.getRecordTypeInfosByDeveloperName().get('Confidential').isAvailable();
            try { Database.query('SELECT Salary__c FROM CalMK4F_DemoEmployee__c', AccessLevel.USER_MODE); salAfter = 'readable'; } catch (Exception e) { salAfter = 'not readable (FLS)'; }
        }
        CalMK4F_TestUsers.ev('T-170 recruiter WITHOUT the Confidential record type: confidential rows readable=' + before + ' recordTypeAvailable=' + availBefore + ' | WITH it: confidential rows readable=' + after + ' recordTypeAvailable=' + availAfter + ' | Salary__c still ' + salAfter);
        System.assertEquals(1, before);
        System.assertEquals(false, availBefore);
        System.assertEquals(1, after);
        System.assertEquals(true, availAfter);
    }
}