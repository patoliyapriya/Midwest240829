public with sharing class NewQuoteController{
    
    public Quote quote{get;set;}
    public String strOpportunityId{get;set;}
    public String opportunityNumber{get;set;}
    public Opportunity opportunity{get;set;}
    public Boolean hasSplitEngineer{get;set;} 
    public Boolean isMaRRsOpportunity {get;set;}
    public Boolean hasApplicationEngineer{get;set;} 
    
    public transient SavePoint sp{get;set;}
    
    public NewQuoteController(Apexpages.standardController stdCon){
    
        quote = new Quote();
                
        strOpportunityId = apexpages.currentpage().getparameters().get('oppid');
        
        hasSplitEngineer = getSplitEngineer();
        
        List<Opportunity> lstOpportunity = [Select Id, AccountId, End_User_Contact_Name__c,Consulting_Engineer__c,General_Contractor__c,
                                                                                Opportunity_Number__c, RecordType.Name, Shipping_Name__c,
                                            Bid_Date__c, Name, Attention_to__c,Sync_Quote__c,Application_Engineer__c
                                            FROM Opportunity
                                            WHERE Id =: strOpportunityId];
         
        if(lstOpportunity.size() > 0){
            opportunity = lstOpportunity[0];

            isMaRRsOpportunity = opportunity.RecordType.Name == 'MaRRS' ? true : false;
            
            if(opportunity.RecordType.Name == 'Equipment' && opportunity.Application_Engineer__c == null) {
                hasApplicationEngineer = false;
            } else {
                hasApplicationEngineer = true;
            }
            quote.General_Contractor__c = lstOpportunity[0].General_Contractor__c;
            quote.Consulting_Engineer__c = lstOpportunity[0].Consulting_Engineer__c;
            quote.opportunityId = strOpportunityId;
            quote.Attention_to_Account__c = lstOpportunity[0].AccountId;
            quote.Bidding_To__c = lstOpportunity[0].Attention_to__c;
            opportunityNumber = lstOpportunity[0].Opportunity_Number__c;
            quote.Name = lstOpportunity[0].Opportunity_Number__c + ' - ' + lstOpportunity[0].Name + ' - ' + system.now();
            if(lstOpportunity[0].RecordType.Name == 'MaRRS'){
                quote.ShippingName = lstOpportunity[0].Shipping_Name__c;
            }
        }
        
    }
    
    public PageReference updateQuote() {
        //UtilitySharePointToSFIntegration.isUpdateFromQuoteUI = true;
        if (quote != null && quote.Id != null) {
            system.debug('updated quote Name=>'+quote.Name);
            system.debug('updated quote sharepointName=>'+quote.Original_Name__c);
            quote.Original_Name__c = quote.Name;
            upsert quote;
            
            //Database.executeBatch(new createFolderForQuote(New Set<Id>{quote.Id}) );
            
        } 
        
        
        PageReference pr = new PageReference('/'+quote.Id);
        pr.setRedirect(true);
        return pr;
    }
        
    public PageReference SaveQuote(){
       
       if(quote.Id != null) {
           return null;
       }
        
       List<Quote> lstDuplicateNameQuote = [Select Id From Quote Where Name =: quote.Name];
        
        if(!lstDuplicateNameQuote.isEmpty()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Quote Name should be unique. There is quote exist with the same Name.'));
            return null;
        }
        
        String quoteRecordTypeName = opportunity.RecordType.Name + ' Quote';
        
        Id quoteRecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get(quoteRecordTypeName).getRecordTypeId();
        
        quote.RecordTypeId = quoteRecordTypeId;
        
        //SavePoint sp = Database.setSavepoint();
        UtilitySharePointToSFIntegration.quoteBulkInsertContext = true;
        system.debug('quote name before insert =>'+quote.Name);
        insert quote;
        
        if(opportunity.Sync_Quote__c == null){
                opportunity.Sync_Quote__c = quote.Id;
                update opportunity;
        }
        
        Quote updateQuote = [Select Id, QuoteNumber From Quote Where Id =: quote.Id];
        
        quote.Name = opportunity.Opportunity_Number__c + '.' + updateQuote.QuoteNumber + ' ' + opportunity.Name;
        
        //Database.rollback(sp);
        
        //quote = new Quote();
        //quote.General_Contractor__c = opportunity .General_Contractor__c;
        //quote.Consulting_Engineer__c = opportunity.Consulting_Engineer__c;
        //quote.opportunityId = strOpportunityId;
        //quote.Attention_to_Account__c = opportunity.AccountId;
        //quote.Bidding_To__c = opportunity.Attention_to__c;
        //opportunityNumber = opportunity.Opportunity_Number__c;
        //quote.Name = quoteName;
             
        return null;
    }
    
    public PageReference Cancel(){
        
        if (quote != null && quote.Id != null) {
            delete quote;
        }
        
        PageReference pr = new Pagereference('/' + strOpportunityId);
        pr.setRedirect(true);
        return pr;
    }
    
    public Boolean getSplitEngineer(){
        List<Sales_Representative__c> lstSalesRepresentative = [Select Id
                                                                                                                        FROM Sales_Representative__c
                                                                                                                        WHERE Opportunity__c =: strOpportunityId];
                
                if(!lstSalesRepresentative.isEmpty()){
                        return true;
                }
                
                return false;
    }
    
    
}