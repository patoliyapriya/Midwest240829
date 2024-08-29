@isTest
private class SyncAddressAccountTriggerTest {
    
    static testMethod void SyncTest() {
        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        newAccount.BillingStreet = '123 Main St';
        newAccount.BillingCity = 'Anytown';
        newAccount.BillingState = 'CA';
        newAccount.BillingPostalCode = '12345';
        newAccount.BillingCountry = 'USA';
        insert newAccount;
        
        Contact newContact = new Contact();
        newContact.FirstName = 'FirstName';
        newContact.LastName = 'LastName';
        newContact.AccountId = newAccount.Id;
        newContact.Sync__c = true;
        insert newContact;

        Opportunity testOpportunity = new Opportunity();
        testOpportunity.Name = 'Test Opportunity';
        testOpportunity.StageName = 'Prospecting';
        testOpportunity.CloseDate = Date.today();
        testOpportunity.AccountId = newAccount.Id;
        testOpportunity.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Equipment').getRecordTypeId();
        insert testOpportunity;

        // Create test bidder detail
        Bidder_Detail__c testBidderDetail = new Bidder_Detail__c();
        testBidderDetail.Bid_Contact__c = newContact.Id;
        testBidderDetail.Mechanical_Contractor__c = null;
        insert testBidderDetail;

        // Set payment and accounting notes
        newAccount.Payment_and_Accounting_Notes__c = 'Test notes';
        update newAccount;

        newContact = [SELECT Id, MailingStreet, MailingCity FROM Contact WHERE Id = :newContact.Id];
        System.assertEquals(newAccount.BillingStreet, newContact.MailingStreet);
        System.assertEquals(newAccount.BillingCity, newContact.MailingCity);

        testOpportunity = [SELECT Id, Credit_Notes__c FROM Opportunity WHERE Id = :testOpportunity.Id];
        System.assertEquals(newAccount.Payment_and_Accounting_Notes__c, testOpportunity.Credit_Notes__c);
 
         // Verify bidder detail updates
        testBidderDetail = [SELECT Id, hasNotes__c FROM Bidder_Detail__c WHERE Id = :testBidderDetail.Id];
        System.assertEquals(true, testBidderDetail.hasNotes__c);
    }
}