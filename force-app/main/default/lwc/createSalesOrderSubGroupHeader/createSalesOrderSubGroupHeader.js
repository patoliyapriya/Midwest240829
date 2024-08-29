import { LightningElement, track, api } from 'lwc';

const EVENT_CONSTANT = {
    ACCORDION : 'accordion'
};
export default class CreateSalesOrderSubGroupHeader extends LightningElement {

    @api subGroupWrapper;
    @api quoteDetails;

    @track subGroupDetails;

    connectedCallback() {
        this.subGroupDetails = JSON.parse(JSON.stringify(this.subGroupWrapper));
    }

    handleSubGroupAccordion() {
        this.subGroupDetails.isOpen = !(this.subGroupDetails.isOpen);
        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.ACCORDION, {
            detail: {
                subGroupDetails : this.subGroupDetails
            }
        }));
    }

    @api
    subGroupAccordion(subGroupDetail) {
        this.subGroupDetails = subGroupDetail;
    }
}