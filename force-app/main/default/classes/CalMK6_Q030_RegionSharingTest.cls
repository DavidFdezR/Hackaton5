/** Q-030 REVIEWED VERSION (the human edit). Criteria-based sharing cannot be exercised from Apex tests (Security Implementation
    Guide), so the agent's runAs test of the rule always saw 0 rows. The reviewer replaced it with what Apex CAN prove:
    the `with sharing` service honours a group share of the kind the rule writes, and a non-member still sees nothing.
    The rule itself is proven on a real planted record via CalMK6_SeedData.plantWestShareProof(). */
@IsTest
private class CalMK6_Q030_RegionSharingTest {
    @IsTest static void groupShareGrantsWestOnly() {
        User u = CalMK6_SharingTestKit.westManager(true);
        CalMK6_SharingTestKit.fiveWestFiveEast();
        Id g = [SELECT Id FROM Group WHERE DeveloperName = 'CalMK6_West_Managers'].Id;
        List<CalMK6_Order__Share> shares = new List<CalMK6_Order__Share>();
        for (CalMK6_Order__c o : [SELECT Id FROM CalMK6_Order__c WHERE Region__c = 'West']) {
            shares.add(new CalMK6_Order__Share(ParentId = o.Id, UserOrGroupId = g, AccessLevel = 'Read', RowCause = 'Manual'));
        }
        insert shares;
        Integer west; Integer east;
        System.runAs(u) {
            west = CalMK6_RegionOrderService.getRegionOrders('West').size();
            east = CalMK6_RegionOrderService.getRegionOrders('East').size();
        }
        Assert.areEqual(5, west);
        Assert.areEqual(0, east);
    }
    @IsTest static void nonMemberStillSeesNothing() {
        User u = CalMK6_SharingTestKit.westManager(false);
        CalMK6_SharingTestKit.fiveWestFiveEast();
        System.runAs(u) { Assert.areEqual(0, CalMK6_RegionOrderService.getRegionOrders('West').size()); }
    }
}