@IsTest
private class CalMK2_RebateCalcTest {
    @IsTest
    static void tierBoundaries() {
        Assert.areEqual('NONE', CalMK2_RebateCalc.tierFor(null));
        Assert.areEqual('GOLD', CalMK2_RebateCalc.tierFor(100000));
        Assert.areEqual('SILVER', CalMK2_RebateCalc.tierFor(10000));
        Assert.areEqual('BRONZE', CalMK2_RebateCalc.tierFor(9999.99));
    }
}