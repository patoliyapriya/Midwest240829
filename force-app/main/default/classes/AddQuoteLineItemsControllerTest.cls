@isTest
private class AddQuoteLineItemsControllerTest{
 
    static testMethod void testMethod1() {
        
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
        
        ApexPages.StandardController sc = new ApexPages.StandardController(newQuote);
        AddQuoteLineItemsController objAddQuoteLineItemsController = new AddQuoteLineItemsController(sc);
        objAddQuoteLineItemsController.addAdditionDeductionLineItem();
        
        objAddQuoteLineItemsController.hidProductRowIndex = 0;
        objAddQuoteLineItemsController.deleteAdditionDeduction();
        objAddQuoteLineItemsController.addProduct();
        
        objAddQuoteLineItemsController.hidGroupIndex = 0;
        objAddQuoteLineItemsController.hidSubGroupIndex = 0;
        objAddQuoteLineItemsController.addCustomProduct();
        objAddQuoteLineItemsController.cloneGroup();
        objAddQuoteLineItemsController.newGroup();
        
        objAddQuoteLineItemsController.createSubGroup();
        objAddQuoteLineItemsController.cloneSubGroup();
        objAddQuoteLineItemsController.newSubGroup();
        
        objAddQuoteLineItemsController.backToQuote();
        objAddQuoteLineItemsController.backToCart();
        objAddQuoteLineItemsController.saveDescription();
        //objAddQuoteLineItemsController.insertNewProduct();
        
        objAddQuoteLineItemsController.deleteProductRow();
        objAddQuoteLineItemsController.deleteGroup();
        objAddQuoteLineItemsController.deleteSubGroup();
        objAddQuoteLineItemsController.deleteGroup();
        objAddQuoteLineItemsController.Save();
    }
    
}