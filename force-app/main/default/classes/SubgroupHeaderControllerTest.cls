@isTest
private class SubgroupHeaderControllerTest {

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
        List<Product_Select__c> lineItems = new List<Product_Select__c>();
        for (Integer i = 0; i < 4; i++) {
            Product_Select__c lineItem = new Product_Select__c(
                Product_Group__c = subGroup1.Id,
                Quote__c = quote.Id
            );
            lineItems.add(lineItem);
        }
        insert lineItems;
    }

    @isTest
    static void testCloneSubGroup() {
        // Retrieve test data
        Product_Group__c grp = [SELECT Id FROM Product_Group__c WHERE Name='Test SubGroup0' LIMIT 1];
        Id quoteId = [SELECT Id FROM Quote LIMIT 1].Id;

        // Call method
        Test.startTest();
        SubgroupHeaderController.cloneSubGroup(grp.Id, quoteId);
        Test.stopTest();

        // // Verify the clone
        // List<Product_Group__c> subGroups = [SELECT Id FROM Product_Group__c WHERE Parent_Product_Group__c = :quoteId];
        // System.assertEquals(4, subGroups.size(), 'There should be 4 sub groups in total after cloning');

        // List<Product_Select__c> lineItems = [SELECT Id FROM Product_Select__c WHERE Product_Group__c = :subGroups[3].Id];
        // System.assertEquals(2, lineItems.size(), 'The cloned sub group should have 2 line items');
    }

    @isTest
    static void testGetGroupDetails() {
        // Retrieve test data
        Product_Group__c grp = [SELECT Id, Parent_Product_Group__c FROM Product_Group__c LIMIT 1];

        // Call method
        String parentProductGroupId = SubgroupHeaderController.getGroupDetails(grp.Id);

        // Verify result
        System.assertEquals(grp.Parent_Product_Group__c, parentProductGroupId, 'The parent product group ID should match');
    }

    @isTest
    static void testGetsubGroupRowIndex() {
        // Retrieve test data
        Product_Group__c grp = [SELECT Id, Index__c FROM Product_Group__c LIMIT 1];

        // Call method
        Decimal rowIndex = SubgroupHeaderController.getsubGroupRowIndex(grp.Id);

        // Verify result
        System.assertEquals(grp.Index__c, rowIndex, 'The row index should match');
    }

    @isTest
    static void testSubGrouprowIndexUpdate() {
        // Retrieve test data
        Product_Group__c grp = [SELECT Id, Index__c FROM Product_Group__c LIMIT 1];

        // Call method
        Decimal newIndex = grp.Index__c + 1;
        SubgroupHeaderController.subGrouprowIndexUpdate(grp.Id, newIndex);

        // Verify result
        // Product_Group__c updatedGroup = [SELECT Id, Index__c FROM Product_Group__c WHERE Id = :grp.Id];
        // System.assertEquals(newIndex, updatedGroup.Index__c, 'The row index should be updated correctly');
    }

    @isTest
    static void testUpdateRowIndex() {
        // Retrieve test data
        List<Product_Group__c> groups = [SELECT Id, Parent_Product_Group__c, Index__c FROM Product_Group__c ORDER BY Index__c LIMIT 2];

        // Call method
        SubgroupHeaderController.updateRowIndex(groups[1].Index__c, groups[0].Parent_Product_Group__c, groups[1].Id, groups[0].Index__c);

        // Verify result
        Product_Group__c updatedGroup1 = [SELECT Id, Index__c FROM Product_Group__c WHERE Id = :groups[0].Id];
        Product_Group__c updatedGroup2 = [SELECT Id, Index__c FROM Product_Group__c WHERE Id = :groups[1].Id];
        System.assert(updatedGroup1.Index__c < updatedGroup2.Index__c, 'The row indices should be updated correctly');
    }

    @isTest
    static void testUpdateGroup() {
        // Retrieve test data
        List<Product_Group__c> groups = [SELECT Id, Parent_Product_Group__c,Index__c FROM Product_Group__c LIMIT 2];

        // Call method
        Decimal newindex = groups[1].Index__c + 1;
        SubgroupHeaderController.updateGroup(groups[0].Id, groups[1].Id, newindex);

        // Verify result
        Product_Group__c updatedGroup = [SELECT Id, Parent_Product_Group__c, Index__c FROM Product_Group__c WHERE Id = :groups[1].Id];
        System.assertEquals(groups[0].Id, updatedGroup.Parent_Product_Group__c, 'The parent group ID should be updated');
        System.assertEquals(newindex, updatedGroup.Index__c, 'The index should be updated');
    }
}