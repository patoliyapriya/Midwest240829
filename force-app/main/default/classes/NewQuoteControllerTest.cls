@isTest
private class NewQuoteControllerTest {
 
    static testMethod void testMethod1() {
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.closeDate = Date.today();
        objOpportunity.Name = 'Test Opportunity';
        objOpportunity.stageName = 'Draft';
        objOpportunity.Application_Engineer__c = UserInfo.getUserId();
        insert objOpportunity;
        
        apexpages.currentpage().getparameters().put('oppid',objOpportunity.Id); 
        
        ApexPages.StandardController sc = new ApexPages.StandardController(new Quote());
        NewQuoteController objNewQuoteController = new NewQuoteController(sc);
        
        //objNewQuoteController.quote = new Quote();
        objNewQuoteController.quote.Name = 'Test Quote';
        objNewQuoteController.quote.opportunityId = objOpportunity.Id;
        objNewQuoteController.quote.Scope_Revision_Number__c = '01';
        objNewQuoteController.quote.Submittal_Revision_Number__c = '01';
        objNewQuoteController.SaveQuote();
        objNewQuoteController.Cancel();
        
    }

    static testMethod void testMethod2() {
        //Create test account
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        //Create test Opp Account
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.closedate = System.today();
        opp.StageName = 'Non Qualified';
        opp.AccountId = acc.Id;
        insert opp;

        // Create a new quote record for testing
        Quote testQuote = new Quote(
            Name = 'Test Quote',
            opportunityId = opp.Id,
            Total_Direct_Sell_Price__c = 100.00,
            Total_Buy_Resell_Margin__c = 50.00,
            Commissions_and_Rebates__c = 10.00,
            Total_Buy_Resell_Price__c = 60.00
        );
        insert testQuote;

        ProjectFinancials pf = new ProjectFinancials();
        Quote result = ProjectFinancials.getQuote(testQuote.Id);

        // Verify that the result matches the expected values
        System.assertEquals(testQuote.Total_Direct_Sell_Price__c, result.Total_Direct_Sell_Price__c);
        System.assertEquals(testQuote.Total_Buy_Resell_Margin__c, result.Total_Buy_Resell_Margin__c);
    }
    
}