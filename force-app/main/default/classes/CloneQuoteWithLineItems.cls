public with sharing class CloneQuoteWithLineItems{

    public Id quoteId{get;set;}
    public Quote oldQuote{get;set;}
    public Quote newQuote{get;set;}
    
    public CloneQuoteWithLineItems(ApexPages.StandardController controller) {
        quoteId = apexpages.currentpage().getparameters().get('id');
        oldQuote = database.query(getQuoteQuery());
        
    }
    
    public PageReference saveQuote() {
        system.debug('inside save method');
        UtilitySharePointToSFIntegration.quoteBulkInsertContext = true;
        newQuote = new Quote();
        newQuote = oldQuote.clone(false, false, false, false);
        newQuote.status = 'Draft';
        newQuote.Is_Locked__c = false;
        newQuote.Original_Name__c = newQuote.Name;
        newQuote.SubmittalDocumentVersion__c = 0;
        newQuote.ScopeDocumentVersion__c = 0;
        newQuote.QuoteDocumentVersion__c = 0;
        newQuote.Scope_File_Name__c = null;
        newQuote.Quote_FileName__c = null;
        insert newQuote;
        
        Quote newlyCreatedQuote = [select 
                                    Opportunity_Number__c,
                                    QuoteNumber,
                                    Opportunity_Name__c
                                    FROM 
                                    Quote where Id = :newQuote.Id];
        newQuote.Name = newlyCreatedQuote.Opportunity_Number__c+ '.' + newlyCreatedQuote.QuoteNumber + ' ' + newlyCreatedQuote.Opportunity_Name__c;
        
        //newQuote.Name = oldQuote.Name;
        system.debug('name of new quote>>'+ newQuote.Name);
        
        return null;
    }
    
    public PageReference cloneQuote(){
        
        /*Quote newQuote = oldQuote.clone(false, false, false, false);
        newQuote.status = 'Draft';
        newQuote.Is_Locked__c = false;
        newQuote.Original_Name__c = oldQuote.Name;
        newQuote.SubmittalDocumentVersion__c = 0;
        newQuote.ScopeDocumentVersion__c = 0;
        newQuote.QuoteDocumentVersion__c = 0;
        newQuote.Scope_File_Name__c = null;
        newQuote.Quote_FileName__c = null;
        insert newQuote;*/
        if(newQuote != null && newQuote.Id != null) {
            newQuote.Original_Name__c = newQuote.Name;
            update newQuote;
            //Database.executeBatch(new createFolderForQuote(New Set<Id>{newQuote.Id}) );
        }
        cloneGroups(newQuote.Id);
        
        PageReference pr = new PageReference('/'+newQuote.Id);
        pr.setRedirect(true);
        return pr;
    
    }
    
    public void cloneGroups(Id newQuoteId){
        
        List<Product_Select__c> lstQuoteLineItems = [SELECT Descriptions__c,Family__c,Freight__c,List_Price__c,
                                                        Margin_Percentage__c,Multiplier__c,Original_Product_Name__c,
                                                        Product_Code__c,Product_Group__c,Product_Name__c,
                                                        Quantity__c,Quote__c,Sales_Price__c,Total_Price__c,T_LBS__c,LBS__c,Tag__c,Extended_Cost__c,                                                               
                                                        Hide_Pricing__c,Hide_Line__c,Unit_Cost__c,Hide_Code__c,Row_Index__c,Page_Break__c,Is_Freight_Override__c,
                                                        Sale_Type__c,Manufacturer__c,Release_pick__c,CR__c,ProductId__c       
                                                        FROM Product_Select__c
                                                        WHERE Quote__c =: quoteId];
        
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
                                                     WHERE Quote__c =: quoteId];

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
                                            WHERE Quote__c =: quoteId];
        
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
    
    public String getQuoteQuery(){
        
        String expr = '';
        
        Schema.DescribeSObjectResult a_desc = Quote.sObjectType.getDescribe();
        Map<String, Schema.SObjectField> a_fields = a_desc.fields.getMap();
        
        for(Schema.sObjectField fld:a_fields.values()){
            Schema.DescribeFieldResult fieldResult = fld.getDescribe(); 
            if(fieldResult.getName() == 'LastViewedDate' || fieldResult.getName() == 'LastReferencedDate') {
                Continue;
            }
            if(expr == ''){
                expr += fld;
            }
            else{
                expr += ', ' + fld ;
            }
            
        }
        expr += ', opportunity.Bid_Date__c';
        String qry = 'Select ' + expr + ' from Quote WHERE Id =' + '\''  + quoteId + '\'' ;
        system.debug(qry +'== query String');
        return qry;
    }
    public PageReference Cancel(){
        
        if (newQuote != null && newQuote.Id != null) {
            delete newQuote;
        }
        
        PageReference pr = new Pagereference('/' + quoteId);
        pr.setRedirect(true);
        return pr;
    }
    






    



    // Lightning Page 

 @AuraEnabled(cacheable=true)  
 public static Quote fetchquoteDetails(Id quoteId){
     
     // Quote quotedetails = [SELECT       Bid_Date__c,
     //                                    Opportunity_Close_Date__c,
     //                                    Opportunity_Name__c,
     //                                    Opportunity_Number__c,
     //                                    Submitted_By__c,
     //                                    prepared_by_user__c,
     //                                    Bidding_To__c,
     //                                    QuoteNumber
     //                             FROM   Quote 
     //                             WHERE Id = :quoteId];
    Quote quotedetails = QuoteQueryHelper.getQuoteById(quoteId);
         return quotedetails;
 }
 
 @AuraEnabled
 public static Quote newQuoteName(Id quoteId){
 
    Quote oldQuote = database.query(getQuotesQuery(quoteId));
     UtilitySharePointToSFIntegration.quoteBulkInsertContext = true;
     Quote newQuote = new Quote();
     newQuote = oldQuote.clone(false, false, false, false);
     System.debug('newquote = ' + newQuote);
 
     newQuote.status = 'Draft';
     newQuote.Is_Locked__c = false;
     newQuote.Original_Name__c = newQuote.Name;
     newQuote.SubmittalDocumentVersion__c = 0;
     newQuote.ScopeDocumentVersion__c = 0;
     newQuote.QuoteDocumentVersion__c = 0;
     newQuote.Scope_File_Name__c = null;
     newQuote.Quote_FileName__c = null;
 
     //insert newQuote;
      QuoteDomain.insertQuoteRecord(newQuote);
 
     System.debug('newquote ==' + newQuote);
         // Quote newlyCreatedQuote = [SELECT 
         //                                     Opportunity_Number__c,
         //                                     QuoteNumber,
         //                                     Opportunity_Name__c
         //                                     FROM 
         //                                     Quote where Id = :newQuote.Id];
         Quote newlyCreatedQuote = QuoteQueryHelper.getQuoteById(newQuote.Id);
 
   
   newQuote.Name = newlyCreatedQuote.Opportunity_Number__c+ '.' + newlyCreatedQuote.QuoteNumber + ' ' + newlyCreatedQuote.Opportunity_Name__c;
    System.debug('newquotename ==' +  newQuote.Name );
       return newQuote;
     
 }
 
 @AuraEnabled
 public static void CancelFunction(Id newquoteId){
 
          //Quote newQuote = [SELECT Id FROM Quote WHERE Id = :newquoteId];
         Quote newQuote = QuoteQueryHelper.getQuoteById(newquoteId);
 
     if (newQuote != null && newQuote.Id != null) {
         System.debug('delete');
         //delete newQuote;
         QuoteDomain.deleteRecord(newQuote);
     }
 }
 
 @AuraEnabled
 public static Id cloneQuotes(String newQuoteDetail , Id newquoteId , Id oldquoteId){
     Id quoteId = oldquoteId;
     Quote newQuote =  (Quote)JSON.deserialize(newQuoteDetail , Quote.class);
     System.debug('newdetail = ' +newQuote );
     newQuote.Id = newquoteId;
     if(newQuote != null && newQuote.Id != null) {
         //update newQuote;
         QuoteDomain.updateRecord(new List<Quote>{newQuote});
 
     }
     cloneGroup(newquoteId , quoteId );
     return newQuote.Id;
 
 }
 
 public static void cloneGroup(Id newQuoteId , Id quoteId){
         
     // List<Product_Select__c> lstQuoteLineItems = [SELECT Descriptions__c,Family__c,Freight__c,List_Price__c,
     //                                                 Margin_Percentage__c,Multiplier__c,Original_Product_Name__c,
     //                                                 Product_Code__c,Product_Group__c,Product_Name__c,
     //                                                 Quantity__c,Quote__c,Sales_Price__c,Total_Price__c,T_LBS__c,LBS__c,Tag__c,Extended_Cost__c,                                                               
     //                                                 Hide_Pricing__c,Hide_Line__c,Unit_Cost__c,Hide_Code__c,Row_Index__c,Page_Break__c,Is_Freight_Override__c,
     //                                                 Sale_Type__c,Manufacturer__c,Release_pick__c,CR__c,ProductId__c       
     //                                                 FROM Product_Select__c
     //                                                 WHERE Quote__c =: quoteId];
     List<Product_Select__c> lstQuoteLineItems = QuoteLineItemQueryHelper.getLineItemsByQuoteId(quoteId);
 
     
     List<Product_Select__c> lstQuoteLineItemsInsert = new List<Product_Select__c>();
     Set<Id> setChildProductGroupId = new Set<Id>();
     
     for(Product_Select__c qli : lstQuoteLineItems){
         Product_Select__c newQuoteLineItem = qli.clone(false,false,false,false);
         newQuoteLineItem.Quote__c = newQuoteId;
         setChildProductGroupId.add(qli.Product_Group__c);
         lstQuoteLineItemsInsert.add(newQuoteLineItem);
     }
     
     // List<Product_Group__c> lstProductGroups = [Select Id,Name, Parent_Product_Group__r.Name, Parent_Product_Group__c,Total_Line_Items__c,Total_Sub_Groups__c,
     //                                              Hide_Pricing__c,Total_Extended_Cost__c,Hide_Base_Bid_Total__c,Total_Group_Extended_Cost__c, Index__c,
     //                                              Hide_Code__c, Hide_Amount__c, Hide_Line__c,Quantity_Total__c,Total_Group_Freight__c,Total_Freight__c,Hide_Quantity__c,
     //                                              Release_Number__c,Grand_Quantity_Total__c,Page_Break__c
     //                                              FROM Product_Group__c
     //                                              WHERE Quote__c =: quoteId];
     List<Product_Group__c> lstProductGroups = GroupQueryHelper.getSubGroupsByQuoteId(quoteId);
 
     List<Product_Group__c>  lstProductGroupsInsert = new List<Product_Group__c>();                                   
     
     for(Product_Group__c pg : lstProductGroups){
         Product_Group__c newProductGroup = pg.clone(false,false,false,false);
         newProductGroup.Quote__c = newQuoteId;
         newProductGroup.Cloned_From__c = pg.Id;
         lstProductGroupsInsert.add(newProductGroup);
     }
     
     //insert lstProductGroupsInsert;
     GroupDomain.insertRecords(lstProductGroupsInsert);
 
     
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
     
     // List<Addition_Deduction__c> lstAddDeduct = [Select Id, Amount__c, Details__c, Type__c
     //                                     FROM Addition_Deduction__c
     //                                     WHERE Quote__c =: quoteId];
     List<Addition_Deduction__c> lstAddDeduct = AdditionDeductionQueryHelper.getAdditionDeductionByQuoteId(quoteId);
 
     
     List<Addition_Deduction__c> lstInsertAddDeduct = new List<Addition_Deduction__c>();
     
     for(Addition_Deduction__c ad : lstAddDeduct){
         Addition_Deduction__c newAddDeduct = ad.clone(false,false,false,false);
         newAddDeduct.Quote__c = newQuoteId;
         lstInsertAddDeduct.add(newAddDeduct);
     }
     
     //insert lstInsertAddDeduct;
     AdditionDeductionDomain.insertRecords(lstInsertAddDeduct);
 
    // insert lstQuoteLineItemsInsert;
     QuoteLineItemDomain.insertLineItems(lstQuoteLineItemsInsert);
 
    // update lstProductGroupsInsert;
    GroupDomain.updateRecord(lstProductGroupsInsert);
 
 }
 
 public static String getQuotesQuery(Id quoteId){
         
     String expr = '';
     
     Schema.DescribeSObjectResult a_desc = Quote.sObjectType.getDescribe();
     Map<String, Schema.SObjectField> a_fields = a_desc.fields.getMap();
     
     for(Schema.sObjectField fld:a_fields.values()){
         Schema.DescribeFieldResult fieldResult = fld.getDescribe(); 
         if(fieldResult.getName() == 'LastViewedDate' || fieldResult.getName() == 'LastReferencedDate') {
             Continue;
         }
         if(expr == ''){
             expr += fld;
         }
         else{
             expr += ', ' + fld ;
         }
         
     }
     expr += ', opportunity.Bid_Date__c';
     String qry = 'Select ' + expr + ' from Quote WHERE Id =' + '\''  + quoteId + '\'' ;
     system.debug(qry +'== query String');
     return qry;
}
}