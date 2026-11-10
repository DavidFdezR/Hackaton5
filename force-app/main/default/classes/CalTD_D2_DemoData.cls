/**
 * CALHACK-101 D2: seeds demo records for the CalHK fixtures (B-101/B-102, B-201/B-202, B-109/B-110, B-211/B-212)
 * and plants B-219/B-220. Compiled class so it can write fields that the running admin has no FLS on. Idempotent.
 */
public without sharing class CalTD_D2_DemoData {
    public static void seed() {
        if ([SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.Name = 'CalHK Nightly Batch'] == 0) {
            System.debug('CALTD B-219 scheduled job id=' + System.schedule('CalHK Nightly Batch', '0 0 2 * * ?', new CalHK_NightlyBatch()));
        }
        if ([SELECT COUNT() FROM AsyncApexJob WHERE ApexClass.Name = 'CalHK_OnceBatch' AND JobType = 'BatchApex'] == 0) {
            System.debug('CALTD B-220 one-off batch id=' + Database.executeBatch(new CalHK_OnceBatch()));
        }
        if ([SELECT COUNT() FROM CalHK_Contract__c WHERE Name LIKE 'CalHK Demo Contract%'] == 0) {
            Map<String, Id> rt = new Map<String, Id>();
            for (RecordType r : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'CalHK_Contract__c']) rt.put(r.DeveloperName, r.Id);
            insert new List<CalHK_Contract__c>{
                new CalHK_Contract__c(Name = 'CalHK Demo Contract Renewal', RecordTypeId = rt.get('CalHK_Renewal'), Region_Present__c = 'Demo North', Region_Absent__c = 'Demo North'),
                new CalHK_Contract__c(Name = 'CalHK Demo Contract Standard', RecordTypeId = rt.get('CalHK_Standard'), Region_Present__c = 'Demo South', Region_Absent__c = 'Demo South') };
        }
        if ([SELECT COUNT() FROM CalHK_Invoice__c WHERE Name LIKE 'CalHK Demo Invoice%'] == 0) {
            insert new List<CalHK_Invoice__c>{
                new CalHK_Invoice__c(Name = 'CalHK Demo Invoice 1', Amount__c = 100),
                new CalHK_Invoice__c(Name = 'CalHK Demo Invoice 2', Amount__c = 250) };
        }
        if ([SELECT COUNT() FROM Case WHERE Subject LIKE 'CalHK Demo High Priority Case%'] == 0) {
            insert new Case(Subject = 'CalHK Demo High Priority Case (B-211/B-212)', Priority = 'High', Origin = 'Web', Status = 'New');
        }
        for (CalHK_Invoice__c i : [SELECT Name, Amount__c, Tax__c FROM CalHK_Invoice__c]) {
            System.debug('CALTD invoice ' + i.Name + ' amount=' + i.Amount__c + ' tax=' + i.Tax__c);
        }
    }
}