@isTest
private class FeedItemTest {
    static testMethod void FeedItemMethod() {
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Contact cont = new Contact();
        cont.AccountId = acc.Id;
        cont.FirstName = 'FirstName';
        cont.LastName = 'LastName';
        insert cont;
        
        Visit_Report__c vr = new Visit_Report__c();
        vr.Name = 'Test Visit Report';
        vr.Account__c = acc.Id;
        vr.Contact__c = cont.Id;
        vr.Type__c = 'Mini Event';
        insert vr;
    }
}