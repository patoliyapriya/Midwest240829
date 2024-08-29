@isTest
private class QuoteHeaderControllerTest {
    
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
        Product_Group__c grp = new Product_Group__c();
        grp.Name = 'Test Group';
        grp.Quote__c = quote.Id;
        grp.Index__c = 1;
        insert grp;

        // Create test Sub Groups
        List<Product_Group__c> subGroups = new List<Product_Group__c>();
        for (Integer i = 0; i < 1; i++) {
            Product_Group__c subGroup = new Product_Group__c(
                Name = 'Test SubGroup' + i,
                Parent_Product_Group__c = grp.Id,
                Quote__c = quote.Id
            );
            subGroups.add(subGroup);
        }
        insert subGroups;

        //select subgroup
        Product_Group__c subGroup1 = [SELECT Id FROM Product_Group__c WHERE Name='Test SubGroup0' LIMIT 1];

        // Create test Line Items
        List<Product_select__c> lineItems = new List<Product_select__c>();
        for (Integer i = 0; i < 2; i++) {
            Product_select__c lineItem = new Product_select__c(
                Sale_Type__c = 'B/R',
                Product_Group__c = subGroup1.Id,
                Quote__c = quote.Id
            );
            lineItems.add(lineItem);
        }
        insert lineItems;
    }

    @isTest
    static void testQuickSave() {
        // Retrieve test data
        Quote testQuote = [SELECT Id, Name, RecordType.Name, QuoteNumber, Opportunity.Office__c, Total_Base_Bid_Total__c, Hide_Total_Base_Bid_Total__c, Total_Extended_Cost__c,
                            Total_Direct_Sell_Price__c, Total_Buy_Resell_Price__c, Total_Buy_Resell_Margin__c, Total_Buy_Resell_Margin_Percentage__c,
                            Commissions_and_Rebates__c, Total_Project_Margin__c, Total_Project_Margin_Percentage__c, Quantity_Total__c, Is_Active_Project_Financials__c
                             FROM Quote LIMIT 1];
        List<Product_Group__c> testGroups = [SELECT Id, Name, Total_Group_Extended_Cost__c, Grand_Quantity_Total__c, 
                                            Total_Sub_Groups__c, Page_Break__c, Hide_Pricing__c, Alternate__c
                                             FROM Product_Group__c WHERE Name='Test Group' LIMIT 1];
        List<Product_Group__c> testSubGroups = [SELECT Id, Name, Total_Extended_Cost__c, Quantity_Total__c, Total_Line_Items__c,
                                                Parent_Product_Group__c, Hide_Quantity__c, Hide_Code__c, Hide_Amount__c,
                                                Hide_Pricing__c, Hide_Line__c, Alternate__c  
                                                FROM Product_Group__c WHERE Name='Test SubGroup0'];
        List<Product_select__c> testLineItems = [SELECT Id, Sale_Type__c, Tag__c, Product_Name__c, Product_Code__c, Quantity__c, List_Price__c, Multiplier__c,
                                                Unit_Cost__c, Margin_Percentage__c, Extended_Cost__c, Sales_Price__c, CR__c, Alternate__c, Product_Group__c,
                                                Descriptions__c, Hide_Quantity__c, Hide_Code__c, Hide_Line__c, Hide_Pricing__c, Page_Break__c, Release_pick__c 
                                                 FROM Product_select__c WHERE Quote__c =: testQuote.Id ];

        
        CartWrapper cartWrapper = new CartWrapper(testQuote);
        // Serialize CartWrapper
        String cartWrapperString = JSON.serialize(cartWrapper);

        // Test quickSave method
        Test.startTest();
        QuoteHeaderController.quickSave(cartWrapperString);
        Test.stopTest();

        // Verify that the records were updated
        List<Product_Group__c> updatedGroups = [SELECT Id, Name FROM Product_Group__c WHERE Id IN :testGroups];
        List<Product_Group__c> updatedSubGroups = [SELECT Id, Name, Parent_Product_Group__c FROM Product_Group__c WHERE Id IN :testSubGroups];
        List<Product_select__c> updatedLineItems = [SELECT Id, Name, Product_Group__c FROM Product_select__c WHERE Id IN :testLineItems];
        List<Quote> updatedQuotes = [SELECT Id, Name FROM Quote WHERE Id = :testQuote.Id];

        System.assertEquals(1, updatedGroups.size(), 'There should be 1 updated groups');
        System.assertEquals(1, updatedSubGroups.size(), 'There should be 1 updated subgroups');
        System.assertEquals(2, updatedLineItems.size(), 'There should be 2 updated line items');
        System.assertEquals(1, updatedQuotes.size(), 'There should be 1 updated quote');
    }
}