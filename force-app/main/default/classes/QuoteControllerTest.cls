/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 04-12-2024
 * @last modified by  : Nilesh Badrakiya
**/
@isTest
private class QuoteControllerTest {

    @testSetup
    static void setup() {
        // Create a test user
        Profile userProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1]; // Assuming you have a profile named 'Standard User'
        User testUser = new User(
            ProfileId = userProfile.Id,
            Username = 'testusermidwest@example.com',
            Email = 'testuser@example.com',
            LastName = 'Test',
            FirstName = 'User',
            Alias = 'tuser',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            IsActive = true
        );
        insert testUser;

        //Create Test Account
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc; 

        //Create Test Contact
        Contact con = new Contact();
        con.LastName = 'Test Contact';
        con.AccountId = acc.Id;
        con.Title = 'Mr';
        insert con; 

        //Create Test Opp
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.Office__c = 'Midwest Machinery STL';
        opp.Attention_to__c = con.Id;
        opp.Opportunity_Source__c = 'Marketing';
        opp.AccountId = acc.Id;
        opp.OwnerId = testUser.Id;
        opp.CloseDate = System.today();
        opp.StageName = 'Lead';
        opp.Probability = 80;
        opp.Parts_Needed__c = 'Notes Added';
        insert opp;

        //create Test Quote
        Quote testQuote = new Quote(
            Name = 'Test Quote',
            opportunityId = opp.Id,
            Total_Direct_Sell_Price__c = 100.00,
            Total_Buy_Resell_Margin__c = 50.00,
            Commissions_and_Rebates__c = 10.00,
            Total_Buy_Resell_Price__c = 60.00
        );

        insert testQuote;
        
        //create Test Group
        Product_Group__c testGroup = new Product_Group__c();
        testGroup.Name = 'Test Group';
        testGroup.Quote__c = testQuote.Id;
        testGroup.Index__c = 1;
        insert testGroup;

        //create Test Product
        Product2 testProduct = new Product2();
        testProduct.Name = 'Test Product';
        testProduct.ProductCode = 'TP';
        insert testProduct;

        //create Test SubGroups
        List<Product_Group__c> testSubGroups = new List<Product_Group__c>();
        for(Integer i=0;i<2;i++) {
            testSubGroups.add(new Product_Group__c(Name = 'Test SubGroup'+i, Quote__c = testQuote.Id, Parent_Product_Group__c = testGroup.Id, Index__c = i));
        }
        if(testSubGroups.size() > 0) {
            insert testSubGroups;
        }

        //select subgroup
        Product_Group__c subGroup1 = [SELECT Id FROM Product_Group__c WHERE Name='Test SubGroup0' LIMIT 1];

        //create Test LineItems
        List<Product_Select__c> testLineItems = new List<Product_Select__c>();
        for(Integer i=0;i<2;i++) {
            testLineItems.add(new Product_Select__c(Sale_Type__c = 'B/R', Quote__c = testQuote.Id, Product_Group__c = subGroup1.Id));
        }
        if(testLineItems.size() > 0) {
            insert testLineItems;
        }
    }

    @isTest
    static void testGetCartWrapper() {
        // Get the first test quote by using a SOQL query
        Quote qt = [SELECT Id FROM Quote WHERE Name='Test Quote' LIMIT 1];

        Test.startTest();
        CartWrapper result = QuoteController.getCartWrapper(qt.Id);
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

}