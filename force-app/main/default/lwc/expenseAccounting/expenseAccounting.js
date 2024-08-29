import { LightningElement, track, wire, api } from 'lwc';
import getCurrentMonth from '@salesforce/apex/MonthlyExpenseReportCtrl.getCurrentMonth';
import getCurrentYear from '@salesforce/apex/MonthlyExpenseReportCtrl.getCurrentYear';
import getExpenseAccounting from '@salesforce/apex/MonthlyExpenseReportCtrl.getExpenseAccounting';
import { loadStyle } from 'lightning/platformResourceLoader';
import SalesDashboardStyle from '@salesforce/resourceUrl/SalesDashboardStyle';
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext,
} from 'lightning/messageService';
import EXPENSE_CHANNEL from '@salesforce/messageChannel/SelectedMonthYear__c';

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
export default class ExpenseAccounting extends LightningElement {
    columns = columns;
    @track getExpenseAccounting;
    @track monthValue;
    @track yearValue;
    @track error;
    @track errorMessage;
    @api isLoading = false;

    renderedCallback() {
        loadStyle(this, SalesDashboardStyle);
    }

    connectedCallback() {
        getCurrentMonth()
            .then((month) => {
                this.monthValue = month;
                getCurrentYear()
                    .then((year) => {
                        this.yearValue = year;
                        this.fetchAccountingData();
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
    
    fetchAccountingData() {
        getExpenseAccounting({month: this.monthValue, year: this.yearValue})
            .then((data) => {
                data = JSON.parse(JSON.stringify(data));
                data[data.length-1].expenseReportBGColor = 'blueRow slds-no-row-hover';
                data[data.length-2].expenseReportBGColor = 'blueRow slds-no-row-hover';
                // data[data.length-3].expenseReportBGColor = 'blueRow slds-no-row-hover';
                this.getExpenseAccounting = data;
                console.log('data expense account =' + data);
            })
            .catch(error => {
                this.getExpenseAccounting = null;
                this.errorMessage = error.body.message;
            });
    }

    //2.subscribe message from channel
    @wire(MessageContext)
    MessageContext;

    //3.Handling 
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
        this.fetchAccountingData();
    }
}