import { LightningElement, wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import QUOTE_SELECTED_PUB from '@salesforce/messageChannel/CalMK4P_QuoteSelectedPub__c';

// CALHACK agent A, T-153 proof: a component that references the exposed channel.
export default class CalMK4PQuoteSelectedProbe extends LightningElement {
    lastQuoteId;
    @wire(MessageContext) messageContext;
    connectedCallback() {
        subscribe(this.messageContext, QUOTE_SELECTED_PUB, (m) => { this.lastQuoteId = m.quoteId; });
    }
}