@isTest
private class OpportunityControllerTest {

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

        //create Test LineItems
        List<Product_Select__c> testLineItems = new List<Product_Select__c>();
        for(Integer i=0;i<2;i++) {
            testLineItems.add(new Product_Select__c(Sale_Type__c = 'B/R', Quote__c = quote.Id, Product_Group__c = subGroup1.Id));
        }
        if(testLineItems.size() > 0) {
            insert testLineItems;
        }
    }

    // @isTest
    // static void testGetQuoteListByOpportunity() {
    //     // Retrieve test Opportunity
    //     Opportunity testOpportunity = [SELECT Id FROM Opportunity LIMIT 1];

    //     // Test getQuoteListByOpportunity method
    //     Test.startTest();
    //     List<OpportunityController.WrapperQuoteList> result = OpportunityController.getQuoteListByOpportunity(testOpportunity.Id);
    //     Test.stopTest();

    //     // Verify the result
    //     // System.assertNotEquals(null, result, 'List should not be null');
    //     // System.assert(result.size() > 0, 'List should not be empty');
    //     // System.assertEquals(result[0].oldQuote.Name, 'Test Quote', 'The name of the first quote should be "Test Quote"');
    // }

    // @isTest
    // static void testCloneOpportunity() {
    //     // Retrieve test Opportunity
    //     Opportunity testOpportunity = [SELECT Id FROM Opportunity LIMIT 1];

    //     // Create WrapperQuoteList JSON string
    //     List<OpportunityController.WrapperQuoteList> quoteWrappers = new List<OpportunityController.WrapperQuoteList>();
    //     for (Quote quote : [SELECT Id FROM Quote]) {
    //         quoteWrappers.add(new OpportunityController.WrapperQuoteList(quote));
    //     }
    //     String opportunityQuotes = JSON.serialize(quoteWrappers);

    //     // Test cloneOpportunity method
    //     Test.startTest();
    //     Id newOpportunityId = OpportunityController.cloneOpportunity(testOpportunity.Id, 'Cloned Opportunity', opportunityQuotes);
    //     Test.stopTest();

    //     // Verify the result
    //     Opportunity newOpportunity = [SELECT Id, Name, StageName FROM Opportunity WHERE Id = :newOpportunityId];
    //     System.assertNotEquals(null, newOpportunity, 'New Opportunity should not be null');
    //     System.assertEquals('Cloned Opportunity', newOpportunity.Name, 'The name of the new Opportunity should be "Cloned Opportunity"');
    //     System.assertEquals('Bidding', newOpportunity.StageName, 'The stage name of the new Opportunity should be "Bidding"');

    //     // Verify that quotes were cloned
    //     List<Quote> newQuotes = [SELECT Id, Name, OpportunityId FROM Quote WHERE OpportunityId = :newOpportunityId];
    //     System.assert(newQuotes.size() > 0, 'There should be at least one cloned quote');
    //     System.assertEquals(newOpportunityId, newQuotes[0].OpportunityId, 'The OpportunityId of the cloned quote should match the new Opportunity');
    // }

    @isTest
    static void testCloneQuotes() {
        // Retrieve test Opportunity and Quote
        Opportunity testOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        Quote testQuote = [SELECT Id FROM Quote LIMIT 1];

        // Create new Opportunity
        Opportunity newOpportunity = testOpportunity.clone(false, false, false, false);
        newOpportunity.Name = 'Cloned Opportunity';
        newOpportunity.StageName = 'Bidding';
        newOpportunity.CloseDate = System.today();
        insert newOpportunity;

        // Create WrapperQuoteList JSON string
        // List<OpportunityController.WrapperQuoteList> quoteWrappers = new List<OpportunityController.WrapperQuoteList>();
        // quoteWrappers.add(new OpportunityController.WrapperQuoteList(testQuote));
        // String opportunityQuotes = JSON.serialize(quoteWrappers);

        // Test cloneQuotes method
        // Test.startTest();
        // OpportunityController.cloneQuotes(newOpportunity.Id, opportunityQuotes);
        // Test.stopTest();

        // Verify that quotes were cloned
        List<Quote> newQuotes = [SELECT Id, Name, OpportunityId FROM Quote WHERE OpportunityId = :newOpportunity.Id];
        System.assert(newQuotes.size() > 0, 'There should be at least one cloned quote');
        System.assertEquals(newOpportunity.Id, newQuotes[0].OpportunityId, 'The OpportunityId of the cloned quote should match the new Opportunity');
    }

    @isTest
    static void testCloneGroups() {
        // Retrieve test Quote
        Quote testQuote = [SELECT Id, OpportunityId FROM Quote LIMIT 1];

        // Create new Quote
        Quote newQuote = testQuote.clone(false, false, false, false);
        newQuote.OpportunityId = testQuote.OpportunityId;
        newQuote.Name = 'Cloned Quote';
        insert newQuote;

        // Test cloneGroups method
        Test.startTest();
        OpportunityController.cloneGroups(testQuote.Id, newQuote.Id);
        Test.stopTest();

        // Verify that groups and line items were cloned
        List<Product_Group__c> newGroups = [SELECT Id, Quote__c FROM Product_Group__c WHERE Quote__c = :newQuote.Id];
        System.assert(newGroups.size() > 0, 'There should be at least one cloned group');
        System.assertEquals(newQuote.Id, newGroups[0].Quote__c, 'The Quote__c of the cloned group should match the new Quote');

        List<Product_select__c> newLineItems = [SELECT Id, Quote__c FROM Product_select__c WHERE Quote__c = :newQuote.Id];
        System.assert(newLineItems.size() > 0, 'There should be at least one cloned line item');
        System.assertEquals(newQuote.Id, newLineItems[0].Quote__c, 'The Quote__c of the cloned line item should match the new Quote');
    }
}