public with sharing class SyncQuoteBackToOpportunityController{
    
    public String quoteId{get;set;}
    public Quote quoteRecord{get;set;}
    
    public SyncQuoteBackToOpportunityController(Apexpages.StandardController stdCont){
        quoteId = stdCont.getId();
        quoteRecord = [Select Id,OpportunityId,Total_Base_Bid_Total__c,Total_Extended_Cost__c,Total_Project_Margin__c
                        FROM Quote
                        WHERE Id =: quoteId];
    }
    
    public PageReference syncBackToOpportunity(){
        
        List<Opportunity> lstOpportunity = [Select Id,Total_Base_Bid_Total_Quote__c,Total_Extended_Cost_Quote__c,Sync_Quote__c,Total_Project_Margin__c 
                                            From Opportunity
                                            WHERE Id =: quoteRecord.opportunityId];
                                            
        if(!lstOpportunity.isEmpty()){
            lstOpportunity[0].Total_Base_Bid_Total_Quote__c = quoteRecord.Total_Base_Bid_Total__c;
            lstOpportunity[0].Total_Extended_Cost_Quote__c = quoteRecord.Total_Extended_Cost__c;
            lstOpportunity[0].Total_Project_Margin__c = quoteRecord.Total_Project_Margin__c;
            lstOpportunity[0].Sync_Quote__c = quoteRecord.Id;
            
            update lstOpportunity[0];
        }
        
        PageReference pr = new PageReference('/'+quoteRecord.Id);
        pr.setRedirect(true);
        return pr;
        
    }
    
}