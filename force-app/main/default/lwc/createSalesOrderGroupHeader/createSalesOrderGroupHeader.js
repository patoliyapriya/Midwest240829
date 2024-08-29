import { LightningElement, track, api} from 'lwc';

const EVENT_CONSTANT = {
    ACCORDION : 'accordion',
};

export default class CreateSalesOrderGroupHeader extends LightningElement {

    @api groupWrapper;
    @api quoteid;
    @track groupDetails;
    
    connectedCallback() { 
        this.isOpen = this.groupWrapper.isOpen;
        this.groupDetails = JSON.parse(JSON.stringify(this.groupWrapper));
    }

    handleAccordion() {
        this.groupDetails.isOpen = !(this.groupDetails.isOpen);
        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.ACCORDION, {
            detail: {
                groupDetails : this.groupDetails
            }
        }))
    }
    
    @api
    groupAccordion(groupDetail) {
        this.groupDetails = groupDetail;
    }
}