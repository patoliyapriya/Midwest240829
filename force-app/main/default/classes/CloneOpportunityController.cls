public class CloneOpportunityController {



    
    public Id opportunityId {get;set;}
    public static boolean bulkQuoteInsert = true;
    public Opportunity opp {get;set;}
    public List<wrapperQuoteList> wrapQuoteList {get; set;}
    public Boolean showQuote{get;set;}
    public Set<Id> selectedQuoteIds = new set<Id>();
    public Boolean quotesNotAvailable {get;set;}
    
    public CloneOpportunityController(ApexPages.StandardController controller) {
        showQuote = false;
        opportunityId = ApexPages.currentPage().getParameters().get('Id');
        opp = getOpportunity(opportunityId); 
        wrapQuoteList = getQuoteList(opportunityId);

    }
    
    public CloneOpportunityController(){
        /*showQuote = false;
        opportunityId = ApexPages.currentPage().getParameters().get('Id');
        opp = getOpportunity(opportunityId); 
        wrapQuoteList = getQuoteList(opportunityId);*/
    }
    public void showQuote() {
        showQuote = true;
        system.debug('size@@='+wrapQuoteList); 
        if(wrapQuoteList != null && wrapQuoteList.size() > 0) {
            for(wrapperQuoteList wrap : wrapQuoteList) {
                wrap.newQuote.Name = opp.Name;
            }   
        } else {
            quotesNotAvailable = true;
        }
    }
    public void hideQuote() {
        showQuote = false;
    }
    public PageReference cloneOpportunityWithChildObjects(){
        selectedQuoteIds = new Set<Id>();
        Id newOpportunityId = cloneOpportunity();
        
        PageReference pr = new PageReference('/'+newOpportunityId);
        pr.setRedirect(true);
        return pr;
    }
    
    public Id cloneOpportunity(){
         
        Opportunity cloneOpportunity = opp.clone(false, false, false, false);
        cloneOpportunity.Total_Base_Bid_Total_Quote__c = 0;
        cloneOpportunity.Total_Extended_Cost_Quote__c  = 0;
        cloneOpportunity.Total_Project_Margin__c = 0;
        cloneOpportunity.Sync_Quote__c = null;
        cloneOpportunity.Active_Financial_Quote__c = null;    
        cloneOpportunity.Name = cloneOpportunity.Name;
        cloneOpportunity.StageName = 'Bidding';
        //UtilitySharePointToSFIntegration.quoteBulkInsertContext = true;
        insert cloneOpportunity;
        
        cloneQuotes(cloneOpportunity.Id);
        
        return cloneOpportunity.Id;
    }
    
    public void cloneQuotes(Id newOpportunityId){
        //List<Quote> lstQuote = getQuotes();
        Opportunity newOpportunity = [SELECT Id,
                                            Opportunity_Number__c 
                                            FROM Opportunity WHERE Id = :newOpportunityId];
        List<Quote> lstQuote = new List<Quote>();  
        system.debug(wrapQuoteList);
        if(wrapQuoteList != null && wrapQuoteList.size() > 0) {
            for(wrapperQuoteList quoteWrap : wrapQuoteList) {
                
                if (quoteWrap!= null && quoteWrap.isSelected && quoteWrap.newQuote != null) {
                    Quote newQuoteToInsert = quoteWrap.newQuote;
                    newQuoteToInsert.Name = newOpportunity.Opportunity_Number__c + ' - ' + newQuoteToInsert.Name; 
                    newQuoteToInsert.OpportunityId = newOpportunity.Id;
                    newQuoteToInsert.status = 'Draft';
                    newQuoteToInsert.SubmittalDocumentVersion__c = 0;
                    newQuoteToInsert.ScopeDocumentVersion__c = 0;
                    newQuoteToInsert.QuoteDocumentVersion__c = 0;
                    newQuoteToInsert.Scope_File_Name__c = null;
                    newQuoteToInsert.Quote_FileName__c = null;
                    
                    insert newQuoteToInsert;
                    cloneGroups(quoteWrap.oldQuote.Id, newQuoteToInsert.Id);
                }
            }       
        }

        /*for(Quote q : lstQuote){
            Quote newQuote = q.clone(false, false, false, false);
            newQuote.Name = newQuote.Name + ' Clone';
            newQuote.OpportunityId = newOpportunityId;
            newQuote.status = 'Draft';
            insert newQuote;
            
            cloneGroups(q.Id, newQuote.Id);
        }*/

        
        //Database.executeBatch(new createfolderForOpportunity(newOpportunityId) );    
    }
    
    public void cloneGroups(Id OldQuoteId, Id newQuoteId){
        
        List<Product_Select__c> lstQuoteLineItems = [SELECT Descriptions__c,Family__c,Freight__c,List_Price__c,
                                                        Margin_Percentage__c,Multiplier__c,Original_Product_Name__c,
                                                        Product_Code__c,Product_Group__c,Product_Name__c,
                                                        Quantity__c,Quote__c,Sales_Price__c,Total_Price__c,T_LBS__c,LBS__c,Tag__c,Extended_Cost__c,                                                               
                                                        Hide_Pricing__c,Hide_Line__c,Unit_Cost__c,Hide_Code__c,Row_Index__c,Page_Break__c,Is_Freight_Override__c,
                                                        Sale_Type__c,Manufacturer__c,Release_pick__c,CR__c ,ProductId__c      
                                                        FROM Product_Select__c
                                                        WHERE Quote__c =: OldQuoteId];
        
        List<Product_Select__c> lstQuoteLineItemsInsert = new List<Product_Select__c>();
        Set<Id> setChildProductGroupId = new Set<Id>();
        
        for(Product_Select__c qli : lstQuoteLineItems){
            Product_Select__c newQuoteLineItem = qli.clone(false,false,false,false);
            newQuoteLineItem.Quote__c = newQuoteId;
            setChildProductGroupId.add(qli.Product_Group__c);
            lstQuoteLineItemsInsert.add(newQuoteLineItem);
        }
        
        List<Product_Group__c> lstProductGroups = [Select Id,Name, Parent_Product_Group__r.Name, Parent_Product_Group__c,Total_Line_Items__c,Total_Sub_Groups__c,
                                                     Hide_Pricing__c,Total_Extended_Cost__c,Hide_Base_Bid_Total__c,Total_Group_Extended_Cost__c, Index__c,
                                                     Hide_Code__c, Hide_Amount__c, Hide_Line__c,Quantity_Total__c,Total_Group_Freight__c,Total_Freight__c,Hide_Quantity__c,
                                                     Release_Number__c,Grand_Quantity_Total__c,Page_Break__c
                                                     FROM Product_Group__c
                                                     WHERE Quote__c =: OldQuoteId];

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
    
    public List<Quote> getQuotes(){
        
        String qryString = buildQuery('Quote','OpportunityId' ,opportunityId);
        
        List<Quote> lstQuote = Database.query(qryString);
        
        return lstQuote;
    }
    
    public Opportunity getOpportunity(Id oppId){
        String qryString = buildQuery('Opportunity','Id' ,opportunityId);
        
        Opportunity opp = Database.query(qryString);
        
        return opp;
    }
    
     public String buildQuery(String selectedObject, String whereField, Id selectedObjectId){
        
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe(); 
        Map <String, Schema.SObjectField> a_fields = schemaMap.get(selectedObject).getDescribe().fields.getMap(); 
         
        String expr = '';
        
        for(Schema.sObjectField fld:a_fields.values()){
            if(expr == ''){
                expr += fld;
            }
            else{
                expr += ', ' + fld ;
            }
            
        }
        
        String qry = 'Select ' + expr + ' from ' + selectedObject + ' WHERE ' + whereField + '=' + '\''  + selectedObjectId + '\'' ;
        if (selectedObject == 'Quote' && selectedQuoteIds.size() > 0) {
            set<Id> quoteIds = new set<Id>();
            
            for(wrapperQuoteList wrapQuote : wrapQuoteList) {
                if(wrapQuote.isSelected) {
                    quoteIds.add(wrapQuote.oldQuote.Id);    
                }
            }
            qry += ' AND OpportunityId IN :selectedQuoteIds'; 
        }
        return qry;
    }
    
    public List<wrapperQuoteList> getQuoteList(Id opportunityId) {
        List<wrapperQuoteList> quoteList = new List<wrapperQuoteList>();
        List<Quote> lstQuote = getQuotes();
        for(Quote quote : lstQuote) {
            quoteList.add(new wrapperQuoteList(quote));                     
        }
        if(!quoteList.isEmpty()) {
            return quoteList;   
        }
        
        return null;
    }
    
    public PageReference doCancel() {
        PageReference pr = new PageReference('/'+opportunityId);
        pr.setRedirect(true);
        return pr;      
    }
    public class wrapperQuoteList {
        public Boolean isSelected {get;set;}
        public Quote oldQuote {get;set;}
        public Quote newQuote {get;set;}
        public wrapperQuoteList(Quote q) {
            oldQuote = q;
            newQuote = q.clone(false, false, false, false);
            isSelected = true;  
        }
    
    } 
    
}