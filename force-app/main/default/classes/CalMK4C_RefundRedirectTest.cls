@IsTest
private class CalMK4C_RefundRedirectTest {
    @IsTest static void retUrlGoesOffPlatform() {
        PageReference pg = Page.CalMK4C_RefundDone;
        pg.getParameters().put('retURL', 'https://refund-verify.example/login');
        Test.setCurrentPage(pg);
        CalMK4C_RefundDoneCtrl c = new CalMK4C_RefundDoneCtrl();
        String leaky = c.finish().getUrl();
        String safe = c.finishSafe().getUrl();
        pg.getParameters().put('retURL', '//refund-verify.example/login');
        String safeProtoRel = c.finishSafe().getUrl();
        System.debug('CALMK4C_EVIDENCE finish() redirects to ' + leaky + ' | finishSafe() -> ' + safe + ' | finishSafe(//host) -> ' + safeProtoRel);
        System.assertEquals('https://refund-verify.example/login', leaky);
        System.assertEquals('/home/home.jsp', safe);
        System.assertEquals('/home/home.jsp', safeProtoRel);
    }
}