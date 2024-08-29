@isTest
private class QuoteLineItemQueryHelperTest {
    
    @testSetup
    static void setupTestData() {
        // Create test Account
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;

        // Create test Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = acc.Id
        );
        insert opp;

        // Create test Quote
        Quote quote = new Quote(
            Name = 'Test Quote',
            OpportunityId = opp.Id
        );
        insert quote;

        //create Test Group
        Product_Group__c testGroup = new Product_Group__c();
        testGroup.Name = 'Test Group';
        testGroup.Quote__c = quote.Id;
        testGroup.Index__c = 1;
        insert testGroup;

        //create Test SubGroups
        List<Product_Group__c> testSubGroups = new List<Product_Group__c>();
        for(Integer i=0;i<2;i++) {
            testSubGroups.add(new Product_Group__c(Name = 'Test SubGroup'+i, Quote__c = quote.Id, Parent_Product_Group__c = testGroup.Id, Index__c = i));
        }
        if(testSubGroups.size() > 0) {
            insert testSubGroups;
        }

        //select subgroup
        Product_Group__c subGroup1 = [SELECT Id FROM Product_Group__c WHERE Name='Test SubGroup0' LIMIT 1];

        // Create test Line Items
        List<Product_select__c> lineItems = new List<Product_select__c>();
        for (Integer i = 0; i < 4; i++) {
            Product_select__c lineItem = new Product_select__c(
                Product_Group__c = subGroup1.Id,
                Quote__c = quote.Id
            );
            lineItems.add(lineItem);
        }
        insert lineItems;
    }

    @isTest
    static void testGetLineItemsByQuoteId() {
        // Retrieve test Quote
        Quote testQuote = [SELECT Id FROM Quote LIMIT 1];

        // Test method
        List<Product_Select__c> lineItems = QuoteLineItemQueryHelper.getLineItemsByQuoteId(testQuote.Id);

        // Verify results
        System.assertEquals(4, lineItems.size(), 'There should be 4 line items related to the quote');
    }

    @isTest
    static void testGetLineItemsById() {
        // Retrieve a test Line Item
        Product_Select__c testLineItem = [SELECT Id FROM Product_select__c LIMIT 1];

        // Test method
        Product_Select__c lineItem = QuoteLineItemQueryHelper.getLineItemsById(testLineItem.Id);

        // Verify results
        System.assertNotEquals(null, lineItem, 'The line item should be retrieved successfully');
        System.assertEquals(testLineItem.Id, lineItem.Id, 'The retrieved line item ID should match the test line item ID');
    }

    @isTest
    static void testGetLineItemsByProductGroup() {
        // Retrieve test Product Groups
        Product_Group__c subGroup = [SELECT Id FROM Product_Group__c WHERE Name='Test SubGroup0' LIMIT 1];

        Set<Id> groupIds = new Set<Id>();
        groupIds.add(subGroup.Id);

        // Test method
        List<Product_Select__c> lineItems = QuoteLineItemQueryHelper.getLineItemsByProductGroup(groupIds);

        // Verify results
        System.assertEquals(4, lineItems.size(), 'There should be 4 line items related to the product groups');
    }

    @isTest
    static void testGetLineItemsByProductGroupId() {
        // Retrieve a test Product Group
        Product_Group__c testGroup = [SELECT Id FROM Product_Group__c LIMIT 1];

        // Test method
        List<Product_Select__c> lineItems = QuoteLineItemQueryHelper.getLineItemsByProductGroupId(testGroup.Id);

        // Verify results
        System.assertEquals(2, lineItems.size(), 'There should be 2 line items related to the product group');
    }

    @isTest
    static void testGetCountofLineItems() {
        // Retrieve a test Product Group
        Product_Group__c testGroup = [SELECT Id FROM Product_Group__c LIMIT 1];

        // Test method
        Integer count = QuoteLineItemQueryHelper.getCountofLineItems(testGroup.Id);

        // Verify results
        System.assertEquals(2, count, 'The count of line items related to the product group should be 2');
    }
}