import { LightningElement, api, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import QUOTE_SELECTED from '@salesforce/messageChannel/CalMK4P_QuoteSelected__c';
import getQuote from '@salesforce/apex/CalMK4P_QuoteCardCtrl.getQuote';

// CALHACK agent A, T-146: stands in for a component inside a 2GP managed package.
export default class CalMK4PQuoteSummaryCard extends LightningElement {
    @api recordId;
    @api showDiscount = false;
    @wire(MessageContext) messageContext;
    @wire(getQuote, { quoteId: '$recordId' }) quote;

    handleSelect() {
        publish(this.messageContext, QUOTE_SELECTED, { quoteId: this.recordId });
    }
}