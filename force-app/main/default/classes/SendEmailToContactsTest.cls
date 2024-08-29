@isTest
private class SendEmailToContactsTest{
 
    static testMethod void testMethod1() {
        
        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        insert newAccount;
        
        Contact newContact = new Contact();
        newContact.firstName = 'Test';
        newContact.LastName = 'Last Name';
        newContact.accountId = newAccount.Id;
        insert newContact;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(newAccount);
        SendEmailToContacts objSendEmailToContacts = new SendEmailToContacts(sc);
        objSendEmailToContacts.redirectBackToAccount();
        
    }
    
    static testMethod void testMethod2() {
        
        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        insert newAccount;
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.closeDate = Date.today();
        objOpportunity.Name = 'Test Opportunity';
        objOpportunity.stageName = 'Draft';
        objOpportunity.End_User__c = newAccount.Id;
        insert objOpportunity;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(newAccount);
        OpportunityEndUser objOpportunityEndUser = new OpportunityEndUser(sc);
        
        
    }
    
    static testMethod void testMethod3() {
        
        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        insert newAccount;
        
        Contact newContact = new Contact();
        newContact.firstName = 'Test';
        newContact.LastName = 'Last Name';
        newContact.accountId = newAccount.Id;
        insert newContact;
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.closeDate = Date.today();
        objOpportunity.Name = 'Test Opportunity';
        objOpportunity.stageName = 'Draft';
        objOpportunity.End_User__c = newAccount.Id;
        insert objOpportunity;
        
        Bidder_Detail__c newBid = new Bidder_Detail__c();
        newBid.Bid_Contact__c = newContact.Id;
        newBid.Mechanical_Contractor__c = newAccount.Id;
        newBid.Opportunity__c = objOpportunity.Id;
        insert newBid;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(newContact);
        OpportunityListOnContact objOpportunityListOnContact = new OpportunityListOnContact(sc);
        
        ApexPages.StandardController sc1 = new ApexPages.StandardController(newAccount);
        OpportunityMechanicalContractors objOpportunityMechanicalContractors = new OpportunityMechanicalContractors (sc1);
    }
}