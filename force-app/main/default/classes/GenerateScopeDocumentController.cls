public with sharing class GenerateScopeDocumentController{
    
    public Id quoteId{get;set;}
    public Quote quote{get;set;}
    public List<ProductGroupWrapperClass> lstProductGroupWrapperClass{get;set;}
    public Boolean isDenverUser{get;set;}
    public string officeName = null;
    
    public GenerateScopeDocumentController(Apexpages.StandardController stdCont){

        quoteId = stdCont.getId();
        
        quote = [Select Id, Name,Scope_of_Work__c,Original_Name__c,Opportunity_Number__c,Opportunity.Name, Opportunity.Owner.Name,QuoteNumber,Include_Cover_Letter__c,
                Top_Exception_Notes__c,Bottom_Exception_Notes__c,Hide_Total_Extended_Cost__c ,Hide_Total_Base_Bid_Total__c,
                Total_Base_Bid_Total__c,Total_Extended_Cost__c,Hide_All_Tags__c,Scope_Top_Comments__c,Scope_Bottom_Comments__c,
                Attention_to_Account__r.Name,Attention_To_Person__r.Name,prepared_by_user__r.Name,Scope_Revision_Number__c,Opportunity.Opportunity_Number__c,
                Payment_Terms__c,Shipping_Charges__c,Current_Lead_Time__c,Consulting_Engineer__r.Name,Bidding_To__r.Name,Plan_Date__c,ScopeDocumentVersion__c,
                Submitted_By__r.Name,Consulting_Engineer_Account__c,Opportunity.OriginalName__c,Opportunity.Consulting_Engineer_Contact_Person__r.Account.Name,GEN__c,             
                Opportunity.RecordType.Name, Opportunity.CreatedDate,Opportunity.CreatedById
                From Quote Where Id =: quoteId];

        User currentUser = [SELECT Office_Location__c 
                            FROM User 
                            WHERE Id = :quote.Opportunity.CreatedById];
       /* if(currentUser.Office_Location__c != null) {
            
            if(currentUser.Office_Location__c.equalsIgnoreCase(UtilitySharePointToSFIntegration.DENVER_CITY)) 
                officeName = 'Engineered Products';
            else
                officeName = currentUser.Office_Location__c;   
        }*/

        lstProductGroupWrapperClass = new List<ProductGroupWrapperClass>();
        BuildProductGroupWrapperClass();
        
        isDenverUser = checkIsDenverUser();
    }
    
    public Boolean checkIsDenverUser(){
        
        for (GroupMember user : [Select Id, UserOrGroupId From GroupMember Where Group.Name = 'Engineered Products']){
            if(user.UserOrGroupId == UserInfo.getUserId()){ 
                return true;
            }
        }
        
        if(quote.OpportunityId != null){
            List<Opportunity> lstOpportunity = [Select Id,Office__c ,Opportunity.RecordType.Name,
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
    
    public void BuildProductGroupWrapperClass(){
        
        List<Product_Group__c> lstProductGroups = [Select Id,Name, Parent_Product_Group__r.Name, Parent_Product_Group__c,Total_Line_Items__c,Total_Sub_Groups__c,Hide_Pricing__c,Hide_Quantity__c,   
                                                            (SELECT Descriptions__c,Family__c,Freight__c,List_Price__c,Tag__c,
                                                                Margin_Percentage__c,Multiplier__c,Original_Product_Name__c,
                                                                Product_Code__c,Product_Group__c,Product_Name__c,Hide_Quantity__c, 
                                                                Quantity__c,Quote__c,Sales_Price__c,Total_Price__c,Hide_Pricing__c,Hide_Line__c,Page_Break__c
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
        
        List<Product_Group__c> lstParentProductGroups = [Select Id,Name,Total_Line_Items__c,Total_Sub_Groups__c,Hide_Pricing__c  
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
        
    }
    
    public PageReference generateAttachment(){
        
        // construct encoded opportunity name
        String oppName = Quote.Opportunity.Opportunity_Number__c + ' ' + Quote.Opportunity.OriginalName__c;
        oppName = EncodingUtil.urlEncode(oppName, 'UTF-8');
        oppName = oppName.replace('+',' ');

        PageReference pdf = new PageReference('/apex/GenerateScope?Id='+quoteId);
        String fileType;
        Date BidDate;
        
        if(Test.isRunningTest()) {
            fileType = '.pdf';
            BidDate  = Date.today();
        } else {
        
            fileType = apexpages.currentpage().getparameters().get('type');
            BidDate = Date.parse(apexpages.currentpage().getparameters().get('biddate'));
        }    
    
        String scopePDFFolder = null;
        String bidDateFolder = String.valueof(BidDate.month())+'-'+String.valueof(BidDate.day())+'-'+String.valueof(BidDate.year());
        if(quote.Opportunity.RecordType.Name == UtilitySharePointToSFIntegration.OPP_EQUIPMENT_RECORDTYPE) {
            scopePDFFolder = UtilitySharePointToSFIntegration.equipmentOpportunityFolders.get(11);
        
        } else if(quote.Opportunity.RecordType.Name == UtilitySharePointToSFIntegration.OPP_PARTS_RECORDTYPE) {
            if(quote.Opportunity.CreatedDate > DateTime.ValueOf(UtilitySharePointToSFIntegration.partsFolderUpdatedOn) ) {
                scopePDFFolder = UtilitySharePointToSFIntegration.partsOpportunityFolders.get(1);
            } else {
                scopePDFFolder = '04 Quotes';
            }    
        
        } else if(quote.Opportunity.RecordType.Name == UtilitySharePointToSFIntegration.OPP_REPAIR_RECORDTYPE) {
            scopePDFFolder = UtilitySharePointToSFIntegration.repairOpportunityFolders.get(11);
        
        }       
            // create folder with new bid date first
        String bidDateFolderPath = UtilitySharePointToSFIntegration.MainFolderOpeningPath + 
                                    quote.Opportunity.CreatedDate.Year();
        if(officeName != null && !UtilitySharePointToSFIntegration.isCurrentUserFromEngineeredProducts()) {
            bidDateFolderPath = bidDateFolderPath + '/' + officeName;
        }
        bidDateFolderPath = bidDateFolderPath + '/' + oppName + '/' + 
                                    scopePDFFolder + '/' + 
                                    bidDateFolder + ' Estimate'+
                                    UtilitySharePointToSFIntegration.MainFolderClosingPath;
        
        system.debug('socepeBidDate==>'+bidDateFolderPath );                         
        bidDateFolderPath = bidDateFolderPath.replace(' ','%20');
        
        if(Test.isRunningTest() == false) {
            // authenticate sharepoint
            SharePointRestServiceCallOut.authenticateSharePoint();
            // create bid date folder
            SharePointRestServiceCallOut.createFolder(bidDateFolderPath);
        } 
         
        Integer versionnumber = quote.ScopeDocumentVersion__c != null ? Integer.valueOf(quote.ScopeDocumentVersion__c) : 0;
        versionnumber ++;
        Quote updateVersion = new Quote(ScopeDocumentVersion__c = versionnumber,Id = quote.Id);
        update updateVersion;
        String fileName ;
        if(Test.isRunningTest()) {
            fileName  = 'filename';
        } else {
            fileName = apexpages.currentpage().getparameters().get('fileName');
        }
        
        //FileName  = FileName.replace(':','%3A');     
        // construct encoded file name
        String encodedFileName =  EncodingUtil.urlEncode(FileName, 'UTF-8').replace('+', '%20');
        system.debug('encodedScopeName ==>'+encodedFileName );                    
        //String fileName = TimeStamp+' '+quote.Opportunity.Opportunity_Number__c + ' - ' + quote.QuoteNumber + ' ' + quote.Opportunity.Name + ' SCOPE REV ' + quote.Scope_Revision_Number__c + '.pdf';
        
        blob body;
        
        if(Test.isRunningTest()) { 
            body = blob.valueOf('Unit.Test');
        } else {
            body = pdf.getContentAsPDF();
        }
        
        string ScopeFilePath = UtilitySharePointToSFIntegration.RootFolderForFilePath + 
                                quote.Opportunity.CreatedDate.Year();
        if(officeName != null && !UtilitySharePointToSFIntegration.isCurrentUserFromEngineeredProducts()) {
            ScopeFilePath = ScopeFilePath + '/' + officeName;
        }
        ScopeFilePath = ScopeFilePath + '/' + oppName +'/'+
                               scopePDFFolder +'/'+
                               bidDateFolder +' Estimate' + '/';                      
        CreateAttachmentInSharePoint.createFile(ScopeFilePath ,encodedFileName,body,'Scope',updateVersion.Id);
        
        Attachment newAttachment = new Attachment();
        newAttachment.Name = fileName;
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
        
        // update scope file name
        Quote quoteToUpdate = new Quote();
        quoteToUpdate.Id = quote.Id;
        quoteToUpdate.Scope_File_Name__c = FileName.remove('.pdf');
        update quoteToUpdate;
        
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
        
        
        public ProductSubGroupWrapperClass(Product_Group__c pg){
            productGroup = pg;
            lstProductSelected = new List<ProductWrapperClass>();
        }
        
    }
}