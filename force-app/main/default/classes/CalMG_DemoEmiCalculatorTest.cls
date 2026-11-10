@IsTest
private class CalMG_DemoEmiCalculatorTest {
    // 1481.40 at 10% -> 14814 / 1200 = 12.345 exactly: policy says 12.35
    @IsTest static void exactHalfCentRoundsUp() {
        Decimal raw = Decimal.valueOf('1481.40') * 10 / 1200;
        Assert.areEqual(Decimal.valueOf('12.345'), raw, 'raw interest');
        Assert.areEqual(Decimal.valueOf('12.35'), CalMG_DemoEmiCalculator.monthlyInterest(Decimal.valueOf('1481.40'), 10), '12.345 must round half-up');
    }
    // 1480.20 at 10% -> 12.335 -> 12.34 (half-even and half-up agree here)
    @IsTest static void oddHalfCentRoundsUp() {
        Assert.areEqual(Decimal.valueOf('12.34'), CalMG_DemoEmiCalculator.monthlyInterest(Decimal.valueOf('1480.20'), 10), '12.335');
    }
    // 1481.28 at 10% -> 12.344 -> 12.34
    @IsTest static void belowHalfRoundsDown() {
        Assert.areEqual(Decimal.valueOf('12.34'), CalMG_DemoEmiCalculator.monthlyInterest(Decimal.valueOf('1481.28'), 10), '12.344');
    }
    // -1481.40 at 10% -> -12.345 -> -12.35 (HALF_UP rounds away from zero; demo policy accepts that sign rule)
    @IsTest static void negativeHalfCentAwayFromZero() {
        Assert.areEqual(Decimal.valueOf('-12.35'), CalMG_DemoEmiCalculator.monthlyInterest(Decimal.valueOf('-1481.40'), 10), '-12.345');
    }
    // 2962.80 over 2 months at 10%: 24.69 + 12.345 -> 24.69 + 12.35 = 37.04
    @IsTest static void scheduleTotal() {
        List<Decimal> rows = CalMG_DemoEmiCalculator.schedule(Decimal.valueOf('2962.80'), 10, 2);
        Decimal total = 0;
        for (Decimal d : rows) { total += d; }
        Assert.areEqual(Decimal.valueOf('37.04'), total, 'schedule interest total; rows=' + rows);
    }
}