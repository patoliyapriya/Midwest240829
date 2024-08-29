/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 10-30-2023
 * @last modified by  : Nilesh Badrakiya
**/
@isTest
public with sharing class SharePointIntermidiateControllerTest {

  @testSetup
  static void setup(){

    Opportunity opp = new Opportunity();
    opp.Name = 'Test Opportunity';
    opp.StageName = 'Prospecting';
    opp.closeDate = Date.today();
    opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Equipment').getRecordTypeId();
    insert opp;

    Profile p = [select id from profile where name='Standard User'];
    User testUserInfo = new User(firstName = 'Test', LastName = 'User', alias = 'Uusers', 
                                email='user123test@example.com', emailencodingkey='UTF-8', 
                                languagelocalekey='en_US', localesidkey='en_US',
                                profileid = p.Id,timezonesidkey='America/Los_Angeles',
                                Username = 'user123test@example.com',IsActive = true);
    insert testUserInfo;
    System.debug('Test user inserted is ' + testUserInfo );

    ContentFolder folders = new ContentFolder(Name = 'Test Opportunity Folder');
    insert folders;   
  }

  static testMethod void testOpenSharepointFolder() {
    Opportunity opp = [select Id from Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
    // Instantiate the controller with the Opportunity's Id and type parameter
    SharePointIntermidiateController controller = new SharePointIntermidiateController();
    controller.opportunityId = opp.Id;
    controller.type = 'createFolder';
    
    //openSharepointFolder method
    PageReference result = controller.openSharepointFolder();
    
    // Verify that the PageReference is not null and is redirected
    System.assertNotEquals(null, result);
    System.assertEquals(true, result.getRedirect());
    
    //sharePointPageUrl.fetchSharePointPageUrl
    SharePointIntermidiateController controller2 = new SharePointIntermidiateController();
    controller2.opportunityId = opp.Id;
    controller2.type = '';
    
    PageReference result2 = controller2.openSharepointFolder();
    
    System.assertNotEquals(null, result2);
    System.assertEquals(true, result2.getRedirect());
  }

  //sharePointPageUrl.isDenverUser method.
  static testMethod void testIsDenverUser() {
    Group testGroup = new Group(Name = 'Test Group');
    insert testGroup;

    Profile p = [select id from profile where name='Standard User'];
    User testUser = new User(firstName = 'Test', LastName = 'cityDenver', alias = 'stand', 
                            email='standarduser1@test.com', emailencodingkey='UTF-8', languagelocalekey='en_US',
                            localesidkey='en_US', profileid = p.Id, Office_Location__c = 'Denver',
                            timezonesidkey='America/Los_Angeles', Username = 'testdenver123@test.com',IsActive = true);
    
    insert testUser;
    system.debug('testUser :- '+testUser);
    System.runAs(testUser) {
        System.assertEquals(false, sharePointPageUrl.isDenverUser(testGroup.Id));
        Boolean result1 = sharePointPageUrl.isCurrentUserFromEngineeredProducts(testUser);
    }
    
     // Call the method createFolderInSharepoint
    Opportunity opp = [select Id, RecordTypeId from Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
    Test.startTest();
    sharePointPageUrl.createFolderInSharepoint(opp.Id);
    Test.stopTest();
      
     //Assert the result
    List<ContentFolder> folders = [SELECT Id FROM ContentFolder WHERE Name = 'Test Opportunity Folder'];
    System.assertEquals(1, folders.size());
  }

  //UtilitySharePointToSFIntegration controller data.
  static testMethod void testUtilitySharePointToSF() {
    Opportunity opp = [select Id, RecordTypeId from Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
    Quote testQuote = new Quote(Name = 'Test Quote', Original_Name__c = 'Test Quote Name', OpportunityId = opp.Id);
    insert testQuote;

    String quoteFolderName = UtilitySharePointToSFIntegration.fetchQuoteFolderName(testQuote);
    System.assertEquals('Test Quote Name', quoteFolderName);

    Map<Integer,String> equFolder = UtilitySharePointToSFIntegration.getequipmentOpportunityFolders();

    String result = UtilitySharePointToSFIntegration.assigneSharepointRootFolder(opp);

    User testUserDetail = [Select Id, Email, LastName, Office_Location__c, isActive FROM User WHERE UserName ='user123test@example.com' Limit 1];
    System.debug('User is ' + testUserDetail);
    system.runAs(testUserDetail){
      Boolean isFromEP = UtilitySharePointToSFIntegration.isCurrentUserFromEngineeredProducts();
      UtilitySharePointToSFIntegration.repairOpportunityFolders.clear();
      Map<Integer,String> folderNames = UtilitySharePointToSFIntegration.repairOpportunityFolders;    
    }
  } 
}