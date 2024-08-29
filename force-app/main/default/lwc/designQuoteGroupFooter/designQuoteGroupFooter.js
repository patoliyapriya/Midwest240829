import { LightningElement,  track, api } from 'lwc';
import groupPriceTotal from "@salesforce/label/c.GroupPriceTotal";
import showGroupPrice from "@salesforce/label/c.ShowGroupPrice";

const EVENT_CONSTANT = {
    TOGGLECHANGE : 'togglechange',
    FOOTERTOGGLECHANGE : 'footertogglechange'
};

export default class DesignQuoteGroupFooter extends LightningElement {

    @api groupWrapper;

    @track groupDetails;

    label = {
        groupPriceTotal,
        showGroupPrice
    };

    connectedCallback() {
        if (this.groupWrapper) {
            this.groupDetails = JSON.parse(JSON.stringify(this.groupWrapper));
        }
    }

    handleChange(event) {
        this.groupDetails.hidePricing = event.target.checked;
        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.FOOTERTOGGLECHANGE, {
            detail: {
                groupDetails : this.groupDetails
            }
        })); 
    }
}