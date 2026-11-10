@IsTest
private class CalMK4_InvoiceAccessTest {
    static User reader;
    static Id adminInvoice;
    static void setup() {
        insert new List<CalMK4_DemoInvoice__c>{
            new CalMK4_DemoInvoice__c(Name = 'CalMK4 Demo Inv A1', Amount__c = 1200, Status__c = 'Open', Billing_Contact__c = 'Demo Contact One'),
            new CalMK4_DemoInvoice__c(Name = 'CalMK4 Demo Inv A2', Amount__c = 3400, Status__c = 'Open', Billing_Contact__c = 'Demo Contact Two'),
            new CalMK4_DemoInvoice__c(Name = 'CalMK4 Demo Inv A3', Amount__c = 5600, Status__c = 'Paid', Billing_Contact__c = 'Demo Contact Three') };
        System.runAs(CalMK4_TestUsers.me()) {
            reader = CalMK4_TestUsers.make('invrdr');
            CalMK4_TestUsers.grant(reader.Id, 'CalMK4_DemoInvoiceReader_PS');
        }
        System.runAs(reader) { insert new CalMK4_DemoInvoice__c(Name = 'CalMK4 Demo Inv Mine', Amount__c = 99, Status__c = 'Open'); }
    }
    @IsTest static void restWithoutSharingVsWithSharing() {
        setup();
        System.runAs(reader) {
            RestContext.request = new RestRequest(); RestContext.response = new RestResponse();
            Integer leaky = CalMK4_InvoiceApi.listInvoices().size();
            Integer safe = CalMK4_InvoiceApiSafe.listInvoices().size();
            System.debug('CALMK4_EVIDENCE REST without sharing rows=' + leaky + ' | with sharing + USER_MODE rows=' + safe);
            System.assertEquals(4, leaky, 'without sharing returns every invoice, incl. 3 owned by others');
            System.assertEquals(1, safe, 'with sharing + USER_MODE returns only the caller\'s own invoice');
        }
    }
    @IsTest static void systemModeKeepsSharingButDropsFls() {
        setup();
        System.runAs(reader) {
            String userMode = 'no exception';
            try { CalMK4_InvoiceCtrl.getInvoices(); } catch (Exception e) { userMode = e.getTypeName() + ': ' + e.getMessage(); }
            List<CalMK4_DemoInvoice__c> sys = CalMK4_InvoiceCtrlSys.getInvoices();
            System.debug('CALMK4_EVIDENCE USER_MODE outcome=' + userMode);
            System.debug('CALMK4_EVIDENCE SYSTEM_MODE in with sharing class rows=' + sys.size() + ' amountVisible=' + (sys.isEmpty() ? null : sys[0].Amount__c));
            System.assert(userMode.contains('QueryException'), 'USER_MODE rejects Amount__c without FLS');
            System.assertEquals(1, sys.size(), 'record sharing still enforced by the with sharing class');
            System.assertEquals(99, sys[0].Amount__c, 'FLS on Amount__c is no longer enforced');
        }
    }
}