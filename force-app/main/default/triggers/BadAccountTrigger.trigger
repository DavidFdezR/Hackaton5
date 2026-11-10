trigger BadAccountTrigger on Account (after update) {
    for (Account acc : Trigger.new) {
        // This query runs for EVERY account in the loop -> hits System.LimitException: Too many SOQL queries: 101
        List<Contact> contacts = [SELECT Id, Name, Description FROM Contact WHERE AccountId = :acc.Id];
        if (contacts.size() > 0){
        
       
        for(Contact c : contacts){
        c.Description = c.Description + '1';
        update c;
        }
        }
    }
}