@isTest
public with sharing class ManageProductControllerTest {

    @testSetup
    static void setup() {
        
        // Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        Pricebook2 standardPricebook= new Pricebook2(Name='Standard Price Book 2009',Description ='Price Book 2009 Products',IsActive = true);
        insert standardPricebook;

        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < 5; i++) {
            products.add(new Product2(Name='Test Product ' + i, ProductCode='P000' + i, Family='Test Family', isActive=true));
        }
        insert products;

        Id pricebookId = Test.getStandardPricebookId();

        // Step 3: Retrieve inserted Product2 records
        List<Product2> insertedProducts = [SELECT Id FROM Product2 WHERE Name LIKE 'Test Product %'];

        // Step 4: Create PricebookEntry records for each Product2
        List<PricebookEntry> entries = new List<PricebookEntry>();
        for (Product2 product : insertedProducts) {
            entries.add(new PricebookEntry(Product2Id=product.Id, Pricebook2Id=pricebookId, UnitPrice=100, isActive=true));
        }
        insert entries;

        Product2 pr = new Product2(Name='Freight',IsActive=true, Midwest_Group_Office__c = 'Spark');
        insert pr;

        

        // List<PricebookEntry> entries = new List<PricebookEntry>();
        //     entries.add(new PricebookEntry(Product2Id=pr.Id, Pricebook2Id=pricebookId, UnitPrice=100, isActive=true));
        // insert entries;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.Office__c = 'Midwest Machinery STL';
        opp.Opportunity_Source__c = 'Marketing';
        opp.CloseDate = System.today();
        opp.StageName = 'Lead';
        opp.Probability = 80;
        opp.Parts_Needed__c = 'Notes Added';
        insert opp;

        Quote newQuote = new Quote();
        newQuote.Name = 'Test Quote';
        newQuote.opportunityId = opp.Id;
        newQuote.Scope_Revision_Number__c = '01';
        newQuote.Submittal_Revision_Number__c = '01';
        insert newQuote;
    }

    @isTest
    static void testGetProducts() {
        Test.startTest();
        List<ProductWrapper> productWrappers = ManageProductController.getProducts('Midwest Machinery STL', 'Test Product ');
        Test.stopTest();
    }

    @isTest
    static void testGetNextProducts() {
        Test.startTest();
        List<ProductWrapper> productWrappers = ManageProductController.getNextProducts('Midwest Machinery STL', 'Test Product 2', 'Test Product ');
        Test.stopTest();
    }

    @isTest
    static void testGetPreviousProducts() {
        Test.startTest();
        List<ProductWrapper> productWrappers = ManageProductController.getPreviousProducts('Midwest Machinery STL', 'Test Product 2', 'Test Product ');
        Test.stopTest();
    }

    @isTest
    static void testGetTotalProducts() {
        Test.startTest();
        Integer totalProducts = ManageProductController.getTotalProducts('Midwest Machinery STL', 'Test Product ');
        Test.stopTest();
    }

    @isTest
    static void testAddLineItems() {

        Product_Group__c subgroup = new Product_Group__c(Name='Test Subgroup');
        insert subgroup;
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'Test Quote'];
       
        List<Product2> products = [SELECT Id FROM Product2 LIMIT 2];

        Test.startTest();
        ManageProductController.addLineItems(new List<Id>{products[0].Id, products[1].Id}, subgroup.Id, quote.Id, false);
        
        Test.stopTest();

        List<Product_Select__c> lineItems = [SELECT Id FROM Product_Select__c WHERE Product_Group__c = :subgroup.Id];
    }

    // @isTest
    // static void testMarrsAddLineItems() {

    //     Product_Group__c subgroup = new Product_Group__c(Name='Test Subgroup');
    //     insert subgroup;
    //     Quote quote = [SELECT Id FROM Quote WHERE Name = 'Test Quote'];

    //     List<PricebookEntry> pricebookEntries = [SELECT Id, Product2Id, Pricebook2Id, UnitPrice, isActive FROM PricebookEntry WHERE Pricebook2Id = :pricebookId];
       
    //     List<Product2> products = [SELECT Id FROM Product2 LIMIT 2];

    //     Test.startTest();
    //     ManageProductController.addLineItems(new List<Id>{products[0].Id, products[1].Id}, subgroup.Id, quote.Id, false);
        
    //     Test.stopTest();

    //     List<Product_Select__c> lineItems = [SELECT Id FROM Product_Select__c WHERE Product_Group__c = :subgroup.Id];
    //     // System.assertEquals(2, lineItems.size());
    // }

    // @isTest
    // static void testMarrsAddLineItems() {
    //     // Create test data
    //     // Create a Pricebook
    //     Pricebook2 testPricebooks = new Pricebook2(Name = 'Test Pricebook', IsActive = true);
    //     insert testPricebooks;
        
    //     // Create a Product2
    //     Product2 testProduct= new Product2(Name = 'Test Product', ProductCode = 'TP001', Family = 'Test Family', Product_Description__c = 'Test Description', Manufacturer__c = 'Test Manufacturer', Product_Type__c = 'Test Type');
    //     insert testProduct;
        
    //     Id Pricebook2Id = Test.getStandardPricebookId();

    //     // Create a PricebookEntry
    //     PricebookEntry testPricebookEntry = new PricebookEntry(Product2Id = testProduct.Id, Pricebook2Id = pricebookId, UnitPrice = 100, IsActive = true);
    //     insert testPricebookEntry;
        
    //     // Create a Quote
    //     Quote testQuote = new Quote(Name = 'Test Quote', Pricebook2Id = testPricebooks.Id, Status = 'Draft');
    //     insert testQuote;
        
    //     // Create a SubGroup (for example purposes, assuming you have this custom object)
    //     Product_Group__c testSubGroup = new Product_Group__c(Name = 'Test SubGroup');
    //     insert testSubGroup;

    //     // Fetch IDs
    //     Id productId = testProduct.Id;
    //     Id subGroupId = testSubGroup.Id;
    //     Id quoteId = testQuote.Id;
        
    //     // Test data setup
    //     List<Id> productIds = new List<Id>{ productId };
    //     Boolean isMarrs = true; // Set to true if needed
        
    //     // Call the method
    //     Test.startTest();
    //     ManageProductController.addLineItems(productIds, subGroupId, quoteId, isMarrs);
    //     Test.stopTest();
        
    //     // Verify results
    //     List<Product_Select__c> lineItems = [SELECT Id, Product_Name__c, Quantity__c, Sales_Price__c, Quote__c, Row_Index__c, Product_Code__c, List_Price__c, Descriptions__c, Family__c, Manufacturer__c, Product_Type__c, Sale_Type__c, ProductId__c FROM Product_Select__c WHERE Quote__c = :quoteId];
        
        
    //     Product_Select__c lineItem = lineItems[0];
    // }
}