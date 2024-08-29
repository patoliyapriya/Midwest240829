@isTest(seeAllData=true)
private class NewProductControllerTest{
 
    static testMethod void testMethod1() {
        
        Product2 pr = new Product2(Name='Connect Pro - Annual Fee',IsActive=true);
        insert pr;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(pr);
        NewProductController objNewProductController = new NewProductController(sc);
        
        objNewProductController.newProduct.Name = 'Test Product';
        objNewProductController.save();
        objNewProductController.stadardPrice = '45';
        objNewProductController.save();
    }
    
    static testMethod void testMethod2() {
    
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.closeDate = Date.today();
        objOpportunity.Name = 'Test Opportunity';
        objOpportunity.stageName = 'Draft';
        insert objOpportunity;
        
        Quote newQuote = new Quote();
        newQuote.Name = 'Test Quote';
        newQuote.opportunityId = objOpportunity.Id;
        newQuote.Scope_Revision_Number__c = '01';
        newQuote.Submittal_Revision_Number__c = '01';
        insert newQuote;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(newQuote);
        SyncQuoteBackToOpportunityController objSyncQuoteBackToOpportunityController = new SyncQuoteBackToOpportunityController(sc);
        objSyncQuoteBackToOpportunityController.syncBackToOpportunity();
    }
    
}