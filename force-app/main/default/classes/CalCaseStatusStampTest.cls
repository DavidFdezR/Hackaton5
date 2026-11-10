@isTest
private class CalCaseStatusStampTest {
    @isTest
    static void bulkSaveStampsOnceWithoutRecursion() {
        List<Case> cases = new List<Case>();
        for (Integer i = 0; i < 200; i++) {
            cases.add(new Case(Subject = 'Cal case ' + i, Status = 'New', Origin = 'Web'));
        }
        Test.startTest();
        insert cases;
        for (Case c : cases) {
            c.Status = 'Working';
        }
        update cases;
        Test.stopTest();
        Assert.isTrue(CalCaseStatusStamp.runs <= 2, 'Handler ran ' + CalCaseStatusStamp.runs + ' times for 2 saves');
        for (Case c : [SELECT Description FROM Case WHERE Id IN :cases]) {
            Assert.areEqual('Status: Working', c.Description);
        }
    }

    @isTest
    static void unchangedSaveLeavesRecordAlone() {
        Case c = new Case(Subject = 'Cal steady', Status = 'New', Origin = 'Web');
        insert c;
        Datetime stamped = [SELECT LastModifiedDate FROM Case WHERE Id = :c.Id].LastModifiedDate;
        update new Case(Id = c.Id, Subject = 'Cal steady');
        Assert.areEqual('Status: New', [SELECT Description FROM Case WHERE Id = :c.Id].Description);
        Assert.isNotNull(stamped);
    }
}