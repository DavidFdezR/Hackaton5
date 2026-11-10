// CalMG demo: give a co-relationship-manager read access to a client's financial account.
public with sharing class CalMG_DemoCoRmSharing {
    public static Id shareWithCoRm(Id finAccountId, Id userId) {
        CalMG_Demo_FinAccount__Share s = new CalMG_Demo_FinAccount__Share(
            ParentId = finAccountId,
            UserOrGroupId = userId,
            AccessLevel = 'Read'
        );
        insert s;
        return s.Id;
    }
}