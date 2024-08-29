global class assignPermissionInSharepointFolder implements Database.Batchable<sObject>, Database.AllowsCallouts,Database.stateful {

    global List<SharePointError__c> errorList = new List<SharePointError__c>();
    global List<Opportunity> OpportunityListToUpdate= new List<Opportunity>();
    
     global Database.QueryLocator start(Database.BatchableContext BC) {
     string tempName = 'test dataActivityPermission & # ()   new opp fd (';
         String fetchOpportunities = 'SELECT  Id,CreatedById, CreatedDate,RecordType.Name,Office__c,Opportunity_Number__c,OriginalName__c FROM Opportunity WHERE OriginalName__c != null AND isPermissionAssigedinSP__c = false  LIMIT 500';
         system.debug('START Method Query=>'+fetchOpportunities);
         return Database.getQueryLocator(fetchOpportunities);
     }
     
    global void execute(Database.BatchableContext BC, List<Opportunity> opportunityList) {   
        system.debug('EXECUTE Method list size=>'+opportunityList.Size());
        
        SharePointRestServiceCallOut.authenticateSharePoint();
        for(Opportunity opp :opportunityList) {
            
            String officeName = UtilitySharePointToSFIntegration.assigneSharepointRootFolder(opp);   
            String oppName = opp.Opportunity_Number__c + ' ' + opp.OriginalName__c ;
            
            String opportunityFolderPath= '/' + UtilitySharePointToSFIntegration.RootFolderForFilePath;
            opportunityFolderPath += opp.CreatedDate.Year() + '/';
            
            if(officeName != null) {
                opportunityFolderPath += officeName + '/';
            }
            opportunityFolderPath += oppName;
            
            system.debug('Execute methhod opportunityFolderPath =>'+opportunityFolderPath);
            
            breakInheritance(opportunityFolderPath);
            
            String groupId = (officeName == null) ? UtilitySharePointToSFIntegration.EPGroupId : UtilitySharePointToSFIntegration.midwestGroupId;
            String permissionLevelId = UtilitySharePointToSFIntegration.editDeltePermissionLevelId;
            
            SharePointError__c error = assignPermission(opportunityFolderPath,
                                                     groupId,
                                                     permissionLevelId);
            if(error != null) {
                error.Opportunity__c = opp.Id;
                errorList.add(error);
            } else {
                Opportunity oppToUpdate = new Opportunity(Id = opp.Id, 
                                                          isPermissionAssigedinSP__c = true);
                OpportunityListToUpdate.add(oppToUpdate);
            } 
                                    
            
        }
    }
    
    global void finish(Database.BatchableContext BC) {
    
        if(errorList.Size() > 0) {
            insert errorList;
        }
        
        if(OpportunityListToUpdate.Size() > 0) {
            update OpportunityListToUpdate;
        }
        
    }
 
    global SharePointError__c assignPermission(String folderPath, String edit_deleteGroupId, String deletePermissionLevelId) {
        SharePointError__c error = null;
        
        /*String folderPath = '/Salesforce/Salesforce/2020/Saint Louis/testNewNam e #& ()';
        string edit_deleteGroupId = string.valueOf(740);
        String deletePermissionLevelId = string.valueOf(1073741929);*/
        
        String baseurl = 'https://midwestmach.sharepoint.com/_api/web/GetFolderByServerRelativePath(decodedurl=';
        String endbaseUrl = ')/ListItemAllFields/roleassignments/addroleassignment(principalid='+edit_deleteGroupId+',roleDefId='+deletePermissionLevelId+')';
        string endpoint = baseurl+'\''+EncodingUtil.urlEncode(folderPath, 'UTF-8').replace('+','%20')+'\''+endbaseUrl;
        
        
        HttpRequest request = new HttpRequest();   
        HttpResponse response = new HttpResponse();
        Http makeReq = new Http();
        
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Accept', 'application/json;odata=verbose');
        request.setHeader('content-Type', 'application/json;odata=verbose');
        request.setHeader('Content-Length', '0');
        
        request.setHeader('X-RequestDigest',SharePointRestServiceCallOut.requestDigestXml);
        request.setHeader('Cookie', SharePointRestServiceCallOut.cookie);
        
        if(!test.isrunningtest()) {
            response = makeReq.send(request);
        }

       if(response.getStatusCode() != 200 || test.isrunningtest()) 
       {
                    
            error = new SharePointError__c(
            Status_Code__c = 'statusCode: ' +String.valueOf(response.getStatusCode())+ 'status:' +response.getStatus(),
            Error__c = ' path:' +folderPath+ 'groupId:' +edit_deleteGroupId+ 'permissionLevel:' +deletePermissionLevelId,
            Type__c = 'Opportunity assign Permission');
            
        }
            
        
        return error;
    }
    
    
    global SharePointError__c breakInheritance(String folderPath ) {
    
        //String folderPath = '/Salesforce/Salesforce/2020/Saint Louis/testNewNam e #& ()';
        SharePointError__c error = null;
        String baseurl = 'https://midwestmach.sharepoint.com/_api/web/GetFolderByServerRelativePath(decodedurl=';
        String endbaseUrl=')/ListItemAllFields/breakroleinheritance(true)';
        string endpoint = baseurl+'\''+EncodingUtil.urlEncode(folderPath, 'UTF-8').replace('+','%20')+'\''+endbaseUrl;
        
        HttpRequest request = new HttpRequest();   
        HttpResponse response = new HttpResponse();
        Http makeReq = new Http();
        
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Accept', 'application/json;odata=verbose');
        request.setHeader('content-Type', 'application/json;odata=verbose');
        request.setHeader('Content-Length', '0');
        
        //SharePointRestServiceCallOut.authenticateSharePoint();
        request.setHeader('X-RequestDigest',SharePointRestServiceCallOut.requestDigestXml);
        request.setHeader('Cookie', SharePointRestServiceCallOut.cookie);
        
        if(!test.isrunningtest()) {
            response = makeReq.send(request);
        } else 
        {
            If(test.isrunningtest())
            {
            }
            If(test.isrunningtest())
            {
            }
                
        }
        
         

        return error;
    }

}