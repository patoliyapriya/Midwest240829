@isTest
public class NewOpportunityControllerTest {
	
	static testMethod void testNewOpportunity(){

		Opportunity newOpportunity = new Opportunity();
		
		ApexPages.StandardController sc = new ApexPages.StandardController(newOpportunity);
		NewOpportunityController newOpp = new NewOpportunityController(sc);
		
		Contact newContact = new Contact();
		newContact.LastName = 'LastName';
		insert newContact;
		newOpp.generalContractorContactId = newContact.Id;
		
		newOpp.populateGeneralContractorAccount();	 
	}
	static testMethod void testSaveOpportunity(){

		Account newAccount = new Account();
		newAccount.Name = 'Test Account';
		insert newAccount;
		
		Contact newContact = new Contact();
		newContact.LastName = 'LastName';
		newContact.AccountId = newAccount.Id;
		insert newContact;

		Opportunity	newOpportunity  = new Opportunity();
		
		ApexPages.StandardController sc = new ApexPages.StandardController(newOpportunity);
		NewOpportunityController newOppController = new NewOpportunityController(sc);
        
		newOppController.opp.Name = 'Test Opportunity';
		newOppController.opp.AccountId = newAccount.Id;
		newOppController.opp.StageName = 'Prospecting';
		newOppController.opp.closeDate = Date.today();
	    Test.startTest();
		PageReference pr = newOppController.saveOpportunity();
		Test.stopTest();
		System.assertEquals('/' + newOppController.opp.Id, pr.getUrl());		
   }
	    
}