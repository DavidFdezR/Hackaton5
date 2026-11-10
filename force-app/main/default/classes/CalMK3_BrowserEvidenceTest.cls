/**
 * CALHACK-101 (Kind 3 browser) evidence for manoj.kumar, prefix CalMK3_.
 * Everything here runs inside Apex tests and rolls back. Demo data only.
 */
@IsTest
private class CalMK3_BrowserEvidenceTest {

    private static User demoUser(String alias) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard Platform User' LIMIT 1];
        String u = 'calmk3.' + alias + '.' + String.valueOf(Crypto.getRandomInteger()).replace('-', '') + '@calmk3.example';
        User usr = new User(Alias = alias, Email = 'calmk3.' + alias + '@calmk3.example', EmailEncodingKey = 'UTF-8',
            LastName = 'CalMK3 Demo ' + alias, LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US',
            ProfileId = p.Id, TimeZoneSidKey = 'America/Chicago', Username = u);
        insert usr;
        return usr;
    }

    // B-031/B-032: Ticket.CalMK3_Request__c has a REQUIRED filter; Request.CalMK3_Ticket__c only an OPTIONAL one.
    @IsTest
    static void lookupFilterRequiredBlocksSave() {
        CalMK3_Request__c closedReq = new CalMK3_Request__c(Name = 'CalMK3_Request_Closed_T', CalMK3_Stage__c = 'Closed');
        insert closedReq;
        String err = null;
        try {
            insert new CalMK3_Ticket__c(Name = 'CalMK3_Ticket_T', CalMK3_Request__c = closedReq.Id);
        } catch (DmlException e) {
            err = e.getDmlType(0) + ': ' + e.getDmlMessage(0);
        }
        System.debug('CALMK3_EVIDENCE required filter -> ' + err);
        System.assertNotEquals(null, err, 'Required lookup filter must block linking a Closed request');
        System.assert(err.contains('FIELD_FILTER_VALIDATION_EXCEPTION'), err);
    }

    @IsTest
    static void lookupFilterOptionalDoesNotBlockSave() {
        CalMK3_Ticket__c closedTicket = new CalMK3_Ticket__c(Name = 'CalMK3_Ticket_Closed_T', CalMK3_Stage__c = 'Closed');
        insert closedTicket;
        CalMK3_Request__c r = new CalMK3_Request__c(Name = 'CalMK3_Request_T', CalMK3_Ticket__c = closedTicket.Id);
        insert r; // optional filter: API/import/flow saves go through
        System.debug('CALMK3_EVIDENCE optional filter -> saved ' + r.Id + ' linked to a Closed ticket');
        System.assertNotEquals(null, r.Id);
    }

    // B-033/B-034: record type Field Service assigned in CalMK3_Request_Agent, not in CalMK3_Ticket_Agent.
    @IsTest
    static void recordTypeAvailabilityFromPermissionSets() {
        User u = demoUser('mk3rt');
        List<PermissionSet> sets = [SELECT Id, Name FROM PermissionSet WHERE Name IN ('CalMK3_Ticket_Agent', 'CalMK3_Request_Agent')];
        List<PermissionSetAssignment> psa = new List<PermissionSetAssignment>();
        for (PermissionSet ps : sets) { psa.add(new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id)); }
        insert psa;
        System.runAs(u) {
            Boolean reqAvail = Schema.SObjectType.CalMK3_Request__c.getRecordTypeInfosByDeveloperName().get('CalMK3_Field_Service').isAvailable();
            Boolean tktAvail = Schema.SObjectType.CalMK3_Ticket__c.getRecordTypeInfosByDeveloperName().get('CalMK3_Field_Service').isAvailable();
            System.debug('CALMK3_EVIDENCE RT available Request=' + reqAvail + ' Ticket=' + tktAvail);
            System.assertEquals(true, reqAvail, 'Request Field Service RT should be available via CalMK3_Request_Agent');
            System.assertEquals(false, tktAvail, 'Ticket Field Service RT should NOT be available via CalMK3_Ticket_Agent');
            System.assertEquals(true, Schema.SObjectType.CalMK3_Ticket__c.isCreateable(), 'Ticket object create is granted, only the RT is missing');
        }
    }

    // B-039/B-040: PSG CalMK3_Ops_Team (no muting) vs CalMK3_Field_Team (muting Edit on Requests).
    @IsTest
    static void permissionSetGroupMuting() {
        PermissionSetGroup ops = [SELECT Id FROM PermissionSetGroup WHERE DeveloperName = 'CalMK3_Ops_Team'];
        PermissionSetGroup field = [SELECT Id FROM PermissionSetGroup WHERE DeveloperName = 'CalMK3_Field_Team'];
        Test.calculatePermissionSetGroup(new List<Id>{ ops.Id, field.Id });
        User a = demoUser('mk3ops');
        User b = demoUser('mk3fld');
        insert new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = a.Id, PermissionSetGroupId = ops.Id),
            new PermissionSetAssignment(AssigneeId = b.Id, PermissionSetGroupId = field.Id)
        };
        Boolean opsEdit; Boolean fieldRead; Boolean fieldEdit; Boolean fieldCreate;
        System.runAs(a) { opsEdit = Schema.SObjectType.CalMK3_Ticket__c.isUpdateable(); }
        System.runAs(b) {
            fieldRead = Schema.SObjectType.CalMK3_Request__c.isAccessible();
            fieldEdit = Schema.SObjectType.CalMK3_Request__c.isUpdateable();
            fieldCreate = Schema.SObjectType.CalMK3_Request__c.isCreateable();
        }
        System.debug('CALMK3_EVIDENCE PSG Ops_Team Ticket edit=' + opsEdit + ' | Field_Team Request read=' + fieldRead + ' create=' + fieldCreate + ' edit=' + fieldEdit);
        System.assertEquals(true, opsEdit);
        System.assertEquals(true, fieldRead);
        System.assertEquals(false, fieldEdit, 'Muting permission set removes Edit inside the group');
    }
}