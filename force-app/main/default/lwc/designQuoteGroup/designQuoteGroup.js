import { LightningElement, api, track} from 'lwc';

const CHILD_CONSTANT = {
    CHILDDESIGNQUOTEGROUPHEADER : 'c-design-quote-group-header',
    QUOTEGROUPTOGGLE : 'quotegrouptoggle'
};

export default class DesignQuoteGroup extends LightningElement {
    
    @api groupWrapper;

    @track groupDetails;

    connectedCallback() {
        this.groupDetails = JSON.parse(JSON.stringify(this.groupWrapper));
    }

    handleAccordianChange(event){
        this.groupDetails = event.detail.groupDetails;
    }

    handleSubGroupAccordion(event) {
        this.replaceElementBySubgroupId(event.detail.subGroupDetails);
        this.template.querySelector(CHILD_CONSTANT.CHILDDESIGNQUOTEGROUPHEADER).groupAccordion(this.groupDetails);
    }
 
    handleToggleChange(event) {
        this.replaceElementBySubgroupId(event.detail.subGroupDetail);
        this.template.querySelector(CHILD_CONSTANT.CHILDDESIGNQUOTEGROUPHEADER).groupAccordion(this.groupDetails);
        this.sendEventToQuoteContainer();
    }

    replaceElementBySubgroupId(newValue) {
        
        const index = this.groupDetails.subGroupDetails.findIndex(item => item.subGroupId === newValue.subGroupId);
        if (index !== -1) {
            this.groupDetails.subGroupDetails[index] = newValue;
        }
    }

    sendEventToQuoteContainer() {
        this.dispatchEvent(new CustomEvent(CHILD_CONSTANT.QUOTEGROUPTOGGLE, {
            detail: {
                message : this.groupDetails
            }
        }));
    }

    handleFooterToggleChange(event) {
        this.groupDetails = event.detail.groupDetails;
        this.sendEventToQuoteContainer();
    }


    
    handleHeaderToggleChange(event) {
        this.groupDetails = event.detail.groupDetails;
        this.sendEventToQuoteContainer();
    } 
}