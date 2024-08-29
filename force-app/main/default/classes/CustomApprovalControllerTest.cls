@isTest
public with sharing class CustomApprovalControllerTest {
    
    @testSetup
    static void setup(){
        Approver__c newApp = new Approver__c();
        newApp.ApproverId__c ='00561000000LHhAAAW';
        insert newApp;

        Approver__c newAppSub = new Approver__c();
        newAppSub.User__c = UserInfo.getUserId();
        newAppSub.ApproverId__c = newApp.ApproverId__c;
        insert newAppSub;

        Approver__c newAppdel = new Approver__c();
        newAppdel.ApproverId__c ='00561000000LHhAAAW';
        insert newAppdel;

        Approver__c newAppSub1 = new Approver__c();
        newAppSub1.User__c = UserInfo.getUserId();
        newAppSub1.ApproverId__c = newAppdel.ApproverId__c;
        insert newAppSub1;

    }

    @isTest static void testgetApprovers(){
        CustomApprovalController.getApprovers();
      
        Approver__c delSubmitter = [SELECT Id FROM Approver__c LIMIT 1];
        if(delSubmitter != null){
            delete delSubmitter;
        }
        CustomApprovalController.deleteSubmitter(delSubmitter.Id);
    }


    @isTest static void testdeleteApprover(){ 
     Approver__c delApporver = [SELECT Id, ApproverId__c FROM Approver__c LIMIT 1];
     if(delApporver !=  null){
        delete delApporver;
     }
     CustomApprovalController.deleteApprover(delApporver.Id);
    }

    @isTest static void testsaveApproverDetails(){

        Approver__c newApp = new Approver__c();
        newApp.ApproverId__c ='00561000000LHhAAAW';
        insert newApp;

        Approver__c newAppSub = new Approver__c();
        newAppSub.User__c = UserInfo.getUserId();
        newAppSub.ApproverId__c = newApp.ApproverId__c;
        insert newAppSub;

        String saveApprovaldata = JSON.serialize(CustomApprovalController.getApprovers());
        CustomApprovalController.saveApproverDetails(saveApprovaldata);
        
    }
}