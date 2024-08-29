import { LightningElement, wire, track } from 'lwc';
import getCurrentMonth from '@salesforce/apex/MonthlyExpenseReportCtrl.getCurrentMonth';
import getCurrentYear from '@salesforce/apex/MonthlyExpenseReportCtrl.getCurrentYear';
import { loadStyle } from 'lightning/platformResourceLoader';
import SalesDashboardStyle from '@salesforce/resourceUrl/SalesDashboardStyle';
import getSubmittedExpenseApprovalData from '@salesforce/apex/MonthlyExpenseReportCtrl.getSubmittedExpenseApprovalData';
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext,
} from 'lightning/messageService';
import EXPENSE_CHANNEL from '@salesforce/messageChannel/SelectedMonthYear__c';

const columns = [
    {
        label: 'Name', fieldName: 'submittedBy', hideDefaultActions: true, cellAttributes: {
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
    },
    {
        label: 'CreatedDate', fieldName: 'createdDate', hideDefaultActions: true, type: 'date', cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' },
            alignment: 'left'
        },typeAttributes: {
            month: "2-digit",
            day: "2-digit",
            year: "numeric"
        }
    }
 
];

export default class SubmittedExpenseApproval extends LightningElement {
    columns = columns;
    @track submittedExpenseApproval;
    @track monthValue;
    @track yearValue;
    @track error;
    @track errorMessage;

    renderedCallback() {
        loadStyle(this, SalesDashboardStyle);
    }


    connectedCallback(){
        getCurrentMonth()
            .then((month) => {
                this.monthValue = month;
                getCurrentYear()
                    .then((year) => {
                        this.yearValue = year;
                        this.fetchSubmittedExpenseApprovalData();
                        this.subscribeToMessageChannel();
                    })
                    .catch(error => {
                        this.error = error
                    });
            })
            .catch(error => {
                this.error = error
            });
    }

    fetchSubmittedExpenseApprovalData(){
        getSubmittedExpenseApprovalData({month: this.monthValue, year: this.yearValue})
            .then((data) => {
                data = JSON.parse(JSON.stringify(data));
                data[data.length-1].expenseReportBGColor = 'blueRow slds-no-row-hover';
                data[data.length-2].expenseReportBGColor = 'blueRow slds-no-row-hover';
                // data[data.length-3].expenseReportBGColor = 'blueRow slds-no-row-hover';
                this.submittedExpenseApproval = data;
            })
            .catch(error => {
                this.submittedExpenseApproval = null;
                this.errorMessage = error.body.message;
            });
    }

    @wire(MessageContext)
    MessageContext;

    subscribeToMessageChannel() {
        if (this.subscription) {
            return;
        } else {
            this.subscription = subscribe(
                this.MessageContext,
                EXPENSE_CHANNEL,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    handleMessage(message){
        this.monthValue = message.month;
        this.yearValue = message.year;
        this.fetchSubmittedExpenseApprovalData();
    }
}