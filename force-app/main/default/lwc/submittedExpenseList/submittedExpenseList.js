import { LightningElement, wire, track,api } from 'lwc';
import getCurrentMonth from '@salesforce/apex/MonthlyExpenseReportCtrl.getCurrentMonth';
import getCurrentYear from '@salesforce/apex/MonthlyExpenseReportCtrl.getCurrentYear';
import getSubmittedExpenseList from '@salesforce/apex/MonthlyExpenseReportCtrl.getSubmittedExpenseList';
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext,
} from 'lightning/messageService';
import EXPENSE_CHANNEL from '@salesforce/messageChannel/SelectedMonthYear__c';
import SalesDashboardStyle from '@salesforce/resourceUrl/SalesDashboardStyle';
import { loadStyle } from 'lightning/platformResourceLoader';

const columns = [
    {
        label: 'Expense Date', fieldName: 'expenseDate', hideDefaultActions: true, cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' }}
    },
    {
        label: 'Call', fieldName: 'logACallURL', hideDefaultActions: true, type: 'url', cellAttributes:
            { class: { fieldName: 'expenseReportBGColor' } },
        typeAttributes: {
            label: { fieldName: 'logACallName' },
            target: '_blank'
        }
    },
    {
        label: 'Expense Name', fieldName: 'ExpenseURL', hideDefaultActions: true, type: 'url', cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' }
        },
        typeAttributes: {
            label: { fieldName: 'expenseName' },
            target: '_blank'
        }
    },
    {
        label: 'Expense Amount', fieldName: 'expenseAmount', hideDefaultActions:true , type: 'currency', cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' },
            alignment: 'left'
        }
    }
];

export default class SubmittedExpenseList extends LightningElement {
    columns = columns;
    @track submittedExpense;
    @track totalLineForSubExp;
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
                        this.fetchSubmittedExpenseData();
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
    fetchSubmittedExpenseData(){
        getSubmittedExpenseList({month: this.monthValue, year: this.yearValue})
            .then((data) => {
                data = JSON.parse(JSON.stringify(data));
                console.log(' submittedexpense data==> ' +JSON.stringify(data));
                if (data) {
                    data.forEach(item => item['logACallURL']
                        = 'https://' + location.host + '/' + item['logACallURL']);
                }
                if (data) {
                    data.forEach(item => item['ExpenseURL']
                        = 'https://' + location.host + '/' + item['ExpenseURL']);
                }
                this.submittedExpense = data;
                data[data.length-1].expenseReportBGColor = 'blueRow slds-no-row-hover';
                data[data.length - 1]['logACallURL'] = null;
                data[data.length - 1]['ExpenseURL'] = null;
                this.totalLineForSubExp = [data[data.length - 1]];
                this.submittedExpense.pop([data.length-1]);  
            })
            .catch(error => {
                this.submittedExpense = null;
                this.totalLineForSubExp = null;
                this.errorMessage = error.body.message;
                console.log('error message' +error);
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
        this.fetchSubmittedExpenseData();
    }

}