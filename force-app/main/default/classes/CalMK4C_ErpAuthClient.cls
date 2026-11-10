/** CALHACK T-190: builds the ERP request. A "temporary" debug line was added while chasing a 401. */
public with sharing class CalMK4C_ErpAuthClient {
    public static HttpRequest buildRequest() {
        CalMK4C_ErpSecret__c cfg = CalMK4C_ErpSecret__c.getOrgDefaults();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://erp.calmk4c.example/api/refunds');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + cfg.Api_Key__c);
        System.debug(LoggingLevel.INFO, 'TEMP 401 debug, remove later: Authorization=' + req.getHeader('Authorization'));
        return req;
    }
}