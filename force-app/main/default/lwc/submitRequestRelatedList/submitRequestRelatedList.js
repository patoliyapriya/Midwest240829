import { LightningElement, wire, api, track } from 'lwc';
import ExpenseRelatedList from '@salesforce/apex/MonthlyExpenseReportCtrl.ExpenseRelatedList';
import { loadStyle } from 'lightning/platformResourceLoader';
import SalesDashboardStyle from '@salesforce/resourceUrl/SalesDashboardStyle';

export default class SubmitRequestRelatedList extends LightningElement {
    columns = [
        { label: 'Name', fieldName: 'ExpenseURL', type: 'url' , hideDefaultActions:true ,
            typeAttributes: {
                label: {fieldName: 'Name'},
                target: '_blank'
            }, cellAttributes: {
                class: {fieldName: 'BGColor'}
            }
        },
        { label: 'Expense Date', fieldName: 'expenseDate', hideDefaultActions: true, cellAttributes: {
                class: { fieldName: 'BGColor' }   
        }},
        { label: 'Log Description', fieldName: 'logDescreiption', hideDefaultActions:true, cellAttributes: {
            class: {fieldName: 'BGColor'}
        }},
        { label: 'Expense Description', fieldName: 'expenseDescription', hideDefaultActions:true, cellAttributes: {
            class: {fieldName: 'BGColor'}
        }},
        { label: 'Contact', fieldName: 'contact', hideDefaultActions:true, cellAttributes: {
            class: {fieldName: 'BGColor'}
        }},
        { label: 'Account', fieldName: 'account', hideDefaultActions:true, cellAttributes: {
            class: {fieldName: 'BGColor'}
        }},
        { label: 'Opportunity', fieldName: 'opportunity', hideDefaultActions:true, cellAttributes: {
            class: {fieldName: 'BGColor'}
        }},
        { label: 'Project', fieldName: 'ProjectURL', type: 'url' , hideDefaultActions:true ,
            typeAttributes: {
                label: {fieldName: 'project'},
                target: '_blank'
            }, cellAttributes: {
                class: {fieldName: 'BGColor'}
            }
        },
        { label: 'Expense type', fieldName: 'expenseType', hideDefaultActions:true, cellAttributes: {
            class: {fieldName: 'BGColor'}
        }},
        { label: 'Payment Type', fieldName: 'paymentType', hideDefaultActions:true, cellAttributes: {
            class: {fieldName: 'BGColor'}
        }},
        { 
            label: 'Expense Amount', fieldName: 'expenseAmount', type: 'currency', hideDefaultActions:true , cellAttributes: {
            alignment: 'left'}, cellAttributes: {
                class: {fieldName: 'BGColor'},
                alignment: 'left'
            }
        }
    ];
    
    @track isLoading = true;
    @api recordId;
    @track total;
    @track Expense;

    renderedCallback() {
        loadStyle(this, SalesDashboardStyle);
    }
    
    @wire(ExpenseRelatedList,{recordId:'$recordId'}) listInfo({ error, data }) {
        if (data) {
            var lstExpense = [];
            for (var i = 0; i < data.length; i++) {  
                let lstRecord = Object.assign({}, data[i]);  
                lstRecord.ExpenseURL = '/lightning/r/Expense__c/' +lstRecord.id +'/view';
                if(lstRecord.projectId == null){
                    lstRecord.ProjectURL = '';
                } else {
                    lstRecord.ProjectURL = '/lightning/r/Project__c/' +lstRecord.projectId +'/view';
                }
                
                lstRecord.BGColor = '';
                lstExpense.push(lstRecord);  
               }
            lstExpense[lstExpense.length - 1]['BGColor'] = 'blueRow slds-no-row-hover';
            lstExpense[lstExpense.length - 1]['ExpenseURL'] = null;
            this.total = [lstExpense[lstExpense.length - 1]];
            this.Expense = lstExpense;
            this.Expense.pop([lstExpense.length - 1]);
            this.isLoading = false;
        } else if (error) {
            this.Expense = null;
            this.isLoading = false;
        }
    } 

}