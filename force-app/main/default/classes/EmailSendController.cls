public with sharing class EmailSendController {
    @AuraEnabled 
    public static void sendMailMethod(String toRecipient ,String Subject ,String body){
    
     List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();     
  
     // Step 1: Create a new Email
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    
    // Step 2: Set list of people who should get the email
       List<String> sendTo = new List<String>();
       sendTo.add(toRecipient);
       mail.setToAddresses(sendTo);
    
    // Step 3: Set who the email is sent from
       mail.setReplyTo('noreply@gmail.com'); // change it with your mail address.
       mail.setSenderDisplayName('salesforce User'); 
    
    // Step 4. Set email contents - you can use variables!
      mail.setSubject(Subject);
      mail.setHtmlBody(body);
    
    // Step 5. Add your email to the master list
      mails.add(mail);
    
  // Step 6: Send all emails in the master list
     //Messaging.sendEmail(mails);
   }   

    @AuraEnabled 
    public static void sendMail(Object emailWrapperString){
    
      system.debug('emailWrapper=>'+emailWrapperString);
      
      sendEmailWrapper wrapper = (sendEmailWrapper) JSON.deserialize(JSON.serialize(emailWrapperString), sendEmailWrapper.class);
     // sendEmailWrapper wrapper = (sendEmailWrapper) JSON.deserialize(emailWrapperString, sendEmailWrapper.class);
      system.debug('wrapper=>'+wrapper);
      List<String> sendTo = new List<String>();
     
      if(wrapper.contactIdList != null) {
        wrapper.targetObjectId = wrapper.contactIdList[0];
        List<Contact> contacts = [SELECT Id,Email From Contact WHERE Id IN :wrapper.contactIdList];
        for(Contact con :contacts) {
          if(con.Email != null) {
            sendTo.add(con.Email);
          }
          
        }
      }
      if(wrapper.toAddress != null && wrapper.toAddress != '') {
        sendTo.add(wrapper.toAddress);
      }
     List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();     
  
      // Step 1: Create a new Email
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    
      // Step 2: Set list of people who should get the email
      //mail.setToAddresses(sendTo);
    
      // Step 3: Set who the email is sent from
      mail.setReplyTo('noreply@gmail.com'); // change it with your mail address.
      //mail.setSenderDisplayName('salesforce User'); 
    
    // Step 4. Set email contents - you can use variables!
    //mail.setSubject(wrapper.Subject);
    mail.setTemplateId(wrapper.emailTemplateId);

    if(wrapper.projectId != null) {
      mail.setWhatId(wrapper.projectId);
    }
    
    if(wrapper.fromAddressId != null && wrapper.fromAddressId != '') {
      mail.setOrgWideEmailAddressId(wrapper.fromAddressId);
    }
    if(wrapper.targetObjectId != null) {
      mail.setTargetObjectID(wrapper.targetObjectId);
    }
    if(wrapper.ccAddress != null) {
      string[] ccEmail = wrapper.ccAddress.split(',', 0);
      mail.setCCAddresses(ccEmail);
    }
    if(wrapper.bccAddress != null && !(String.isEmpty(wrapper.bccAddress)) ) {
      string[] bccEmail = wrapper.bccAddress.split(',', 0);
      mail.setBccAddresses(bccEmail);
    }
    
    // Step 5. Add your email to the master list
    mails.add(mail);
    system.debug('emailSendcontroller=>'+mail);
    // Step 6: Send all emails in the master list
    Messaging.sendEmail(mails);
   }   

   @AuraEnabled(cacheable=true)
    public static String getPreviewURLForProject(Id projectId) {
      system.debug('projectId==>'+projectId);
      EmailTemplate et = [Select Id From EmailTemplate Where DeveloperName = 'Stage_Startup_and_Warranty'];  
      return getURLForEmailPreview(et.Id, projectId, null);
        
    }




    public static String getURLForEmailPreview(Id emialTemplateId, Id whatId, Id whoId) {
        String url = null;
        String baseUrl = null;
        Boolean isSandBox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        /*if(UserInfo.getOrganizationId() == '00D61000000dPHn') {
          isProduction = true;
        }*/

        if(isSandBox == false) {
          // baseUrl = 'https://midwest--c.na130.content.force.com'; //production  
          baseUrl = 'https://midwest.file.force.com';  
        } else {
          // baseUrl = 'https://midwest--Quoting--c.cs124.content.force.com';  //sandbox
          baseUrl = 'https://midwest--quoting.sandbox.file.force.com';   
        }
        url = baseUrl + '/email/templaterenderer?';
        url += 'id=' + emialTemplateId + '&';
        url += 'related_to_id=' + whatId + '&';
        url += 'base_href=' + baseUrl + '&preview_frame=contentFrame&render_type=REPLACED_HTML_BODY';
        system.debug('url==>>'+url);
        return url;
    }

    @AuraEnabled(cacheable=true)
    public static List<sendEmailWrapper> prepareEmailData(Id projectId) {
      sendEmailWrapper response = new sendEmailWrapper();
      Project__c project = [SELECT Name,
                                  PO_Number__c,
                                  OwnerId,
                                  Owner.Email,
                                  Opportunity__r.Project_Manager__r.Email,
                                  Opportunity__r.Opportunity_Number__c
                            FROM Project__c 
                            WHERE Id = :projectId];
      String subject = 'PO #' + project.PO_Number__c + ' - ' + project.Name +' - ' +project.Opportunity__r.Opportunity_Number__c;
      String ccEmail = project.Opportunity__r.Project_Manager__r.Email;
      response.Subject = subject;
      response.ccAddress = ccEmail;
      response.fromAddress = project.Owner.Email;
      response.fromAddressId = project.OwnerId;
      EmailTemplate et = [Select Id From EmailTemplate Where DeveloperName = 'Stage_Startup_and_Warranty'];  
      response.emailPreviewUrl =  getURLForEmailPreview(et.Id, projectId, null);
      response.emailTemplateId = et.Id;

      Boolean isDenverUser = checkIsDenverUser(project.OwnerId);
      for(OrgWideEmailAddress orgWideAdd :[SELECT Id, Address FROM OrgWideEmailAddress]) {
          if(isDenverUser == false && orgWideAdd.Address == 'info@midwestmachinery.net') {
            response.orgWideFromAddressId = orgWideAdd.Id;
            response.orgWideFromAddress = orgWideAdd.Address;
            break;
          } else if(isDenverUser && orgWideAdd.Address == 'info@engineeredproducts.com') {
            response.orgWideFromAddressId = orgWideAdd.Id;
            response.orgWideFromAddress = orgWideAdd.Address;
            break;
          }
      }

      List<sendEmailWrapper> responseList = new List<sendEmailWrapper>{response};
      return responseList;

        
    }

    public static Boolean checkIsDenverUser(Id userIdToCheck){
        
      for (GroupMember user : [Select Id, UserOrGroupId From GroupMember Where Group.Name = 'Engineered Products']){
          if(user.UserOrGroupId == userIdToCheck){ 
              return true;
          }
      }
      
      return false;
  }

    public class sendEmailWrapper {
      @AuraEnabled
      public String toAddress;
      @AuraEnabled
      public List<Id> contactIdList;
      @AuraEnabled
      public String ccAddress;
      @AuraEnabled
      public String bccAddress;
      @AuraEnabled
      public String Subject;
      @AuraEnabled
      public Id emailTemplateId;
      @AuraEnabled
      public String fromAddress;
      @AuraEnabled
      public String fromAddressId;
      @AuraEnabled
      public String orgWideFromAddress;
      @AuraEnabled
      public String orgWideFromAddressId;
      @AuraEnabled
      public String projectId;
      @AuraEnabled
      public String targetObjectId;
      @AuraEnabled
      public String emailPreviewUrl;
      public sendEmailWrapper() {
        toAddress = '';
        Subject = '';
        emailTemplateId = null;
        fromAddress = null;
        projectId = null;
        targetObjectId = null;
      }
  } 
}