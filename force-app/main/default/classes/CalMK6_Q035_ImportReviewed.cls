/** Q-035 after the reviewer's edit: same partial-success insert, now returns one message per failed row. */
public with sharing class CalMK6_Q035_ImportReviewed {
    public static List<String> importRows(List<CalMK6_Order__c> rows) {
        List<String> errors = new List<String>();
        List<Database.SaveResult> results = Database.insert(rows, false);
        for (Integer i = 0; i < results.size(); i++) {
            if (!results[i].isSuccess()) {
                for (Database.Error e : results[i].getErrors()) { errors.add('row ' + i + ': ' + e.getMessage()); }
            }
        }
        return errors;
    }
}