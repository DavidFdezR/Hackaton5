/** CALHACK round3 B: discovery probes. Every method fails on purpose with its observations in the message. */
@IsTest
private class CalMK4F_ProbeTest {
    static String q(String soql) {
        try { List<SObject> r = Database.query(soql, AccessLevel.USER_MODE); return 'rows=' + r.size() + ' ' + JSON.serialize(r).left(300); }
        catch (Exception e) { return 'EXC ' + e.getTypeName() + ': ' + e.getMessage().left(200); }
    }
    @IsTest static void requiredAndFormula() {
        String out = '';
        insert new CalMK4F_DemoFlsProbe__c(Name = 'CalMK4F Probe', Probe_Salary__c = 123456, Probe_Required__c = 7777);
        User u; PermissionSet ps;
        System.runAs(CalMK4F_TestUsers.me()) {
            u = CalMK4F_TestUsers.make('probe1');
            ps = CalMK4F_TestUsers.testSet('CalMK4F_RT_Probe');
            CalMK4F_TestUsers.objRead(ps.Id, 'CalMK4F_DemoFlsProbe__c');
            CalMK4F_TestUsers.fieldRead(ps.Id, 'CalMK4F_DemoFlsProbe__c', 'Probe_Formula__c');
            CalMK4F_TestUsers.assign(u.Id, ps.Id);
            try { CalMK4F_TestUsers.fieldRead(ps.Id, 'CalMK4F_DemoFlsProbe__c', 'Probe_Required__c'); out += ' | FP on required: inserted'; }
            catch (Exception e) { out += ' | FP on required: ' + e.getMessage().left(150); }
        }
        System.runAs(u) {
            Map<String, Schema.SObjectField> f = Schema.SObjectType.CalMK4F_DemoFlsProbe__c.fields.getMap();
            out += ' | req acc=' + f.get('probe_required__c').getDescribe().isAccessible() + ' upd=' + f.get('probe_required__c').getDescribe().isUpdateable();
            out += ' | sal acc=' + f.get('probe_salary__c').getDescribe().isAccessible();
            out += ' | formula acc=' + f.get('probe_formula__c').getDescribe().isAccessible();
            out += ' | Qreq ' + q('SELECT Probe_Required__c FROM CalMK4F_DemoFlsProbe__c');
            out += ' | Qform ' + q('SELECT Probe_Formula__c FROM CalMK4F_DemoFlsProbe__c');
            out += ' | Qsal ' + q('SELECT Probe_Salary__c FROM CalMK4F_DemoFlsProbe__c');
        }
        System.assert(false, out);
    }
    @IsTest static void lookupNamesAndCrossFormula() {
        String out = '';
        CalMK4F_DemoDeal__c d = new CalMK4F_DemoDeal__c(Name = 'CalMK4F Demo Deal - Project Falcon acquisition', Amount__c = 9500000);
        insert d;
        insert new CalMK4F_DemoDealNote__c(Name = 'CalMK4F Note 1', Deal__c = d.Id);
        insert new CalMK4F_DemoFlsProbe__c(Name = 'CalMK4F Probe X', Probe_Required__c = 1, Probe_Deal__c = d.Id);
        User u; PermissionSet ps;
        System.runAs(CalMK4F_TestUsers.me()) {
            u = CalMK4F_TestUsers.make('probe2');
            CalMK4F_TestUsers.grant(u.Id, 'CalMK4F_DemoDealDesk_PS');
            ps = CalMK4F_TestUsers.testSet('CalMK4F_RT_Probe2');
            CalMK4F_TestUsers.objRead(ps.Id, 'CalMK4F_DemoFlsProbe__c');
            CalMK4F_TestUsers.fieldRead(ps.Id, 'CalMK4F_DemoFlsProbe__c', 'Probe_Deal_Amount__c');
            CalMK4F_TestUsers.fieldRead(ps.Id, 'CalMK4F_DemoFlsProbe__c', 'Probe_Deal__c');
            CalMK4F_TestUsers.assign(u.Id, ps.Id);
        }
        System.runAs(u) {
            out += ' | deals ' + q('SELECT Id FROM CalMK4F_DemoDeal__c');
            out += ' | noteName ' + q('SELECT Deal__c, Deal__r.Name FROM CalMK4F_DemoDealNote__c');
            out += ' | xformula ' + q('SELECT Probe_Deal_Amount__c FROM CalMK4F_DemoFlsProbe__c');
        }
        System.runAs(CalMK4F_TestUsers.me()) {
            PermissionSet vl = new PermissionSet(Name = 'CalMK4F_RT_LookupNames', Label = 'CalMK4F RT LookupNames', PermissionsViewAllForeignKeyNames = true);
            insert vl;
            CalMK4F_TestUsers.assign(u.Id, vl.Id);
        }
        System.runAs(u) {
            out += ' | WITH VALN: noteName ' + q('SELECT Deal__c, Deal__r.Name FROM CalMK4F_DemoDealNote__c');
            out += ' | deals ' + q('SELECT Id, Name FROM CalMK4F_DemoDeal__c');
        }
        System.assert(false, out);
    }
    @IsTest static void emailFedAndFreeze() {
        String out = '';
        User a; User b;
        System.runAs(CalMK4F_TestUsers.me()) {
            a = CalMK4F_TestUsers.make('probe3');
            b = CalMK4F_TestUsers.make('probe4');
            a.Email = 'attacker.inbox@calmk4f-evil.example';
            a.FederationIdentifier = 'shared.fed@calmk4f.example';
            update a;
            User r = [SELECT Email, FederationIdentifier FROM User WHERE Id = :a.Id];
            out += ' | email now=' + r.Email + ' fed=' + r.FederationIdentifier;
            try { b.FederationIdentifier = 'shared.fed@calmk4f.example'; update b; out += ' | dup fed: allowed'; }
            catch (Exception e) { out += ' | dup fed: ' + e.getMessage().left(150); }
            UserLogin ul = [SELECT Id, IsFrozen FROM UserLogin WHERE UserId = :a.Id];
            ul.IsFrozen = true; update ul;
            out += ' | frozen=' + [SELECT IsFrozen FROM UserLogin WHERE Id = :ul.Id].IsFrozen + ' active=' + [SELECT IsActive FROM User WHERE Id = :a.Id].IsActive;
        }
        // helpdesk b without/with Freeze Users freezes the org admin
        System.runAs(b) {
            try { UserLogin adm = [SELECT Id FROM UserLogin WHERE UserId = :UserInfo.getUserId()]; adm.IsFrozen = true; Database.update(adm, AccessLevel.USER_MODE); out += ' | b(no perm) froze admin: OK'; }
            catch (Exception e) { out += ' | b(no perm) freeze admin: ' + e.getMessage().left(150); }
        }
        System.runAs(CalMK4F_TestUsers.me()) {
            try {
                PermissionSet fz = new PermissionSet(Name = 'CalMK4F_RT_Freeze', Label = 'CalMK4F RT Freeze', PermissionsFreezeUsers = true);
                insert fz; CalMK4F_TestUsers.assign(b.Id, fz.Id); out += ' | freeze PS ok';
            } catch (Exception e) { out += ' | freeze PS: ' + e.getMessage().left(200); }
        }
        System.runAs(b) {
            try { UserLogin adm = [SELECT Id FROM UserLogin WHERE UserId = :UserInfo.getUserId()]; adm.IsFrozen = true; Database.update(adm, AccessLevel.USER_MODE); out += ' | b(FreezeUsers) froze admin: OK'; }
            catch (Exception e) { out += ' | b(FreezeUsers) freeze admin: ' + e.getMessage().left(150); }
        }
        System.assert(false, out);
    }
}