import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OpportunityTurnover extends LightningElement {
    @track searchKey = '';
    @api isLoading = false;
    @track field = 'Customer_PO_In_Hand__c';
    @track marginRows = [
        { label:'Final Review Before Release?', picklist: 'Final_Review_Before_Release__c', note: 'Final_Review_Before_Release_Notes__c'},
        { label:'Has Project Info Sheet been Received?', picklist: 'Has_Project_Info_Sheet_been_Received__c', note: 'Has_Project_Info_Sheet_been_Notes__c'},
        { label:'Tax status?', picklist: 'Tax_Status__c', note: 'Tax_status_Notes__c'},
        { label:'O&M\'s Sent?', picklist: 'O_M_s_Sent__c', note: 'O_M_s_Sent_Notes__c'},
        { label:'Thank you Letter Sent to Customer?', picklist: 'Thank_you_Letter_Sent_to_Customer__c', note: 'Thank_you_Letter_Sent_Notes__c'},
        { label:'Does Price Reflect Equipment Want Date?', picklist: 'Does_Price_Reflect_Equipement_Want_Date__c', note: 'Does_Price_Reflect_Equipment_Notes__c'},
        { label:'Review Statement of Compliance from SE 2/Comments?', picklist: 'Review_Statement_of_Compliance_from_SE_2__c', note: 'Review_Statement_of_Compliance_Notes__c'}
    ]
    @track turnoverRows = [
        { picklist: 'Review_Credit_Status__c', note: 'Existing_Customer_Notes__c', label:'Existing Customer - has accounting review credit status?' },
        { picklist: 'Return_to_Accounting__c', note: 'New_Customer_has_customer_Notes__c', label:'New Customer - has customer provide completed credit applications and resale certificate if applicable and return to accounting?' },
        { picklist:'Customer_PO_In_Hand__c', note:'Customer_PO_In_Hand_Notes__c', label:'Customer PO In Hand?' },
        { picklist:'Submittal_Approval_Received__c', note:'Submittal_Approval_Received_Notes__c', label:'Submittal Approval Received?' },
        { picklist:'Special_pricing_approval_documentation_n__c', note:'Special_pricing_approval_Notes__c', label:'Special pricing approval documentation needed?' },
        { picklist:'Special_Shipping_Requirements__c', note:'Special_Shipping_Requirements_Notes__c', label:'Special Shipping Requirements?' },
        { picklist:'Special_Warranty_Requirements__c', note:'Special_Warranty_Requirements_Notes__c', label:'Special Warranty Requirements?' },
        { picklist:'Special_Drawing_Requirements__c', note:'Special_Drawing_Requirements_Notes__c', label:'Special Drawing Requirements?' },
        { picklist:'Special_Submittal_Requirements__c', note:'Special_Submittal_Requirements_Notes__c', label:'Special Submittal Requirements?' },
        { picklist:'Attached_Commission_Worksheet__c', note:'Attached_Commission_Worksheet_Notes__c', label:'Attached Commission Worksheet?' },
        { picklist:'Attached_Final_Scope_Letter__c', note:'Attached_Final_Scope_Letter_Notes__c', label:'Attached Final Scope Letter?' },
        { picklist:'Attached_All_Backup_Info_for_Special_Req__c', note:'Attached_All_Backup_Info_Notes__c', label:'Attached All Backup Info for Special Req?' },
        { picklist:'Attached_All_Design_and_Selection_Docs__c', note:'Attached_All_Design_Notes__c', label:'Attached All Design and Selection Docs?' },
        { picklist:'Attached_Pricing_Approval_Docs__c', note:'Attached_Pricing_Approval_Notes__c', label:'Attached Pricing Approval Docs?' },
        { picklist:'Attached_Any_Field_Purchased_Items_Quote__c', note:'Attached_Any_Field_Purchased_Notes__c', label:'Attached Any Field Purchased Items/Quotes?' },
        { picklist:'Identified_and_Attached_Service_Items_Qu__c', note:'Identified_and_Attached_Service_Notes__c', label:'Identified and Attached Service Items/Quotes?' },
        { picklist:'Margin_Adjusted__c', note:'Margin_Adjusted_Notes__c', label:'Margin Adjusted?' },
        { picklist:'Is_Electronic_File_Cleaned__c', note:'Is_Electronic_File_Notes__c', label:'Is Electronic File Cleaned?' },
        { picklist:'Attached_all_Email_Correspondence__c', note:'Attached_all_Email_Notes__c', label:'Attached all Email Correspondence?' },
        { picklist:'Does_Customer_PO_Reflect_Negotiated_Scop__c', note:'Does_Customer_PO_Reflect_Notes__c', label:'Does Customer PO Reflect Negotiated Scope?' }
    ];
    /*
    @wire(fetchTurnoverInfo, { opportunityId: '0063J0000028hmZQAQ' })
    
    wiredResult(result) { 
        this.isLoading = true;

        if(result.data) {
            this.isLoading = false; 
        }
        console.log('Id=>'+this.searchKey);
    }*/

    connectedCallback(){
        this.searchKey = this.recordId;
    }

    @api recordId;
    handleSubmit(event) {
        console.log('onsubmit: '+ JSON.stringify(event.detail));
        console.log('onsubmit1: '+ JSON.stringify(event.error));
        this.isLoading = true;
        console.log('execution end'+this.isLoading);
    }

    showError(event) {
        console.log('error message'+JSON.stringify(event.detail.output.errors[0].message));
        var errorMessage = event.detail.output.errors[0].message;
        this.isLoading = false;
        const evt = new ShowToastEvent({
            title: 'Error',
            message: errorMessage,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);

    }
    showSuccessToast() {
        this.isLoading = false;
        const evt = new ShowToastEvent({
            title: 'Turnover/Project Margin Information Saved',
            message: '',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

}