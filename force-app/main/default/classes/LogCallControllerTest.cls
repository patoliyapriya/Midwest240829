@isTest
public with sharing class LogCallControllerTest {
    @testSetup static void setup()
    {
        Account account = new Account();
        account.Name = 'Test Acct';
        account.AcctSeed__Accounting_Type__c = 'Customer';
        insert account;

        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.FirstName = 'TestCon';
        contact.LastName = 'LastCon';
        insert contact;

        Opportunity testobjOppo = new Opportunity();
        testobjOppo.Name = 'Test opportunity';
        testobjOppo.AccountId = account.Id;
        testobjOppo.StageName = 'TARGET_NEGOTIATING';
        testobjOppo.Project_Manager__c = UserInfo.getUserId();
        testobjOppo.closeDate = Date.today();
        insert testobjOppo;

        LogACall__c logACall = new LogACall__c();
        logACall.Type_of_Call__c = 'Meal';
        logACall.Mileage_Type__c ='Car Allowance';
        logACall.Mileage_Traveled__c = 35;
        logACall.Assigned_To__c = UserInfo.getUserId();
        logACall.CreatedDate = system.now().addMonths(-1);
        logACall.Event_Date__c = Date.today();
        logACall.Opportunity__c =testobjOppo.Id;
        insert logACall;
        
        Expense__c expense = new Expense__c();
        expense.Log_A_Call__c = logACall.Id;
        expense.Vendor_Or_Venue__c = 'Test of expense';
        expense.Expense_Type__c = 'Fuel';
        expense.Expense_Amount__c = 150;
        expense.Payment_Type__c = 'Company Expense';
        expense.Expense_Date__c = Date.today();
        expense.Description_Or_Notes_Related_To_Expense__c = 'test expense record';
        expense.Split_Expense_Across_Offices__c = 'Saint Louis';
        insert expense;
   
        Task task = new Task();
        task.ActivityDate = Date.today();
        task.Subject = 'Send Letter';
        task.Contact__c = contact.Id;
        task.WhatId = testobjOppo.Id;
        insert task;

    }
 
    @isTest static void testloadLogACall(){
       
        LogCallController.loadLogACall(UserInfo.getUserId(), 'Opportunity');
        LogCallController.loadLogACall(UserInfo.getUserId(), 'Contact');
        LogCallController.loadLogACall(UserInfo.getUserId(), 'Account');
        LogCallController.getCurrentUserOfficeLocation();
    }

    @isTest static void testsaveLogACall(){

        Account account = new Account();
        account.Name = 'Test Acct';
        account.AcctSeed__Accounting_Type__c = 'Customer';
        insert account;

        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.FirstName = 'TestCon';
        contact.LastName = 'LastCon';
        insert contact;

        Opportunity testobjOppo = new Opportunity();
        testobjOppo.Name = 'Test opportunity';
        testobjOppo.AccountId = account.Id;
        testobjOppo.StageName = 'TARGET_NEGOTIATING';
        testobjOppo.Project_Manager__c = UserInfo.getUserId();
        testobjOppo.closeDate = Date.today();
        insert testobjOppo;

        LogACall__c logACall = new LogACall__c();
        logACall.Type_of_Call__c = 'Meal';
        logACall.Mileage_Type__c ='Car Allowance';
        logACall.Mileage_Traveled__c = 35;
        logACall.Assigned_To__c = UserInfo.getUserId();
        logACall.CreatedDate = system.now().addMonths(-1);
        logACall.Event_Date__c = Date.today();
        logACall.Relationship__c ='Existing Contact';
        logACall.Opportunity__c =testobjOppo.Id;
        logACall.Comments__c = 'test comment';
        logACall.Contact_Names__c = 'TestCon LastCon';
        logACall.Account_Names__c = 'Test Acct';
        insert logACall;
        
        Expense__c expense = new Expense__c();
        expense.Log_A_Call__c = logACall.Id;
        expense.Vendor_Or_Venue__c = 'Test of expense';
        expense.Expense_Type__c = 'Fuel';
        expense.Expense_Amount__c = 150;
        expense.Payment_Type__c = 'Company Expense';
        expense.Reason_For_Personal_Expense__c = 'Test reson for Expense';
        expense.Split_Expense_Across_Offices__c = 'Saint Louis';
        expense.Expense_Date__c = Date.today();
        insert expense;
   
        Task task = new Task();
        task.ActivityDate = Date.today();
        task.Subject = 'Send Letter';
        task.Contact__c = contact.Id;
        task.WhatId = testobjOppo.Id;
        insert task;

        LogCallExtend__c logACallExtendContact = new LogCallExtend__c();
        logACallExtendContact.Contact__c = contact.Id;
        logACallExtendContact.logACall__c = logACall.Id;
        insert logACallExtendContact;

        LogCallExtend__c logACallExtendAccount = new LogCallExtend__c();
        logACallExtendAccount.Account__c = account.Id;
        logACallExtendAccount.logACall__c = logACall.Id;
        insert logACallExtendAccount;

        FeedItem post = new FeedItem();
        post.ParentId = UserInfo.getUserId();
        post.Body = 'Test post a chatter record';
        insert post;
        system.debug('Test chatter record insert :- '+post);

        Test.startTest();
        try{
            String loadedLogACall = LogCallController.loadLogACall(UserInfo.getUserId(), 'Contact');
            system.debug('Loaded log a call: '+loadedLogACall);

            LogCallController.LogACallDetailWrapper strJson = new LogCallController.LogACallDetailWrapper();
            strJson = (LogCallController.LogACallDetailWrapper) 
                      JSON.deserialize(loadedLogACall, LogCallController.LogACallDetailWrapper.class);

            LogCallController.logACallWrapper logACallWrapperObj = new  LogCallController.logACallWrapper();

            if(strJson != null && strJson.logACall != null) {
                system.debug('fetch contact and account data'+strJson.logACall.contacts);
                system.debug('fetch account data'+strJson.logACall.accounts);
                
                logACallWrapperObj = (LogCallController.logACallWrapper) 
                                     JSON.deserialize(JSON.serialize(strJson.logACall), LogCallController.logACallWrapper.class);
            }
     
            //Task Records
            List<LogCallController.TaskWrapper> lstTasks = new List<LogCallController.TaskWrapper>();
            List<LogCallController.TaskWrapper> lstTaskWrapper = (List<LogCallController.TaskWrapper>) JSON.deserialize(
                JSON.serialize(strJson.lstTasks), List<LogCallController.TaskWrapper>.class);

            if(strJson != null && strJson.lstTasks != null) {
                system.debug('task to insert : '+strJson.lstTasks);
                for(Integer i=0; i < lstTaskWrapper.size(); i++) {

                    lstTasks.add(lstTaskWrapper[i]);
                }
            }
            
            //Expense Record
            List<LogCallController.ExpenseWrapper> lstExpenses = new List<LogCallController.ExpenseWrapper>();
            List<LogCallController.ExpenseWrapper> lstExpWrapper = (List<LogCallController.ExpenseWrapper>) JSON.deserialize(
                                    JSON.serialize(strJson.lstExpenses), List<LogCallController.ExpenseWrapper>.class);

            if(strJson != null && strJson.lstExpenses != null) {
                for(Integer i=0; i < lstExpWrapper.size(); i++) {
                    
                    lstExpenses.add(lstExpWrapper[i]);
                }
            }
            // chatter expense 
            List<LogCallController.ChatterWrapper> lstChatter = new List<LogCallController.ChatterWrapper>();
            List<LogCallController.ChatterWrapper> lstchatWrapper = (List<LogCallController.ChatterWrapper>) JSON.deserialize(
                                    JSON.serialize(strJson.lstChatter), List<LogCallController.ChatterWrapper>.class);

            if(strJson != null && strJson.lstChatter != null) {
                for(Integer i=0; i < lstchatWrapper.size(); i++) {
                    
                    lstChatter.add(lstchatWrapper[i]);
                }
            }
            String strExpenseJSON;
            String strTasksJSON;
            if(logACallWrapperObj.typeOfCall != 'Expense Only') {
                logACallWrapperObj.contacts = new List<String>{contact.id};
                logACallWrapperObj.accounts = new List<String>{account.id};
    
                List<LogCallController.TaskWrapper> lstTasksToInsert = new List<LogCallController.TaskWrapper>();
                strTasksJSON = JSON.serialize(lstTasksToInsert);
            }

            
            LogCallController.saveLogACall(JSON.serialize(logACallWrapperObj), JSON.serialize(lstExpenses), strTasksJSON ,JSON.serialize(lstChatter));
            
        }
        catch(exception e){
        }     
        Test.stopTest();
    }

}