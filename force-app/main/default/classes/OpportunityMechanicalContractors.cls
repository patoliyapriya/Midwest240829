public class OpportunityMechanicalContractors{
    
    public Id accountId{get;set;}
    public List<Opportunity> lstOpportunity{get;set;}
    
    public OpportunityMechanicalContractors(Apexpages.StandardController stdCon){
        accountId = stdCon.getId();
        getOpportunities();
    }
    
    public void getOpportunities(){
        
        List<Bidder_Detail__c> lstBidderDetails = [Select Id, Opportunity__c From Bidder_Detail__c 
                                                    WHERE (Mechanical_Contractor__c =: accountId
                                                    OR Bid_Contact__r.AccountId =: accountId)
                                                    AND (Won_Lost_Bidding__c = 'Won' OR Won_Lost_Bidding__c = 'Bidding')];
        
        Set<Id> setOpportunityIds = new Set<Id>();
            
        for(Bidder_Detail__c bd : lstBidderDetails){
            setOpportunityIds.add(bd.Opportunity__c);
        }    
        
        lstOpportunity = [Select Id, Name, StageName, Total_Base_Bid_Total_Quote__c, CloseDate From Opportunity Where Id IN: setOpportunityIds];
            
        
    }
    
}