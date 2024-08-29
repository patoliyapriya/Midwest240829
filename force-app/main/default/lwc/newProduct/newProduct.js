import { LightningElement, api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RecordFormCreateExample extends LightningElement {
    // objectApiName is "Account" when this component is placed on an account record page
    @api objectApiName;
    @track isLoading = false;

    fields = [  'Name', 'Manufacturer__c', 'ProductCode', 'Product_Type__c',
                'Description', 'IsActive', 'Weight__c', 'Product_Description__c'];

    handleSuccess(event) {
        let url = window.location.origin + '/lightning/r/Product2/'+ event.detail.id +'/view';
        const evt = new ShowToastEvent({
            title: "Product "+event.detail.Name+" was created",
            message: '',
            variant: "success"
        });
        this.dispatchEvent(evt);
        console.log('url='+url);
        window.open(url,'_self');
    }

    handleError(event) {
        this.isLoading = false;
        console.log('1'+JSON.stringify(event));
        console.log('2'+JSON.stringify(event.detail.detail));
        const evt = new ShowToastEvent({
            title: "Error",
            message: JSON.stringify(event.detail.detail),
            variant: "error"
        });
        this.dispatchEvent(evt);
    }

    validateFields() {
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            element.reportValidity();
        });
    }

    loading(event) {
        this.isLoading = true;
    }
}