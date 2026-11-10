/** CALHACK round 3 C test helper: Standard Platform User demo users, rolled back with the test (max 2 per method). */
@IsTest
public class CalMK4C_TestUsers {
    public static User make(String tag) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard Platform User' LIMIT 1];
        String rnd = String.valueOf(Math.abs(Crypto.getRandomInteger()));
        User u = new User(Alias = ('mk4c' + tag).left(8), Email = 'demo.' + tag + '@calmk4c.example',
            EmailEncodingKey = 'UTF-8', LastName = 'CalMK4C Demo ' + tag, LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', ProfileId = p.Id, TimeZoneSidKey = 'America/Chicago',
            UserName = 'calmk4c.' + tag + '.' + rnd + '@calmk4c.example');
        insert u;
        return u;
    }
    public static void grant(Id userId, String permSetName) {
        insert new PermissionSetAssignment(AssigneeId = userId,
            PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = :permSetName LIMIT 1].Id);
    }
    public static User me() { return new User(Id = UserInfo.getUserId()); }
    /** 3 refunds owned by the running admin + 1 owned by a new refund agent. Returns the agent. */
    public static User agentWithOneOwnRefund() {
        insert new List<CalMK4C_DemoRefund__c>{
            new CalMK4C_DemoRefund__c(Name = 'CalMK4C Demo Refund A1', Amount__c = 120, Status__c = 'Pending', Bank_Account__c = 'DEMO-ACCT-0001'),
            new CalMK4C_DemoRefund__c(Name = 'CalMK4C Demo Refund A2', Amount__c = 340, Status__c = 'Pending', Bank_Account__c = 'DEMO-ACCT-0002'),
            new CalMK4C_DemoRefund__c(Name = 'CalMK4C Demo Refund A3', Amount__c = 560, Status__c = 'Paid', Bank_Account__c = 'DEMO-ACCT-0003') };
        User agent;
        System.runAs(me()) {
            agent = make('agent');
            grant(agent.Id, 'CalMK4C_DemoRefundAgent_PS');
        }
        System.runAs(agent) { insert new CalMK4C_DemoRefund__c(Name = 'CalMK4C Demo Refund Mine', Amount__c = 25, Status__c = 'Pending'); }
        // admin stamps a bank account on the agent's own refund (agent has no FLS on it)
        CalMK4C_DemoRefund__c mine = [SELECT Id FROM CalMK4C_DemoRefund__c WHERE Name = 'CalMK4C Demo Refund Mine'];
        mine.Bank_Account__c = 'DEMO-ACCT-0099';
        update mine;
        return agent;
    }
}