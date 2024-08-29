global class debugScheduledEmailProjectTool implements Schedulable {
    public contact con;
    global debugScheduledEmailProjectTool (){
               
    }
    
    global String getOrgWideEmailAddressId(){
        
        String fromAddressId = null;
        
        List<OrgWideEmailAddress> lstOrgWideEmailAddress = [SELECT Id, Address,DisplayName 
                                                            FROM OrgWideEmailAddress
                                                            WHERE Address = 'info@midwestmachinery.net'];
        if(!lstOrgWideEmailAddress.isEmpty()){
            fromAddressId = lstOrgWideEmailAddress[0].Id;
        }
        
        return fromAddressId;
    }
    
    global void execute(SchedulableContext ctx) {
        
        con = [SELECT id,pi__created_date__c from Contact where lastName = 'debug PM scheduleTp'];
        Datetime dt;
        if(con.pi__created_date__c == null) {
            dt = System.now();
        } else {
            dt = con.pi__created_date__c;
        }
        
        String todayDay = dt.format('EEEE');
        
        List<Project__c> lstProjects = [Select Id, Schedule_To__c, Schedule_End_Date__c, Schedule_On__c,
                                        Owner.Email,
                                        (Select Contact__c, User__c, Contact__r.Email, User__r.Email, Schedule_Type__c
                                        FROM Schedules__r)
                                        FROM Project__c
                                        WHERE Schedule_On__c =: todayDay
                                        AND Schedule_End_Date__c >= TODAY];
        
        String fromEmailAddressId = getOrgWideEmailAddressId();
        
        EmailTemplate et = [Select Id From EmailTemplate WHERE developerName =: 'Stage_Startup_and_Warranty'];
        
        List<Messaging.SingleEmailMessage> lstEmailToSend = new List<Messaging.SingleEmailMessage>();
                                                
        for(Project__c project : lstProjects) {
            List<Project_Schdule_To__c> lstScheduleTo = project.Schedules__r;
            lstEmailToSend.add(sendEmail(et.Id, project.Id, lstScheduleTo, 'nilesh.badrakia@gmail.com', fromEmailAddressId));
        }
        
        if(lstEmailToSend.size() > 0){
            Messaging.sendemailResult[] r = Messaging.sendemail(lstEmailToSend);
            List<PM_Tool_Send_Email_History__c> lstSendEmailFailHistory = new List<PM_Tool_Send_Email_History__c>();
            
            for(Messaging.sendemailResult result : r){
                if(!result.IsSuccess()){
                    for(Messaging.sendEmailError error : result.getErrors()){
                        PM_Tool_Send_Email_History__c history = new PM_Tool_Send_Email_History__c();
                        history.Error_Message__c = error.getMessage();
                        history.Schedule_To__c = error.getTargetObjectId();
                        lstSendEmailFailHistory.add(history);
                    }
                    
                    
                }
            }
            
            if(!lstSendEmailFailHistory.isEmpty()){
                insert lstSendEmailFailHistory;
            }
        }
        
        
    }
    
    global Messaging.SingleEmailMessage sendEmail(String emailTemplateId, String projectId, List<Project_Schdule_To__c> lstScheduleTo, string ccEmail, string fromEmailId){
        
        List<String> lstCCEmail = new List<String>();
        lstCCEmail.add('nilesh.badrakia@gmail.com');
        
        List<String> lstEmailsTo = new List<String>();
        lstEmailsTo.add('vadariasagar@gmail.com');

        
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        
        message.setTemplateID(emailTemplateId);
        message.setCcAddresses(lstCCEmail);
        message.setTargetObjectID(con.Id);
        message.setToAddresses(lstEmailsTo);
        message.setWhatId(projectId);
        message.setOrgWideEmailAddressId(fromEmailId);
        
        return message;
        
    }
    
}