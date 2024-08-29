public with sharing class GenerateQuoteDocumentController{
    
    public Id quoteId{get;set;}
    public Quote quote{get;set;}
    public List<ProductGroupWrapperClass> lstProductGroupWrapperClass{get;set;}
    public List<ProductGroupWrapperClass> lstProductGroupWrapperClassForAlternate{get;set;}
    public String hideTotalBaseDisplay{get;set;}
    public String hideTotalExtendedCost{get;set;}
    public List<Addition_Deduction__c> lstAdditionDuduction{get;set;}
    public Boolean isDenverUser{get;set;}
    public string officeName = null;
    public Boolean hasAlternates {get;set;}
    public Boolean hasIndividualAlternates {get;set;}
    
    public GenerateQuoteDocumentController() {
    }
    
    public GenerateQuoteDocumentController(Apexpages.StandardController stdCont){

        quoteId = stdCont.getId();
        quote = [Select Id,Original_Name__c,Opportunity_Number__c,Name,Scope_of_Work__c,Opportunity.Name, Opportunity.Owner.Name,QuoteNumber,Include_Cover_Letter__c,Hide_Price_Per__c,
                Top_Exception_Notes__c,Bottom_Exception_Notes__c,Hide_Total_Extended_Cost__c ,Hide_Total_Base_Bid_Total__c,
                Total_Base_Bid_Total__c,Total_Extended_Cost__c,Hide_All_Tags__c,Opportunity.Opportunity_Number__c,Attention_to_Account__r.Name,Attention_to__c,
                prepared_by_user__r.Name,Hide_All_Product_Code__c,Payment_Terms__c,Shipping_Charges__c,Current_Lead_Time__c,Bidding_To__r.Name, Bidding_To__r.Email, Bidding_To__r.Phone,
                Consulting_Engineer__r.Name,Opportunity.Bid_Date__c,Plan_Date__c,Submitted_By__r.Name, RecordType.Name,
                Consulting_Engineer_Account__c,GEN__c,Opportunity.OriginalName__c,Opportunity.Consulting_Engineer_Contact_Person__r.Account.Name,QuoteDocumentVersion__c,      
                Scope_Revision_Number__c, Opportunity.RecordType.Name,Opportunity.CreatedDate,Opportunity.CreatedById,
                Opportunity.Origin__c, Opportunity.Consolidation__c, Opportunity.Destination__c, Opportunity.Service__c, Opportunity.Order__c,
                Opportunity.Consolidation_City__c, Opportunity.Consolidation_Country__c, Opportunity.Consolidation_PostalCode__c, Opportunity.Consolidation_State__c, Opportunity.Consolidation_Street__c,
                Opportunity.Destination_City__c, Opportunity.Destination_Country__c, Opportunity.Destination_PostalCode__c, Opportunity.Destination_State__c, Opportunity.Destination_Street__c,
                Opportunity.Origin_City__c, Opportunity.Origin_Country__c, Opportunity.Origin_PostalCode__c, Opportunity.Origin_State__c, Opportunity.Origin_Street__c   
                From Quote 
                Where Id =: quoteId];
        
        hasAlternates = hasAlternateLineItems();
        hasIndividualAlternates = hasIndividualAlternateLineItems();

        User currentUser = [SELECT Office_Location__c 
                            FROM User 
                            WHERE Id = :quote.Opportunity.CreatedById];
        /*if(currentUser.Office_Location__c != null) {
            
            if(currentUser.Office_Location__c.equalsIgnoreCase(UtilitySharePointToSFIntegration.DENVER_CITY)) 
                officeName = 'Engineered Products';
            else
                officeName = currentUser.Office_Location__c;   
        }*/

        if(quote.Hide_Total_Extended_Cost__c){
            hideTotalExtendedCost = 'display:none';
        }
        else{
            hideTotalExtendedCost = 'display:table-row';
        }
        
        if(quote.Hide_Total_Base_Bid_Total__c){
            hideTotalBaseDisplay = 'display:none';
        }
        else{
            hideTotalBaseDisplay = 'display:table-row';
        }
                
        lstProductGroupWrapperClass = new List<ProductGroupWrapperClass>();
        lstProductGroupWrapperClassForAlternate = new List<ProductGroupWrapperClass>();
        BuildProductGroupWrapperClass();
        FillAdditionDeductionList();
        
        isDenverUser = checkIsDenverUser();
        
    }

    
    
    public Boolean hasAlternateLineItems() {
        AggregateResult arAlternateLineItems = [Select count(Id) cnt FROM Product_Select__c
                                                WHERE Quote__c =: quoteId
                                                AND Alternate__c = true];
        
        Integer totalAlternateRows = (Integer) arAlternateLineItems.get('cnt');

        return totalAlternateRows > 0;
    }

    public Boolean hasIndividualAlternateLineItems() {
        AggregateResult arAlternateLineItems = [Select count(Id) cnt FROM Product_Select__c
                                                WHERE Quote__c =: quoteId
                                                AND Alternate__c = true
                                                And Product_Group__r.Alternate__c = false
                                                And Product_Group__r.Parent_Product_Group__r.Alternate__c = false];
        
        Integer totalAlternateRows = (Integer) arAlternateLineItems.get('cnt');

        return totalAlternateRows > 0;
    }

    public Boolean checkIsDenverUser(){
        
        for (GroupMember user : [Select Id, UserOrGroupId From GroupMember Where Group.Name = 'Engineered Products']){
            if(user.UserOrGroupId == UserInfo.getUserId()){ 
                return true;
            }
        }
        
        if(quote.OpportunityId != null){
            List<Opportunity> lstOpportunity = [Select Id,Office__c, Opportunity.RecordType.Name,
                                                        CreatedById
                                                From Opportunity
                                                WHERE Id =: quote.OpportunityId];
                                
            if(!lstOpportunity.isEmpty()){
                officeName = UtilitySharePointToSFIntegration.assigneSharepointRootFolder(lstOpportunity[0]); 
                Opportunity opp = lstOpportunity[0];
                if(opp.RecordType.Name == 'Parts' && opp.Office__c == 'Engineered Products'){
                  return true;
                }
            }
        }
        
        return false;
    }
    
    public void FillAdditionDeductionList(){
        lstAdditionDuduction = [Select Id,Amount__c,Details__c,Quote__c,Type__c
                                FROM Addition_Deduction__c
                                WHERE Quote__c =: quoteId];
        
    }
    
    public Integer getColSpanOfSubGroup(Product_Group__c pg){
        
        integer colspan = 1;
        
        if(quote.Hide_All_Product_Code__c || pg.Hide_Code__c){
            colspan++;
        }
        if(quote.Hide_Price_Per__c){
            colspan++;
        }
        if(pg.Hide_Price_Column__c){
            colspan++;
        }
        if(quote.Hide_All_Tags__c){
            colspan++;
        }
        if(pg.Hide_Quantity__c){
            colspan++;
        }
        
        return colspan;
    }
    
    public void BuildProductGroupWrapperClass(){
        
        List<Product_Group__c> lstProductGroups = [Select Id,Name, Parent_Product_Group__r.Name, Parent_Product_Group__c,Total_Line_Items__c,Total_Sub_Groups__c,
                                                    Hide_Pricing__c, Hide_Price_Column__c,Hide_Code__c,Hide_Quantity__c,Page_Break__c, Alternate__c,
                                                            (SELECT Descriptions__c,Family__c,Freight__c,List_Price__c,Tag__c,Price_Per__c,
                                                                Margin_Percentage__c,Multiplier__c,Original_Product_Name__c,
                                                                Product_Code__c,Product_Group__c,Product_Name__c,Hide_Quantity__c ,Alternate__c,
                                                                Quantity__c,Quote__c,Sales_Price__c,Total_Price__c,Hide_Pricing__c,Hide_Line__c,Hide_Code__c,Page_Break__c 
                                                                FROM Quote_Line_Items__r WHERE Hide_Line__c = false
                                                                ORDER BY Row_Index__c ASC)
                                                            From Product_Group__c 
                                                            WHERE Quote__c =: quoteId
                                                            AND Parent_Product_Group__c != null
                                                            ORDER BY Parent_Product_Group__c,Index__c ASC];    
        
        Set<Id> setParentGroupIds = new Set<Id>();
        
        for(Product_Group__c pg : lstProductGroups){
            if(pg.Parent_Product_Group__c != null){
                setParentGroupIds.add(pg.Parent_Product_Group__c);
            }
        }
        
        List<Product_Group__c> lstParentProductGroups = [Select Id,Name,Total_Line_Items__c,Total_Sub_Groups__c,Hide_Pricing__c,Page_Break__c,Alternate__c
                                                        FROM Product_Group__c
                                                        WHERE Id IN :setParentGroupIds];
        
        Map<Id,Product_Group__c> mapProductGroup = new Map<Id,Product_Group__c>();
        
        for(Product_Group__c pg : lstParentProductGroups){
            mapProductGroup.put(pg.Id, pg);
        }
        
        Id parentGroup = null;
        
        ProductGroupWrapperClass objProductGroupWrapperClass;
        Map<Id,ProductGroupWrapperClass> mapParentGroupIdWrapper = new Map<Id,ProductGroupWrapperClass>();
        
        for(Product_Group__c pg : lstProductGroups){
            system.debug('###'+pg.Parent_Product_Group__r.Name);
            system.debug('###'+pg.Name);
            
            if(parentGroup == null){
                parentGroup = pg.Parent_Product_Group__c;
            }
            
            if(parentGroup != pg.Parent_Product_Group__c && parentGroup != null){
            
                lstProductGroupWrapperClass.add(objProductGroupWrapperClass);
                objProductGroupWrapperClass = new ProductGroupWrapperClass(mapProductGroup.get(pg.Parent_Product_Group__c));
                
                parentGroup = pg.Parent_Product_Group__c;
                
            }
            
            ProductSubGroupWrapperClass objProductSubGroupWrapperClass = new ProductSubGroupWrapperClass(pg);
            objProductSubGroupWrapperClass.colspan = getColSpanOfSubGroup(pg);
            
            for(Product_Select__c ql : pg.Quote_Line_Items__r){
                ProductWrapperClass objProductWrapperClass = new ProductWrapperClass(ql);
                objProductSubGroupWrapperClass.lstProductSelected.add(objProductWrapperClass);
            }
            if(mapParentGroupIdWrapper.get(pg.Parent_Product_Group__c) != null){
                objProductGroupWrapperClass = mapParentGroupIdWrapper.get(pg.Parent_Product_Group__c);
            }
            else{
                objProductGroupWrapperClass = new ProductGroupWrapperClass(mapProductGroup.get(pg.Parent_Product_Group__c));
                mapParentGroupIdWrapper.put(pg.Parent_Product_Group__c,objProductGroupWrapperClass);
            }
            if(objProductSubGroupWrapperClass.productGroup.Name == 'Please Enter Sub Group Name'){
                objProductGroupWrapperClass.isSubGroupingEnable = false;
            }
            else{
                objProductGroupWrapperClass.isSubGroupingEnable = true;
            }
            objProductGroupWrapperClass.lstProductSubGroup.add(objProductSubGroupWrapperClass);    
            
            
        }
        
        lstProductGroupWrapperClass.add(objProductGroupWrapperClass);

        BuildProductGroupWrapperClassForAlterNate();
        
    }
    
    public void BuildProductGroupWrapperClassForAlterNate(){
        
        List<Product_Group__c> lstProductGroups = [Select Id,Name, Parent_Product_Group__r.Name, Parent_Product_Group__c,Total_Line_Items__c,Total_Sub_Groups__c,
                                                    Hide_Pricing__c, Hide_Price_Column__c,Hide_Code__c,Hide_Quantity__c,Page_Break__c, Alternate__c,Hide_Line__c,
                                                            (SELECT Descriptions__c,Family__c,Freight__c,List_Price__c,Tag__c,Price_Per__c,
                                                                Margin_Percentage__c,Multiplier__c,Original_Product_Name__c,
                                                                Product_Code__c,Product_Group__c,Product_Name__c,Hide_Quantity__c ,Alternate__c,
                                                                Quantity__c,Quote__c,Sales_Price__c,Total_Price__c,Hide_Pricing__c,Hide_Line__c,Hide_Code__c,Page_Break__c 
                                                                //FROM Quote_Line_Items__r WHERE Hide_Line__c = false
                                                                FROM Quote_Line_Items__r 
                                                                ORDER BY Row_Index__c ASC)
                                                            From Product_Group__c 
                                                            WHERE Quote__c =: quoteId
                                                            AND Parent_Product_Group__c != null
                                                            ORDER BY Parent_Product_Group__c,Index__c ASC];    
        
        Set<Id> setParentGroupIds = new Set<Id>();
        
        for(Product_Group__c pg : lstProductGroups){
            if(pg.Parent_Product_Group__c != null){
                setParentGroupIds.add(pg.Parent_Product_Group__c);
            }
        }
        
        List<Product_Group__c> lstParentProductGroups = [Select Id,Name,Total_Line_Items__c,Total_Sub_Groups__c,Hide_Pricing__c,Page_Break__c,Alternate__c,Hide_Line__c
                                                        FROM Product_Group__c
                                                        WHERE Id IN :setParentGroupIds];
        
        Map<Id,Product_Group__c> mapProductGroup = new Map<Id,Product_Group__c>();
        
        for(Product_Group__c pg : lstParentProductGroups){
            mapProductGroup.put(pg.Id, pg);
        }
        
        Id parentGroup = null;
        
        ProductGroupWrapperClass objProductGroupWrapperClass;
        Map<Id,ProductGroupWrapperClass> mapParentGroupIdWrapper = new Map<Id,ProductGroupWrapperClass>();
        
        for(Product_Group__c pg : lstProductGroups){
            system.debug('###'+pg.Parent_Product_Group__r.Name);
            system.debug('###'+pg.Name);
            
            if(parentGroup == null){
                parentGroup = pg.Parent_Product_Group__c;
            }
            
            if(parentGroup != pg.Parent_Product_Group__c && parentGroup != null){
            
                lstProductGroupWrapperClassForAlternate.add(objProductGroupWrapperClass);
                objProductGroupWrapperClass = new ProductGroupWrapperClass(mapProductGroup.get(pg.Parent_Product_Group__c));
                
                parentGroup = pg.Parent_Product_Group__c;
                
            }
            
            ProductSubGroupWrapperClass objProductSubGroupWrapperClass = new ProductSubGroupWrapperClass(pg);
            objProductSubGroupWrapperClass.colspan = getColSpanOfSubGroup(pg);
            
            for(Product_Select__c ql : pg.Quote_Line_Items__r){
                ProductWrapperClass objProductWrapperClass = new ProductWrapperClass(ql);
                objProductSubGroupWrapperClass.lstProductSelected.add(objProductWrapperClass);
            }
            if(mapParentGroupIdWrapper.get(pg.Parent_Product_Group__c) != null){
                objProductGroupWrapperClass = mapParentGroupIdWrapper.get(pg.Parent_Product_Group__c);
            }
            else{
                objProductGroupWrapperClass = new ProductGroupWrapperClass(mapProductGroup.get(pg.Parent_Product_Group__c));
                mapParentGroupIdWrapper.put(pg.Parent_Product_Group__c,objProductGroupWrapperClass);
            }
            if(objProductSubGroupWrapperClass.productGroup.Name == 'Please Enter Sub Group Name'){
                objProductGroupWrapperClass.isSubGroupingEnable = false;
            }
            else{
                objProductGroupWrapperClass.isSubGroupingEnable = true;
            }
            objProductGroupWrapperClass.lstProductSubGroup.add(objProductSubGroupWrapperClass);    
            
            
        }
        
        lstProductGroupWrapperClassForAlternate.add(objProductGroupWrapperClass);
        
    }

    public PageReference generateAttachment(){
        /*
        String quoteType = apexpages.currentpage().getparameters().get('quoteType');
        if(quoteType == 'marrs') {
            return generateMarrsQuote();
        }
        */ 
        if (quote.RecordType.Name == 'Spark' || quote.RecordType.Name == 'MaRRS Quote') {
            return generateQuote(quote.RecordType.Name);
        }

        PageReference pdf = new PageReference('/apex/GenerateQuoteDocument?Id='+quoteId);
        String fileType = apexpages.currentpage().getparameters().get('type');
        Integer versionnumber = quote.QuoteDocumentVersion__c != null ? Integer.valueOf(quote.QuoteDocumentVersion__c) : 0;
        versionnumber ++;
        
        // construct encoded opportunity name
        String oppName = Quote.Opportunity.Opportunity_Number__c + ' ' + Quote.Opportunity.OriginalName__c;
        oppName = EncodingUtil.urlEncode(oppName, 'UTF-8');
        oppName = oppName.replace('+',' ');
        
        //system.debug('updated version velue='+updateVersion.get('QuoteDocumentVersion__c'));
        String TimeStamp = String.valueOf(system.now());
        TimeStamp = TimeStamp.replace('-','');
        TimeStamp = TimeStamp.replace(' ','');
        TimeStamp = TimeStamp.replace(':','');
        /*String fileName = quote.QuoteNumber + ' ' +
                          quote.Name+ ' '+
                          ' V'+versionnumber+
                          '.'+fileType;*/
        /*String fileName = quote.Opportunity_Number__c + '.';
        fileName += quote.QuoteNumber.substringAfter('-') + ' - ';                 
        fileName += quote.Opportunity.OriginalName__c;
        fileName += ' Quotation'+versionnumber;
        fileName += '.'+fileType;
         */
        String fileName;
        Date BidDate;
        if (Test.isRunningTest()) {
            BidDate = Date.Today();
            fileName = 'quotefileName';
        } else {
            BidDate = Date.parse(apexpages.currentpage().getparameters().get('biddate'));
            fileName = apexpages.currentpage().getparameters().get('fileName');
        }
        
        //FileName  = FileName.replace(':','%3A');        
        system.debug(FileName);
        
        blob body;
        
        if(Test.isRunningTest()) {  
            body = blob.valueOf('Unit.Test');
        } else {
            body = pdf.getContentAsPDF(); 
        }
        
        String quotePDFFolder = null;
        String bidDateFolder =  String.valueof(BidDate.month()) + '-' + String.valueof(BidDate.day()) + '-' + String.valueof(BidDate.year());
        if(quote.Opportunity.RecordType.Name == UtilitySharePointToSFIntegration.OPP_EQUIPMENT_RECORDTYPE) {
            quotePDFFolder = UtilitySharePointToSFIntegration.equipmentOpportunityFolders.get(11);
        
        } else if(quote.Opportunity.RecordType.Name == UtilitySharePointToSFIntegration.OPP_PARTS_RECORDTYPE) {
            
            if(quote.Opportunity.CreatedDate > DateTime.ValueOf(UtilitySharePointToSFIntegration.partsFolderUpdatedOn) ) {
                quotePDFFolder = UtilitySharePointToSFIntegration.partsOpportunityFolders.get(1);
            } else {
                quotePDFFolder = '04 Quotes';
            }
            
        
        } else if(quote.Opportunity.RecordType.Name == UtilitySharePointToSFIntegration.OPP_REPAIR_RECORDTYPE) {
            quotePDFFolder = UtilitySharePointToSFIntegration.repairOpportunityFolders.get(11);
        
        }
        // check if sharepoint folder is already created with bid date or not
        Integer bidDateFolderCount = [SELECT Count() 
                                      FROM SharepointBidDateFolder__c
                                      WHERE Bid_Date_Sharepoint_Folder__c = :BidDate
                                      AND Object_Type__c = 'Opportunity'
                                      AND Opportunity_RecordType__c = :quote.Opportunity.RecordType.Name
                                      AND Opportunity__c = :quote.OpportunityId];
    

        if(bidDateFolderCount == 0) {

            // create folder with new bid date first
            String bidDateFolderPath = UtilitySharePointToSFIntegration.MainFolderOpeningPath + 
                                       quote.Opportunity.CreatedDate.Year();
            if(officeName != null && !UtilitySharePointToSFIntegration.isCurrentUserFromEngineeredProducts()) {
                bidDateFolderPath = bidDateFolderPath + '/' + officeName;
            }
            
            
            
            bidDateFolderPath = bidDateFolderPath + '/' + oppName + '/' + 
                                     quotePDFFolder + '/' + 
                                     bidDateFolder + ' Estimate'+
                                     UtilitySharePointToSFIntegration.MainFolderClosingPath;
                                     
            bidDateFolderPath = bidDateFolderPath.replace(' ','%20');
            system.debug('in else part bidDateFolderPath>>'+bidDateFolderPath);

            // authenticate sharepoint
            SharePointRestServiceCallOut.authenticateSharePoint();  
            // create bid date folder
            SharePointRestServiceCallOut.createFolder(bidDateFolderPath);  
            
            // create bid date record
            SharepointBidDateFolder__c createNewBidDateRecord = new SharepointBidDateFolder__c(
                                                                    Bid_Date_Sharepoint_Folder__c = BidDate,
                                                                    Object_Type__c = 'Opportunity',
                                                                    Opportunity_RecordType__c = quote.Opportunity.RecordType.Name,
                                                                    Opportunity__c = quote.OpportunityId);
           insert createNewBidDateRecord;                                                       

        } 
        Quote updateVersion = new Quote(QuoteDocumentVersion__c = versionnumber,Id = quote.Id);
        update updateVersion;               
        
        // construct encoded file name
        String encodedFileName = FileName;
        encodedFileName = EncodingUtil.urlEncode(FileName, 'UTF-8').replace('+', '%20');
        system.debug('encodedFileName ==>'+encodedFileName );

        string quoteFilePath = UtilitySharePointToSFIntegration.RootFolderForFilePath +
                               quote.Opportunity.CreatedDate.Year();
        if(officeName != null && !UtilitySharePointToSFIntegration.isCurrentUserFromEngineeredProducts()) {
            quoteFilePath = quoteFilePath + '/' + officeName;
        }
        quoteFilePath = quoteFilePath + '/' + oppName +'/'+
                               quotePDFFolder +'/'+
                               bidDateFolder +' Estimate';
        system.debug('QuoteFolder==>'+quoteFilePath );
        CreateAttachmentInSharePoint.createFile(quoteFilePath, encodedFileName, body, 'Quote', updateVersion.Id);         
       
        // update file name in quote
        Quote quoteToUpdate = new Quote();
        quoteToUpdate.Id = quote.Id;
        quoteToUpdate.Quote_FileName__c = FileName.remove('.pdf');
        update quoteToUpdate;      
        
        
        Attachment newAttachment = new Attachment();
        newAttachment.Name = quote.Opportunity.Opportunity_Number__c + ' - ' + quote.QuoteNumber + ' ' + quote.Opportunity.Name + ' QUOTE' + '.' + fileType;
        newAttachment.IsPrivate = false;
        newAttachment.ParentId = quoteId;
        if(!Test.isRunningTest()){
            newAttachment.body = pdf.getContentAsPDF();
        }
        else{
            Blob content = Blob.valueOf('UNIT.TEST');
            newAttachment.body = content;
        }
        insert newAttachment;
        

        
        PageReference pr = new PageReference('/'+quoteId);
        pr.setRedirect(true);
        return pr;
        
    }
    
    public pageReference generateQuote(String recordTypeName) {

        PageReference pdf;
        if (recordTypeName == 'MaRRS Quote') {
            pdf = new PageReference('/apex/MarrsQuotePdf?Id=' + quoteId);
        } else {
            pdf = new PageReference('/apex/SparkQuotePdf?Id=' + quoteId);
        }

        String fileType = apexpages.currentpage().getparameters().get('type');

        Attachment newAttachment = new Attachment();
        newAttachment.Name = quote.Opportunity.Opportunity_Number__c + ' - ' + quote.QuoteNumber + ' ' + quote.Opportunity.Name + ' QUOTE' + '.' + fileType;
        newAttachment.IsPrivate = false;
        newAttachment.ParentId = quoteId;
        if(!Test.isRunningTest()){
            newAttachment.body = pdf.getContentAsPDF();
        }
        else{
            Blob content = Blob.valueOf('UNIT.TEST');
            newAttachment.body = content;
        }
        insert newAttachment;

        PageReference pr = new PageReference('/'+quoteId);
        pr.setRedirect(true);
        return pr;
    }

    public class ProductWrapperClass{
        
        public Boolean isSelect{get;set;}
        public Product_Select__c productDetails{get;set;}
          
        public ProductWrapperClass(Product_Select__c ps){
            isSelect = false;
            productDetails = ps;
        }
        
    }
    
    public class ProductGroupWrapperClass{
        
        public Boolean isSubGroupingEnable{get;set;}
        public Product_Group__c productGroup{get;set;}
        public List<ProductSubGroupWrapperClass> lstProductSubGroup{get;set;}
                
        public ProductGroupWrapperClass(Product_Group__c pg){
            productGroup = pg;
            lstProductSubGroup = new List<ProductSubGroupWrapperClass>();
        }
        
    }
    
    public class ProductSubGroupWrapperClass{
        
        public Product_Group__c productGroup{get;set;}
        public List<ProductWrapperClass> lstProductSelected{get;set;}
        public Integer colspan{get;set;}
        
        public ProductSubGroupWrapperClass(Product_Group__c pg){
            productGroup = pg;
            lstProductSelected = new List<ProductWrapperClass>();
        }
        
    }
    
}