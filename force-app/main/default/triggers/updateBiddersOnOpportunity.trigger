trigger updateBiddersOnOpportunity on Bidder_Detail__c (before insert, before update, after insert,after delete,after update) {
    
    if(!trigger.isDelete && trigger.new.size() > 1) return;
    
    if(trigger.isBefore){
        Id accountId = null;
        
        for(Bidder_Detail__c bd : trigger.new) {
            if(bd.Bid_Contact__c != null) {
                List<Contact> lstContacts = [Select AccountId 
                                            From Contact 
                                            Where Id =: bd.Bid_Contact__c];
                if(!lstContacts.isEmpty()) {
                    accountId = lstContacts[0].accountId;
                }
            } else if(bd.Mechanical_Contractor__c != null) {
                accountId = bd.Mechanical_Contractor__c;
            }
            
            if(accountId != null){
                List<Account> lstAccount = [Select Payment_and_Accounting_Notes__c FROM Account WHERE Id =: accountId];
                
                if(!lstAccount.isEmpty() && String.isNotBlank(lstAccount[0].Payment_and_Accounting_Notes__c)){
                    bd.hasNotes__c = true;
                } else {
                    bd.hasNotes__c = false;
                }
                
            } else {
                bd.hasNotes__c = false;
            }
        }
    } else {
        String strBiddersName = null;
        Boolean isWon = false;
        Id oppId = null;
        
        if(trigger.isInsert){
            for(Bidder_Detail__c bd : trigger.new){
                if(bd.Won_Lost_Bidding__c == 'Won' && bd.opportunity__c != null){
                    Id bidderAccountId = bd.Bid_Contact__r.AccountId != null ? bd.Bid_Contact__r.AccountId : bd.Mechanical_Contractor__c;
                    Opportunity opp = [Select Id, Bidders__c From Opportunity Where Id =: bd.opportunity__c];
                    Account bidderName = [Select Id, Name From Account Where Id =: bidderAccountId];
                    opp.Bidders__c = bidderName.Name;
                    opp.AccountId = bidderAccountId;
                    update opp;
                    
                    List<Bidder_Detail__c> lstBidders = [Select Id,Won_Lost_Bidding__c From Bidder_Detail__c Where Opportunity__c =: bd.opportunity__c And Id !=: bd.Id AND Won_Lost_Bidding__c != 'Lost'];
                    for(Bidder_Detail__c bda : lstBidders ){
                        bda.Won_Lost_Bidding__c = 'Lost';
                    }
                    update lstBidders;
                }
                else if((bd.Won_Lost_Bidding__c == 'Bidding' || bd.Won_Lost_Bidding__c == 'Quote Sent') && bd.Mechanical_Contractor__c != null && bd.opportunity__c != null){
                    List<Bidder_Detail__c> lstBidders = [Select Id From Bidder_Detail__c Where Opportunity__c =: bd.opportunity__c AND Won_Lost_Bidding__c = 'Won'];
                    if(lstBidders.size() > 0){
                        return;
                    }
                    Opportunity opp = [Select Id, Bidders__c From Opportunity Where Id =: bd.opportunity__c];
                    Account bidderName = [Select Id, Name From Account Where Id =: bd.Mechanical_Contractor__c];
                    
                    if(opp.Bidders__c != null && opp.Bidders__c != ''){
                        opp.Bidders__c = opp.Bidders__c + ',' + bidderName.Name;
                    }
                    else{
                        opp.Bidders__c = bidderName.Name;
                    }
                    update opp;
                }
            }
        }
        else if(trigger.isDelete){
            if(trigger.old.size() > 1){
                return;
            }
            
            Bidder_Detail__c bd = trigger.old[0];
            
            if((bd.Won_Lost_Bidding__c == 'Bidding' || bd.Won_Lost_Bidding__c == 'Quote Sent') && bd.Mechanical_Contractor__c != null && bd.opportunity__c != null){
                Opportunity opp = [Select Id, Bidders__c From Opportunity Where Id =: bd.opportunity__c];
                Account bidderName = [Select Id, Name From Account Where Id =: bd.Mechanical_Contractor__c];
                
                if(opp.Bidders__c.contains(',' + bidderName.Name)){
                    opp.Bidders__c = opp.Bidders__c.replace(',' + bidderName.Name,'');
                }
                else if(opp.Bidders__c.contains(',')){
                    opp.Bidders__c = opp.Bidders__c.replace(bidderName.Name + ',','');
                }
                else{
                    opp.Bidders__c = opp.Bidders__c.replace(bidderName.Name,'');
                }
                update opp;
            }
            else if(bd.Won_Lost_Bidding__c == 'Won' && bd.opportunity__c != null && bd.Mechanical_Contractor__c != null){
                // error message should be there, you should not able to delete this.
            }
        }
        else if(trigger.isUpdate){
            for(Bidder_Detail__c bd : trigger.new){
                if(bd.Won_Lost_Bidding__c == 'Won' && bd.opportunity__c != null){
                    List<Bidder_Detail__c> lstBidder = [Select Id,Bid_Contact__r.AccountId 
                                                            FROM Bidder_Detail__c
                                                            WHERE Id =: bd.Id];

                    Id bidderAccountId = lstBidder[0].Bid_Contact__r.AccountId != null ? lstBidder[0].Bid_Contact__r.AccountId : bd.Mechanical_Contractor__c;
                    Opportunity opp = [Select Id, Bidders__c From Opportunity Where Id =: bd.opportunity__c];
                    Account bidderName = [Select Id, Name From Account Where Id =: bidderAccountId];
                    opp.Bidders__c = bidderName.Name;
                    opp.AccountId = bidderAccountId;
                    update opp; 
                    
                    if(trigger.oldmap.get(bd.Id).Won_Lost_Bidding__c != bd.Won_Lost_Bidding__c){
                        List<Bidder_Detail__c> lstBidders = [Select Id,Won_Lost_Bidding__c From Bidder_Detail__c 
                                                            Where Opportunity__c =: bd.opportunity__c 
                                                            AND Won_Lost_Bidding__c != 'Lost'
                                                            AND Id !=: bd.Id];
                        for(Bidder_Detail__c bda : lstBidders ){
                            bda.Won_Lost_Bidding__c = 'Lost';
                        }
                        update lstBidders;
                    }
                }
                else if((bd.Won_Lost_Bidding__c == 'Bidding' || bd.Won_Lost_Bidding__c == 'Quote Sent') && bd.Mechanical_Contractor__c != null && bd.opportunity__c != null){
                    List<Bidder_Detail__c> lstBidders = [Select Id From Bidder_Detail__c Where Opportunity__c =: bd.opportunity__c AND Won_Lost_Bidding__c = 'Won' AND Id !=:bd.Id];
                    if(lstBidders.size() > 0){
                        return;
                    }
                    if(trigger.oldmap.get(bd.Id).Won_Lost_Bidding__c != bd.Won_Lost_Bidding__c &&
                        (trigger.oldmap.get(bd.Id).Won_Lost_Bidding__c == 'Not Bidding' || trigger.oldmap.get(bd.Id).Won_Lost_Bidding__c == 'Lost')){
                        Opportunity opp = [Select Id, Bidders__c From Opportunity Where Id =: bd.opportunity__c];
                        Account bidderName = [Select Id, Name From Account Where Id =: bd.Mechanical_Contractor__c];
                        
                        if(opp.Bidders__c == '' || opp.Bidders__c == null){
                            opp.Bidders__c = bidderName.Name;
                        }
                        else{
                            opp.Bidders__c = opp.Bidders__c + ',' + bidderName.Name;
                        }
                        update opp;
                    }
                    else if(trigger.oldmap.get(bd.Id).Won_Lost_Bidding__c == 'Won' && (bd.Won_Lost_Bidding__c == 'Bidding' || bd.Won_Lost_Bidding__c == 'Quote Sent')){
                        Opportunity opp = [Select Id, Bidders__c From Opportunity Where Id =: bd.opportunity__c];
                        Account bidderName = [Select Id, Name From Account Where Id =: bd.Mechanical_Contractor__c];
                        
                        opp.Bidders__c = bidderName.Name;
                        update opp;
                    }
                }
                else if((bd.Won_Lost_Bidding__c == 'Not Bidding' || bd.Won_Lost_Bidding__c == 'Lost') && bd.Mechanical_Contractor__c != null && bd.opportunity__c != null
                    && (trigger.oldmap.get(bd.Id).Won_Lost_Bidding__c == 'Bidding' || trigger.oldmap.get(bd.Id).Won_Lost_Bidding__c == 'Won' || trigger.oldmap.get(bd.Id).Won_Lost_Bidding__c == 'Quote Sent')){
                    Opportunity opp = [Select Id, Bidders__c From Opportunity Where Id =: bd.opportunity__c];
                    Account bidderName = [Select Id, Name From Account Where Id =: bd.Mechanical_Contractor__c];
                    
                    if(opp.Bidders__c != '' && opp.Bidders__c != null && opp.Bidders__c.contains(',' + bidderName.Name)){
                        opp.Bidders__c = opp.Bidders__c.replace(',' + bidderName.Name,'');
                    }
                    else if(opp.Bidders__c != '' && opp.Bidders__c != null && opp.Bidders__c.contains(',')){
                        opp.Bidders__c = opp.Bidders__c.replace(bidderName.Name + ',','');
                    }
                    else if(opp.Bidders__c != '' && opp.Bidders__c != null){
                        opp.Bidders__c = opp.Bidders__c.replace(bidderName.Name,'');
                    }
                    update opp;
                }
            }
        }
    }
    
    
    
}