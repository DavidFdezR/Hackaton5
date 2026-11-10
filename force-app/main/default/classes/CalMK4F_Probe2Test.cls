/** CALHACK round3 B: discovery probes, part 2 (fail on purpose with observations). */
@IsTest
private class CalMK4F_Probe2Test {
    static String names() {
        try { List<CalMK4F_DemoDealNote__c> r = Database.query('SELECT Deal__c, Deal__r.Name FROM CalMK4F_DemoDealNote__c', AccessLevel.USER_MODE);
              return 'rows=' + r.size() + ' dealId=' + r[0].Deal__c + ' dealName=' + (r[0].Deal__r == null ? 'NULL-REL' : r[0].Deal__r.Name); }
        catch (Exception e) { return 'EXC ' + e.getMessage().left(200); }
    }
    @IsTest static void lookupNames() {
        String out = '';
        CalMK4F_DemoDeal__c d = new CalMK4F_DemoDeal__c(Name = 'CalMK4F Demo Deal - Project Falcon acquisition', Amount__c = 9500000);
        insert d;
        insert new CalMK4F_DemoDealNote__c(Name = 'CalMK4F Note 1', Deal__c = d.Id);
        User u;
        System.runAs(CalMK4F_TestUsers.me()) { u = CalMK4F_TestUsers.make('probe5'); CalMK4F_TestUsers.grant(u.Id, 'CalMK4F_DemoDealDesk_PS'); }
        System.runAs(u) { out += ' | before ' + names(); }
        System.runAs(CalMK4F_TestUsers.me()) {
            PermissionSet vl = new PermissionSet(Name = 'CalMK4F_RT_LookupNames', Label = 'CalMK4F RT LookupNames', PermissionsViewAllForeignKeyNames = true);
            insert vl; CalMK4F_TestUsers.assign(u.Id, vl.Id);
        }
        System.runAs(u) {
            out += ' | after ' + names();
            out += ' | search deals ' + [SELECT count() FROM CalMK4F_DemoDeal__c];
        }
        System.assert(false, out);
    }
    @IsTest static void masterDetailAndRecordTypes() {
        String out = '';
        CalMK4F_DemoProject__c p = new CalMK4F_DemoProject__c(Name = 'CalMK4F Demo Project Atlas');
        insert p;
        insert new List<CalMK4F_DemoCost__c>{
            new CalMK4F_DemoCost__c(Name = 'CalMK4F Cost 1', Project__c = p.Id, Amount__c = 180000, Payee__c = 'CalMK4F Demo Contractor A'),
            new CalMK4F_DemoCost__c(Name = 'CalMK4F Cost 2', Project__c = p.Id, Amount__c = 95000, Payee__c = 'CalMK4F Demo Severance B')};
        Id conf = Schema.SObjectType.CalMK4F_DemoEmployee__c.getRecordTypeInfosByDeveloperName().get('Confidential').getRecordTypeId();
        insert new CalMK4F_DemoEmployee__c(Name = 'CalMK4F Demo Exec', RecordTypeId = conf, Salary__c = 400000);
        User u; Group g;
        System.runAs(CalMK4F_TestUsers.me()) {
            u = CalMK4F_TestUsers.make('probe6');
            CalMK4F_TestUsers.grant(u.Id, 'CalMK4F_DemoPMO_PS');
            CalMK4F_TestUsers.grant(u.Id, 'CalMK4F_DemoRecruiter_PS');
            g = [SELECT Id FROM Group WHERE DeveloperName = 'CalMK4F_DemoPMO'];
            insert new GroupMember(GroupId = g.Id, UserOrGroupId = u.Id);
        }
        System.runAs(u) {
            out += ' | before projects=' + [SELECT count() FROM CalMK4F_DemoProject__c] + ' costs=' + [SELECT count() FROM CalMK4F_DemoCost__c];
            out += ' | conf employees visible=' + [SELECT count() FROM CalMK4F_DemoEmployee__c WHERE RecordType.DeveloperName = 'Confidential'];
            out += ' | rt available=' + Schema.SObjectType.CalMK4F_DemoEmployee__c.getRecordTypeInfosByDeveloperName().get('Confidential').isAvailable();
        }
        insert new CalMK4F_DemoProject__Share(ParentId = p.Id, UserOrGroupId = g.Id, AccessLevel = 'Read', RowCause = 'Manual');
        System.runAs(u) {
            out += ' | after share projects=' + [SELECT count() FROM CalMK4F_DemoProject__c];
            List<CalMK4F_DemoCost__c> cs = Database.query('SELECT Payee__c, Amount__c FROM CalMK4F_DemoCost__c', AccessLevel.USER_MODE);
            out += ' costs=' + cs.size() + ' ' + JSON.serialize(cs).left(250);
        }
        System.assert(false, out);
    }
    @IsTest static void groupBosses() {
        String out = '';
        UserRole mgrRole; UserRole invRole; User inv; User mgr; Group gNo; Group gYes;
        System.runAs(CalMK4F_TestUsers.me()) {
            mgrRole = new UserRole(Name = 'CalMK4F RT Ops Director', DeveloperName = 'CalMK4F_RT_OpsDirector'); insert mgrRole;
            invRole = new UserRole(Name = 'CalMK4F RT Investigator', DeveloperName = 'CalMK4F_RT_Investigator', ParentRoleId = mgrRole.Id); insert invRole;
            inv = CalMK4F_TestUsers.make('inv', invRole.Id);
            mgr = CalMK4F_TestUsers.make('mgr', mgrRole.Id);
            CalMK4F_TestUsers.grant(inv.Id, 'CalMK4F_DemoInvestigator_PS');
            CalMK4F_TestUsers.grant(mgr.Id, 'CalMK4F_DemoInvestigator_PS');
            gNo = [SELECT Id, DoesIncludeBosses FROM Group WHERE DeveloperName = 'CalMK4F_DemoEthicsTeam'];
            insert new GroupMember(GroupId = gNo.Id, UserOrGroupId = inv.Id);
            gYes = new Group(Name = 'CalMK4F RT Ethics Bosses', DeveloperName = 'CalMK4F_RT_EthicsBosses', DoesIncludeBosses = true); insert gYes;
            insert new GroupMember(GroupId = gYes.Id, UserOrGroupId = inv.Id);
            out += ' | planted group includeBosses=' + gNo.DoesIncludeBosses;
        }
        CalMK4F_DemoGrievance__c g1 = new CalMK4F_DemoGrievance__c(Name = 'CalMK4F Grievance A', Accused_Manager__c = 'CalMK4F Demo Director');
        insert g1; // owned by admin, shared to planted group by criteria rule
        System.runAs(inv) { out += ' | inv sees=' + [SELECT count() FROM CalMK4F_DemoGrievance__c]; }
        System.runAs(mgr) { out += ' | mgr sees (rule->group no bosses)=' + [SELECT count() FROM CalMK4F_DemoGrievance__c]; }
        CalMK4F_DemoGrievance__c g2 = new CalMK4F_DemoGrievance__c(Name = 'CalMK4F Grievance B', Accused_Manager__c = 'CalMK4F Demo Director');
        insert g2;
        insert new CalMK4F_DemoGrievance__Share(ParentId = g2.Id, UserOrGroupId = gYes.Id, AccessLevel = 'Read', RowCause = 'Manual');
        System.runAs(mgr) { out += ' | mgr sees after share to includeBosses group=' + [SELECT count() FROM CalMK4F_DemoGrievance__c] + ' ' + [SELECT Name FROM CalMK4F_DemoGrievance__c]; }
        System.assert(false, out);
    }
}