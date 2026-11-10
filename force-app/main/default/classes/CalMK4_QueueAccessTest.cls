@IsTest
private class CalMK4_QueueAccessTest {
    static Integer seenBy(User u, Id invId) { Integer n; System.runAs(u) { n = [SELECT COUNT() FROM CalMK4_DemoInvoice__c WHERE Id = :invId WITH USER_MODE]; } return n; }
    /** T-143 / T-144: who sees a Private invoice owned by a queue, depending on the queue's members. */
    @IsTest static void queueMembershipDecidesVisibility() {
        User rep; User fin; Group q; Group team;
        System.runAs(CalMK4_TestUsers.me()) {
            rep = CalMK4_TestUsers.make('anyrep'); fin = CalMK4_TestUsers.make('finance');
            CalMK4_TestUsers.grant(rep.Id, 'CalMK4_DemoInvoiceReader_PS'); CalMK4_TestUsers.grant(fin.Id, 'CalMK4_DemoInvoiceReader_PS');
            q = new Group(Name = 'CalMK4 RT Finance Queue', DeveloperName = 'CalMK4_RT_FinanceQueue', Type = 'Queue');
            insert q;
            insert new QueueSobject(QueueId = q.Id, SobjectType = 'CalMK4_DemoInvoice__c');
            team = new Group(Name = 'CalMK4 RT Finance Team', DeveloperName = 'CalMK4_RT_FinanceTeam', Type = 'Regular');
            insert team;
            insert new GroupMember(GroupId = team.Id, UserOrGroupId = fin.Id);
            insert new GroupMember(GroupId = q.Id, UserOrGroupId = team.Id);
        }
        CalMK4_DemoInvoice__c inv = new CalMK4_DemoInvoice__c(Name = 'CalMK4 Demo Invoice Queue', Amount__c = 4200, Status__c = 'Disputed', OwnerId = q.Id);
        insert inv;
        Integer finNamed = seenBy(fin, inv.Id), repNamed = seenBy(rep, inv.Id);
        Id allInternal = [SELECT Id FROM Group WHERE Type = 'Organization' LIMIT 1].Id;
        System.runAs(CalMK4_TestUsers.me()) { insert new GroupMember(GroupId = q.Id, UserOrGroupId = allInternal); }
        Integer repAll = seenBy(rep, inv.Id);
        Database.SaveResult take;
        System.runAs(rep) { take = Database.update(new CalMK4_DemoInvoice__c(Id = inv.Id, OwnerId = rep.Id), false, AccessLevel.USER_MODE); }
        System.debug('CALMK4_EVIDENCE T-144 queue with named group: finance member sees=' + finNamed + ' other rep sees=' + repNamed);
        System.debug('CALMK4_EVIDENCE T-143 after adding All Internal Users to the queue: other rep sees=' + repAll + ' | rep takes ownership=' + take.isSuccess() + ' ' + take.getErrors());
    }
}