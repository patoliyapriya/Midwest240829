@isTest
private class SharePointTest {

@TestSetup static void setup() {
        Account acc = new Account();
        acc.Name = 'Test Account 01';
        
        insert acc;
        // Create new opportunity.
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.StageName = 'Bidding';
        opp.Name = 'Test Opp 01';
        opp.CloseDate = system.today().addDays(30);
        opp.Bid_Date__c = system.today().addDays(3);
        
        insert opp;  
}

    @isTest static void testSharepointBatch(){

        Opportunity opp = [select id from Opportunity limit 1];
        Test.StartTest();
            // Set mock callout class 
            Test.setMock(HttpCalloutMock.class, new MockHttpSharePointResponseGenerator());
            Database.executeBatch(new createfolderForOpportunity(opp.id));
         Test.StopTest();
    }
     
}