import { LightningElement,track,api,wire } from 'lwc';
import expenseAccounting from '@salesforce/apex/ApprovalRequestPagectrl.expenseAccounting';

const columns = [
    { label: 'Account', fieldName: 'expenseTypeCode', hideDefaultActions: true, cellAttributes: {
        class: {fieldName: 'expenseReportBGColor'}
    }},
    { label: 'Debit', fieldName: 'debit', hideDefaultActions: true, type: 'currency', cellAttributes: {
        class: {fieldName: 'expenseReportBGColor'},
        alignment: 'left'
    }},
    { label: 'Credit', fieldName: 'credit', hideDefaultActions: true, type: 'currency', cellAttributes: {
        class: {fieldName: 'expenseReportBGColor'},
        alignment: 'left'
    }}
];

export default class ApprovalExpenseAccounting extends LightningElement {

    columns = columns;
    @api recordId;
    @track getExpenseAccounting;
    @track error;
    @track errorMessage;
    @track isLoading = true;

    @wire(expenseAccounting,{recordId:'$recordId'}) listInfo({ error, data }) {
        if(data){
            data = JSON.parse(JSON.stringify(data));
            data[data.length-1].expenseReportBGColor = 'blueRow slds-no-row-hover';
            data[data.length-2].expenseReportBGColor = 'blueRow slds-no-row-hover';
            this.getExpenseAccounting = data;
            this.isLoading = false;
            console.log('data expense account =' + data);
        } else if(error){
            this.getExpenseAccounting = null;
            this.errorMessage = error.body.message;
            this.isLoading = false;
        }
    }
}