import { LightningElement, track, wire } from 'lwc';
import { getRecord } from "lightning/uiRecordApi";
import NAME_FIELD from "@salesforce/schema/Opportunity.Name";
import getQuoteListByOpportunity from '@salesforce/apex/OpportunityController.getQuoteListByOpportunity';
import { NavigationMixin } from "lightning/navigation";
import cloneOpportunity from '@salesforce/apex/OpportunityController.cloneOpportunity';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const NAV_CONSTANT = {
    STANDARDRECORDPAGE : 'standard__recordPage',
    VIEW : 'view'
}

const MESSAGE_CONSTANT = {
    ERROR : 'error',
    ERRORAPEX : 'Error calling Apex method:',
    SUCCESS : 'success',
    SAVEDMSG : 'The record has been saved successfully',
};

export default class CloneOpportunityWithQuotes extends NavigationMixin(LightningElement) {

    @track recordId;
    @track showNext = false;
    @track oppName;
    @track title = 'Opportunity Information';
    @track isLoading = true;
    @track opportunityQuotes;
    @track checkboxVal = true;
    @track checkboxTopVal = true;
    error;

    connectedCallback() {
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        if(urlParams.has('recordId')){
            this.recordId = urlParams.get('recordId');
        }
    }

    @wire(getRecord, {recordId: "$recordId", fields: [NAME_FIELD] })
        wiredOpportunity({ error, data }) {
        if (data) {
            this.error = undefined;
            this.oppName = data.fields.Name.value;
            this.loadQuotes();
        } else if (error) {
            this.error = error;
        }
    }

    handleOppNameChange(event) {
        this.oppName = event.target.value;

        this.opportunityQuotes.forEach(element => {
            element.newQuote.Opportunity_Name__c = event.target.value;
        });
    }

    handleNext() {
        if(this.oppName == null || this.oppName == ''){
            return;
        } else {
            this.isLoading = true;
            this.showNext = true;
            this.title = 'Quote Information';
            this.isLoading = false;
        }
    }

    async loadQuotes() {
        this.opportunityQuotes = await getQuoteListByOpportunity({recordId : this.recordId});
        this.isLoading = false;
    }


    handlePrevious() {
        this.showNext = false;
        this.title = 'Opportunity Information';
    }

    handleCancel() {
        this[NavigationMixin.Navigate]({
            type: NAV_CONSTANT.STANDARDRECORDPAGE,
            attributes: {
                recordId: this.recordId,
                actionName: NAV_CONSTANT.VIEW
            }
        });
    }

    navigateToNewOpportunity() {
        this[NavigationMixin.Navigate]({
            type: NAV_CONSTANT.STANDARDRECORDPAGE,
            attributes: {
                recordId: this.recordId,
                actionName: NAV_CONSTANT.VIEW
            }
        });
    }

    handleChange(event) { 
        const field = event.target.dataset.name;
        this.opportunityQuotes.forEach(element => {
            if(event.target.dataset.id == element.oldQuote.Id) {
                if(field == 'cloneQuoteName') {
                    element.newQuote.Opportunity_Name__c = event.target.value;
                } else if(field == 'checkbox') {  
                    element.isSelected = event.target.checked;
                    if(event.target.checked) {
                        this.template.querySelector(`[data-id="${event.target.dataset.id}"][data-name="cloneQuoteName"]`).required = true;
                    } else{
                        this.template.querySelector(`[data-id="${event.target.dataset.id}"][data-name="cloneQuoteName"]`).required = false;
                    }
                }
            }
        });

        this.checkboxTopVal = this.checkAllChecked();
    }


    checkAllChecked() {
        return this.opportunityQuotes.every((element) => {
            return element.isSelected;
        });
    }
    

    async cloneOpportunity() {
        try {
            this.recordId = await cloneOpportunity({opportunityId : this.recordId, opportunityName : this.oppName, opportunityQuotes : JSON.stringify(this.opportunityQuotes) });
            this.isLoading = false;
            this.showToast(MESSAGE_CONSTANT.SUCCESS, MESSAGE_CONSTANT.SAVEDMSG, MESSAGE_CONSTANT.SUCCESS);
            this.navigateToNewOpportunity();
        } catch (error) {
            this.showToast(MESSAGE_CONSTANT.ERROR, MESSAGE_CONSTANT.ERRORAPEX + error.body.message, MESSAGE_CONSTANT.ERROR);
        }
    }

    handleSave() { 
        const flag = true;
        this.opportunityQuotes.forEach(element => {
            if(element.isSelected == true && (element.newQuote.Opportunity_Name__c == '' || element.newQuote.Opportunity_Name__c == null) ) {
                flag = false;
                return;
            }
         });
         if(flag == true) {
            this.isLoading = true;
            this.cloneOpportunity();
         }
    }


    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    selectAllCheckboxes(event) {
        const checked = event.target.checked;
        
       if(checked) {
            this.checkboxVal = true;
            this.checkboxTopVal = true;
       } else {
            this.checkboxVal = false;
            this.checkboxTopVal = false;
       }

       this.opportunityQuotes.forEach(element => {
            element.isSelected = event.target.checked;        
        });
    }
}