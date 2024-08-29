@isTest
public with sharing class TopOpportunitiesControllerTest {

   @testSetup static void setup()
   {
       Account acctobj = new Account();
       acctobj.Name = 'Testing oppo';
       acctobj.AcctSeed__Accounting_Type__c = 'Customer';
       insert acctobj;

       Opportunity testobjOppo = new Opportunity();
       testobjOppo.Name = 'Test opportunity';
       testobjOppo.AccountId = acctobj.Id;
       testobjOppo.StageName = 'TARGET_NEGOTIATING';
       testobjOppo.Project_Manager__c = UserInfo.getUserId();
       testobjOppo.Office__c = 'Midwest Machinery STL';
       testobjOppo.Total_Project_Margin__c = 1520;
       testobjOppo.Total_Base_Bid_Total_Quote__c = 2150;
       testobjOppo.Probability = 70;
       testobjOppo.Ship_Date__c = Date.today();
       testobjOppo.closeDate = Date.today();
       testobjOppo.Targeted__c = true;
       
       insert testobjOppo;
       System.debug('TestOpportunity Inserted: '+testobjOppo);

       Sales_Representative__c testsalesRep = new Sales_Representative__c();  
       testsalesRep.Commision__c = 100;
       testsalesRep.Sales_Rep__c = UserInfo.getUserId(); 
       testsalesRep.Opportunity__c = testobjOppo.Id;
       insert testsalesRep ;
       System.debug('TestsalesRep testsalesRep: '+testsalesRep);

   } 

    @isTest static void testgetSalesRepOppoIds(){
        TopOpportunitiesController topOppController = new TopOpportunitiesController();
        TopOpportunitiesController.getSalesRepOpportunityIds(UserInfo.getUserId());
        //else if case
        TopOpportunitiesController.getSalesRepOpportunityIds('Oklahoma');
        //for else case
        TopOpportunitiesController.getSalesRepOpportunityIds('Midwest Machinery');
    }

    @isTest static void testgetSetFromStageName(){
        TopOpportunitiesController.getSetFromStageName('TARGET/NEGOTIATING');

    }
    @isTest static void testbuildOpporunityWrapper(){
        TopOpportunitiesController.buildOpporunityWrapper('TARGET/NEGOTIATING' , UserInfo.getUserId());
        //for else case 
        TopOpportunitiesController.buildOpporunityWrapper('BIDDING' , UserInfo.getUserId());   
    }
}