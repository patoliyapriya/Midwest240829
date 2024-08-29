@isTest
public with sharing class SalesResultCtrlTest {


    @testSetup static void setup() 
    { 
        Sales_Rep_Goal__c  testsrGoal  = new Sales_Rep_Goal__c();
        testsrGoal.Margin_Goal__c = 1500000;
        testsrGoal.Revenue_Goal__c = 40000000;
        testsrGoal.Direct_Sales_Goal__c = 260000;
        testsrGoal.Resell_Sales_Goal__c = 200000;
        testsrGoal.Direct_Sales_Percentage__c = 7;
        testsrGoal.Sales_Margin_Percentage__c = 40;
        testsrGoal.Year__c = String.valueof(system.now().year());
        testsrGoal.Sales_Rep__c = UserInfo.getUserId();
        insert testsrGoal;
        System.debug('TestSales rep goal inserted: '+testsrGoal); 

        Account acctobj = new Account();
        acctobj.Name = 'Testing GoalChart';
        acctobj.AcctSeed__Accounting_Type__c = 'Customer';
        insert acctobj;
        System.debug('TestAccount Inserted: '+acctobj);

         // calculate booked value
         Opportunity testobjOppo = new Opportunity();
         testobjOppo.Name = ' salesResult goals';
         testobjOppo.AccountId = acctobj.Id;
         testobjOppo.closeDate = Date.today();
         testobjOppo.StageName = 'Closed Won';
         testobjOppo.Project_Manager__c = UserInfo.getUserId();
         testobjOppo.Application_Engineer__c = UserInfo.getUserId();
         testobjOppo.Probability = 70;
         testobjOppo.Total_Project_Margin__c = 150;
         testobjOppo.Office__c = 'Midwest Machinery STL';
         insert testobjOppo;
 
         System.debug('TestOpportunity Inserted: '+testobjOppo); 

         // Quote 
         Quote newQuote = new Quote();
         newQuote.Name = 'Quote';
         newQuote.Total_Project_Margin__c = 150;
         newQuote.Total_Buy_Resell_Price__c= 75000;
         newQuote.Total_Buy_Resell_Margin__c = 150;
         newQuote.Total_Buy_Resell_Margin_Percentage__c = 400;
         newQuote.Commissions_and_Rebates__c =70;
         newQuote.Total_Direct_Sell_Price__c = 150;
         newQuote.opportunityId = testobjOppo.Id;
         insert newQuote;
 
         System.debug('TestQuote Inserted: '+newQuote);
         testobjOppo.Sync_Quote__c = newQuote.Id;
         testobjOppo.Active_Financial_Quote__c  = newQuote.Id;
         update testobjOppo;

         //Quote line item
         Product_Select__c testQuoteLine = new Product_Select__c();
         testQuoteLine.Product_Name__c = 'Parent Product Name';
         testQuoteLine.Quote__c = newQuote.Id;
         testQuoteLine.Sale_Type__c = 'B/R';
         testQuoteLine.Estimated_Ship_Date__c = system.now().date();
         testQuoteLine.Product_Name__c = 'Freight';
         testQuoteLine.Margin_Percentage__c = 75;
         testQuoteLine.List_Price__c = 100;
         testQuoteLine.Quantity__c = 4;
         testQuoteLine.CR__c = 2830;
         testQuoteLine.Sales_Price__c = 1050;
         insert testQuoteLine;
         System.debug('testQuoteLine Inserted: '+testQuoteLine);

         Project__c testProject = new Project__c();
         testProject.Name = testobjOppo.Name;
         testProject.PO_Number__c ='PO-1234';
         testProject.Receipt_of_Order_Date__c = system.now().date();
         testProject.Opportunity__c =testobjOppo.Id;
         testProject.Active_Financial_Quote__c = newQuote.Id;
         testProject.ProjectShipDate__c = system.now().date();
         testProject.CreatedDate = system.now().date();
         insert testProject;

         testobjOppo.Project__c = testProject.id;
         update testobjOppo;
         System.debug('TestProject Inserted: '+testProject); 

         // for this you need to create quote
         Sales_Representative__c testsalesEggSplits = new Sales_Representative__c();  
         testsalesEggSplits.Commision__c = 100;
         testsalesEggSplits.Sales_Rep__c = UserInfo.getUserId(); 
         testsalesEggSplits.Opportunity__c = testobjOppo.Id;
         insert testsalesEggSplits ;
         System.debug('TestSales Representative Inserted: '+testsalesEggSplits);

    }

    @isTest static void testBuyResellMarginGoal(){  

        SalesResultCtrl.buildSalesResultsWrapper(UserInfo.getUserId());
    }   
    @isTest static void testgetSalesRepIds(){
        SalesResultCtrl.getSalesRepIds(UserInfo.getUserId());
    }
       
    @isTest static void testGetPercentageGoals(){
        SalesResultCtrl.getPercentageGoals(UserInfo.getUserId());
    }

    @isTest static void testGetSalesBackLog()
    {
        SalesResultCtrl.getSalesBackLog(UserInfo.getUserId());
    }

    @isTest static void testGetDashboardBackLog()
    {
        SalesResultCtrl.getDashboardBackLog(UserInfo.getUserId());
        SalesResultCtrl.getDashboardBackLog2(UserInfo.getUserId());
    }

}