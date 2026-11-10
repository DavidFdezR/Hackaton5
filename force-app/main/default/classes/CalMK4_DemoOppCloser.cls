/** CALHACK T-093 (planted, bad on purpose): one update DML per Opportunity inside the loop. */
public with sharing class CalMK4_DemoOppCloser {
    public static void closeAll(List<Opportunity> opps) {
        for (Opportunity o : opps) {
            o.StageName = 'Closed Won';
            update o;
        }
    }
}