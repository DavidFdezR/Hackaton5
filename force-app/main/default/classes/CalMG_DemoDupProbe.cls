// CalMG demo probe (CALHACK-103 B-05): runs the three insert styles against the live duplicate rule
// outside a test and reports what happened. Rows it saves are kept as evidence.
public with sharing class CalMG_DemoDupProbe {
    public static String run(String tag) {
        String nid = 'DEMO-NID-P' + tag;
        List<String> out = new List<String>();
        CalMG_Demo_Customer__c base = new CalMG_Demo_Customer__c(Name = 'CalMG Demo Probe ' + tag + ' base', National_Id__c = nid, Email__c = 'probe@calmg-demo.example');
        Database.SaveResult s0 = Database.insert(base, false);
        out.add('base saved=' + s0.isSuccess() + errs(s0));

        CalMG_Demo_Customer__c a1 = new CalMG_Demo_Customer__c(Name = 'CalMG Demo Probe ' + tag + ' plain', National_Id__c = nid);
        try { insert a1; out.add('plain insert saved=true'); }
        catch (DmlException e) { out.add('plain insert saved=false ' + e.getDmlType(0) + ' ' + e.getDmlMessage(0)); }

        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;

        CalMG_Demo_Customer__c a2 = new CalMG_Demo_Customer__c(Name = 'CalMG Demo Probe ' + tag + ' setOptions', National_Id__c = nid);
        a2.setOptions(dml);
        try { insert a2; out.add('setOptions+insert saved=true'); }
        catch (DmlException e) { out.add('setOptions+insert saved=false ' + e.getDmlType(0) + ' ' + e.getDmlMessage(0)); }

        CalMG_Demo_Customer__c a3 = new CalMG_Demo_Customer__c(Name = 'CalMG Demo Probe ' + tag + ' dbinsert', National_Id__c = nid);
        Database.SaveResult s3 = Database.insert(a3, dml);
        out.add('Database.insert(rec,dml) saved=' + s3.isSuccess() + errs(s3));
        return String.join(out, ' | ');
    }

    private static String errs(Database.SaveResult sr) {
        String s = '';
        for (Database.Error e : sr.getErrors()) {
            s += ' [' + e.getStatusCode() + (e instanceof Database.DuplicateError ? ' DuplicateError' : '') + ']';
        }
        return s;
    }
}