@isTest
public with sharing class MonthlyExpenseReportCtrlTest 
{
    @testSetup
    static void setup(){
         //ExpenseReportController
         final String PERSONAL_EXPENSE = 'Personal Expense';
         final String COMPANY_EXPENSE = 'Company Expense';
         final String TOLLS = 'Tolls';
         final String TRAVEL_HOTEL = 'Travel - Hotel';
         final String TRAVEL_MEAL = 'Travel - Meal';
         final String UBER_TAXI = 'Uber/Taxi';
         final String PARKING = 'Parking';
         final String DONATIONS = 'Donations';
        List<String> paymentType = new List<String>{PERSONAL_EXPENSE, COMPANY_EXPENSE};
        List<String> ExpenseType = new list<String>{TOLLS,TRAVEL_HOTEL,TRAVEL_MEAL,UBER_TAXI,PARKING,DONATIONS};

        Date createDate = Date.newInstance(System.today().year(), System.today().month(), 1);
        
        //MonthlyExpenseReportCtrl
        LogACall__c testLogcall = new LogACall__c();
        testLogcall.Type_of_Call__c = 'Meal';
        testLogcall.Mileage_Type__c ='Car Allowance';
        testLogcall.Mileage_Traveled__c = 35;
        testLogcall.Account_Names__c = 'Test Billing';
        testLogcall.Contact_Names__c = 'Brian Gomski';
        testLogcall.Assigned_To__c = UserInfo.getUserId();
        testLogcall.CreatedDate = createDate;
        testLogcall.Event_Date__c = createDate;
        insert testLogcall;
        System.debug('LogAcall inserted: '+testLogcall);

        Expense__c expenseObj = new Expense__c ();
        expenseObj.Log_A_Call__c = testLogcall.Id;
        expenseObj.Vendor_Or_Venue__c = 'Test of expense';
        expenseObj.Expense_Type__c = ExpenseType[0];
        expenseObj.Expense_Amount__c = 100;
        expenseObj.Payment_Type__c = paymentType[0];
        expenseObj.CreatedDate = createDate;
        expenseObj.Expense_Date__c = createDate;
        insert expenseObj;

        List<Expense__c> lstTestEpense = new List<Expense__c>();
        for(Integer i=0 ; i<12 ; i++){
            Expense__c testPersonalExpense = new Expense__c ();
            testPersonalExpense.Log_A_Call__c = testLogcall.Id;
            testPersonalExpense.Vendor_Or_Venue__c = 'Test of expense';
            testPersonalExpense.Expense_Type__c = ExpenseType[math.mod(i,6)];
            testPersonalExpense.Expense_Amount__c = 100;
            testPersonalExpense.Payment_Type__c = paymentType[0];
            testPersonalExpense.CreatedDate = system.now().addMonths(-(Math.mod(i,12)));
            testPersonalExpense.Expense_Date__c = system.now().addMonths(-(Math.mod(i,12))).date();
            lstTestEpense.add(testPersonalExpense);

            Expense__c testCompanyExpense = new Expense__c ();
            testCompanyExpense.Log_A_Call__c = testLogcall.Id;
            testCompanyExpense.Vendor_Or_Venue__c = 'Test of expense';
            testCompanyExpense.Expense_Type__c = ExpenseType[math.mod(i,6)];
            testCompanyExpense.Expense_Amount__c = 100;
            testCompanyExpense.Payment_Type__c = paymentType[1];
            testCompanyExpense.CreatedDate = system.now().addMonths(-(Math.mod(i,12)));
            testCompanyExpense.Expense_Date__c = system.now().addMonths(-(Math.mod(i,12))).date();
            lstTestEpense.add(testCompanyExpense);
        }
        insert lstTestEpense;


        List<LogACall__c> listofLogACalls = new List<LogACall__c>();
        for (Integer i=0; i<12; i++){

            LogACall__c  LogcallTst = new LogACall__c();
            LogcallTst.Type_of_Call__c = 'Meal';
            LogcallTst.Mileage_Traveled__c = 70;
            LogcallTst.CreatedDate = system.now().addMonths(-(Math.mod(i,10)));
            LogcallTst.Event_Date__c = system.now().addMonths(-(Math.mod(i,10))).date();
            listofLogACalls.add(LogcallTst);
        }  
        insert listofLogACalls; 
        

        //For the declined record trigger code coverage 

        LogACall__c testLogcall1 = new LogACall__c();
        testLogcall1.Event_Date__c = Date.newInstance(2022, 06, 06);
        insert testLogcall1;

        Submit_Request__c newSR = new Submit_Request__c();
        insert newSR;

        newSR.Total_Expense_Amount__c = 150;
        newSR.Status__c = 'Requested';
        update newSR;

        Expense__c newExpense = new Expense__c();
        newExpense.Log_A_Call__c = testLogcall1.Id;
        newExpense.Expense_Date__c = Date.newInstance(2022, 06, 06);
        newExpense.Expense_Amount__c = 150;
        newExpense.Submit_Request__c = newSR.Id;
        insert newExpense;

        newSR.Status__c = 'Declined';
        update newSR;
        

    }

    @isTest static void testMonthYear()
    {
     
        MonthlyExpenseReportCtrl.getCurrentMonth();
        MonthlyExpenseReportCtrl.getCurrentYear();
    }
    @isTest static void testExpensemonthlyReport(){

        MonthlyExpenseReportCtrl.getAllExpensemonthlyReport('June', '2022' );
         
    }
    @isTest static void testgetExpenseAccounting(){
          
         MonthlyExpenseReportCtrl.getExpenseAccounting('June', '2022');   
    }
    @isTest static void testhandleSubmitRequest(){
 
           LogACall__c testLogcall = new LogACall__c();
           //testLogcall.Event_Date__c = Date.newInstance(2022, 06, 06);
           testLogcall.Type_of_Call__c = 'Client Office Visit';
           insert testLogcall;
   
           Expense__c newExpense1 = new Expense__c();
           newExpense1.Log_A_Call__c = testLogcall.Id;
           newExpense1.Expense_Date__c = Date.newInstance(2022, 06, 20);
           newExpense1.Expense_Amount__c = 500;
           insert newExpense1;

           Submit_Request__c newSR1 = new Submit_Request__c();
           newSR1.Status__c = 'Requested';
           insert newSR1;

           newExpense1.Submit_Request__c = newSR1.Id;
           update newExpense1;
   
           Approver__c newApp = new Approver__c();
           newApp.ApproverId__c = UserInfo.getUserId();
           insert newApp;
   
           Approver__c newAppSub = new Approver__c();
           newAppSub.User__c = UserInfo.getUserId();
           newAppSub.ApproverId__c = newApp.ApproverId__c;
           insert newAppSub;
   
           newSR1.Total_Expense_Amount__c = 250;
           newSR1.Approver__c = newAppSub.ApproverId__c;
           update newSR1;


        Approval.ProcessSubmitRequest testapproval = new Approval.ProcessSubmitRequest();
        testapproval.setComments('Submitting request for approval');
        testapproval.setObjectId(newSR1.Id);
        testapproval.setSubmitterId(UserInfo.getUserId());
        Approval.ProcessResult result1 = Approval.process(testapproval);
        system.debug('Test Approval process record :-' +result1);
        system.debug('Test Approval process record :-' +result1.getNewWorkitemIds().get(0));

        // Verify the results
        System.assert(result1.isSuccess());
        System.assertEquals('Pending', result1.getInstanceStatus(), 'Instance Status'+result1.getInstanceStatus());
        system.debug('status for approval::'+result1.getInstanceStatus());

        MonthlyExpenseReportCtrl.handleSubmitRequest(newSR1.Id , 'June','2022'); 
        MonthlyExpenseReportCtrl.getSubmittedExpenseApprovalData('June','2022');

        MonthlyExpenseReportCtrl.ExpenseRelatedList(result1.getNewWorkitemIds().get(0));
    }

    @isTest static void testSubmittedExpenseList(){
        LogACall__c testLogcall = new LogACall__c();
       // testLogcall.Event_Date__c = Date.newInstance(2022, 06, 06);
        testLogcall.Type_of_Call__c = 'Client Office Visit';
        insert testLogcall;

        Expense__c newExpense1 = new Expense__c();
        newExpense1.Log_A_Call__c = testLogcall.Id;
        newExpense1.Expense_Date__c = Date.newInstance(2022, 06, 20);
        insert newExpense1;

        Submit_Request__c newSR1 = new Submit_Request__c();
        newSR1.Total_Expense_Amount__c = 150;
        newSR1.Status__c = 'Requested';
        insert newSR1;

        newExpense1.Submit_Request__c = newSR1.Id;
        update newExpense1;

        MonthlyExpenseReportCtrl.getSubmittedExpenseList('All','2022');
    }

    @isTest
    static void testSetTaskForSecondApproval()
    {

        Submit_Request__c newSR1 = new Submit_Request__c();
        newSR1.Status__c = 'Requested';
        insert newSR1;

        Approver__c newApp = new Approver__c();
        newApp.ApproverId__c = UserInfo.getUserId();
        insert newApp;

        Approver__c newAppSub = new Approver__c();
        newAppSub.User__c = UserInfo.getUserId();
        newAppSub.ApproverId__c = newApp.ApproverId__c;
        insert newAppSub;

        newSR1.Total_Expense_Amount__c = 250;
        newSR1.Approver__c = newAppSub.ApproverId__c;
        update newSR1;

        Submit_Request__c SrRecord = [SELECT id,name FROM Submit_Request__c where id=: newSR1.Id];
        system.debug('SrRecord :- '+SrRecord);

        Task taskForApproval = new Task();
        taskForApproval.OwnerId = UserInfo.getUserId(); 
        taskForApproval.SR_Name__c = SrRecord.Name;
        taskForApproval.Subject = 'Approver task';
        taskForApproval.ActivityDate = Date.today().addDays(3);
        taskForApproval.Priority = 'Medium';
        insert taskForApproval;


        Approval.ProcessSubmitRequest testapproval = new Approval.ProcessSubmitRequest();
        testapproval.setComments('Submitting request for approval');
        testapproval.setObjectId(newSR1.Id);
        testapproval.setSubmitterId(UserInfo.getUserId());

        Approval.ProcessResult result = Approval.process(testapproval);
        system.debug('Test-22 Approval process record :-' +result);

        System.assert(result.isSuccess());
        System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());
        system.debug('status for approvalhistory::' +result.getInstanceStatus());

        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        system.debug('newWorkItemIds ::'+newWorkItemIds );

        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest(); 
        req2.setComments('Approving request.');
        req2.setAction('Approve');
        req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        req2.setWorkitemId(newWorkItemIds.get(0));

        Approval.ProcessResult result2 =  Approval.process(req2);
        system.debug('update approval process id :- '+result2);

        // Verify the results
        System.assert(result2.isSuccess(), 'Result Status:'+result2.isSuccess());

        // System.assertEquals(
        //     'Approved', result2.getInstanceStatus(), 
        //     'Instance Status'+result2.getInstanceStatus());
        // system.debug('status for approvalhistory::' +result2.getInstanceStatus());

        ProcessInstanceStep approvalHistory = [SELECT Id ,ProcessInstance.TargetObjectId FROM ProcessInstanceStep 
                                                    WHERE ProcessInstance.TargetObjectId =:newSR1.Id
                                                    AND StepStatus = 'Approved' order by CreatedDate desc LIMIT 1];
        system.debug('approvalHistrory record '+approvalHistory);                                            
        
        ApprovalProcSendCustomTaskCtrl.setTaskForSecondApproval(approvalHistory.Id);      
        
    }

    //Below test is covered for ExpenseReport.page -- ExpenseReportController
    @isTest static void testExpenseReport(){
        ExpenseReportController testExpenseReport = new ExpenseReportController();
        List<String> ExpenseTypeString = testExpenseReport.getExpenseType();
        
    }

    
 
  
}