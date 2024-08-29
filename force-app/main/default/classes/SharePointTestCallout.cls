@isTest
private class SharePointTestCallout {

        @isTest static void testSharepointBatch() {
           // create folder for current year
           String PathForYearFolder = UtilitySharePointToSFIntegration.MainFolderOpeningPath+ 
                                      Date.Today().Year()+
                                      UtilitySharePointToSFIntegration.MainFolderClosingPath;
           
           PathForYearFolder = PathForYearFolder.replace(' ','%20'); 
           Test.setMock(HttpCalloutMock.class, new MockHttpSharePointResponseGenerator());                      
           SharePointRestServiceCallOut.authenticateSharePoint();
           SharePointRestServiceCallOut.createFolder(PathForYearFolder);
           Blob body =  blob.valueOf('Unit.Test');
           SharePointRestServiceCallOut.breakInheritanceForFolder(PathForYearFolder,null);
           SharePointRestServiceCallOut.assignFolderPermission(PathForYearFolder,'12','23',null);
           
               
        }
}