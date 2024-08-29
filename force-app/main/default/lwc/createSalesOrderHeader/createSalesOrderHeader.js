import {api, track} from "lwc";
import { LightningElement} from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import cancelLabel from "@salesforce/label/c.CancelButtonLabel";
import CreateSalesOrder from "@salesforce/label/c.CreateSalesOrder";
import insertQuote from '@salesforce/apex/CreateSalesOrder.insertQuote';

const NAV_CONSTANT = {
    STANDARDRECORDPAGE : 'standard__recordPage',
    VIEW : 'view',
    BLANK : '_blank',
}

export default class CreateSalesOrderHeader extends NavigationMixin(LightningElement) {
    
    @api quoteid;
    @api cartWrapper;
    @api isTaxable;
    
    @track AccountTaxable;
    @track cartWrapperDetails;

    label = {cancelLabel, CreateSalesOrder};

    connectedCallback() {
        this.cartWrapperDetails = JSON.parse(JSON.stringify(this.cartWrapper));
        // this.AccountTaxable = this.cartWrapperDetails.quoteDetails.Opportunity.Account.Is_Taxable__c;
        console.log(JSON.stringify(this.cartWrapper));
        // console.log('dddddddddddd'+this.isTaxable);
    }

    handleCancel() {
        this[NavigationMixin.Navigate]({
            type: NAV_CONSTANT.STANDARDRECORDPAGE,
            attributes: {
                recordId: this.quoteid,
                actionName: NAV_CONSTANT.VIEW
            }
        });
    }

    openQuote() {
        var url = '/one/one.app?id='+this.quoteid+'&mode=create#eyJjb21wb25lbnREZWYiOiJjOmNyZWF0ZVNhbGVzT3JkZXIifQ==';
        window.open(url, NAV_CONSTANT.BLANK);
    }

    async handlecreateSalesOrder() {
        await insertQuote({ cartWrapperString: JSON.stringify(this.cartWrapper) })
                        .then(result => {

                        })
                        .catch(error => {
                            this.error = error;
                            console.error("Error retrieving Opportunity: ", error);
                        });
    }
}