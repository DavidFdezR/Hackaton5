// CALHACK-103 X-06 shared test: the check an agent usually writes - field describe lists Escalated.
// Apex has no record-type-level picklist API, so this test passes before and after the fix.
@isTest
private class CalMG_DemoRequestPicklistTest {
    @isTest
    static void describeListsEscalated() {
        List<String> values = new List<String>();
        for (Schema.PicklistEntry e : CalMG_Demo_Request__c.Stage__c.getDescribe().getPicklistValues()) {
            values.add(e.getValue());
        }
        Assert.isTrue(values.contains('Escalated'), 'describe values = ' + values);
        Assert.isNotNull(Schema.SObjectType.CalMG_Demo_Request__c.getRecordTypeInfosByDeveloperName().get('CalMG_Standard'),
            'record type CalMG_Standard exists');
    }
}