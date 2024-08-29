import { LightningElement,api, track } from 'lwc';
import subGroupPriceTotal from "@salesforce/label/c.SubGroupPriceTotal";
import showSubGroupPricing from "@salesforce/label/c.ShowSubGroupPricing";

const EVENT_CONSTANT = {
    FOOTERTOGGLECHANGE : 'footertogglechange',
};

export default class DesignQuoteSubGroupFooter extends LightningElement {

    @api subGroupWrapper;
    
    @track subGroupDetails;
    
    label = {
        subGroupPriceTotal,
        showSubGroupPricing
    };

    connectedCallback() {
        this.subGroupDetails = JSON.parse(JSON.stringify(this.subGroupWrapper));
    }

    handleToogle(event) {
        this.subGroupDetails.hidePricing = event.target.checked;
        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.FOOTERTOGGLECHANGE, {
            detail: {
                message : this.subGroupDetails
            }
        }));
    }
    
    @api
    toggleChanges(subGroupDetail) {
        this.subGroupDetails = subGroupDetail;
    }
}