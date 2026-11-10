/** CALHACK T-180: after saving, send the user back to retURL (the "standard Salesforce pattern"). */
public with sharing class CalMK4C_RefundDoneCtrl {
    public PageReference finish() {
        String ret = ApexPages.currentPage().getParameters().get('retURL');
        PageReference pr = new PageReference(String.isBlank(ret) ? '/home/home.jsp' : ret);
        pr.setRedirect(true);
        return pr;
    }
    /** Safe twin: only same-org relative paths. */
    public PageReference finishSafe() {
        String ret = ApexPages.currentPage().getParameters().get('retURL');
        Boolean relative = ret != null && ret.startsWith('/') && !ret.startsWith('//') && !ret.contains('\\');
        PageReference pr = new PageReference(relative ? ret : '/home/home.jsp');
        pr.setRedirect(true);
        return pr;
    }
}