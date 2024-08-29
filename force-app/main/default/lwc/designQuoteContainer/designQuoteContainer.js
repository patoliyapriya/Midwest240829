import { LightningElement, api, track} from 'lwc';
import getCartWrapper from '@salesforce/apex/QuoteController.getCartWrapper';

export default class DesignQuoteContainer extends LightningElement {
    
    @api quoteid;

    @track isLoading = false;
    @track cartWrapper;

    connectedCallback() {
        this.loadCartWrapper();
    }
    
    async loadCartWrapper() {
        try {
            this.isLoading = true;
            const response = await getCartWrapper({ quoteId: this.quoteid });
            this.isLoading = false;
            this.cartWrapper = response;
        }
        catch (error) {
            console.error(error);
        }
    }

    handleQuoteGroupToggle(event) {
        this.replaceElementByGroupId(event.detail.message);
    }

    replaceElementByGroupId(newValue) {  
        const index = this.cartWrapper.groupDetails.findIndex(item => item.groupId === newValue.groupId);
        if (index !== -1) {
            this.cartWrapper.groupDetails[index] = newValue;
        }
    }

    handleQuoteFooterToggle(event) {
        this.cartWrapper.quoteDetails = event.detail.quoteDetails;
    }
    
}