import { LightningElement, api, track } from 'lwc';

const CHILD_CONSTANT = {
    CHILDGROUPHEADER : 'c-create-sales-order-group-header',
}

export default class CreateSalesOrderGroup extends LightningElement {

    @api groupWrapper;
    @track groupDetails;

    @api quoteid;
    @api quoteDetails;

    connectedCallback() {
        this.groupDetails = JSON.parse(JSON.stringify(this.groupWrapper));
    }

    handleAccordianChange(event){
        this.groupDetails = event.detail.groupDetails;
    }

    handleSubGroupAccordion(event) {
        this.replaceElementBySubgroupId(event.detail.subGroupDetails);
        this.template.querySelector(CHILD_CONSTANT.CHILDGROUPHEADER).groupAccordion(this.groupDetails);
    }

    replaceElementBySubgroupId(newValue) {  
        const index = this.groupDetails.subGroupDetails.findIndex(item => item.subGroupId === newValue.subGroupId);
        if (index !== -1) {
            this.groupDetails.subGroupDetails[index] = newValue;
        }
    }

}