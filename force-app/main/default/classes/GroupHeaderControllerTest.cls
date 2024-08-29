@IsTest
public class GroupHeaderControllerTest {

    @TestSetup
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

    @IsTest
    static void testCloneGroup() {
        // Retrieve test data
        Quote testQuote = [SELECT Id FROM Quote LIMIT 1];
        Product_Group__c testGroup = [SELECT Id,External_Id__c FROM Product_Group__c WHERE Name = 'Test Group' LIMIT 1];

        // Call the method
        Test.startTest();
        GroupHeaderController.cloneGroup(testGroup.Id, testQuote.Id);
        Test.stopTest();

        // Verify the cloned group
        Product_Group__c clonedGroup = [SELECT Id, External_Id__c, Index__c FROM Product_Group__c WHERE External_Id__c != 'Group1' LIMIT 1];
        System.assertNotEquals(testGroup.External_Id__c, clonedGroup.External_Id__c);
        System.assertEquals(2, clonedGroup.Index__c);

        // Verify the cloned subgroups
        List<Product_Group__c> clonedSubGroups = [SELECT Id, Parent_Product_Group__c, External_Id__c FROM Product_Group__c WHERE Parent_Product_Group__c = :clonedGroup.Id];
        System.assertEquals(2, clonedSubGroups.size());

        // Verify the cloned line items
        List<Product_Select__c> clonedLineItems = [SELECT Id, Product_Group__c, Product_Name__c FROM Product_Select__c WHERE Product_Group__c IN :clonedSubGroups];
        System.assertEquals(4, clonedLineItems.size());
    }
}