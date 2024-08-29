@isTest
public class DesignQuoteHeaderControllerTest {


    @IsTest
    static void testQuickSave() {
        // Prepare test data
        List<Product_Group__c> groups = new List<Product_Group__c>();
        List<Product_Group__c> subGroups = new List<Product_Group__c>();
        List<Product_Select__c> lineItems = new List<Product_Select__c>();

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

        for (Integer i = 0; i < 1; i++) {
            Product_Group__c parentgrp = new Product_Group__c(Name = 'Group' + i, Quote__c = quote.Id);
            groups.add(parentgrp);
        }
        insert groups;

        for (Product_Group__c grp1 : groups) {
            for (Integer i = 0; i < 2; i++) {
                Product_Group__c subGroup = new Product_Group__c(Name = 'SubGroup' + i, Parent_Product_Group__c = grp1.Id, Quote__c = quote.Id);
                subGroups.add(subGroup);
            }
        }
        insert subGroups;

        for (Product_Group__c subGroup : subGroups) {
            for (Integer i = 0; i < 2; i++) {
                Product_Select__c lineItem = new Product_Select__c(Product_Group__c = subGroup.Id, Quote__c = quote.Id);
                lineItems.add(lineItem);
            }
        }
        insert lineItems;

        CartWrapper cartWrapper = new CartWrapper(quote);

        // Call the method
        Test.startTest();
        DesignQuoteHeaderController.quickSave(cartWrapper.groupDetails);
        Test.stopTest();

    }
}