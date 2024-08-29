trigger quoteTrigger on Quote (after insert,before Insert,before Update,after update,before delete) {
       
      /*if (Trigger.isAfter && Trigger.isUpdate) {
          system.debug('new quoteId'+trigger.New[0].id);
          system.debug('isNewQuote = '+UtilitySharePointToSFIntegration.isNewQuote);
          if(UtilitySharePointToSFIntegration.isNewQuote) {
              Database.executeBatch(new createFolderForQuote(New Set<Id>{trigger.New[0].id} ));    
          }
      }*/ 
      
      if (Trigger.isBefore && Trigger.isInsert) {
          
          for (Quote eachQuote : Trigger.New) {
              
              system.debug('quote Name inside quoteTrigger>>'+eachQuote.Name);
              eachQuote.Original_Name__c = eachQuote.Name;
              
          }
      }
      
      if (Trigger.isUpdate) {
         

         for (Quote eachQuote : Trigger.New) {
              
              if (eachQuote.Original_Name__c != null && eachQuote.CreatedDate >= UtilitySharePointToSFIntegration.deploymentDate ) {
                  
                  if (Trigger.oldMap.get(eachQuote.Id).Original_Name__c != Trigger.oldMap.get(eachQuote.Id).Original_Name__c) {
                      
                      eachQuote.Original_Name__c.addError('Original name can not be updated');
 
                  }
              }
              
          } 
      }
       
      if(Trigger.isBefore && Trigger.isDelete){
        for (Quote toBeDeleteQuote : Trigger.old) {
            system.debug('before delete trigger');
            Id profileId = UserInfo.getProfileId();
            String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
            system.debug('Profile Name'+profileName);
            
            If(profileName != 'System Administrator' && toBeDeleteQuote.Is_Active_Project_Financials__c == true){
                toBeDeleteQuote.addError('Please contact admin to delete the Active Project Financials Quote');
            }
        }
    }
               
    
}