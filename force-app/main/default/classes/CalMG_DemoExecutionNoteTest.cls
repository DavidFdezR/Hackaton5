// CALHACK-103 R-07 shared test: the flow-owned note must survive the save, and the before trigger should run once per save.
@isTest
private class CalMG_DemoExecutionNoteTest {
    private static List<CalMG_Demo_Execution__c> build(Integer n) {
        List<CalMG_Demo_Execution__c> rows = new List<CalMG_Demo_Execution__c>();
        for (Integer i = 0; i < n; i++) {
            rows.add(new CalMG_Demo_Execution__c(Name = 'CalMG Demo Exec ' + i));
        }
        return rows;
    }

    private static void runAndCheck(Integer n) {
        List<CalMG_Demo_Execution__c> rows = build(n);
        Test.startTest();
        Integer cpuBefore = Limits.getCpuTime();
        insert rows;
        Integer cpuUsed = Limits.getCpuTime() - cpuBefore;
        Integer triggerRuns = CalMG_DemoExecutionHandler.invocations;
        Test.stopTest();
        Integer flowNotes = [SELECT COUNT() FROM CalMG_Demo_Execution__c WHERE Status_Note__c = 'Set by flow'];
        String sample = [SELECT Status_Note__c FROM CalMG_Demo_Execution__c LIMIT 1].Status_Note__c;
        String facts = 'n=' + n + ' flowNotes=' + flowNotes + ' sampleNote=' + sample
            + ' beforeTriggerRuns=' + triggerRuns + ' cpuMs=' + cpuUsed;
        Assert.areEqual(n, flowNotes, 'every record keeps the flow note; ' + facts);
        Assert.areEqual(1, triggerRuns, 'before trigger runs once for one save; ' + facts);
    }

    @isTest
    static void singleInsertKeepsFlowNote() {
        runAndCheck(1);
    }

    @isTest
    static void bulkInsertKeepsFlowNote() {
        runAndCheck(200);
    }
}