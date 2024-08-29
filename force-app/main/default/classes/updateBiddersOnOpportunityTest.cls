@isTest
private class updateBiddersOnOpportunityTest{
 
    @testSetup
    static void testSetup() {
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.closeDate = Date.today();
        objOpportunity.Name = 'Test Opportunity';
        objOpportunity.stageName = 'Draft';
        insert objOpportunity;
        
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        
        Contact cont = new Contact();
        cont.LastName = 'Test Name';
        cont.AccountId = acc.Id;
        cont.Email = 'nilesh.badrakia@gmail.com';
        insert cont;
    }
    static testMethod void testMethod1() {

        Opportunity objOpportunity = [SELECT Id FROM Opportunity Limit 1];
        Contact cont = [SELECT Id FROM Contact Limit 1];
        Account acc = [SELECT Id FROM Account Limit 1];
        Bidder_Detail__c newBd = new Bidder_Detail__c();
        newBd.Bid_Contact__c = cont.Id;
        newBd.Opportunity__c = objOpportunity.Id;
        newBd.Won_Lost_Bidding__c = 'Bidding';
        newBd.Mechanical_Contractor__c = acc.Id;
        insert newBd;

        Test.startTest();
        newBd.Won_Lost_Bidding__c = 'Won';
        update newBd;
        Test.stopTest();
    }
    static testMethod void testMethod2() {

        Opportunity objOpportunity = [SELECT Id FROM Opportunity Limit 1];
        Contact cont = [SELECT Id FROM Contact Limit 1];
        Account acc = [SELECT Id FROM Account Limit 1];
        Bidder_Detail__c newBd1 = new Bidder_Detail__c();
        newBd1.Opportunity__c = objOpportunity.Id;
        newBd1.Won_Lost_Bidding__c = 'Won';
        newBd1.Mechanical_Contractor__c = acc.Id;
        insert newBd1;
        Test.startTest();
        newBd1.Won_Lost_Bidding__c = 'Bidding';
        update newBd1;
        delete newBd1;
        Test.stopTest();
    }
        
    static testMethod void testMethod3() {
        
        Opportunity objOpportunity = [SELECT Id FROM Opportunity Limit 1];
        Contact cont = [SELECT Id FROM Contact Limit 1];
        Account acc = [SELECT Id FROM Account Limit 1];
        Bidder_Detail__c newBd3 = new Bidder_Detail__c();
        newBd3.Opportunity__c = objOpportunity.Id;
        newBd3.Won_Lost_Bidding__c = 'Not Bidding';
        newBd3.Mechanical_Contractor__c = acc.Id;
        insert newBd3;

        Test.startTest();
        newBd3.Won_Lost_Bidding__c = 'Bidding';
        update newBd3;  
        Test.stopTest();
    }

    static testMethod void testMethod4() {
        
        Opportunity objOpportunity = [SELECT Id FROM Opportunity Limit 1];
        Contact cont = [SELECT Id FROM Contact Limit 1];
        Account acc = [SELECT Id FROM Account Limit 1];
        Bidder_Detail__c newBd2 = new Bidder_Detail__c();
        newBd2.Opportunity__c = objOpportunity.Id;
        newBd2.Won_Lost_Bidding__c = 'Not Bidding';
        newBd2.Mechanical_Contractor__c = acc.Id;
        insert newBd2;

        Test.startTest();
        newBd2.Won_Lost_Bidding__c = 'Won';
        update newBd2;
        Test.stopTest();
    }

    static testMethod void testMethod5() {
        
        Opportunity objOpportunity = [SELECT Id FROM Opportunity Limit 1];
        Contact cont = [SELECT Id FROM Contact Limit 1];
        Account acc = [SELECT Id FROM Account Limit 1];
        Bidder_Detail__c newBd2 = new Bidder_Detail__c();
        newBd2.Opportunity__c = objOpportunity.Id;
        newBd2.Won_Lost_Bidding__c = 'Won';
        newBd2.Mechanical_Contractor__c = acc.Id;
        insert newBd2;

        Test.startTest();
        newBd2.Won_Lost_Bidding__c = 'Lost';
        update newBd2;
        Test.stopTest();
    }
    
    static testMethod void testMethod6() {
        
        Opportunity objOpportunity = [SELECT Id FROM Opportunity Limit 1];
        Contact cont = [SELECT Id FROM Contact Limit 1];
        Account acc = [SELECT Id FROM Account Limit 1];
        Bidder_Detail__c testBidderDetail1 = new Bidder_Detail__c(Opportunity__c=objOpportunity.Id, Bid_Contact__c=cont.Id, Won_Lost_Bidding__c='Won',Mechanical_Contractor__c=acc.Id);
        insert testBidderDetail1;
    
        String emailList = EmailAllBidders.SendEmail(objOpportunity.Id);
        System.assertEquals('nilesh.badrakia@gmail.com;', emailList);
    }
}