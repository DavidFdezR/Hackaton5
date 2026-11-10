import { LightningElement, api } from 'lwc';
// CALHACK T-187: internal badge, not exposed. legacyLabel is an unused @api property left from a prototype.
export default class Calmk4cRefundBadge extends LightningElement {
    @api status;
    @api legacyLabel;
    get label() { return this.status === 'Approved' ? 'Approved' : 'Pending'; }
}