/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 04-08-2024
 * @last modified by  : Nilesh Badrakiya
**/

public with sharing class OpportunityController {
   
    /**
    * @description : get quote list related to opportunity
    * @author Nilesh Badrakiya | 03-15-2024 
    * @param recordId
    **/
    @AuraEnabled(cacheable=true)
    public static List<Quote> getQuoteListByOpportunity(Id recordId) {
        List<Quote> quoteList = QuoteQueryHelper.getQuoteByOpportunityId(recordId);
        return quoteList;
    }

    /**
    * @description : Clone the opportunity based on opportunityId
    * @author Nilesh Badrakiya | 03-21-2024 
    * @param opportunityId
    **/
    @AuraEnabled
    public static Id cloneOpportunity(Id opportunityId, String opportunityName) {
        Opportunity opportunity = OpportunityQueryHelper.getOpportunityById(opportunityId);
        Opportunity cloneOpportunity = opportunity.clone(false, false, false, false);
        cloneOpportunity.Total_Base_Bid_Total_Quote__c = 0;
        cloneOpportunity.Total_Extended_Cost_Quote__c  = 0;
        cloneOpportunity.Total_Project_Margin__c = 0;
        cloneOpportunity.Sync_Quote__c = null;
        cloneOpportunity.Active_Financial_Quote__c = null;    
        cloneOpportunity.Name = opportunityName;
        cloneOpportunity.StageName = 'Bidding';
        Opportunity newOpportunity = OpportunityDomain.insertOpportunity(cloneOpportunity);
        cloneQuotes(opportunityId, newOpportunity.Id);
        return newOpportunity.Id;
    }

    /**
    * @description : Clone the quote based on opportunityId
    * @author Nilesh Badrakiya | 03-21-2024 
    * @param oldOpportunityId
    * @param newOpportunityId
    **/
    public static void cloneQuotes(Id oldOpportunityId,  Id newOpportunityId) {
        List<Quote> quoteList = getQuoteListByOpportunity(oldOpportunityId);

        Opportunity newOpportunity = OpportunityQueryHelper.getOpportunityById(newOpportunityId);

        for(Quote quote : quoteList) {
            Quote newQuoteToInsert = new Quote();
            newQuoteToInsert.Name = newOpportunity.Opportunity_Number__c + ' - ' + quote.Name; 
            newQuoteToInsert.OpportunityId = newOpportunityId;
            newQuoteToInsert.status = 'Draft';
            newQuoteToInsert.SubmittalDocumentVersion__c = 0;
            newQuoteToInsert.ScopeDocumentVersion__c = 0;
            newQuoteToInsert.QuoteDocumentVersion__c = 0;
            newQuoteToInsert.Scope_File_Name__c = null;
            newQuoteToInsert.Quote_FileName__c = null;
            Quote newQuote = QuoteDomain.insertRecord(newQuoteToInsert);

            cloneGroups(quote.Id, newQuote.Id);
        }
    }

    /**
    * @description : Clone the the groups based on quotes  
    * @author Nilesh Badrakiya | 03-21-2024 
    * @param OldQuoteId
    * @param newQuoteId
    **/
    public static void cloneGroups(Id OldQuoteId, Id newQuoteId){
        
        List<Product_Select__c> lstQuoteLineItems = QuoteLineItemQueryHelper.getLineItemsByQuoteId(OldQuoteId);
        
        List<Product_Select__c> lstQuoteLineItemsInsert = new List<Product_Select__c>();
        Set<Id> setChildProductGroupId = new Set<Id>();
        
        for(Product_Select__c qli : lstQuoteLineItems){
            Product_Select__c newQuoteLineItem = qli.clone(false,false,false,false);
            newQuoteLineItem.Quote__c = newQuoteId;
            setChildProductGroupId.add(qli.Product_Group__c);
            lstQuoteLineItemsInsert.add(newQuoteLineItem); 
        }

        List<Product_Group__c> lstProductGroups = GroupQueryHelper.getAllGroupsByQuoteId(OldQuoteId);

        List<Product_Group__c>  lstProductGroupsInsert = new List<Product_Group__c>();                                   
        
        for(Product_Group__c pg : lstProductGroups){
            Product_Group__c newProductGroup = pg.clone(false,false,false,false);
            newProductGroup.Quote__c = newQuoteId;
            newProductGroup.Cloned_From__c = pg.Id;
            lstProductGroupsInsert.add(newProductGroup);
        }
        
        insert lstProductGroupsInsert;
        
        Map<Id, Id> mapParentChildProductGroup = new Map<Id, Id>();
        
        for(Product_Group__c pg : lstProductGroupsInsert){
            mapParentChildProductGroup.put(pg.Cloned_From__c,pg.Id);
        }
        
        for(Product_Select__c qli : lstQuoteLineItemsInsert){
            qli.Product_Group__c = mapParentChildProductGroup.get(qli.Product_Group__c);
        }
        
        for(Product_Group__c pg : lstProductGroupsInsert){
            if(pg.Parent_Product_Group__c != null){
                pg.Parent_Product_Group__c = mapParentChildProductGroup.get(pg.Parent_Product_Group__c);
            }
        }
        
        List<Addition_Deduction__c> lstAddDeduct = [Select Id, Amount__c, Details__c, Type__c
                                            FROM Addition_Deduction__c
                                            WHERE Quote__c =: OldQuoteId];
        
        List<Addition_Deduction__c> lstInsertAddDeduct = new List<Addition_Deduction__c>();
        
        for(Addition_Deduction__c ad : lstAddDeduct){
            Addition_Deduction__c newAddDeduct = ad.clone(false,false,false,false);
            newAddDeduct.Quote__c = newQuoteId;
            lstInsertAddDeduct.add(newAddDeduct);
        }
        
        insert lstInsertAddDeduct;
        insert lstQuoteLineItemsInsert;
        update lstProductGroupsInsert;
    }
}