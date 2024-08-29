public class OpportunityListOnContact{
    
    public List<Opportunity> lstOpportunity{get;set;}
    public String contactId{get;set;}
    
    public OpportunityListOnContact(Apexpages.StandardController stdCon){
        contactId = stdCon.getId();
        getOpportunities();
    }
    
    public void getOpportunities(){
        
        List<Bidder_Detail__c> lstBidderDetails = [Select Id, Opportunity__c From Bidder_Detail__c WHERE Bid_Contact__c =: contactId ];
        
        Set<Id> setOpportunityIds = new Set<Id>();
            
        for(Bidder_Detail__c bd : lstBidderDetails){
            setOpportunityIds.add(bd.Opportunity__c);
        }    
        
        lstOpportunity = [Select Id, Name, StageName, Total_Base_Bid_Total_Quote__c, CloseDate From Opportunity Where Id IN: setOpportunityIds];
            
        
    }
    
    
}