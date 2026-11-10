/**
 * CALHACK round3 B (T-161..T-165, T-174). Field-level "hide it" illusions.
 * All users, permission sets and records are created inside the test and rolled back.
 */
@IsTest
private class CalMK4F_FieldExposureTest {
    static final String E = 'CalMK4F_DemoEmployee__c';
    static final String P = 'CalMK4F_DemoFlsProbe__c';
    static String q(String soql) {
        try { List<SObject> r = Database.query(soql, AccessLevel.USER_MODE); return 'rows=' + r.size() + ' ' + JSON.serialize(r).replaceAll('"attributes":\\{[^}]*\\},', ''); }
        catch (Exception e) { return 'EXC ' + e.getTypeName() + ': ' + e.getMessage().left(120); }
    }
    static User recruiter() {
        User u;
        System.runAs(CalMK4F_TestUsers.me()) { u = CalMK4F_TestUsers.make('recruit'); CalMK4F_TestUsers.grant(u.Id, 'CalMK4F_DemoRecruiter_PS'); }
        return u;
    }
    static void employee() {
        insert new CalMK4F_DemoEmployee__c(Name = 'CalMK4F Demo Employee Exec', Department__c = 'Executive', Salary__c = 410000, Bonus__c = 95000);
    }

    /** T-161: Salary__c is not on the page layout, yet a Read FLS grant exposes it to the recruiter through any API/list/report path. */
    @IsTest static void t161_flsGrantExposesFieldThatIsNotOnTheLayout() {
        employee();
        User u = recruiter();
        String before; String after;
        System.runAs(u) { before = q('SELECT Name, Salary__c FROM ' + E); }
        System.runAs(CalMK4F_TestUsers.me()) {
            PermissionSet ps = CalMK4F_TestUsers.testSet('CalMK4F_RT_RecruiterSalary');
            CalMK4F_TestUsers.fieldRead(ps.Id, E, 'Salary__c');
            CalMK4F_TestUsers.assign(u.Id, ps.Id);
        }
        System.runAs(u) { after = q('SELECT Name, Salary__c FROM ' + E); }
        CalMK4F_TestUsers.ev('T-161 before Read FLS: ' + before);
        CalMK4F_TestUsers.ev('T-161 after Read FLS (layout unchanged, Salary__c not on it): ' + after);
        System.assert(before.startsWith('EXC'), before);
        System.assert(after.contains('410000'), after);
    }

    /** T-162: putting Salary__c on the layout (even as Required) shows nothing to a user without FLS. */
    @IsTest static void t162_layoutPlacementDoesNotBypassFls() {
        employee();
        User u = recruiter();
        System.runAs(u) {
            Schema.DescribeFieldResult d = Schema.SObjectType.CalMK4F_DemoEmployee__c.fields.Salary__c;
            List<CalMK4F_DemoEmployee__c> rows = [SELECT Name, Salary__c FROM CalMK4F_DemoEmployee__c];
            SObjectAccessDecision dec = Security.stripInaccessible(AccessType.READABLE, rows);
            String q1 = q('SELECT Name, Salary__c FROM ' + E);
            CalMK4F_TestUsers.ev('T-162 recruiter Salary__c isAccessible=' + d.isAccessible() + ' stripInaccessible removed=' + dec.getRemovedFields() + ' USER_MODE query: ' + q1);
            System.assertEquals(false, d.isAccessible());
            System.assert(dec.getRemovedFields().get(E).contains('Salary__c'));
            System.assert(q1.startsWith('EXC'), q1);
        }
    }

    /** T-163: a universally required field cannot be FLS-restricted: every user with object Read sees it. */
    @IsTest static void t163_requiredFieldIgnoresFls() {
        insert new CalMK4F_DemoFlsProbe__c(Name = 'CalMK4F Probe Exec', Probe_Salary__c = 410000, Probe_Required__c = 410000);
        User u; String fp;
        System.runAs(CalMK4F_TestUsers.me()) {
            u = CalMK4F_TestUsers.make('reqprobe');
            PermissionSet ps = CalMK4F_TestUsers.testSet('CalMK4F_RT_ProbeReadOnly');
            CalMK4F_TestUsers.objRead(ps.Id, P);            // object Read only, NO field permissions at all
            CalMK4F_TestUsers.assign(u.Id, ps.Id);
            try { CalMK4F_TestUsers.fieldRead(ps.Id, P, 'Probe_Required__c'); fp = 'accepted'; }
            catch (Exception e) { fp = 'rejected: ' + e.getMessage().left(140); }
        }
        System.runAs(u) {
            Map<String, Schema.SObjectField> f = Schema.SObjectType.CalMK4F_DemoFlsProbe__c.fields.getMap();
            String optional = q('SELECT Probe_Salary__c FROM ' + P);
            String required = q('SELECT Probe_Required__c FROM ' + P);
            CalMK4F_TestUsers.ev('T-163 user with object Read and no FLS: optional field isAccessible=' + f.get('probe_salary__c').getDescribe().isAccessible()
                + ' query: ' + optional + ' | required field isAccessible=' + f.get('probe_required__c').getDescribe().isAccessible() + ' query: ' + required
                + ' | FieldPermissions row for the required field: ' + fp);
            System.assert(optional.startsWith('EXC'), optional);
            System.assert(required.contains('410000'), required);
            System.assert(fp.startsWith('rejected'), fp);
        }
    }

    /** T-164 (risky) and T-174 (twin): a formula over Salary__c has its own FLS. */
    @IsTest static void t164_formulaLeaksSalaryToRecruiter() {
        insert new CalMK4F_DemoFlsProbe__c(Name = 'CalMK4F Probe Exec', Probe_Salary__c = 410000, Probe_Bonus__c = 95000, Probe_Required__c = 1);
        User u;
        System.runAs(CalMK4F_TestUsers.me()) {
            u = CalMK4F_TestUsers.make('formula');
            PermissionSet ps = CalMK4F_TestUsers.testSet('CalMK4F_RT_ProbeRecruiter');
            CalMK4F_TestUsers.objRead(ps.Id, P);
            CalMK4F_TestUsers.fieldRead(ps.Id, P, 'Probe_Bonus__c');      // recruiters already read Bonus__c
            CalMK4F_TestUsers.fieldRead(ps.Id, P, 'Probe_TotalComp__c');  // the proposed grant on the new formula
            CalMK4F_TestUsers.assign(u.Id, ps.Id);
        }
        System.runAs(u) {
            String sal = q('SELECT Probe_Salary__c FROM ' + P);
            List<CalMK4F_DemoFlsProbe__c> r = Database.query('SELECT Probe_Bonus__c, Probe_TotalComp__c FROM ' + P, AccessLevel.USER_MODE);
            Decimal derived = r[0].Probe_TotalComp__c - r[0].Probe_Bonus__c;
            CalMK4F_TestUsers.ev('T-164 recruiter: salary field query: ' + sal + ' | total comp=' + r[0].Probe_TotalComp__c + ' bonus=' + r[0].Probe_Bonus__c + ' -> derived salary=' + derived);
            System.assert(sal.startsWith('EXC'), sal);
            System.assertEquals(410000, derived);
        }
    }

    @IsTest static void t174_formulaGrantToHrAddsNothingNew() {
        insert new CalMK4F_DemoFlsProbe__c(Name = 'CalMK4F Probe Exec', Probe_Salary__c = 410000, Probe_Bonus__c = 95000, Probe_Required__c = 1);
        User u;
        System.runAs(CalMK4F_TestUsers.me()) {
            u = CalMK4F_TestUsers.make('hr');
            PermissionSet ps = CalMK4F_TestUsers.testSet('CalMK4F_RT_ProbeHR');
            CalMK4F_TestUsers.objRead(ps.Id, P);
            CalMK4F_TestUsers.fieldRead(ps.Id, P, 'Probe_Salary__c');
            CalMK4F_TestUsers.fieldRead(ps.Id, P, 'Probe_Bonus__c');
            CalMK4F_TestUsers.assign(u.Id, ps.Id);
        }
        String before; String after;
        System.runAs(u) { before = q('SELECT Probe_Salary__c, Probe_Bonus__c FROM ' + P); }
        System.runAs(CalMK4F_TestUsers.me()) {
            PermissionSet f = CalMK4F_TestUsers.testSet('CalMK4F_RT_ProbeHRFormula');
            CalMK4F_TestUsers.fieldRead(f.Id, P, 'Probe_TotalComp__c');
            CalMK4F_TestUsers.assign(u.Id, f.Id);
        }
        System.runAs(u) { after = q('SELECT Probe_Salary__c, Probe_Bonus__c, Probe_TotalComp__c FROM ' + P); }
        CalMK4F_TestUsers.ev('T-174 HR before formula grant: ' + before + ' | after: ' + after);
        System.assert(before.contains('410000') && after.contains('505000'), after);
    }

    /** T-165: a cross-object formula on a Public Read Only child shows a Private parent's Amount__c. */
    @IsTest static void t165_crossObjectFormulaIgnoresParentSharing() {
        CalMK4F_DemoDeal__c d = new CalMK4F_DemoDeal__c(Name = 'CalMK4F Demo Deal Falcon', Amount__c = 9500000);
        insert d;  // Private OWD, owned by the admin
        insert new CalMK4F_DemoFlsProbe__c(Name = 'CalMK4F Probe Note', Probe_Required__c = 1, Probe_Deal__c = d.Id);
        User u;
        System.runAs(CalMK4F_TestUsers.me()) {
            u = CalMK4F_TestUsers.make('dealdesk');
            CalMK4F_TestUsers.grant(u.Id, 'CalMK4F_DemoDealDesk_PS');  // Read on deals + Amount__c FLS, but sharing hides the deal
            PermissionSet ps = CalMK4F_TestUsers.testSet('CalMK4F_RT_ProbeDealAmt');
            CalMK4F_TestUsers.objRead(ps.Id, P);
            CalMK4F_TestUsers.fieldRead(ps.Id, P, 'Probe_Deal__c');
            CalMK4F_TestUsers.fieldRead(ps.Id, P, 'Probe_Deal_Amount__c');
            CalMK4F_TestUsers.assign(u.Id, ps.Id);
        }
        System.runAs(u) {
            String deals = q('SELECT Name, Amount__c FROM CalMK4F_DemoDeal__c');
            String viaFormula = q('SELECT Name, Probe_Deal_Amount__c FROM ' + P);
            CalMK4F_TestUsers.ev('T-165 deal desk user: Private deals visible: ' + deals + ' | via cross-object formula on the readable child: ' + viaFormula);
            System.assert(deals.startsWith('rows=0'), deals);
            System.assert(viaFormula.contains('9500000'), viaFormula);
        }
    }
}