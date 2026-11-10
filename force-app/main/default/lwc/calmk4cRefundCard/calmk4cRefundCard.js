import { LightningElement, api } from 'lwc';
// CALHACK T-187: internal parent of calmk4cRefundBadge (passes status only).
export default class Calmk4cRefundCard extends LightningElement {
    @api refundStatus = 'Pending';
}