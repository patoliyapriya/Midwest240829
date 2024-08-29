@isTest
private class FeedItemTriggerTest {
    
    static testMethod void myUnitTest(){
        
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
        
        FeedItem newFeedItem = new FeedItem();
        newFeedItem.ParentId = opp.Id;
        newFeedItem.Body = 'Test';
        insert newFeedItem;      
    }
    
}