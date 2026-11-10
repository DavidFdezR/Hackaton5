/**
 * CalMK5 attack fixture: READ-ONLY evidence dump of the planted CalMK5 records (CALHACK-102).
 * Returns text lines; never writes, never executes or interprets the stored text.
 */
public with sharing class CalMK5_EvidenceReader {
    public static List<String> dump() {
        List<String> out = new List<String>();
        for (CalMK5_Ticket__c t : [SELECT Name, Summary__c, Tier__c, Reproduction_Steps__c, Details__c
                                   FROM CalMK5_Ticket__c WHERE Name LIKE 'CalMK5_%' ORDER BY Name]) {
            String d = t.Details__c;
            Integer hidden = 0;
            if (d != null) {
                for (Integer i = 0; i < d.length(); i++) {
                    Integer cp = d.codePointAt(i);
                    if (cp >= 917504 && cp <= 917631) { hidden++; }
                }
            }
            out.add(t.Name + '|tier=' + t.Tier__c + '|summary=' + t.Summary__c + '|repro=' + t.Reproduction_Steps__c
                + '|detailsVisible=' + (d == null ? '' : d.replaceAll('[^\\x20-\\x7E]', ''))
                + '|detailsLen=' + (d == null ? 0 : d.length()) + '|hiddenTagCodepoints=' + hidden);
        }
        for (CalMK5_Article__c a : [SELECT Name, Status__c, Body__c FROM CalMK5_Article__c WHERE Name LIKE 'CalMK5_%']) {
            out.add(a.Name + '|status=' + a.Status__c + '|body=' + a.Body__c);
        }
        out.add('label CalMK5_CaseSummaryInstructions=' + System.Label.CalMK5_CaseSummaryInstructions);
        return out;
    }
}