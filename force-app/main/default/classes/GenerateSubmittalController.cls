public class GenerateSubmittalController{
    
    public List<Product_Group__c> lstProductGroups{get;set;}
    public Id quoteId{get;set;}
    public Quote quote{get;set;}
    public Product_Group__c currentSubGroup{get;set;}
    public Boolean isDenverUser{get;set;}
    public string officeName = null;
     
    public GenerateSubmittalController(Apexpages.StandardController stdCont){
   
        quoteId = stdCont.getId();
        
        quote = [Select Id, Name,Original_Name__c,Scope_of_Work__c,Opportunity_Number__c,Opportunity.Name, Opportunity.Owner.Name,QuoteNumber,Include_Cover_Letter__c,
                    Top_Exception_Notes__c,Bottom_Exception_Notes__c,Hide_Total_Extended_Cost__c ,Hide_Total_Base_Bid_Total__c,
                    Total_Base_Bid_Total__c,Total_Extended_Cost__c,Hide_All_Tags__c,Submittal_opening_comments__c,Submittal_Closing_Comments__c,
                    Consulting_Engineer__r.Name,Location__c,Customer_P_O__c,Revision__c,Current_Lead_Time__c,prepared_by_user__r.Name,
                    Submitted_By__r.Name,This_data_is_submitted_for__c,Submittal_Revision_Number__c,Opportunity.Opportunity_Number__c,
                    Attention_to_Account__r.Name,Bidding_To__r.Name,Plan_Date__c,Attention_To_Person__r.Name,Consulting_Engineer_Account__c,
                    Opportunity.Consulting_Engineer_Contact_Person__r.Account.Name,Opportunity.OriginalName__c,GEN__c,Attention_to_Contact__r.Name,SubmittalDocumentVersion__c,
                    Opportunity.RecordType.Name, Opportunity.CreatedDate,Opportunity.CreatedById
                    From Quote Where Id =: quoteId];

         User currentUser = [SELECT Office_Location__c 
                            FROM User 
                            WHERE Id = :quote.Opportunity.CreatedById];
        /*if(currentUser.Office_Location__c != null) {
            
            if(currentUser.Office_Location__c.equalsIgnoreCase(UtilitySharePointToSFIntegration.DENVER_CITY)) 
                officeName = 'Engineered Products';
            else
                officeName = currentUser.Office_Location__c;   
        }*/

        String subGroupId = apexpages.currentpage().getparameters().get('subGroupId');
        if(subGroupId != null && subGroupId != ''){
            lstProductGroups = [Select Id,Name,Hide_Quantity__c,    
                                (SELECT Descriptions__c,Tag__c,Product_Code__c,Product_Name__c,Quote__c,Quantity__c,Page_Break__c,Hide_Quantity__c  
                                    FROM Quote_Line_Items__r WHERE Hide_Line__c = false
                                    ORDER BY Row_Index__c ASC)
                                From Product_Group__c 
                                WHERE Quote__c =: quoteId
                                AND Id =: subGroupId
                                ORDER BY Index__c ASC]; 
            currentSubGroup = lstProductGroups[0];
        }
        else{
            lstProductGroups = [Select Id,Name,Hide_Quantity__c ,   
                                    (SELECT Descriptions__c,Tag__c,Product_Code__c,Product_Name__c,Quote__c,Quantity__c,Page_Break__c,Hide_Quantity__c  
                                        FROM Quote_Line_Items__r WHERE Hide_Line__c = false
                                        ORDER BY Row_Index__c ASC)
                                    From Product_Group__c 
                                    WHERE Quote__c =: quoteId
                                    AND Parent_Product_Group__c != null
                                    ORDER BY Index__c ASC]; 
        }
        isDenverUser = checkIsDenverUser();
    }
    
    public Boolean checkIsDenverUser(){
        
        for (GroupMember user : [Select Id, UserOrGroupId From GroupMember Where Group.Name = 'Engineered Products']){
            if(user.UserOrGroupId == UserInfo.getUserId()){ 
                return true;
            }
        }
        
        if(quote.OpportunityId != null){
            List<Opportunity> lstOpportunity = [Select Id,Office__c,Opportunity.RecordType.Name,
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
    
    public PageReference generateAttachment(){
        
        Integer versionnumber = quote.SubmittalDocumentVersion__c != null ? Integer.valueOf(quote.SubmittalDocumentVersion__c) : 0;
        versionnumber ++;
        Quote updateVersion = new Quote(SubmittalDocumentVersion__c = versionnumber,Id = quote.Id);
        
        // construct encoded opportunity name
        String oppName = Quote.Opportunity.Opportunity_Number__c + ' ' + Quote.Opportunity.OriginalName__c;
        oppName = EncodingUtil.urlEncode(oppName, 'UTF-8');
        oppName = oppName.replace('+',' ');

        String TimeStamp = String.valueOf(system.now());
        TimeStamp = TimeStamp.replace('-','');
        TimeStamp = TimeStamp.replace(' ','');
        TimeStamp = TimeStamp.replace(':','');
        // create for aaproval sub folder under quote submittals
        /*string quoteSubFolder = UtilitySharePointToSFIntegration.opportunityFolderNamesMap.get(3)+'/'+
                                quote.QuoteNumber +' '+quote.Name+ '/'+
                                UtilitySharePointToSFIntegration.quoteFolderNamesMap.get(1); */
                                
        /*String folderPath = UtilitySharePointToSFIntegration.MainFolderOpeningPath + 
                            quote.Opportunity.Opportunity_Number__c+' '+quote.Opportunity.OriginalName__c+'/' +
                            UtilitySharePointToSFIntegration.opportunityFolderNamesMap.get(3) + '/' +
                            quote.QuoteNumber +' '+quote.Original_Name__c + '/' +
                            UtilitySharePointToSFIntegration.quoteFolderNamesMap.get(3) + '/'+
                            'V'+versionnumber+' '+UtilitySharePointToSFIntegration.submittalSubFolder +
                            UtilitySharePointToSFIntegration.MainFolderClosingPath; */
                            
         //folderPath = folderPath .replace(' ','%20');
        
        //SharePointRestServiceCallOut.authenticateSharePoint();    
        //SharePointRestServiceCallOut.createFolder(folderPath);
            
        List<Attachment> lstAttachmentsToInsert = new List<Attachment>();
        if(UtilitySharePointToSFIntegration.OPP_EQUIPMENT_RECORDTYPE == quote.Opportunity.RecordType.Name
        || UtilitySharePointToSFIntegration.OPP_REPAIR_RECORDTYPE == quote.Opportunity.RecordType.Name) {
            if (lstProductGroups.size() > 0) {
                
                update updateVersion;
            }
            for(Product_Group__c pg : lstProductGroups){
                
            
                PageReference pdf = new PageReference('/apex/GenerateSubmittal?Id='+quoteId+'&subGroupId='+pg.Id);
                
                /*String fileName = quote.QuoteNumber +' '+
                                  quote.Name +' '+
                                  pg.Name+' '+
                                  'For Approval '+
                                  ' V'+versionnumber+
                                  '.'+'pdf';*/
                                  
                String fileName = quote.Opportunity_Number__c + '.';
                fileName += quote.QuoteNumber.substringAfter('-') + ' - ';                 
                fileName += quote.Opportunity.OriginalName__c;
                fileName += ' '+pg.Name;
                fileName += ' Submittal'+versionnumber;
                fileName += '.pdf';                  

                // construct encoded file name
                String encodedFileName =  EncodingUtil.urlEncode(FileName, 'UTF-8').replace('+', '%20');
                system.debug('encodedScopeName ==>'+encodedFileName );                    
                        
                //String fileName = TimeStamp+' '+quote.Opportunity.Opportunity_Number__c + ' - ' + quote.QuoteNumber + ' ' + quote.Opportunity.Name + ' ' + pg.Name + ' SUBMITTAL REV ' + quote.Submittal_Revision_Number__c + '.pdf';
                blob body;
            
                if(Test.isRunningTest()) { 
                    body = blob.valueOf('Unit.Test');
                } else {
                    body = pdf.getContentAsPDF();
                }
                
                String filePath = UtilitySharePointToSFIntegration.RootFolderForFilePath + 
                                quote.Opportunity.CreatedDate.Year();
                if(officeName != null && !UtilitySharePointToSFIntegration.isCurrentUserFromEngineeredProducts()) {
                    filePath = filePath + '/' + officeName;
                }
                filePath = filePath + '/' + oppName +'/' ;
                if(UtilitySharePointToSFIntegration.OPP_EQUIPMENT_RECORDTYPE == quote.Opportunity.RecordType.Name) {
                    if(UtilitySharePointToSFIntegration.isCurrentUserFromEngineeredProducts()) {
                        filePath = filePath + UtilitySharePointToSFIntegration.equipmentOpportunityFolders.get(22);
                    } else {
                        filePath = filePath + UtilitySharePointToSFIntegration.equipmentOpportunityFolders.get(16);
                    }
                } else if(UtilitySharePointToSFIntegration.OPP_REPAIR_RECORDTYPE == quote.Opportunity.RecordType.Name) {
                    filePath = filePath + UtilitySharePointToSFIntegration.repairOpportunityFolders.get(22);
                }
                
                system.debug('filePath=>'+filePath);         
                                  //+'/'+UtilitySharePointToSFIntegration.fetchQuoteFolderName(quote) + '/' +
                                  //UtilitySharePointToSFIntegration.quoteFolderNamesMap.get(3) + '/'+
                                  //UtilitySharePointToSFIntegration.submittalSubFolder; 
                CreateAttachmentInSharePoint.createFile(filePath,
                                                        encodedFileName,
                                                        body,
                                                        'Submittal',
                                                        updateVersion.Id);
                
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
                lstAttachmentsToInsert.add(newAttachment);
        }
            

            
        }
        
        if(!lstAttachmentsToInsert.isEmpty()){
            insert lstAttachmentsToInsert;
        }
        
        
        PageReference pr = new PageReference('/'+quoteId);
        pr.setRedirect(true);
        return pr;
        
    }
    
}