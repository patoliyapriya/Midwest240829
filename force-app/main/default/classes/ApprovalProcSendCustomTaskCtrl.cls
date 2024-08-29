public with sharing class ApprovalProcSendCustomTaskCtrl {
   public ApprovalProcSendCustomTaskCtrl() {
   }
   // Custom task for final Approval(Joe)- in task relatedToAppReq onclick of SR-0001 
   //SR-0001 need to redirect to processinstnaceWorkItem page.
   //Task email with template is send from Workflow Rule

   @AuraEnabled
   public static void setTaskForSecondApproval(String recordId){

      try{
         ProcessInstanceStep approvalHistory = [SELECT Id, ProcessInstanceId, StepStatus, ProcessInstance.TargetObjectId, 
                                                       ActorId, CreatedDate
                                                FROM ProcessInstanceStep
                                                WHERE Id =: recordId
                                                AND StepStatus = 'Approved' ORDER BY CreatedDate desc LIMIT 1];
  
           ProcessInstanceWorkitem approvalWorkIteam = [SELECT Id, ProcessInstance.TargetObjectId, ActorId ,
                                                               ProcessInstance.TargetObject.Name    
                                                        FROM ProcessInstanceWorkitem 
                                                        WHERE ProcessInstance.TargetObjectId =: approvalHistory.ProcessInstance.TargetObjectId];
                                                  
           Submit_Request__c subRequest = [SELECT Id, Name, Status__c FROM Submit_Request__c 
                                           WHERE Id =:approvalWorkIteam.ProcessInstance.TargetObjectId];
              
           Task taskrecord = [SELECT Id, whatId, OwnerId, Approval_Request_Id__c FROM task 
                              WHERE SR_Name__c =: subRequest.Name
                              ORDER BY CreatedDate desc LIMIT 1];

                             
              if(approvalHistory.StepStatus == 'Approved' && subRequest.Status__c == 'Requested' && taskrecord.OwnerId != approvalWorkIteam.ActorId){

                 Task taskForApproval = new Task();
                 taskForApproval.OwnerId = approvalWorkIteam.ActorId; //userId
                 taskForApproval.Approval_Request_Id__c = approvalWorkIteam.Id; //ProcessInstanceWorkitemId
                 taskForApproval.SR_Name__c = approvalWorkIteam.ProcessInstance.TargetObject.Name; // SR-Name
                 taskForApproval.Subject = 'Approver task';
                 taskForApproval.ActivityDate = Date.today().addDays(3);
                 taskForApproval.Priority = 'Medium';
                 insert taskForApproval;

              }else{  
                 
              }
          
      }catch(DmlException e) {
              System.debug('The following exception has occurred: ' + e.getMessage());
      }
   }
}