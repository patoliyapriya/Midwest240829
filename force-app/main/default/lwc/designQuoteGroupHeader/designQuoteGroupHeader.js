import { LightningElement,  track, api } from 'lwc';
import pageBreakAfterGroup from "@salesforce/label/c.PageBreakAfterGroup";

const EVENT_CONSTANT = {
    ACCORDION : 'accordion',
    HEADERTOGGLECHANGE : 'headertogglechange'
};

export default class DesignQuoteGroupHeader extends LightningElement {

    @api groupWrapper;

    @track groupDetails;

    label = { 
        pageBreakAfterGroup
    };
    
    connectedCallback() {
        this.groupDetails = JSON.parse(JSON.stringify(this.groupWrapper));
    }

    @api
    groupAccordion(groupDetail) {
        this.groupDetails = groupDetail;
    }
    
    handleAccordion() {
        this.groupDetails.isOpen = !(this.groupDetails.isOpen);
        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.ACCORDION, {
            detail: {
                groupDetails : this.groupDetails
            }
        }))
    }

    handleChange(event) {
        this.groupDetails.pageBreak = event.target.checked;

        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.HEADERTOGGLECHANGE, {
            detail: {
                groupDetails : this.groupDetails
            }
        })); 
    }
}