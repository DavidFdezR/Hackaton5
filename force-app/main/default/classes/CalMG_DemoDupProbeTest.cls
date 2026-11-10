@IsTest
private class CalMG_DemoDupProbeTest {
    @IsTest static void probeRunsInTest() {
        String r = CalMG_DemoDupProbe.run('T');
        System.debug(LoggingLevel.ERROR, 'CALMG ' + r);
        Assert.isTrue(r.startsWith('base saved=true'), r);
    }
}