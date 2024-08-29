global class sharePointPageUrl {
public Static Boolean DenverUser;   
public static final string DENVER_CITY = 'Denver'; 
Public static User currentUser ;
 public static Boolean isDenverUser(String groupName) {
     try {
            DenverUser = UtilitySharePointToSFIntegration.isCurrentUserExistInGroup(groupName);
        } catch(Exception ex) {
            
            string message = 'Somthing went wrong while determining the user Group Error details : ';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, message+ex));
        }
     return DenverUser;
 }

     public static Boolean isCurrentUserFromEngineeredProducts(User owner) {
        try { 
                if(owner.Office_Location__c.equalsIgnoreCase(DENVER_CITY)) {
                    return true;
                } else {
                    return false;
                }
        } catch(Exception ex) {
            return false;
        }
        
    }
 
  webservice static String fetchSharePointPageUrl(String opportunityId) {
    Opportunity oppRecord = [SELECT Id,
                                    OriginalName__c,
                                    Opportunity_Number__c,
                                    CreatedById,
                                    CreatedDate,
                                    RecordType.Name,Office__c
                            FROM Opportunity 
                            WHERE Id =: opportunityId];
    User oppOwner = [SELECT Office_Location__c FROM User WHERE Id = :oppRecord.CreatedById];
    String officeName = UtilitySharePointToSFIntegration.assigneSharepointRootFolder(oppRecord);
    String url;
    String folderName = oppRecord.Opportunity_Number__c +' '+oppRecord.OriginalName__c;
    
    String folderURL = 'https://midwestmach.sharepoint.com/';
    if (isCurrentUserFromEngineeredProducts(oppOwner)) {
        folderURL = folderURL + 'Engineered Products/';
    } else {
        folderURL = folderURL + 'Salesforce/';
    }
    
    folderURL = folderURL + 'Forms/AllItems.aspx?id=/';
    
    String opportunityFolderPath;
    if (isCurrentUserFromEngineeredProducts(oppOwner)) {
        opportunityFolderPath = 'Engineered Products/Salesforce/';
    } else {
           opportunityFolderPath = 'Salesforce/Salesforce/';
    }
    opportunityFolderPath = opportunityFolderPath + oppRecord.CreatedDate.Year();
    if(officeName != null && !isCurrentUserFromEngineeredProducts(oppOwner)) {
            opportunityFolderPath = opportunityFolderPath + '/' + officeName;
    }
    opportunityFolderPath = opportunityFolderPath + '/' + folderName;

    system.debug('encoded url==>>'+EncodingUtil.urlEncode(opportunityFolderPath, 'UTF-8'));
    
    opportunityFolderPath = EncodingUtil.urlEncode(opportunityFolderPath, 'UTF-8');
    folderURL = folderURL + opportunityFolderPath ;
    system.debug('folderURL==>'+folderURL);
    return folderURL;
  
  }

    webservice static void createFolderInSharepoint(String opportunityId) {
        Opportunity opp = [SELECT Id,
                                  Name 
                            FROM Opportunity 
                            WHERE Id =: opportunityId];

        opp.OriginalName__c = opp.Name.replaceAll('[^a-zA-Z0-9\\s+]', ' ');
        update opp;

        Database.executeBatch(new createfolderForOpportunity(opportunityId));

    }

}