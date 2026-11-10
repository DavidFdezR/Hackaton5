// CALHACK-103 X-04 shared test.
@isTest
private class CalMG_DemoShippingCalcTest {
    @isTest
    static void partialBoxRoundsUp() {
        Assert.areEqual(4, CalMG_DemoShippingCalc.boxesNeeded(1250, 400), '1250 units at 400 per box');
    }

    @isTest
    static void exactDivisionUnchanged() {
        Assert.areEqual(2, CalMG_DemoShippingCalc.boxesNeeded(800, 400), '800 units at 400 per box');
    }

    @isTest
    static void zeroUnitsNeedNoBox() {
        Assert.areEqual(0, CalMG_DemoShippingCalc.boxesNeeded(0, 400), '0 units');
    }

    @isTest
    static void discountKeepsFraction() {
        Decimal pct = CalMG_DemoShippingCalc.discountPercent(15, 40);
        Assert.areEqual(37.50, pct, '15 off 40');
    }
}