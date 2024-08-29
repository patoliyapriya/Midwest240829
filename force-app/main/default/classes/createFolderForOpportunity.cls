global class createFolderForOpportunity implements Database.Batchable<sObject>, Database.AllowsCallouts
{
global String query='';
global Id OpportunityId;
public string officeName = null;
global  Opportunity OpportunityRecord;
//global List<String> subFolders;
    global createfolderForOpportunity (Id OppId) 
    {
        Opportunity opp = [SELECT Id,CreatedById, CreatedDate,
                                  RecordType.Name,Office__c,
                                  Opportunity_Number__c,
                                  OriginalName__c 
                           FROM Opportunity 
                           WHERE Id = :OppId];
        officeName = UtilitySharePointToSFIntegration.assigneSharepointRootFolder(opp);                   
        //User currentUser = [SELECT Office_Location__c FROM User WHERE Id = :opp.CreatedById];
        //if(currentUser.Office_Location__c != null) {
            
            /*if(currentUser.Office_Location__c.equalsIgnoreCase(UtilitySharePointToSFIntegration.DENVER_CITY)) 
                officeName = 'Engineered Products';
            else*/
                //officeName = currentUser.Office_Location__c;   
        //}

        OpportunityRecord = Opp;
        OpportunityId = OppId;    
        query = 'SELECT Id,Name,Opportunity_Number__c,RecordTypeId,RecordType.Name From Opportunity WHERE Id= :OpportunityId';
              
    }

    global Database.QueryLocator start(Database.BatchableContext BC) 
    {  
        officeName = UtilitySharePointToSFIntegration.assigneSharepointRootFolder(OpportunityRecord);
        try{            
            Opportunity OpportunitySO = [SELECT Id,
                                            OriginalName__c,
                                            Opportunity_Number__c,
                                            RecordType.Name,
                                            CreatedDate
                                        FROM Opportunity 
                                        WHERE Id =: OpportunityId]; 

        // create folder for year
        String PathForYearFolder = UtilitySharePointToSFIntegration.MainFolderOpeningPath+ 
                                    OpportunitySO.CreatedDate.Year() +
                                    UtilitySharePointToSFIntegration.MainFolderClosingPath;
        
        PathForYearFolder = PathForYearFolder.replace(' ','%20');  
        if(Test.isrunningtest() == false) {                         
            SharePointRestServiceCallOut.authenticateSharePoint();
            SharePointRestServiceCallOut.createFolder(PathForYearFolder);
        }    
        
        if (officeName != null) {
                // create office folders
                List<String> officeNameList = new List<String>();
                // get pick list value for opportunity.Midwest Group Office
                Schema.DescribeFieldResult fieldResult = User.Office_Location__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                for( Schema.PicklistEntry pickListVal : ple){
                    officeNameList.add(pickListVal.getLabel());
                }
                
                // create folders for all  offices
                for(String office : officeNameList) {
                    
                    if(office.equalsIgnoreCase(UtilitySharePointToSFIntegration.DENVER_CITY)) {
                        continue;
                        //office ='Engineered Products';
                    }
                    String PathForOfficeFolder = UtilitySharePointToSFIntegration.MainFolderOpeningPath+ 
                                                OpportunitySO.CreatedDate.Year() +'/'+office+
                                                UtilitySharePointToSFIntegration.MainFolderClosingPath;
                    PathForOfficeFolder = PathForOfficeFolder.replace(' ','%20');
                    if(Test.isrunningtest() == false) {
                    // create folder in sharepoint for office
                    SharePointRestServiceCallOut.createFolder(PathForOfficeFolder);
                    }
                }
            }            
        
        // construct encoded opportunity name
        String oppName = OpportunitySO.Opportunity_Number__c+' '+OpportunitySO.OriginalName__c ;
        oppName = EncodingUtil.urlEncode(oppName, 'UTF-8').replace('+', '%20');
        

        String Path = UtilitySharePointToSFIntegration.MainFolderOpeningPath +
                        OpportunitySO.CreatedDate.Year();
            system.System.debug('officeNAme==>>'+officeName);            
            if (officeName != null && !UtilitySharePointToSFIntegration.isCurrentUserFromEngineeredProducts()) {
                Path = Path + '/' + officeName;
            }    
            Path = Path + '/' + oppName +
                UtilitySharePointToSFIntegration.MainFolderClosingPath;
                        
        Path = Path.replace(' ','%20');
        if(Test.isrunningtest() == false) {
        //SharePointRestServiceCallOut.authenticateSharePoint();
        SharePointRestServiceCallOut.createFolder(Path); 
        }
            
            
        List<Opportunity> opportunityList = [SELECT Id,Name,Opportunity_Number__c,RecordTypeId,RecordType.Name From Opportunity WHERE Id= :OpportunityId];
        
        List<String> Oppfolders = new List<String>(); 
    
        for(Opportunity opp : opportunityList) 
        {
            If(UtilitySharePointToSFIntegration.OPP_EQUIPMENT_RECORDTYPE.equalsIgnoreCase(opp.RecordType.Name)) {
                    Oppfolders  = UtilitySharePointToSFIntegration.equipmentOpportunityFolders.Values();        
            }
            else if(UtilitySharePointToSFIntegration.OPP_PARTS_RECORDTYPE.equalsIgnoreCase(opp.RecordType.Name)){
                Oppfolders  = UtilitySharePointToSFIntegration.partsOpportunityFolders.Values();     
            }
            else if(UtilitySharePointToSFIntegration.OPP_REPAIR_RECORDTYPE.equalsIgnoreCase(opp.RecordType.Name)){
            
                Oppfolders  = UtilitySharePointToSFIntegration.repairOpportunityFolders.Values();        
            }
            
            if(Test.isrunningtest() == false) {
                // authenticate sharepoint
                SharePointRestServiceCallOut.authenticateSharePoint(); 
                }

                    for(String folderName : Oppfolders)
                    {                             
                    Path = UtilitySharePointToSFIntegration.MainFolderOpeningPath + 
                            OpportunitySO.CreatedDate.Year();
                        if(officeName != null && !UtilitySharePointToSFIntegration.isCurrentUserFromEngineeredProducts()) {
                        Path = Path + '/' + officeName;     
                        }  
                        Path = Path + '/' + oppName + '/' + folderName +
                                    UtilitySharePointToSFIntegration.MainFolderClosingPath;
                    Path = Path.replace(' ','%20');
                if(Test.isrunningtest() == false) {
                    SharePointRestServiceCallOut.createFolder(Path);
                }     
            
            }
            }
        } catch (exception ex) {
            SharePointError__c error = new SharePointError__c(
                Opportunity__c = OpportunityId,
                Error__c = ex.getMessage(),
                Type__c = 'Opportunity Folder'
            );
            insert error;
        }
            return Database.getQueryLocator(query);

    }


    global void execute(Database.BatchableContext BC, List<Opportunity> opportunityList) 
    {   
     
    }


    global void finish(Database.BatchableContext BC) 
    {
        officeName = UtilitySharePointToSFIntegration.assigneSharepointRootFolder(OpportunityRecord);
        system.debug('officeName  in finish'+officeName );
        system.debug('OpportunityRecord in finish'+OpportunityRecord);
        List<SharePointError__c> errorList = new List<SharePointError__c>();
        // construct encoded opportunity folder name
        String oppName = OpportunityRecord.Opportunity_Number__c + ' ' + OpportunityRecord.OriginalName__c ;
        oppName = oppName;
        
        String opportunityFolderPath= '/' + UtilitySharePointToSFIntegration.RootFolderForFilePath;
        opportunityFolderPath += OpportunityRecord.CreatedDate.Year() + '/';
        
        if(officeName != null) {
            opportunityFolderPath += officeName + '/';
        }
        opportunityFolderPath += oppName;
        
        opportunityFolderPath = EncodingUtil.urlEncode(opportunityFolderPath, 'UTF-8').replace('+', '%20');
        
        if(!Test.isRunningTest()) {
            SharePointRestServiceCallOut.authenticateSharePoint();
        }
        SharePointError__c errorRecord =  SharePointRestServiceCallOut.breakInheritanceForFolder(opportunityFolderPath, OpportunityRecord.Id);
        if(errorRecord != null) {
            errorList.add(errorRecord);
        }
        String groupId = (officeName == null) ? UtilitySharePointToSFIntegration.EPGroupId : UtilitySharePointToSFIntegration.midwestGroupId;
        
        SharePointRestServiceCallOut.assignFolderPermission(opportunityFolderPath,
                                                              groupId,
                                                              UtilitySharePointToSFIntegration.editDeltePermissionLevelId,
                                                              OpportunityRecord.Id);
        
        insert errorList;
        
        
    }
}