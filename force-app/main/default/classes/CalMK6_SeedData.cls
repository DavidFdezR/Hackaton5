/** CALHACK-103 lab seed (idempotent, never deletes). Plants org records used as reproduction evidence. */
public with sharing class CalMK6_SeedData {
    /** Q-036: the org reference record that the SeeAllData test silently depends on. */
    public static String plantGoldReference() {
        List<CalMK6_Customer__c> existing = [SELECT Id, Default_Discount__c FROM CalMK6_Customer__c WHERE Name = 'CalMK6_Demo Gold Reference' LIMIT 1];
        if (!existing.isEmpty()) { return 'exists ' + existing[0].Default_Discount__c; }
        insert new CalMK6_Customer__c(Name = 'CalMK6_Demo Gold Reference', Tier__c = 'Gold', Default_Discount__c = 12);
        return 'created 12';
    }
    /** Q-030: one real West and one real East order; reports the share rows the criteria rule wrote to CalMK6_West_Managers. */
    public static String plantWestShareProof() {
        Map<String, String> wanted = new Map<String, String>{ 'CalMK6_Demo West Share Proof' => 'West', 'CalMK6_Demo East Share Proof' => 'East' };
        Map<String, CalMK6_Order__c> have = new Map<String, CalMK6_Order__c>();
        for (CalMK6_Order__c o : [SELECT Id, Name FROM CalMK6_Order__c WHERE Name IN :wanted.keySet()]) { have.put(o.Name, o); }
        List<CalMK6_Order__c> toInsert = new List<CalMK6_Order__c>();
        for (String n : wanted.keySet()) { if (!have.containsKey(n)) { toInsert.add(new CalMK6_Order__c(Name = n, Region__c = wanted.get(n), Amount__c = 100)); } }
        if (!toInsert.isEmpty()) { insert toInsert; for (CalMK6_Order__c o : toInsert) { have.put(o.Name, o); } }
        Id g = [SELECT Id FROM Group WHERE DeveloperName = 'CalMK6_West_Managers'].Id;
        Integer westRule = [SELECT COUNT() FROM CalMK6_Order__Share WHERE ParentId = :have.get('CalMK6_Demo West Share Proof').Id AND UserOrGroupId = :g AND RowCause = 'Rule'];
        Integer eastRule = [SELECT COUNT() FROM CalMK6_Order__Share WHERE ParentId = :have.get('CalMK6_Demo East Share Proof').Id AND UserOrGroupId = :g];
        return 'inserted=' + toInsert.size() + ' westRuleSharesToGroup=' + westRule + ' eastSharesToGroup=' + eastRule;
    }
}