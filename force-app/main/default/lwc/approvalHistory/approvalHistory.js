import { LightningElement, wire, api, track } from 'lwc';
import submittedExpenseList from '@salesforce/apex/ApprovalRequestPagectrl.submittedExpenseList';

const columns = [
    {
        label: 'Name', fieldName: 'approver', hideDefaultActions: true, cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' }
        }
    },
    {
        label: 'Status', fieldName: 'submitStatus', hideDefaultActions: true, cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' }
        }
    },
    {
        label: 'Amount', fieldName: 'totalExpenseAmount', hideDefaultActions: true, type: 'currency', cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' },
            alignment: 'left'
        }
    }
 
];

export default class ApprovalHistory extends LightningElement {

    columns = columns;
    @api recordId;
    @track submittedExpenseApproval;
    @track error;
    @track errorMessage;
    @track isloading = true;

    @wire(submittedExpenseList,{recordId:'$recordId'}) listInfo({ error, data }){
        if(data){
            data = JSON.parse(JSON.stringify(data));
            data[data.length-1].expenseReportBGColor = 'blueRow slds-no-row-hover';
            this.submittedExpenseApproval = data;
            this.isloading = false;
        } else if(error) {
            this.submittedExpenseApproval = null;
            this.errorMessage = error.body.message;
            this.isloading = false;
        }
    }
  
}