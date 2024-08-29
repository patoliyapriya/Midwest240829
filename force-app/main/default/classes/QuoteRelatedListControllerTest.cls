@isTest
public class QuoteRelatedListControllerTest {
	
	static testMethod void testQuoteRelatedList(){
		
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
        
        ApexPages.StandardController sc = new ApexPages.StandardController(objOpportunity);
		QuoteRelatedListController quoteRelateList = new QuoteRelatedListController(sc);
		
		quoteRelateList.syncQuoteId = newQuote.Id;
		
		quoteRelateList.newQuote();
		quoteRelateList.syncBackToOpportunity(); 
		
		quoteRelateList.deleteQuoteId = newQuote.Id;
		
		quoteRelateList.deleteQuote();
		
	}
	
}