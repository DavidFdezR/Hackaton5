import { LightningElement, api, wire } from 'lwc';
import getQuote from '@salesforce/apex/CalMK4P_QuoteCardCtrl.getQuote';

// CALHACK agent A, T-147: demo-org-only copy, NOT part of any package.
export default class CalMK4PQuoteDemoCard extends LightningElement {
    @api recordId;
    @wire(getQuote, { quoteId: '$recordId' }) quote;
}