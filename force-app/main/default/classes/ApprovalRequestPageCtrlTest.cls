@isTest
public with sharing class ApprovalRequestPageCtrlTest {

    @isTest static void testhandleApprovalRequest(){
        LogACall__c testLogcall = new LogACall__c();
        testLogcall.Event_Date__c = Date.newInstance(2022, 06, 06);
        insert testLogcall;

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

        Expense__c newExpense1 = new Expense__c();
        newExpense1.Log_A_Call__c = testLogcall.Id;
        newExpense1.Expense_Amount__c = 500;
        newExpense1.Submit_Request__c = newSR1.Id;
        newExpense1.Expense_Date__c = Date.today();
        insert newExpense1;

        Approval.ProcessSubmitRequest testapproval = new Approval.ProcessSubmitRequest();
        testapproval.setComments('Submitting request for approval');
        testapproval.setObjectId(newSR1.Id);
        testapproval.setSubmitterId(UserInfo.getUserId());
        Approval.ProcessResult result1 = Approval.process(testapproval);
        system.debug('Test Approval process record :-' +result1);
        system.debug('Test Approval process record :-' +result1.getNewWorkitemIds().get(0));

        ApprovalRequestPagectrl.expenseAccounting(result1.getNewWorkitemIds().get(0));
        ApprovalRequestPagectrl.submittedExpenseList(result1.getNewWorkitemIds().get(0));
        ApprovalRequestPagectrl.getApprovalComments(result1.getNewWorkitemIds().get(0));
    }
}