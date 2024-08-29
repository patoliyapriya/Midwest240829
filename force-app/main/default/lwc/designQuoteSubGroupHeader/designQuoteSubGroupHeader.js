import { LightningElement, api, track } from 'lwc';

const EVENT_CONSTANT = {
    TOGGLECHANGE : 'togglechange',
    ACCORDION : 'accordion'
};

const FIELD_CONSTANT = {
    HIDEQUANTITY : 'hideQuantity',
    HIDECODE : 'hideCode',
    HIDEAMOUNT : 'hideAmount'
}

export default class DesignQuoteSubGroupHeader extends LightningElement {
    
    @api subGroupWrapper;

    @track subGroupDetails;
   
    connectedCallback() {
        this.subGroupDetails = JSON.parse(JSON.stringify(this.subGroupWrapper));
        // this.subGroupDetails.hideQuantity = !(this.subGroupDetails.hideQuantity);
        // this.subGroupDetails.hideCode = !(this.subGroupDetails.hideCode);
        // this.subGroupDetails.hideAmount = !(this.subGroupDetails.hideAmount);
        // this.subGroupDetails.hideLine = !(this.subGroupDetails.hideLine);
    }

    handleToogle(event) {
        const isFrom = event.target.dataset.name;

        if (isFrom === FIELD_CONSTANT.HIDEQUANTITY) {
            this.subGroupDetails.hideQuantity = event.target.checked;
        } 
        else if (isFrom === FIELD_CONSTANT.HIDECODE) {
            this.subGroupDetails.hideCode = event.target.checked;
        }
        else if (isFrom === FIELD_CONSTANT.HIDEAMOUNT) {
            this.subGroupDetails.hideAmount = event.target.checked;
        }
        else {
            this.subGroupDetails.hideLine = event.target.checked;
        }  
        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.TOGGLECHANGE, {
            detail: {
                from : isFrom,
                message : this.subGroupDetails
            }
        }));
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
    lineItemToggle(subGroupHeader) {
        this.subGroupDetails = subGroupHeader;
    }
  
}