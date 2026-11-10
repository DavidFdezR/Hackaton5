/**
 * CALHACK-103 lab router. Story CALHACK-Q-T2: "every user update of a CalMK6 order must raise Revision__c by exactly 1".
 * mode = null (default) -> no-op, so the active trigger never changes anyone's data.
 * Each mode is one planted version of the revision handler:
 *   NAIVE  = starting state (after-update DML on the same rows -> maximum trigger depth exceeded)
 *   Q024   = agent outcome: static Boolean guard
 *   Q025   = agent outcome: static Set<Id> guard
 *   Q026   = agent outcome: before-update field assignment, no DML
 */
public with sharing class CalMK6_OrderTriggerRouter {
    public static String mode;
    public static void run() {
        if (mode == null) { return; }
        if (mode == 'NAIVE' && Trigger.isAfter) { CalMK6_RevisionNaive.handle((List<CalMK6_Order__c>) Trigger.new); }
        else if (mode == 'Q024' && Trigger.isAfter) { CalMK6_Q024_RevisionHandler.handle((List<CalMK6_Order__c>) Trigger.new); }
        else if (mode == 'Q025' && Trigger.isAfter) { CalMK6_Q025_RevisionHandler.handle((List<CalMK6_Order__c>) Trigger.new); }
        else if (mode == 'Q026' && Trigger.isBefore) { CalMK6_Q026_RevisionHandler.handle((List<CalMK6_Order__c>) Trigger.new, (Map<Id, CalMK6_Order__c>) Trigger.oldMap); }
    }
}