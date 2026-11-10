/** Test data: 10 rows, row 4 has Amount -5 (breaks validation rule CalMK6_Amount_Not_Negative). */
@IsTest
public class CalMK6_ImportTestData {
    public static List<CalMK6_Order__c> tenRowsOneBad() {
        List<CalMK6_Order__c> rows = new List<CalMK6_Order__c>();
        for (Integer i = 0; i < 10; i++) { rows.add(new CalMK6_Order__c(Name = 'CalMK6_Imp' + i, Amount__c = (i == 4) ? -5 : 10 + i)); }
        return rows;
    }
}