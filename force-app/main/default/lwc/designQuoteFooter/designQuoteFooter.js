import { LightningElement, api, track} from 'lwc';
import quotetotals from "@salesforce/label/c.QUOTETOTALS";
import showGrandTotal from "@salesforce/label/c.ShowGrandTotal";
import totalSellPrice from "@salesforce/label/c.TotalSellPrice";

const EVENT_CONSTANT = {
    QUOTEFOOTERTOGGLE : 'quotefootertoggle'
}

export default class DesignQuoteFooter extends LightningElement {

    @api quoteWrapper;

    @track quoteDetails;

    label = {
        quotetotals,
        showGrandTotal,
        totalSellPrice
    };

    connectedCallback() {
        if (this.quoteWrapper) {
            this.quoteDetails = JSON.parse(JSON.stringify(this.quoteWrapper)); 
        }
    }

    handleChange(event) {
        this.quoteDetails.grandTotal = event.target.checked;

        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.QUOTEFOOTERTOGGLE, {
            detail: {
                quoteDetails : this.quoteDetails
            }
        })); 
    }
}