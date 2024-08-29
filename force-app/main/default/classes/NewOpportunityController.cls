public with sharing class NewOpportunityController{
    
    public Id generalContractorContactId {get; set;}
    public Opportunity opp {get;set;}

    public NewOpportunityController(Apexpages.StandardController stdCon){
        opp = new Opportunity();
        opp.recordTypeId = apexpages.currentpage().getparameters().get('RecordType');
        
        if(opp.recordTypeId == null) {
            opp.recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('MaRRS').getRecordTypeId();
        }
        system.debug('Opportunity=>'+opp);
    }
    
    public void populateGeneralContractorAccount(){
        Contact con = [Select accountId From contact Where Id =: generalContractorContactId];
        opp.General_Contractor__c = con.accountId;
    }
     
    public PageReference saveOpportunity(){
        
        insert opp;
        
        PageReference pr = new PageReference('/'+ opp.Id);
        pr.setRedirect(true);
        return pr;
    } 
        
}