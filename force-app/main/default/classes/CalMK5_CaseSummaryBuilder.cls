/**
 * CalMK5 attack fixture (CALHACK-102 A-022). Builds the prompt text a summary feature would send
 * to an LLM. The instruction part comes from Custom Label CalMK5_CaseSummaryInstructions, so whoever
 * edits that label edits the prompt. Nothing here calls an LLM or any URL.
 */
public with sharing class CalMK5_CaseSummaryBuilder {
    public static String buildPrompt(CalMK5_Ticket__c t) {
        return System.Label.CalMK5_CaseSummaryInstructions + '\n<data>\n' + t.Name + '\n' + t.Summary__c + '\n</data>';
    }
}