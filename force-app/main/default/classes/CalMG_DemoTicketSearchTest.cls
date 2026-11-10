// CALHACK-103 X-01 shared test: searches run as an in-test Minimum Access user holding CalMG_Demo_Ticket_Searcher.
@isTest
private class CalMG_DemoTicketSearchTest {
    private static User makeSearcher() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Minimum Access - Salesforce' LIMIT 1];
        String stamp = String.valueOf(Datetime.now().getTime());
        User u = new User(
            LastName = 'CalMG Demo Searcher', Alias = 'calmgx01', Email = 'calmg.x01@demo.example',
            Username = 'calmg.x01.' + stamp + '@demo.example', ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US');
        insert u;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CalMG_Demo_Ticket_Searcher'];
        insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
        return u;
    }

    private static User setup(List<String> extraNames) {
        User u;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            u = makeSearcher();
        }
        List<CalMG_Demo_Ticket__c> rows = new List<CalMG_Demo_Ticket__c>{
            new CalMG_Demo_Ticket__c(Name = 'CalMG Demo Alpha', Archived__c = false),
            new CalMG_Demo_Ticket__c(Name = 'CalMG Demo Hidden', Archived__c = true)
        };
        for (String n : extraNames) {
            rows.add(new CalMG_Demo_Ticket__c(Name = n, Archived__c = false));
        }
        insert rows;
        return u;
    }

    @isTest
    static void plainTermFindsOneRow() {
        User u = setup(new List<String>());
        System.runAs(u) {
            Assert.areEqual(1, CalMG_DemoTicketSearch.search('Alpha').size(), 'Alpha matches one open ticket');
        }
    }

    @isTest
    static void craftedTermCannotReachArchivedRow() {
        User u = setup(new List<String>());
        System.runAs(u) {
            List<CalMG_Demo_Ticket__c> found = CalMG_DemoTicketSearch.search('zzz%\') OR (Name LIKE \'');
            List<String> names = new List<String>();
            for (CalMG_Demo_Ticket__c t : found) {
                names.add(t.Name);
            }
            Assert.areEqual(0, found.size(), 'crafted input returned ' + names);
        }
    }

    @isTest
    static void apostropheNameIsFound() {
        User u = setup(new List<String>{ 'CalMG O\'Demo' });
        System.runAs(u) {
            List<CalMG_Demo_Ticket__c> found = CalMG_DemoTicketSearch.search('O\'Demo');
            Assert.areEqual(1, found.size(), 'search for O\'Demo');
        }
    }
}