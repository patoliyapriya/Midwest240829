import { LightningElement, api, track } from 'lwc';

const EVENT_CONSTANT = {
    TOGGLECHANGE : 'togglechange'
}


export default class DesignQuoteLineItems extends LightningElement {

    @api lineItemWrapper;

    @track lineItemDetails;

    connectedCallback() {
        this.lineItemDetails = JSON.parse(JSON.stringify(this.lineItemWrapper));
        // this.lineItemDetails.forEach((element) => {
        //     element.hideQuantity = !(element.hideQuantity);
        //     element.hideCode = !(element.hideCode);
        //     element.hidePricing = !(element.hidePricing);
        //     element.hideLine = !(element.hideLine);
        // });
    }

    @api 
    subGroupToggle(checked,field) {
        this.lineItemDetails = this.lineItemDetails.map((element) => {
            const updatedElement = { ...element };
            updatedElement[field] = checked;    
            return updatedElement;
        });
        return this.lineItemDetails;
    }

    handleToggleChange (event) {
        const field = event.target.dataset.name;
        this.lineItemDetails.forEach((element) => {
            if(element.lineItemId === event.target.dataset.id) {
                element[field] = event.target.checked;
            }
        });
        let allLineItemChecked=  this.isAllLineItemChecked(this.lineItemDetails,field);

        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.TOGGLECHANGE, {
            detail: {
                message : allLineItemChecked,
                isFrom : field,
                value : this.lineItemDetails
            }
        }));
    }

    isAllLineItemChecked(allLineItems,field) {
        return allLineItems.every((element) => {
            return element[field];
        });
    }
}