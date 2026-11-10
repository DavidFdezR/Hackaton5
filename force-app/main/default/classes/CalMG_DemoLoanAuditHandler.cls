// CalMG demo: custom audit trail for regulated loan fields (beyond field history's limits).
public without sharing class CalMG_DemoLoanAuditHandler {
    public static final List<String> REGULATED = new List<String>{
        'Credit_Memo__c', 'Collateral_Value__c', 'Interest_Rate__c', 'Credit_Limit__c', 'Status__c'
    };

    public static void audit(List<CalMG_Demo_Loan__c> rows, Map<Id, CalMG_Demo_Loan__c> oldMap) {
        List<CalMG_Demo_Loan_Audit__c> out = new List<CalMG_Demo_Loan_Audit__c>();
        for (CalMG_Demo_Loan__c l : rows) {
            CalMG_Demo_Loan__c o = oldMap.get(l.Id);
            for (String f : REGULATED) {
                Object nv = l.get(f), ov = o.get(f);
                if (nv != ov) {
                    out.add(new CalMG_Demo_Loan_Audit__c(Loan__c = l.Id, Field__c = f,
                        Old__c = clip(ov), New__c = clip(nv), Changed_By__c = UserInfo.getUserId()));
                }
            }
        }
        insert out;
    }

    private static String clip(Object v) {
        return v == null ? null : String.valueOf(v).left(255);
    }
}