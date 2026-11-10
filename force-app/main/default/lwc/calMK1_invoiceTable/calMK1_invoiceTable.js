import { LightningElement, api, wire } from 'lwc';
import getOpenInvoices from '@salesforce/apex/CalMK1_InvoiceController.getOpenInvoices';

export default class CalMK1InvoiceTable extends LightningElement {
    @api region = 'EMEA';
    @wire(getOpenInvoices, { region: '$region' }) invoices;
}