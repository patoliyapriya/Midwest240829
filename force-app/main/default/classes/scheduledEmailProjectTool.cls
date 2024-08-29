public class scheduledEmailProjectTool implements Schedulable {
    public map<String, String> projectIdToFromAddressId = new Map<String, String>();
    public map<Id, GroupMember > egineeredGroupMember = new Map<Id, GroupMember>([Select Id, UserOrGroupId From GroupMember Where Group.Name = 'Engineered Products']);
    public scheduledEmailProjectTool(){
        
    }

    public Boolean checkIsDenverUser(Id userIdToCheck){
        
        for (GroupMember user : egineeredGroupMember.values()){
            if(user.UserOrGroupId == userIdToCheck){ 
                return true;
            }
        }
        
        return false;
    }
    public void getOrgWideEmailAddressId(List<Project__c> projects){
        
        String midWestFromAddressId = null;
        String EPFromAddressId = null;
        String orgWideAddress = null;
        List<OrgWideEmailAddress> lstOrgWideEmailAddress = [SELECT Id, Address FROM OrgWideEmailAddress];
        
        for(OrgWideEmailAddress orgWideAdd :lstOrgWideEmailAddress) {
            if(orgWideAdd.Address == 'info@midwestmachinery.net') {
                midWestFromAddressId = orgWideAdd.Id;
            } else if(orgWideAdd.Address == 'info@engineeredproducts.com') {
                EPFromAddressId = orgWideAdd.Id;
            }
        }
        for(Project__c proj :projects) {
            
            if(checkIsDenverUser(proj.OwnerId)) {
                projectIdToFromAddressId.put(proj.Id,EPFromAddressId);
            } else {
                projectIdToFromAddressId.put(proj.Id,midWestFromAddressId);
            }
        }
        
    }
    
    public void execute(SchedulableContext ctx) {
    ID projectId;
    ID TargetObjectId; 
        
        try {
    
                Datetime dt = System.now();
                String todayDay = dt.format('EEEE');
                
                PM_Tool_Send_Email_History__c historyJonInitiated = new PM_Tool_Send_Email_History__c();
                historyJonInitiated.Error_Message__c = 'Job is initiated on ' + String.valueOf(dt) +'   ProjectId :- '+projectId;
                insert historyJonInitiated;
                
                List<Project__c> lstProjects = [Select Id, Schedule_To__c, Schedule_End_Date__c, Schedule_On__c,
                                                Owner.Email, OwnerId,
                                                (Select Contact__c, User__c, Contact__r.Email, User__r.Email, Schedule_Type__c
                                                FROM Schedules__r)
                                                FROM Project__c
                                                WHERE Schedule_On__c =: todayDay
                                                AND Schedule_End_Date__c >= TODAY];
                
                getOrgWideEmailAddressId(lstProjects);
                
                EmailTemplate et = [Select Id From EmailTemplate WHERE developerName =: 'Stage_Startup_and_Warranty'];
                
                List<Messaging.SingleEmailMessage> lstEmailToSend = new List<Messaging.SingleEmailMessage>();
                                                        
                for(Project__c project : lstProjects) {
                    projectId = project.Id;
                    String fromEmailAddressId = projectIdToFromAddressId.get(project.Id);
                    List<Project_Schdule_To__c> lstScheduleTo = project.Schedules__r;
                    lstEmailToSend.add(sendEmail(et.Id, project.Id, lstScheduleTo, project.Owner.Email, fromEmailAddressId));
                }
                
                if(lstEmailToSend.size() > 0){
                    Messaging.sendemailResult[] r = Messaging.sendemail(lstEmailToSend, false);
                    List<PM_Tool_Send_Email_History__c> lstSendEmailFailHistory = new List<PM_Tool_Send_Email_History__c>();
                    
                    for(Messaging.sendemailResult result : r){
                        if(!result.IsSuccess()){
                            for(Messaging.sendEmailError error : result.getErrors()){
                                targetObjectId = error.getTargetObjectId();
                                PM_Tool_Send_Email_History__c history = new PM_Tool_Send_Email_History__c();
                                history.Error_Message__c = error.getMessage() + ' TargetObjectId : ' + error.getTargetObjectId() +'  ProjectId : '+projectId+ '  Status code : '+  error.getStatusCode();
                                // history.Schedule_To__c = error.getTargetObjectId();
                                lstSendEmailFailHistory.add(history);
                            }
                        }
                    }
                    
                    if(!lstSendEmailFailHistory.isEmpty()){
                        insert lstSendEmailFailHistory;
                    } else {
                        // insert a record indicating job is completed
                        PM_Tool_Send_Email_History__c history = new PM_Tool_Send_Email_History__c();
                        history.Error_Message__c = 'Job is Completed successfully on ' + String.valueOf(dt);
                        //history.Recipients__c = 
                        insert history;
                    }
                }        
        } catch(exception ex) {
            PM_Tool_Send_Email_History__c history = new PM_Tool_Send_Email_History__c();
            history.Error_Message__c = 'Error on ' + String.valueOf(System.now()) + ex.getmessage() + ' ProjectId : '+projectId+ ' TargetObjectId :' +targetObjectId;
            insert history;
        }
    }
    
    public Messaging.SingleEmailMessage sendEmail(String emailTemplateId, String projectId, List<Project_Schdule_To__c> lstScheduleTo, string ccEmail, string fromEmailId){

        Boolean isUserId = false;
        List<String> lstCCEmail = new List<String>();
        lstCCEmail.add(ccEmail);
        
        Id targetObjectId = null;
        List<String> lstEmailsTo = new List<String>();

        for(Project_Schdule_To__c sch : lstScheduleTo) {
            system.debug('sch='+sch);
            if(targetObjectId == null) {
                System.debug('target object is null='+targetObjectId);
                if(sch.Schedule_Type__c == 'User') {
                    isUserId = true;
                    targetObjectId = sch.User__c;
                } else {
                    targetObjectId = sch.Contact__c; 
                }
            } else {
                System.debug('targetObjectId='+targetObjectId);
                if(sch.Schedule_Type__c == 'User') {
                    isUserId = true;
                    lstEmailsTo.add(sch.User__r.Email);
                } else {
                    lstEmailsTo.add(sch.Contact__r.Email);
                }
            }
        }

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTemplateID(emailTemplateId);
        if(ccEmail != null && ccEmail != ''){
            message.setCcAddresses(lstCCEmail);
        }
        message.setTargetObjectID(targetObjectId);
        if(!lstEmailsTo.isEmpty()) {
            message.setToAddresses(lstEmailsTo);
        }
        message.setWhatId(projectId);
        message.setOrgWideEmailAddressId(fromEmailId);
        // saveAsActivity works only with contact id not with userid for userid need to set false
        if(isUserId){
            message.setSaveAsActivity(false);
        }
        system.debug('Email Message='+message);
        return message;
        
    }
    
}