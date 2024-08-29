import { LightningElement,api,track } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import getCartWrapper from '@salesforce/apex/QuoteController.getCartWrapper';

const MESSAGE_CONSTANT = {
    ERRORAPEX : 'Error calling Apex method:'
};

const protocol = window.location.href ;
console.log('URL is '+ protocol);

var urlObj = new URL(protocol);
var queryParams = new URLSearchParams(urlObj.search);
var quoteI = queryParams.get("id");
console.log("Quote ID:", quoteI);

let ids = new Set();

export default class SalesOrderCreate extends NavigationMixin(LightningElement) {

    @api quoteId;

    @track cartWrapper;
    @track isLoading = false;
    @track isIds;

    connectedCallback() {
        this.quoteId = quoteI;
        this.loadCartWrapper();
    }

    async loadCartWrapper(message) {
        try {
            this.isLoading = true;
            const response = await getCartWrapper({ quoteId: this.quoteId });
            this.isLoading = false;
            this.cartWrapper = response;
            // console.log('cartwrapper is================'+ this.cartWrapper);
            // this.isTaxable = response.isTaxable;
            // console.log('istexableis-----------------' +this.cartWrapper.quoteDetails.isTaxable);
        } catch (error) {
            this.isLoading = false;
            console.error(MESSAGE_CONSTANT.ERRORAPEX, error);
        }
    }
    
    handleLineItemChange(event) {
        // ids = event.detail.selectedId;
        this.isIds = Array.from(event.detail.selectedId);
        // console.log('idssssss' + Array.from(idss));
        console.log('idssssss' + this.isIds);
    }

}