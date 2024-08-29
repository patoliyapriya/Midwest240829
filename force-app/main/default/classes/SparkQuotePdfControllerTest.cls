@isTest
private class SparkQuotePdfControllerTest {
    
    @TestSetup static void setup() {
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.closeDate = Date.today();
        objOpportunity.Name = 'Test Opportunity';
        objOpportunity.stageName = 'Draft';
        objOpportunity.Office__c = 'MaRRs';
        insert objOpportunity;

        Quote newQuote = new Quote();
        newQuote.Name = 'Test Quote';
        newQuote.opportunityId = objOpportunity.Id;
        newQuote.Scope_Revision_Number__c = '01';
        newQuote.Submittal_Revision_Number__c = '01';
        insert newQuote;

        Product_Group__c objParentProductGroup = new Product_Group__c();
        objParentProductGroup.Name = 'Parent Group';
        objParentProductGroup.Quote__c = newQuote.Id;
        insert objParentProductGroup;
        
        Product_Group__c objChildProductGroup = new Product_Group__c();
        objChildProductGroup.Name = 'Parent Group';
        objChildProductGroup.Quote__c = newQuote.Id;
        objChildProductGroup.Parent_Product_Group__c = objParentProductGroup.Id;
        insert objChildProductGroup;
        
        Product_Select__c objParentLineItem = new Product_Select__c();
        objParentLineItem.Product_Name__c = 'Parent Product Name';
        objParentLineItem.Quote__c = newQuote.Id;
        objParentLineItem.Product_Group__c = objChildProductGroup.Id;
        insert objParentLineItem;
        
        Product_Select__c objChildLineItem = new Product_Select__c();
        objChildLineItem.Product_Name__c = 'Child Product Name';
        objChildLineItem.Quote__c = newQuote.Id;
        objChildLineItem.Product_Group__c = objChildProductGroup.Id;
        insert objChildLineItem;
    }

    @isTest static void testSparkQuoteGenerate() {

        Quote quoteSO = [SELECT ID FROM Quote WHERE Name = 'Test Quote'];

        ApexPages.StandardController sc = new ApexPages.StandardController(quoteSO);

        SparkQuotePdfController objSparkQuotePdfController = new SparkQuotePdfController(sc);

    }
}