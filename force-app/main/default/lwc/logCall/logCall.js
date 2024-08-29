import { LightningElement, track, api, wire} from 'lwc';
import Id from '@salesforce/user/Id';
import loadLogACall from '@salesforce/apex/LogCallController.loadLogACall';
import getCurrentUserOfficeLocation from '@salesforce/apex/LogCallController.getCurrentUserOfficeLocation';
import saveLogACall from '@salesforce/apex/LogCallController.saveLogACall';
//import makeChatterPost from '@salesforce/apex/LogCallController.makeChatterPost';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { CurrentPageReference } from 'lightning/navigation';

export default class LogCall extends LightningElement {
    
    @wire(CurrentPageReference) pageRef;
    userId = Id;
    @api recordId;
    @api objectApiName;
    @api currentContactId = []; //Auto fill Contact 
    @api currentAccountId = []; //Auto fill Account
    @api currentUserOfficeLocation;  // current user office


    @track strJson;
    
    @track logACall;
    @track lstTasks = [];
    @track lstExpenses = [];
    @track lstChatter = [];

    
    @track selectedItemsToDisplay = ''; //to display items in comma-delimited way
    @track values = []; //stores the labels in this array
    @track isItemExists = false; //flag to check if message can be displayed
    @track ToContactIds = [];

    @track selectedAccountsToDisplay = '';
    @track accountValues = [];
    @track isAccountExists = false;
    @track accountIds = [];

    @track selectedAssignedToDisplay = '';
    @track assignedToValues = [];
    @track isAssignedToExists = false;
    @track assignedToIds = [];
    @track PostFeddMesg;
    @track CheckBoxselectedIds = '';
    disableCheckbox = true;
    
   
    connectedCallback() {
        this.loadCurrentUserData();
    }

    // Getting current user office location when page loads
    loadCurrentUserData(){
        getCurrentUserOfficeLocation()
            .then(result => {
                this.currentUserOfficeLocation = result;
                this.loadLogACallJSON();
            }).catch(error => {});
    }

    loadLogACallJSON() {
        loadLogACall({ recordId: this.recordId, objectName: this.objectApiName})
            .then(result => {
                this.prepareLogACall(result);
            }).catch(error => {});
    }

    prepareLogACall(result) {
        this.strJson = JSON.parse(result);
        console.log("Loding Data  :" + result);
      
        if(this.strJson && this.strJson.logACall) {
            console.log('fetch contact and account data', this.strJson.logACall.contacts);
            
            this.logACall = JSON.parse(JSON.stringify(this.strJson.logACall));
            this.currentContactId = this.strJson.logACall.contacts[0];
            this.currentAccountId = this.strJson.logACall.accounts[0];
        }

        this.lstTasks = [];
        if(this.strJson && this.strJson.lstTasks) {
            console.log('task to insert : ' , this.strJson.lstTasks);
            for(let i=0; i<this.strJson.lstTasks.length; i++) {
                this.strJson.lstTasks[i].Id = 'task' + i;
                this.strJson.lstTasks[i].sectionName = 'Follow Up Task (' + (i + 1) + ')';
                this.lstTasks.push(this.strJson.lstTasks[i]);
            }
        }

        this.lstExpenses = [];
        if(this.strJson && this.strJson.lstExpenses) {
            for(let i=0; i<this.strJson.lstExpenses.length; i++) {
                this.strJson.lstExpenses[i].Id = 'expense' + i;
                this.strJson.lstExpenses[i].sectionName = 'Expense (' + (i + 1) + ')'; 
                this.strJson.lstExpenses[i].splitExpenses = this.currentUserOfficeLocation;   
                console.log("After setting office location to exp:" +this.strJson.lstExpenses[i].splitExpenses);
                this.lstExpenses.push(this.strJson.lstExpenses[i]);
            }
        }
        this.lstChatter = [];
        if(this.strJson && this.strJson.lstChatter){
            for(let i=0; i<this.strJson.lstChatter.length; i++){
                this.strJson.lstChatter[i].Id = 'chatter' + i;
                // this.strJson.lstChatter[i].sectionName = 'Post Update to Chatter (' + (i + 1) + ')';
                console.log('chatter in prepare log :-' + this.strJson.lstChatter[i].Id);
                this.lstChatter.push(this.strJson.lstChatter[i]);
            }
        }

    }

    handleDeleteTask(event) {
        this.lstTasks[event.target.value].isDeleted = true;
    }

    handleDeleteExpense(event) {
        console.log('index---'+event.target.value);
        this.lstExpenses[event.target.value].isDeleted = true;
    }

    //captures the retrieve event propagated from lookup component
    selectItemEventHandler(event){
        console.log('event fired from child');
        let args = JSON.parse(JSON.stringify(event.detail.arrItems));
        console.log('args='+args);
        this.displayItem(args);        
    }

    //captures the remove event propagated from lookup component
    deleteItemEventHandler(event){
        let args = JSON.parse(JSON.stringify(event.detail.arrItems));
        this.displayItem(args);
    }

    //displays the items in comma-delimited way
    displayItem(args){
        this.values = []; //initialize first
        this.ToContactIds = [];
        args.map(element=>{
            this.ToContactIds.push(element.value);
            this.values.push(element.label);
        });

        this.isItemExists = (args.length>0);
        this.selectedItemsToDisplay = this.values.join(', ');
        
        console.log('selected contact=>'+this.ToContactIds);
    }

    //captures the retrieve event propagated from lookup component
    selectAccountEventHandler(event){
        let args = JSON.parse(JSON.stringify(event.detail.arrItems));
        this.displayAccounts(args);        
    }

    //captures the remove event propagated from lookup component
    deleteAccountEventHandler(event){
        let args = JSON.parse(JSON.stringify(event.detail.arrItems));
        this.displayAccounts(args);
    }

    //displays the items in comma-delimited way
    displayAccounts(args){
        this.accountValues = []; //initialize first
        this.accountIds = [];
        args.map(element=>{
            this.accountIds.push(element.value);
            this.accountValues.push(element.label);
        });

        this.isAccountExists = (args.length>0);
        this.selectedAccountsToDisplay = this.accountValues.join(', ');
    }
    
    //captures the retrieve event propagated from lookup component
    selectAssignedToEventHandler(event){
        
        console.log('detail---'+JSON.stringify(event.detail));
        console.log('rowIndex---'+JSON.stringify(event.detail.rowIndex));
        let args = JSON.parse(JSON.stringify(event.detail.arrItems));
        this.displayAssignedTo(args, event.detail.rowIndex);        
    }

    //captures the remove event propagated from lookup component
    deleteAssignedToEventHandler(event){
        let args = JSON.parse(JSON.stringify(event.detail.arrItems));
        this.displayAssignedTo(args, event.detail.rowIndex);
    }

    //displays the items in comma-delimited way
    displayAssignedTo(args, rowIndex){
        console.log('event---'+JSON.stringify(args));
        this.assignedToValues = []; //initialize first
        this.assignedToIds = [];
        //this.assignedToIds = this.userId;

        args.map(element=>{
            this.assignedToIds.push(element.value);
            this.assignedToValues.push(element.label);
        });

        this.isAssignedToExists = (args.length>0);
        this.selectedAssignedToDisplay = this.assignedToValues.join(', ');
        this.lstTasks[rowIndex].assignedToIds = this.assignedToIds;
    }

    handleSubmit(event) {
        event.preventDefault();
        console.log('handle submitLogcall: '+ JSON.stringify(event.detail));
        console.log('handle submit1: '+ JSON.stringify(event.error));
    
        //before code was not working when handlesubmit called.
      /* event.preventDefault();
        const fields = event.detail.fields;
        console.log('handle submit :-' +JSON.stringify(fields));
        fields[FIELD_CONTACTS.fieldApiName] = this.ToContactIds.join(', ');
        fields[FIELD_ACCOUNTS.fieldApiName] = this.accountIds.join(', ');
        
        const recordInput = { apiName: OBJECT_LOGACALL.objectApiName, fields };
    
        createRecord(recordInput)
            .then(logACall => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Log A call created',
                        variant: 'success',
                    }),
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            }); */
    }
    
    handleAddExpense() {
        let currentElement = this.lstExpenses[0];
        //Clone Object
        let newExpense = JSON.parse(JSON.stringify(currentElement));
        newExpense.sectionName = 'Expense (' + (this.lstExpenses.length + 1) + ')';    
        newExpense.Id = 'expense' + this.lstExpenses.length + 1;
        newExpense.isDeleted = false;
        newExpense.vendorOrVenue = '';
        newExpense.expenseType = '';
        newExpense.expenseAmount = null;
        newExpense.paymentType = 'Company Expense';
        newExpense.reason = '';
        newExpense.description = '';
        newExpense.expenseDate ='';
         // newExpense.project = this.recordId;
         newExpense.project = null;
        newExpense.splitExpenses = this.currentUserOfficeLocation; //default officeloction for multiple Expense
        newExpense.expenseDate = this.logACall.eventDate;
        this.lstExpenses.push(newExpense);
    }

    handleAddTask() {

        let currentElement = this.lstTasks[0];
        //Clone Object
        let newTask = JSON.parse(JSON.stringify(currentElement));
        newTask.sectionName = 'Follow Up Task (' + (this.lstTasks.length + 1) + ')';    
        newTask.Id = 'task' + this.lstTasks.length + 1;
        newTask.isDeleted = false;
        newTask.subject = '';
        newTask.dueDate = null;
        newTask.assignedToIds = [];

        if(this.recordId.toString().startsWith('006')){ //for auto-populate opportunity
            newTask.contact = null;
            newTask.relatedTo = this.recordId;
        } else if (this.recordId.toString().startsWith('003')){ // for auto-populate contact
            newTask.contact = this.recordId;
            newTask.relatedTo = null;
        } else { //for account 
            newTask.contact = null;
            newTask.relatedTo = null;
        }
        this.lstTasks.push(newTask);
        
    }

    handleSave(event) {
        console.log('this.ToContactIds='+this.ToContactIds);
        console.log('this.accountIds='+this.accountIds);
        let strTasksJSON;

        if(this.logACall.typeOfCall !== 'Expense Only') {
            this.logACall.contacts = this.ToContactIds;
            this.logACall.accounts = this.accountIds;

            let lstTasksToInsert = [];
            this.lstTasks.forEach(task =>{
                if(!task.isDeleted){
                    //task.contacts = 
                    lstTasksToInsert.push(task);
                    console.log('task to insert ' , task);
                }
            })
            console.log('test handle save ' , lstTasksToInsert);
            strTasksJSON = JSON.stringify(lstTasksToInsert);
            
        }
        
        let lstExpensesToInsert = [];
        this.lstExpenses.forEach(expense =>{
            if(!expense.isDeleted){
                console.log('split Expense value :-'+expense.splitExpenses);
                if(expense.splitExpenses != null){
                expense.splitExpenses = expense.splitExpenses.toString().split(';');
                }
                console.log('inside handle save expense split', JSON.stringify(expense.splitExpenses));
                lstExpensesToInsert.push(expense);
            }
            
        })

        let lstChatterToInsert = [];
        this.lstChatter.forEach(chatter =>{
            if(!chatter.isDeleted){
                chatter.chatterParentId = this.recordId;
                console.log('chatter record id :-' +chatter.chatterParentId);
                chatter.postFeedCheckBox = this.checkBoxchatterValue;
                console.log('chatter checkBox :-' +chatter.postFeedCheckBox);
                lstChatterToInsert.push(chatter);
                console.log('chatter record need to insert', +lstChatterToInsert);
            }
        })


        saveLogACall({logACall: JSON.stringify(this.logACall), strExpenses: JSON.stringify(lstExpensesToInsert), strTasks: strTasksJSON, strChatter: JSON.stringify(lstChatterToInsert)})
                .then(result => {
                  
                    this.showNotification('Log A Call', 'Log A Call is inserted successfully', 'success');
                     console.log('Handle save in log a call value =', saveLogACall);
                     // Reload the page
                     window.location.reload();
                }).catch(error => {
                    this.showNotification('Error', error.body.message, 'error');
                    console.error('the error is :-' +error.body.message);
                });
        

                //to refesh the form
        // const inputFields = this.template.querySelectorAll( 'lightning-input-field' );
        //     if ( inputFields ) {
        //          inputFields.forEach( field => {
        //              field.reset();
        //          } );
        //       }
        

    }
        //to refesh the form
    // handleSubmit(event){

    //      event.preventDefault();
    //      let fields = event.detail.fields;
    //       console.log( 'Fields are ' + JSON.stringify( fields ) );
    //      this.querySelector( 'lightning-record-edit-form').submit( fields );
    // }

    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    handleTypeOfCall(event) {
        this.logACall.typeOfCall = event.target.value;
        console.log('test logcall typeofcall :' , event.target.value );
        if(this.logACall.typeOfCall === 'Expense Only') {
            this.logACall.isExpenseOnly = true;
        } else {
            this.logACall.isExpenseOnly = false;
        }
    }

    handleEventDate(event) {
        this.logACall.eventDate = event.target.value;
        // setting default logACall Event date as Expense date for single or mutiple Expenses by for loop
        this.lstExpenses.forEach( expense =>{
            expense.expenseDate = this.logACall.eventDate;
        });
    }

    handleRelationship(event) {
        this.logACall.relationship = event.target.value;
    }

    handleOpportunityId(event) {
        this.logACall.opportunityId = event.target.value;
    }


    handleComments(event) {
        this.logACall.comments = event.target.value;
        if(this.logACall.comments !== '' && /[a-zA-Z]/g.test(this.logACall.comments)){
            this.disableCheckbox = false;
        } else {
            this.disableCheckbox = true;
        }
    }

    handlePostMsgChatter(event){
        this.checkBoxchatterValue = event.target.checked;
        console.log('body of text:- '+ this.checkBoxchatterValue);
    }

    handleMileageType(event) {
        this.logACall.mileageType = event.target.value;
    }

    handleMileageTraveled(event) {
        this.logACall.mileageTraveled = event.target.value;
    }


    handleSubject(event) {
        let index = event.target.title;
        this.lstTasks[index].subject = event.target.value;
    }

    handleDueDate(event) {
        let index = event.target.title;
        this.lstTasks[index].dueDate = event.target.value;
        
    }
    /*
    handleAssignedTo(event) {
        let index = event.target.title;
        this.lstTasks[index].assignedTo = event.target.value;
    }
    */
    handleContact(event) {
        let index = event.target.title;
        this.lstTasks[index].contact = event.target.value;
    }

    handleRelatedTo(event) {
        let index = event.target.title;
        this.lstTasks[index].relatedTo = event.target.value;
    }



    handleVendorOrVenue(event) {
        let index = event.target.title;
        this.lstExpenses[index].vendorOrVenue = event.target.value;
    }

    handleExpenseType(event) {
        let index = event.target.title;
        this.lstExpenses[index].expenseType = event.target.value;
    }

    handleExpenseAmount(event) {
        let index = event.target.title;
        this.lstExpenses[index].expenseAmount = event.target.value;
    }

    handlePaymentType(event) {
        let index = event.target.title;
        if(event.target.value === 'Personal Expense') {
            this.lstExpenses[index].isPersonalExpense = true;
        } else {
            this.lstExpenses[index].isPersonalExpense = false;
        }
        this.lstExpenses[index].paymentType = event.target.value;
    }

    handleReason(event) {
        let index = event.target.title;
        this.lstExpenses[index].reason = event.target.value;
    }

    handleDescription(event) {
        let index = event.target.title;
        this.lstExpenses[index].description = event.target.value;   
    }
    handleProjectId(event) {
        let index = event.target.title;
        this.lstExpenses[index].project = event.target.value;
        
    }
    handleSplitExpense(event) {
        console.log('handleSplitExpense event'+event.target.value);
        let index = event.target.title;
        this.lstExpenses[index].splitExpenses = event.target.value;
        // let commaSeparatedValue = event.target.value.split(',');
        // if(this.lstExpenses[index].splitExpenses != commaSeparatedValue){
        //     this.lstExpenses[index].splitExpenses = commaSeparatedValue;
        //     //this.lstExpenses[index].splitExpenses = event.target.value.split(",");
        // }
       
        console.log('selected value' , this.lstExpenses[index].splitExpenses);
        console.log('chosen' ,event.target.value.split(', '));
    }

    handleExpenseDate(event) {
        let index = event.target.title;
        this.lstExpenses[index].expenseDate = event.target.value;
         

        // this.lstExpenses[index].expenseDate = this.logACall.eventDate;
        //this.lstExpenses[index].expenseDate = event.target.value;
       
    }

    @api get
    isLastTask() {
        let count = 0;
        this.lstTasks.forEach( task =>{
            if(!task.isDeleted){
                count++;
            }
        } )
        return count === 1 ;
    }

    @api get
    isLastExpense() {
        let count = 0;
        this.lstExpenses.forEach( expense =>{
            if(!expense.isDeleted){
                count++;
            }
        } )
        return count === 1 ;
    }

}