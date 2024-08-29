public with sharing class AddEditSalesEngineerSplitController{
    
    public Id opportunityId{get;set;}
    public List<Sales_Representative__c> lstSalesRep{get;set;}
    
    public String hidSalesRepId{get;set;}
    public Integer hidRowIndex{get;set;}
    
    public AddEditSalesEngineerSplitController(){
        
        opportunityId = Apexpages.currentPage().getParameters().get('oppId');
        
        lstSalesRep = [Select Id, Sales_Rep__c,Commision__c
                        FROM Sales_Representative__c
                        WHERE Opportunity__c =: opportunityId];
                        
        
    }
    
    public void addSalesEngineer(){
        lstSalesRep.add(new Sales_Representative__c(Opportunity__c = opportunityId));
    }
    
    public void deleteSalesEnginner(){
        if(hidSalesRepId != null && hidSalesRepId != ''){
            delete [Select Id From Sales_Representative__c WHERE Id =:hidSalesRepId];
        }
        lstSalesRep.remove(hidRowIndex - 1);
    }
    
    public PageReference redirectBackToOpportunity(){
        PageReference pr = new PageReference('/'+opportunityId);
        pr.setRedirect(true);
        return pr;
    }
    
    public PageReference Save(){
        upsert lstSalesRep;
        
        return redirectBackToOpportunity();
    }
    
}