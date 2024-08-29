public class OpportunityEndUser{
    
    public Id accountId{get;set;}
    public List<Opportunity> lstOpportunity{get;set;}
    
    public OpportunityEndUser(Apexpages.StandardController stdCon){
        accountId = stdCon.getId();
        getOpportunities();
    }
    
    public void getOpportunities(){
        
        lstOpportunity = [Select Id, Name, StageName, Total_Base_Bid_Total_Quote__c, CloseDate From Opportunity Where End_User__c =: accountId];
            
        
    }
    
}