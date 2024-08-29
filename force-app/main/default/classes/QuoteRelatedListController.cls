public with sharing class QuoteRelatedListController{
    
    public List<Quote> lstQuote{get;set;}
    public String syncQuoteId{get;set;}
    public String oppId{get;set;}
    public Id deleteQuoteId{get;set;}
    
    public QuoteRelatedListController(Apexpages.standardController stdController){
        oppId = stdController.getId();
        
        lstQuote = [Select Id, Name, QuoteNumber, Is_Locked__c, Total_Base_Bid_Total__c, Total_Project_Margin__c,
                    Total_Project_Margin_Percentage__c 
                    From Quote
                    WHERE opportunityId =: oppId
                    ORDER BY createdDate DESC];
       
    }
    
    public void deleteQuote(){
        Quote toBeDeleteQuote = [Select Id, Is_Active_Project_Financials__c From Quote Where Id =: deleteQuoteId];
        Id profileId = UserInfo.getProfileId();
        String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
        system.debug('Profile Name'+profileName);
        if(profileName != 'System Administrator' && toBeDeleteQuote.Is_Active_Project_Financials__c == true) {
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'You cannot delete the Active Project Financials Quote'));
        } else {
            delete toBeDeleteQuote;
        }
    }
    
    public pageReference newQuote(){
        // PageReference pr = new PageReference('/apex/NewQuote?retURL='+ oppId + '&cancelURL=' + oppId + '&oppId=' + oppId);
        PageReference pr = new PageReference('/one/one.app?retURL='+ oppId + '&cancelURL=' + oppId + '&oppId=' + oppId + '#eyJjb21wb25lbnREZWYiOiJjOm5ld1F1b3RlIiwiYXR0cmlidXRlcyI6e319');
        return pr;
    }
    
    //public void makeQuotePrimaryAndSync(){}
    
    public void syncBackToOpportunity(){
        system.debug('##--'+syncQuoteId);
        if(syncQuoteId != null && syncQuoteId != ''){
            system.debug('##--'+syncQuoteId);
            Quote quoteRecord = [Select Id,OpportunityId,Total_Base_Bid_Total__c,Total_Extended_Cost__c,Total_Project_Margin__c
                                    FROM Quote
                                    WHERE Id =: syncQuoteId];
            
            List<Opportunity> lstOpportunity = [Select Id,Total_Base_Bid_Total_Quote__c,Total_Extended_Cost_Quote__c,Sync_Quote__c,Total_Project_Margin__c 
                                            From Opportunity
                                            WHERE Id =: quoteRecord.opportunityId];
                                            
            if(!lstOpportunity.isEmpty()){
                lstOpportunity[0].Total_Base_Bid_Total_Quote__c = quoteRecord.Total_Base_Bid_Total__c;
                lstOpportunity[0].Total_Extended_Cost_Quote__c = quoteRecord.Total_Extended_Cost__c;
                lstOpportunity[0].Total_Project_Margin__c = quoteRecord.Total_Project_Margin__c;
                lstOpportunity[0].Sync_Quote__c = syncQuoteId;
                
                update lstOpportunity[0];
                                                
            }
            
            
        }
        
    }
    
}