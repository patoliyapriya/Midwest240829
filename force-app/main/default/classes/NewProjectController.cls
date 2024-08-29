public with sharing class NewProjectController{
    
    public Project__c newProject{get;set;}
    public Date projectBidDate{get;set;}
    public String oppId{get;set;}
    public Id quoteId{get;set;} 
    public Project__c redirectProject{get;set;}
    public Boolean isQuoteSync{get;set;}
    public Opportunity opportunityToUpdate{get;set;}
    public String errorMessage {get;set;}

    public NewProjectController(){
    
        oppId = Apexpages.currentpage().getparameters().get('Id');
        
        if(!String.isEmpty(oppId)){
            
            List<Project__c> lstProject = [Select Id,Name From Project__c Where Opportunity__c =: oppId];
            
            if(lstProject.isEmpty()){
                newProject = new Project__c();
            
                List<Opportunity> lstOpportunity = [Select Name,Id,Sync_Quote__r.QuoteNumber,Sync_Quote__r.Bid_Date__c,Sync_Quote__c,
                                                    Project_Manager__c, AccountId, StageName
                                                    From Opportunity
                                                    Where Id =: oppId];
                                                
                if(!lstOpportunity.isEmpty()){
                    opportunityToUpdate = lstOpportunity[0];

                    errorMessage = validateCreateProject(opportunityToUpdate);
                    if(String.isEmpty(errorMessage)) {
                        newProject.Opportunity__c = oppId;
                        newProject.Name = lstOpportunity[0].Name;
                        if(lstOpportunity[0].Sync_Quote__c == null){
                            isQuoteSync = false;
                        } else{
                            isQuoteSync = true;
                            
                            newProject.Quote__c = lstOpportunity[0].Sync_Quote__c;
                            newProject.Project_Number__c = String.valueOf(lstOpportunity[0].Sync_Quote__r.QuoteNumber).replace('Q','P');
                            projectBidDate = lstOpportunity[0].Sync_Quote__r.Bid_Date__c;
                        }
                    }
                    
                    
                }
            } else{
                isQuoteSync = true;
                redirectProject = lstProject[0];
            }
        }
        
        
    }
    
    private String validateCreateProject(Opportunity opp) {
        if(String.isEmpty(opp.Project_Manager__c)) {
            return 'Project Manager field is required prior to convert opportunity to the project.';
        } else if(String.isEmpty(opp.AccountId) && opp.StageName != 'Closed-Won') {
            return 'Account is required prior to convert opportunity to the project or opportunity stage should be Closed-Won.';
        }
   
        return null;
    }

    public void continueConvertToProject(){
        if(opportunityToUpdate != null){
            
            Quote quoteRecord = [Select Id, Total_Base_Bid_Total__c,Total_Extended_Cost__c,Total_Project_Margin__c
                                FROM Quote
                                WHERE Id =: opportunityToUpdate.Sync_Quote__c];
            
            opportunityToUpdate.Total_Base_Bid_Total_Quote__c = quoteRecord.Total_Base_Bid_Total__c;
            opportunityToUpdate.Total_Extended_Cost_Quote__c = quoteRecord.Total_Extended_Cost__c;
            opportunityToUpdate.Total_Project_Margin__c = quoteRecord.Total_Project_Margin__c;
            opportunityToUpdate.Sync_Quote__c = quoteRecord.Id;
            update opportunityToUpdate;
            
            isQuoteSync = true;
            
            List<Opportunity> lstOpportunity = [Select Id, Sync_Quote__r.QuoteNumber,Sync_Quote__r.Bid_Date__c,Sync_Quote__c,
                                                Project_Manager__c
                                                From Opportunity
                                                Where Id =: opportunityToUpdate.Id];

            if(!lstOpportunity.isEmpty()){
                newProject.Quote__c = lstOpportunity[0].Sync_Quote__c;
                newProject.Project_Number__c = String.valueOf(lstOpportunity[0].Sync_Quote__r.QuoteNumber).replace('Q','P');
                projectBidDate = lstOpportunity[0].Sync_Quote__r.Bid_Date__c;
            } 
            
        }
        
    }
    
    public PageReference backToOpportunity(){
        PageReference pr = new PageReference('/'+opportunityToUpdate.Id);
        pr.setRedirect(true);
        return pr;
    }
    
    public void poNumber(){
    }
    
    public PageReference saveProject(){
        newProject.Project_Stage__c = 'Open';
        insert newProject;
        
        opportunityToUpdate.Project__c = newProject.Id;
        update opportunityToUpdate;
        lockAndCloneQuote();

        PageReference pr = new PageReference('/'+newProject.Id);
        pr.setRedirect(true);
        return pr;
    }
    
    public void updateOpportunityWithNewClonedQuoteDetails(Id quoteId){
        List<Opportunity> lstOpportunity = [Select Id,Active_Financial_Quote__c,Project_Manager__c,StageName
                                            From Opportunity
                                            Where Id =: oppId];      
        if(!lstOpportunity.isEmpty()){
            lstOpportunity[0].Active_Financial_Quote__c = quoteId;
            lstOpportunity[0].StageName = 'Closed Won';
            update lstOpportunity[0];

            newProject.Active_Financial_Quote__c = quoteId;
            update newProject;
        }
    }
    
    public void lockAndCloneQuote(){
        
        List<Opportunity> lstOpportunity = [Select Id, Sync_Quote__c,Project_Manager__c From Opportunity Where Id =: oppId];
        
        if(!lstOpportunity.isEmpty() && lstOpportunity[0].Sync_Quote__c != null){
            quoteId = lstOpportunity[0].Sync_Quote__c;
            
            Quote updateQuoteLocked = [Select Is_Locked__c From Quote Where Id =: quoteId];
            updateQuoteLocked.Is_Locked__c = true;
            update updateQuoteLocked;
            
            Approval.LockResult lockResult = Approval.lock(lstOpportunity[0].Sync_Quote__c, false);
        }
        
		cloneQuote();
		
    }
    
    public PageReference returnToOpportunity(){
        PageReference pr = new PageReference('/'+oppId);
        pr.setRedirect(true);
        return pr;
    }
   
    public void cloneQuote(){
        
        Quote oldQuote = database.query(getQuoteQuery());
        
        Quote newQuote = oldQuote.clone(false, false, false, false);
        newQuote.Name = newQuote.Name + ' Active Project Financials';
		newQuote.Is_Locked__c = false;
        insert newQuote;
        
        cloneGroups(newQuote.Id);
        
        updateOpportunityWithNewClonedQuoteDetails(newQuote.Id);
        
    }
    
    public void cloneGroups(Id newQuoteId){
        
        List<Product_Select__c> lstQuoteLineItems = [SELECT Descriptions__c,Family__c,Freight__c,List_Price__c,
                                                        Margin_Percentage__c,Multiplier__c,Original_Product_Name__c,
                                                        Product_Code__c,Product_Group__c,Product_Name__c,
                                                        Quantity__c,Quote__c,Sales_Price__c,Total_Price__c,T_LBS__c,LBS__c,Tag__c,Extended_Cost__c,                                                               
                                                        Hide_Pricing__c,Hide_Line__c,Unit_Cost__c,Hide_Code__c,Row_Index__c,Page_Break__c,
                                                        Is_Freight_Override__c,Release_pick__c, Sale_Type__c,CR__c,ProductId__c     
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
                                                     Hide_Code__c, Hide_Amount__c, Hide_Line__c,Quantity_Total__c,Grand_Quantity_Total__c,Total_Freight__c,
                                                     Total_Group_Freight__c
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
            newAddDeduct.Quote__c = quoteId;
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
            if(expr == ''){
                expr += fld;
            }
            else{
                expr += ', ' + fld ;
            }
            
        }
        
        String qry = 'Select ' + expr + ' from Quote WHERE Id =' + '\''  + quoteId + '\'' ;
        
        return qry;
    }
}