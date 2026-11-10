/**
 * CALHACK Friday (CalMK2_) demo. Planted bug: adds the approver to the CalMK2 Finance public group
 * (GroupMember = setup object) and writes an invoice log row (non-setup object) in one transaction.
 * Salesforce rejects this with MIXED_DML_OPERATION. Not called by any trigger.
 */
public with sharing class CalMK2_OnboardingService {
    public static void addApproverAndLog(Id approverId) {
        Group fin = [SELECT Id FROM Group WHERE DeveloperName = 'CalMK2_Finance_Group' LIMIT 1];
        insert new GroupMember(GroupId = fin.Id, UserOrGroupId = approverId);
        insert new CalMK2_Invoice__c(Name = 'CalMK2_Approver_Log');
    }
}