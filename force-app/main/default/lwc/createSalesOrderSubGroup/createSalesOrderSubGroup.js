import { LightningElement, api, track } from 'lwc';

const EVENT_CONSTANT = {
   ACCORDION : 'accordion'
}

const CHILD_CONSTANT = {
    CHILDSUBGROUPHEADER : 'c-create-sales-order-sub-group-header',
};

export default class CreateSalesOrderSubGroup extends LightningElement {

    @api subGroupWrapper;
    @api quoteDetails;
    @api groupWrapper;

    @track subGroupHeader;

    connectedCallback() {
        this.subGroupHeader = JSON.parse(JSON.stringify(this.subGroupWrapper));
    }

    handleAccordianChange(event){
        this.subGroupHeader = event.detail.subGroupDetails;
        this.template.querySelector(CHILD_CONSTANT.CHILDSUBGROUPHEADER).subGroupAccordion(this.subGroupHeader);

        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.ACCORDION, {
            detail: {
                subGroupDetails : this.subGroupHeader
            }
        }));
    }
    
}