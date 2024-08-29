@isTest
private class GenerateQuoteDocumentControllerTest {
 
    static testMethod void testMethod1() {
        
        RecordType oppType = [SELECT ID,Name From RecordType WHERE Name =: 'Equipment'];
         
        //Test.setMock(HttpCalloutMock.class, new MockHttpSharePointResponseGenerator());
         
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.closeDate = Date.today();
        objOpportunity.Name = 'Test Opportunity';
        objOpportunity.stageName = 'Draft';
        objOpportunity.RecordTypeId =oppType .Id;
        insert objOpportunity;
        
        Quote newQuote = new Quote();
        newQuote.Name = 'Test Quote';
        newQuote.opportunityId = objOpportunity.Id;
        newQuote.Scope_Revision_Number__c = '01';
        newQuote.Submittal_Revision_Number__c = '01';
        insert newQuote;
        
        Product_Group__c objParentProductGroup = new Product_Group__c();
        objParentProductGroup.Name = 'Parent Group';
        objParentProductGroup.Quote__c = newQuote.Id;
        insert objParentProductGroup;
        
        Product_Group__c objChildProductGroup = new Product_Group__c();
        objChildProductGroup.Name = 'Parent Group';
        objChildProductGroup.Quote__c = newQuote.Id;
        objChildProductGroup.Parent_Product_Group__c = objParentProductGroup.Id;
        insert objChildProductGroup;
        
        Product_Select__c objParentLineItem = new Product_Select__c();
        objParentLineItem.Product_Name__c = 'Parent Product Name';
        objParentLineItem.Quote__c = newQuote.Id;
        objParentLineItem.Product_Group__c = objChildProductGroup.Id;
        insert objParentLineItem;
        
        Product_Select__c objChildLineItem = new Product_Select__c();
        objChildLineItem.Product_Name__c = 'Child Product Name';
        objChildLineItem.Quote__c = newQuote.Id;
        objChildLineItem.Product_Group__c = objChildProductGroup.Id;
        insert objChildLineItem;
        
        // SharePointRestServiceCallOut mock data
        String folderName = 'TestFolder';
        String fileName = 'TestFile.txt';
        Blob body = Blob.valueOf('Test Body');

         // Set the request digest and cookie values
         String requestDigestXml = '<requestDigest>1234567890</requestDigest>';
         String cookie = 'cookie_value';

        // Set the values for path, grpId, and permissionLevelId
        String path = '/Documents/Test Folder';
        String grpId = '1234567890';
        String permissionLevelId = '1234567890';

        Test.setMock(HttpCalloutMock.class, new MockHttpSharePointResponseGenerator());
        HttpResponse res = SharePointRestServiceCallOut.createFile(folderName, fileName, body);

        Integer statusCode = SharePointRestServiceCallOut.assignFolderPermission(path, grpId, permissionLevelId, objOpportunity.Id);

        Test.StartTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(newQuote);
        GenerateQuoteDocumentController objGenerateQuoteDocumentController = new GenerateQuoteDocumentController(sc);   
        objGenerateQuoteDocumentController.generateAttachment();
        
        
        GenerateScopeDocumentController objGenerateScopeDocumentController = new GenerateScopeDocumentController(sc);
        objGenerateScopeDocumentController.generateAttachment();
  
        GenerateSubmittalController objGenerateSubmittalController = new GenerateSubmittalController(sc);
        objGenerateSubmittalController.generateAttachment();
        Database.executeBatch(new createfolderForOpportunity(objOpportunity.id));
  
        Test.StopTest();
        
        PageReference pageRef = Page.GeneratePdfOnQuote;
        Test.setCurrentPage(pageRef);
    
    }

}