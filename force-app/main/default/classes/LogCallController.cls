public with sharing class LogCallController {
    public class applicationException extends Exception {}
   
    public LogCallController() {

    }

    // for Getting current user office location
    // And permission set name for MaRRs user default office is set as MaRRs
    @AuraEnabled
    public static string getCurrentUserOfficeLocation(){
        Set<Id> setMarrsPermissonUser = new Set<Id>();
           List<PermissionSetAssignment> lstPermissionUser = [SELECT Id, PermissionSet.Name, AssigneeId, Assignee.Name
                                                              FROM PermissionSetAssignment 
                                                              WHERE PermissionSet.Name = 'MaRRs'];
        for(PermissionSetAssignment permissionUser : lstPermissionUser){
            setMarrsPermissonUser.add(permissionUser.AssigneeId);
        }
        
        List<User> lstUser = [SELECT Id, Office_Location__c FROM User WHERE Id =: UserInfo.getUserId()];
        if(lstUser.size() > 0){
            User user = lstUser[0];
            if(setMarrsPermissonUser.contains(user.id)){
                system.debug('inside if user Marrs' +user.id);
                return 'MaRRS';
            }
            else if(lstUser != null && lstUser.size() > 0){
                User currentUser = lstUser.get(0);
                return currentUser.Office_Location__c;
            }
        }
        return '';
    }

    @AuraEnabled
    public static string loadLogACall(String recordId, String objectName) {

        LogACallDetailWrapper logACall = new LogACallDetailWrapper();
        system.debug(' record id loadlogcall : ' + recordId);
        if(objectName == 'Opportunity') {
            logACall.logACall.opportunityId = recordId;
            logACall.lstTasks[0].relatedTo = recordId;
            

        //loadlogACall with Contactid, Name, Accountid, AccountNm task-contact field auto-populate on contact page 
        } else if(objectName == 'Contact') {
            logACall.logACall.contacts.add(recordId);
           
            List<Contact> lstContacts = [SELECT Id,Name, AccountId, Account.Name FROM Contact WHERE Id =: recordId];
             system.debug('contact list before load :' + lstContacts);
            if(!lstContacts.isEmpty()) {
                logACall.logACall.contactNames.add(lstContacts[0].Name);
                logACall.lstTasks[0].contact = recordId; //auto- pouplate only on contact page.

                if(lstContacts[0].AccountId != null) {
                    logACall.logACall.accounts.add(lstContacts[0].AccountId);
                    logACall.logACall.accountNames.add(lstContacts[0].Account.Name); 
                } 
            }
        }
        else if(objectName == 'Account'){
            logACall.logACall.accounts.add(recordId);
            
            List<Account> lstAccounts = [SELECT Id, Account.Name 
                                         FROM Account WHERE id =: recordId];

                system.debug('Account list before load :' + lstAccounts);
                if(!lstAccounts.isEmpty()){
                    logACall.logACall.accountNames.add(lstAccounts[0].Name);
                }
        }
        system.debug('LogACallDetailWrapper' + logACall);
        return JSON.serialize(logACall);
    }

    @AuraEnabled
    public static string saveLogACall(String logACall, String strExpenses, String strTasks, String strChatter) {
        system.debug('LogACall=>'+logACall);
        system.debug('Expenses=>'+strExpenses);
        system.debug('Tasks=>'+strTasks);
        system.debug('Chatter=>'+strChatter);

        try {
            
            LogACallWrapper objLogACall = (LogACallWrapper) JSON.deserialize(logACall, LogACallWrapper.class);

            LogACall__c newLogACall = new logACall__c();

            newLogACall.Type_of_Call__c = objLogACall.typeOfCall;
            newLogACall.Event_Date__c = objLogACall.eventDate;
            newLogACall.Mileage_Type__c = objLogACall.mileageType;
            newLogACall.Mileage_Traveled__c = objLogACall.mileageTraveled;
            newLogACall.Opportunity__c = objLogACall.opportunityId;
            newLogACall.Assigned_To__c = UserInfo.getUserId();

            if(newLogACall.Type_of_Call__c != 'Expense Only') {
                newLogACall.Relationship__c = objLogACall.relationship;    
                newLogACall.Comments__c = objLogACall.comments;

                if(!objLogACall.contacts.isEmpty()) {
                    newLogACall.Contacts__c = String.join(objLogACall.contacts, ', ');
                   //newLogACall.Contact_Names__c = String.join(objLogACall.contactNames, ',');

                    List<String> lstContactNames = new List<String>();
                    for(Contact contact : [SELECT Name FROM Contact WHERE Id IN : objLogACall.contacts]){
                        lstContactNames.add(contact.Name);
                    }
                    newLogACall.Contact_Names__c = String.Join(lstContactNames, ', ');

                    system.debug('contact name selected by users'+ newLogACall.Contacts__c + ',' + newLogACall.Contact_Names__c);
                }
            }
                if(!objLogACall.accounts.isEmpty()) {
                    newLogACall.Accounts__c = String.join(objLogACall.accounts, ', ');

                    List<String> lstAccountNames = new List<string>();
                    for(Account account : [SELECT Name FROM Account WHERE Id IN : objLogACall.accounts]){
                        lstAccountNames.add(account.Name);
                    }
                    newLogACall.Account_Names__c = string.join(lstAccountNames, ', ');
                }
            
            insert newLogACall; 
                 
            //Related records for LogACall ||Account || Contact
            List<LogCallExtend__c> lstLogCallExt = new List<LogCallExtend__c>();
                    for(String contactId : objLogACall.contacts){
                        LogCallExtend__c extCon = new LogCallExtend__c();
                        extCon.Contact__c = contactId;
                        extCon.logACall__c = newLogACall.Id;
                        lstLogCallExt.add(extCon);
                       
                    }
                    for(String AccountId : objLogACall.accounts){
                        LogCallExtend__c extAcc = new LogCallExtend__c();
                        extAcc.Account__c = AccountId;
                        extAcc.logACall__c = newLogACall.Id;
                        lstLogCallExt.add(extAcc);
                        
                    }
                    insert lstLogCallExt;
            

            if(newLogACall.Type_of_Call__c != 'Expense Only') {
                List<Task> lstTasksToInsert = new List<Task>();
                List<TaskWrapper> lstTasksWrapper = (List<TaskWrapper>) JSON.deserialize(strTasks, List<TaskWrapper>.class);
                 
                for(TaskWrapper taskWrapper : lstTasksWrapper) {
                    // for(String userId : taskWrapper.assignedToIds) {}
                    Task newTask = new Task();
                    if(objLogACall.opportunityId != null) {
                        newTask.WhatId = objLogACall.opportunityId;
                    }
                    newTask.ActivityDate = taskWrapper.dueDate;
                    newTask.Subject = taskWrapper.subject;
                    if(taskWrapper.relatedTo != ''){
                        newTask.WhatId = taskWrapper.relatedTo;
                    }
                    if(taskWrapper.contact != ''){
                        newTask.Contact__c = taskWrapper.contact;
                    }
                    lstTasksToInsert.add(newTask);
                }

                if(!lstTasksToInsert.isEmpty()) {
                    insert lstTasksToInsert;
                }
            }
            
            List<Expense__c> lstExpensesToInsert = new List<Expense__c>();
            List<ExpenseWrapper> lstExpensesWrapper = (List<ExpenseWrapper>) JSON.deserialize(strExpenses, List<ExpenseWrapper>.class);

            Boolean hasEmptyElement = false;
            for(ExpenseWrapper expenseWrapper : lstExpensesWrapper) {
                Expense__c newExpense = new Expense__c();
                newExpense.Log_A_Call__c = newLogACall.Id;
                newExpense.Vendor_Or_Venue__c = expenseWrapper.vendorOrVenue;
                newExpense.Expense_Type__c = expenseWrapper.expenseType;
                newExpense.Expense_Amount__c = expenseWrapper.expenseAmount;
                newExpense.Payment_Type__c = expenseWrapper.paymentType;
                newExpense.Project__c = expenseWrapper.project;

                //expense date = event date if not then save expense date
                if(newLogACall.Event_Date__c != expenseWrapper.expenseDate) 
                {
                    newExpense.Expense_Date__c = expenseWrapper.expenseDate;
                   
                }else{
                    newExpense.Expense_Date__c = newLogACall.Event_Date__c;
                    
                }

                if(newExpense.Payment_Type__c == 'Personal Expense') {
                    newExpense.Reason_For_Personal_Expense__c = expenseWrapper.reason;
                }
                newExpense.Description_Or_Notes_Related_To_Expense__c = expenseWrapper.description;
                
                // To check whether the split expense is blank or not, If blank it throws error
                 for (String str : expenseWrapper.splitExpenses) {
                     if (String.isBlank(str)) {
                        hasEmptyElement = true;
                         break;
                     }
                 }
                 if(hasEmptyElement){
                    break;
                 }else{
                    newExpense.Split_Expense_Across_Offices__c = String.join(expenseWrapper.splitExpenses, ', ');
                        lstExpensesToInsert.add(newExpense);
                 }
            }
            
            if(hasEmptyElement == true) {
                system.debug('error thrown');
                throw new applicationException('Split expenses cannot be empty.');   
            }else{
                if(!lstExpensesToInsert.isEmpty()) {
                    insert lstExpensesToInsert;   
                }
                
                List<FeedItem> lstChatterToInsert = new List<FeedItem>();
                List<ChatterWrapper> lstChatterWrapper = (List<ChatterWrapper>) JSON.deserialize(strChatter, List<ChatterWrapper>.class);
    
                for(ChatterWrapper chatterWrapper : lstChatterWrapper) {
                    if(chatterWrapper.postFeedCheckBox  == true && newLogACall.Comments__c != ''){
                        FeedItem feed = new FeedItem();
                        feed.ParentId = chatterWrapper.chatterParentId;     
                        feed.Body = objLogACall.comments;
                        //insert feed;
                        system.debug('chatter post message :- ' +feed);
                        lstChatterToInsert.add(feed);
                    }
                    if(!lstChatterToInsert.isEmpty()){
                        insert lstChatterToInsert;
                        system.debug('chatter record insert :- ' +lstChatterToInsert);
                    }
                }

                if(newLogACall.Opportunity__c != null) {
                    return loadLogACall(newLogACall.Opportunity__c, 'Opportunity');
                }
            }
            return null;
        } catch (Exception e) {
            system.debug('Inside catch :- ' +e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public with sharing class LogACallDetailWrapper {
        @AuraEnabled public logACallWrapper logACall {get;set;}
        @AuraEnabled public List<TaskWrapper> lstTasks {get;set;}
        @AuraEnabled public List<ExpenseWrapper> lstExpenses {get;set;}
        @AuraEnabled public List<ChatterWrapper> lstChatter {get;set;}
       // @AuraEnabled public UserWrapper lstUser {get;set;}

        public LogACallDetailWrapper() {
            
            logACall = new logACallWrapper();

            lstTasks = new List<TaskWrapper>();
            lstTasks.add(new TaskWrapper());
            
            lstExpenses = new List<ExpenseWrapper>();
            lstExpenses.add(new ExpenseWrapper());

            lstChatter = new  List<ChatterWrapper>();
            lstChatter.add(new ChatterWrapper());

           // lstUser = new UserWrapper();
        }

    }


    public with sharing class logACallWrapper {
        @AuraEnabled public String typeOfCall {get; set;}
        @AuraEnabled public Date eventDate {get; set;}
        @AuraEnabled public List<String> contacts {get; set;}
        @AuraEnabled public List<String> contactNames {get; set;}
        @AuraEnabled public List<String> accounts {get; set;}
        @AuraEnabled public List<String> accountNames {get; set;}
        @AuraEnabled public String relationship {get; set;}
        @AuraEnabled public String opportunityId {get; set;}
        @AuraEnabled public String comments {get; set;} //used in logAcall comment field and chatter body.
        @AuraEnabled public String mileageType {get; set;}
        @AuraEnabled public Integer mileageTraveled {get; set;}

        public logACallWrapper() {
            
            this.eventDate = Date.today();
            this.mileageType = 'Car Allowance';

            this.contacts = new List<String>();
            this.contactNames = new List<String>();
            
            this.accounts = new List<String>();
            this.accountNames = new List<String>();
        }
    }

    public with sharing class TaskWrapper {
        @AuraEnabled public String subject {get; set;}
        @AuraEnabled public Date dueDate {get; set;}
        @AuraEnabled public List<String> assignedToIds {get; set;}
        @AuraEnabled public String contact {get; set;}
        @AuraEnabled public String relatedTo {get; set;}

        public TaskWrapper() {
            this.assignedToIds = new List<String>();
        }
    }

    public with sharing class ExpenseWrapper {
        @AuraEnabled public String vendorOrVenue {get; set;}
        @AuraEnabled public String expenseType {get; set;}
        @AuraEnabled public Decimal expenseAmount {get; set;}
        @AuraEnabled public String paymentType {get; set;}
        @AuraEnabled public String reason {get; set;}
        @AuraEnabled public String description {get; set;}
        @AuraEnabled public List<String> splitExpenses {get; set;}
        @AuraEnabled public Date expenseDate {get;set;}
        @AuraEnabled public String project {get; set;}

        public ExpenseWrapper() {
            this.splitExpenses = new List<String>();
            this.paymentType = 'Company Expense';
            this.expenseDate = Date.today();
        }
    }
    public with sharing class ChatterWrapper {
        @AuraEnabled  public string chatterParentId{get;set;}
        @AuraEnabled  public Boolean postFeedCheckBox{ get; set;}
    }
}