import { LightningElement, track, wire, api } from 'lwc';
import getAllExpensemonthlyReport from '@salesforce/apex/MonthlyExpenseReportCtrl.getAllExpensemonthlyReport';
import getCurrentMonth from '@salesforce/apex/MonthlyExpenseReportCtrl.getCurrentMonth';
import getCurrentYear from '@salesforce/apex/MonthlyExpenseReportCtrl.getCurrentYear';
import handleSubmitRequest from '@salesforce/apex/MonthlyExpenseReportCtrl.handleSubmitRequest';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/User.Name';
import { publish, MessageContext } from 'lightning/messageService';
import EXPENSE_CHANNEL from '@salesforce/messageChannel/SelectedMonthYear__c';
import SalesDashboardStyle from '@salesforce/resourceUrl/SalesDashboardStyle';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
    {
        label: 'Expense Date', fieldName: 'expenseDate', hideDefaultActions: true, cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' }
            
        }
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
        label: 'Account Name', fieldName: 'accountNames', hideDefaultActions: true, cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' }
        }
    },
    {
        label: 'Contact Name', fieldName: 'contactNames', hideDefaultActions: true, cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' }
        }
    },
    {
        label: 'Relationship', fieldName: 'relationship', hideDefaultActions: true, cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' }
           
        }
    },
    {
        label: 'Comments', fieldName: 'comments', hideDefaultActions: true, cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' }
        }
    },
    {
        label: 'Opportunity', fieldName: 'opportunityId', hideDefaultActions: true, cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' }
        }
    },
    {
        label: 'Type of Call', fieldName: 'typeOfCall', hideDefaultActions: true, cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' }
        }
    },
    {
        label: 'Type of Expense', fieldName: 'expenseType', hideDefaultActions: true, cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' }
        }
    },
    {
        label: 'Accounting code', fieldName: 'expenseTypeCode', hideDefaultActions: true, cellAttributes: {
            class: { fieldName: 'expenseReportBGColor'}
        }
    },
    {
        label: 'Expense Amount', fieldName: 'expenseAmount', hideDefaultActions: true, type: 'currency', cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' },
            alignment: 'left'
   
        }
    },
    {
        label: 'Card Type', fieldName: 'paymentType', hideDefaultActions: true, cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' }
        }
    },
    {
        label: 'Mileage', fieldName: 'mileageTraveled', hideDefaultActions: true, cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' },
            alignment: 'left'
        }
    },
    {
        label: 'Mileage Type', fieldName: 'mileageType', hideDefaultActions: true, cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' }
        }
    },
    {
        label: 'Mileage Cost', fieldName: 'mileageCost', hideDefaultActions: true, type: 'currency', cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' },
            alignment: 'left'
        }
    },
    {
        label: 'Total Cost', fieldName: 'totalCost', hideDefaultActions: true, type: 'currency', cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' },
            alignment: 'left',
        }
    }

];

const totalBlueColumns = [
    {
        label: 'hiddenCheckBox',  hideDefaultActions: true, type: 'boolean',  fixedWidth: 21, cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' }
        }},
    {
        label: 'Expense Date', fieldName: 'expenseDate', hideDefaultActions: true, cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' }
            
        }},
    {
        label: 'Call', fieldName: 'logACallURL', hideDefaultActions: true, type: 'url', cellAttributes:
            { class: { fieldName: 'expenseReportBGColor' } },
        typeAttributes: {
            label: { fieldName: 'logACallName' },
            target: '_blank'
        }},
    {
        label: 'Account Name', fieldName: 'accountNames', hideDefaultActions: true, cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' }
        }
    },
    {
        label: 'Contact Name', fieldName: 'contactNames', hideDefaultActions: true, cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' }
        }},
    {
        label: 'Relationship', fieldName: 'relationship', hideDefaultActions: true, cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' }
           
        }},
    {
        label: 'Comments', fieldName: 'comments', hideDefaultActions: true, cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' }
        }},
    {
        label: 'Opportunity', fieldName: 'opportunityId', hideDefaultActions: true, cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' }
        }},
    {
        label: 'Type of Call', fieldName: 'typeOfCall', hideDefaultActions: true, cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' }
        }},
    {
        label: 'Type of Expense', fieldName: 'expenseType', hideDefaultActions: true,  cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' }
        }
    },
    {
        label: 'Accounting code', fieldName: 'expenseTypeCode', hideDefaultActions: true, cellAttributes: {
            class: { fieldName: 'expenseReportBGColor'}
        }
    },
    {
        label: 'Expense Amount', fieldName: 'expenseAmount', hideDefaultActions: true, type: 'currency',
        cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' },
            alignment: 'left'
        }},
    {
        label: 'Card Type', fieldName: 'paymentType', hideDefaultActions: true, cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' }
        }},
    {
        label: 'Mileage', fieldName: 'mileageTraveled', hideDefaultActions: true, cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' },
            alignment: 'left'
        }},
    {
        label: 'Mileage Type', fieldName: 'mileageType', hideDefaultActions: true, cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' }
        }},
    {
        label: 'Mileage Cost', fieldName: 'mileageCost', hideDefaultActions: true, type: 'currency', cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' },
            alignment: 'left'
        }},
    {
        label: 'Total Cost', fieldName: 'totalCost', hideDefaultActions: true, type: 'currency', cellAttributes: {
            class: { fieldName: 'expenseReportBGColor' },
            alignment: 'left'
        }}
];

export default class MonthlyExpRptWithLogCall extends LightningElement {
    @wire(MessageContext)
    MessageContext;

    //userId = Id;
    columns = columns;
    totalBlueColumns = totalBlueColumns;
    currentUserName;
    @track expenseRptWithLogCall;
    @track total;
    @track errorMessage;
    @track monthValue = '';  //initialize combo box value
    @track yearValue = '';
    @track selectedIds = '';
    disableBtn = true;  // true
    @api isLoading = false;
    error;

    //Month list
    get monthOptions() {
        return [
            { label: 'All ', value: 'All' },
            { label: 'January ', value: 'January' },
            { label: 'February ', value: 'February' },
            { label: 'March', value: 'March' },
            { label: 'April', value: 'April' },
            { label: 'May', value: 'May' },
            { label: 'June', value: 'June' },
            { label: 'July', value: 'July' },
            { label: 'August', value: 'August' },
            { label: 'September', value: 'September' },
            { label: 'October', value: 'October' },
            { label: 'November', value: 'November' },
            { label: 'December', value: 'December' }

        ];
    }
    //Year list 
    get yearOptions() {
        return [
            { label: '2019', value: '2019' },
            { label: '2020', value: '2020' },
            { label: '2021', value: '2021' },
            { label: '2022', value: '2022' },
            { label: '2023', value: '2023' },
            { label: '2024', value: '2024' },
            { label: '2025', value: '2025' },
            { label: '2026', value: '2026' },
            { label: '2027', value: '2027' },
            { label: '2028', value: '2028' }

        ];
    }

    //user name
    @wire(getRecord, { recordId: Id, fields: [NAME_FIELD] })
    userDetails({ error, data }) {
        if (data) {
            this.currentUserName = data.fields.Name.value;
        } else if (error) {
            this.error = error;
        }
    }

    renderedCallback() {
        loadStyle(this, SalesDashboardStyle);
    }

    connectedCallback() {
        this.isLoading = true;
        getCurrentMonth()
            .then((month) => {
                this.monthValue = month;
                getCurrentYear()
                    .then((year) => {
                        this.yearValue = year;
                        this.fetchInitialData();
                    })
                    .catch(error => {
                        this.error = error
                        this.isLoading = false;
                    });
            })
            .catch(error => {
                this.error = error
                this.isLoading = false;
            });
    }

    fetchInitialData() {
        this.isLoading = true;
        getAllExpensemonthlyReport({ month: this.monthValue, year: this.yearValue })
            .then((data) => {
                data = JSON.parse(JSON.stringify(data));
                console.log('Monthly expense data==>' + data);
                if (data) {
                    data.forEach(item => item['logACallURL']
                        = 'https://' + location.host + '/' + item['logACallURL']);
                }
                this.expenseRptWithLogCall = data;
                data[data.length-1].expenseReportBGColor = 'blueRow slds-no-row-hover ';
                data[data.length - 1]['logACallURL'] = null;
                this.total = [data[data.length - 1]] ;
                this.expenseRptWithLogCall.pop([data.length-1]);
                this.isLoading = false;
                
            })
            .catch(error => {
                this.expenseRptWithLogCall = null;
                this.errorMessage = error.body.message;
                this.isLoading = false;
            });
    }

    handleMonthChange(event) {
        this.monthValue = event.detail.value;
        console.log('selected value=' + this.monthValue);
        this.isLoading = false;
        this.fetchInitialData();
        const message = {
            month: this.monthValue,
            year: this.yearValue
        }
        publish(this.MessageContext, EXPENSE_CHANNEL, message);
    }

    handleYearChange(event) {
        this.yearValue = event.detail.value;
        this.isLoading = false;
        console.log('selected value=' + this.yearValue);
        this.fetchInitialData();
        const message = {
            month: this.monthValue,
            year: this.yearValue
        }
        publish(this.MessageContext, EXPENSE_CHANNEL, message);
    }

    handleRowSelection(event) {
        var selected = event.detail.selectedRows;
        let ids = '';
        selected.forEach(currentItem => {
            if(currentItem.id){
                console.log('found id: '+currentItem.id);
                ids = ids + ',' + currentItem.id;
            }
        });
        ids = ids.replace(/^,/, '');
        this.selectedIds = ids;

        if(this.selectedIds !== ''){
            this.disableBtn = false;
        }else{
            this.disableBtn = true;
        }
    }

    handelSubmit() {
        this.isLoading = true;
        console.log('inside handle submit');
            handleSubmitRequest({ selectedIds: this.selectedIds, month: this.monthValue, year: this.yearValue})
                .then(() => {
                    console.log('inside HSR' +this.selectedIds);
                    this.isLoading = false;
                    const toastEvent  = new ShowToastEvent({
                        title: "Success!",
                        message: "Submit Request Created",
                        variant: "success",
                    });
                    this.dispatchEvent(toastEvent);
                    this.fetchInitialData();
                    //to reload Expense Accounting and Submit Request
                    const message = {
                        month: this.monthValue,
                        year: this.yearValue
                    }
                    publish(this.MessageContext, EXPENSE_CHANNEL, message); 
                })
                .catch((error) => { });
            this.selectedIds = null;
    }

}