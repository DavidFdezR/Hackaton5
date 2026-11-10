/** CALHACK T-184: audit stamp on refund update. Deactivated in the org during the demo incident (duplicate ERP postings). */
trigger CalMK4C_RefundAuditTrigger on CalMK4C_DemoRefund__c (before update) {
    for (CalMK4C_DemoRefund__c r : Trigger.new) {
        r.Notes__c = 'audited';
    }
}