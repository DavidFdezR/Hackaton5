// CALHACK-103 R-05 demo: a second user approves a form; approval is confirmed with the ERP over HTTP first.
public with sharing class CalMG_DemoFormApprovalController {
    public class ApprovalException extends Exception {}

    public static CalMG_Demo_Form__c approve(Id formId) {
        CalMG_Demo_Form__c form = [SELECT Id, Status__c, CreatedById FROM CalMG_Demo_Form__c WHERE Id = :formId];
        if (form.CreatedById == UserInfo.getUserId()) {
            throw new ApprovalException('The creator of a form cannot approve it.');
        }
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:CalMG_Demo_ERP/forms/approve');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(new Map<String, Object>{ 'formId' => form.Id }));
        HttpResponse res = new Http().send(req);
        Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        form.Status__c = 'Approved';
        form.Erp_Ref__c = (String) body.get('erpRef');
        update form;
        return form;
    }
}