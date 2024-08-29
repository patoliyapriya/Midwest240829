@isTest
public class NewGroupModalControllerTest {
    
    @isTest
    static void testCreateGroup() {
        // Setup test data
        Account account = new Account(Name = 'Test Account');
        insert account;

        Opportunity opp = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today(), AccountId = account.Id);
        insert opp;

        Quote quote = new Quote(Name = 'Test Quote', OpportunityId = opp.Id);
        insert quote;
        
        String groupName = 'Test Group';
        String subGroupName = 'Test SubGroup0';
        
        // Test the createGroup method
        Test.startTest();
        NewGroupModalController.createGroup(quote.Id, groupName, subGroupName);
        Test.stopTest();
        
        // Verify the results
        List<Product_Group__c> groups = [SELECT Id, Name, Quote__c FROM Product_Group__c WHERE Quote__c = :quote.Id AND Parent_Product_Group__c = NULL ];
        System.assertEquals(1, groups.size(), 'There should be one group created');
        System.assertEquals(groupName, groups[0].Name, 'The group name should match');
        
        List<Product_Group__c> subGroups = [SELECT Id, Name FROM Product_Group__c WHERE Quote__c = :quote.Id AND Parent_Product_Group__c =:groups[0].Id];
        System.assertEquals(1, subGroups.size(), 'There should be one subgroup created');
        System.assertEquals(subGroupName, subGroups[0].Name, 'The subgroup name should match');
    }
}