trigger SyncAddress on Account (after update) {
    
    List<Contact> lstContactUpdate = new List<Contact>();
    
    List<Contact> lstContact = [Select Id, Sync__c,MailingCity, MailingState, MailingCountry,MailingPostalCode,MailingStreet ,AccountId
                                     FROM Contact
                                     WHERE Sync__c = true AND
                                     AccountId =: trigger.newMap.keySet()];
    
    for(Contact cont : lstContact){
        Account acc = trigger.newMap.get(cont.AccountId);
        cont.MailingCity = acc.BillingCity;
        cont.MailingState = acc.BillingState;
        cont.MailingCountry = acc.BillingCountry;
        cont.MailingStreet = acc.BillingStreet;
        cont.MailingPostalCode = acc.BillingPostalCode;
        lstContactUpdate.add(cont);
    }
    
    if(lstContactUpdate.size() > 0){
        update lstContactUpdate;
    }
    
    if(trigger.new.size() > 1) {
        return;
    } else {
        if(trigger.new[0].Payment_and_Accounting_Notes__c != trigger.old[0].Payment_and_Accounting_Notes__c) {
        
            List<Bidder_Detail__c> lstBidders = [Select Id, hasNotes__c, Bid_Contact__r.AccountId, Mechanical_Contractor__c,Bid_Contact__r.Account.Payment_and_Accounting_Notes__c,
                                                Mechanical_Contractor__r.Payment_and_Accounting_Notes__c
                                                FROM Bidder_Detail__c
                                                WHERE Bid_Contact__r.AccountId =: trigger.new[0].Id
                                                OR Mechanical_Contractor__c =: trigger.new[0].Id];
                                                
            for(Bidder_Detail__c bd : lstBidders) {
                if(bd.Bid_Contact__r.AccountId != null) {
                    bd.hasNotes__c = String.isNotBlank(bd.Bid_Contact__r.Account.Payment_and_Accounting_Notes__c) ? true : false; 
                } else if(bd.Mechanical_Contractor__c != null) {
                    bd.hasNotes__c = String.isNotBlank(bd.Mechanical_Contractor__r.Payment_and_Accounting_Notes__c) ? true : false;
                } else {
                    bd.hasNotes__c = false; 
                }
            }
            
            if(!lstBidders.isEmpty()) {
                update lstBidders;
            }
            
            List<Opportunity> lstOpportunity = [Select Id, Credit_Notes__c
                                                FROM Opportunity
                                                WHERE AccountId =: trigger.new[0].Id
                                                AND RecordType.Name = 'Equipment'];
        
            for(Opportunity opp : lstOpportunity){
                opp.Credit_Notes__c = trigger.new[0].Payment_and_Accounting_Notes__c;
            }
            
            if(!lstOpportunity.isEmpty()) { 
                update lstOpportunity; 
            }
        }
        
        
    }
    
    
}