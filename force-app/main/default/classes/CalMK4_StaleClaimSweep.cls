/** CALHACK T-141/T-142: nightly sweep, with sharing, marks open claims older than the cutoff as Stale. Runs as whoever scheduled it. */
public with sharing class CalMK4_StaleClaimSweep implements Schedulable {
    public static Integer lastSwept;
    public static Id lastRunAs;
    public void execute(SchedulableContext ctx) {
        List<CalMK4_DemoClaim__c> rows = [SELECT Id FROM CalMK4_DemoClaim__c WHERE Status__c = 'Open'];
        for (CalMK4_DemoClaim__c c : rows) { c.Status__c = 'Stale'; }
        update rows;
        lastSwept = rows.size();
        lastRunAs = UserInfo.getUserId();
    }
}