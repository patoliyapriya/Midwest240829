@isTest
public with sharing class GoalChartControllerTest 
{

    @testSetup static void setup() {
        // point__c calculation
        final String ACTIVITY_CLIENTOFFICE_VISIT = 'Client Office Visit';
        final String ACTIVITY_ENDUSER_VISIT = 'End User Visit';
        final String ACTIVITY_ENTERTAINMENT = 'Entertainment (Golf, Games)';
        final String ACTIVITY_HAPPY_HOUR = 'Happy Hour - Cocktails';
        final String ACTIVITY_Meal = 'Meal';

        ActivityGoalPoints__c clientOfficeGoalPoint = new ActivityGoalPoints__c();
        clientOfficeGoalPoint.Name = ACTIVITY_CLIENTOFFICE_VISIT ;
        clientOfficeGoalPoint.Point__c = 1;
        insert clientOfficeGoalPoint;

        ActivityGoalPoints__c entertainmentGoalPoint = new ActivityGoalPoints__c();
        entertainmentGoalPoint.Name = ACTIVITY_ENTERTAINMENT ;
        entertainmentGoalPoint.Point__c = 3;
        insert entertainmentGoalPoint;

        ActivityGoalPoints__c endUserVisitGoalPoint = new ActivityGoalPoints__c();
        endUserVisitGoalPoint.Name = ACTIVITY_ENDUSER_VISIT ;
        endUserVisitGoalPoint.Point__c = 1;
        insert endUserVisitGoalPoint;

        ActivityGoalPoints__c happyHourGoalPoints = new ActivityGoalPoints__c();
        happyHourGoalPoints.Name = ACTIVITY_HAPPY_HOUR ;
        happyHourGoalPoints.Point__c = 2;
        insert happyHourGoalPoints;

        ActivityGoalPoints__c mealGoalPoints = new ActivityGoalPoints__c();
        mealGoalPoints.Name = ACTIVITY_Meal ;
        mealGoalPoints.Point__c = 2;
        insert mealGoalPoints;

        //Create common test data in setup method 
        //ActivityChartNumbers --> gauge chart
        SalesActivityGoal__c chartTotlaListTest = new  SalesActivityGoal__c();
        //chartTotlaListTest.Name = 'Test Goal';
        chartTotlaListTest.ClientOfficeVisit__c = 15;
        chartTotlaListTest.EndUserVisit__c = 12;
        chartTotlaListTest.Entertainment__c = 10;
        chartTotlaListTest.FactoryVisitLocal__c = 16;
        chartTotlaListTest.FactoryVisitTravel__c = 18;
        chartTotlaListTest.HappyHour__c = 22; 
        chartTotlaListTest.Meal__c = 25;
        chartTotlaListTest.SiteVisit__c = 23;
        chartTotlaListTest.Training__c = 14;
        // chartTotlaListTest.SalesRep__c = UserInfo.getUserId();
        chartTotlaListTest.Year__c = String.valueof(system.now().year());
        chartTotlaListTest.Master_Report__c = 'Saint Louis';

        insert chartTotlaListTest;
        System.debug('Sales activity goal inserted: '+chartTotlaListTest);

        // create a logACall for SalesActivityGoal
    
        LogACall__c  testLogcall = new LogACall__c();
        testLogcall.Type_of_Call__c = 'Meal';
        testLogcall.Assigned_To__c = UserInfo.getUserId();
        testLogcall.CreatedDate = system.now().addMonths(-1);
        testLogcall.Event_Date__c = Date.today();
        insert testLogcall;
        System.debug('LogAcall inserted: '+testLogcall);

        //MarginGoalChartNumbers--> gauge chart
        Sales_Rep_Goal__c  testsrGoal  = new Sales_Rep_Goal__c();
        testsrGoal.Margin_Goal__c = 1500000;
        testsrGoal.Revenue_Goal__c = 40000000;
        testsrGoal.Direct_Sales_Goal__c = 26000;
        testsrGoal.Resell_Sales_Goal__c = 20000;
        testsrGoal.Direct_Sales_Percentage__c = 20;
        testsrGoal.Sales_Margin_Percentage__c = 20;
        testsrGoal.Year__c = String.valueof(system.now().year());
        testsrGoal.Sales_Rep__c = UserInfo.getUserId();
        insert testsrGoal;
        System.debug('Sales rep goal inserted: '+testsrGoal);

       
       Account acctobj = new Account();
        acctobj.Name = 'Testing GoalChart';
        acctobj.AcctSeed__Accounting_Type__c = 'Customer';
        insert acctobj;
        System.debug('Account Inserted: '+acctobj);
        

        // calculate booked value
        Opportunity testobjOppo = new Opportunity();
        testobjOppo.Name = 'Test goals';
        testobjOppo.AccountId = acctobj.Id;
        testobjOppo.closeDate = Date.today();
        testobjOppo.StageName = 'Closed Won';
        testobjOppo.Project_Manager__c = UserInfo.getUserId();
        testobjOppo.Office__c = 'Midwest Machinery STL';
        insert testobjOppo;
        System.debug('Opportunity Inserted: '+testobjOppo);

        //getRevenueGoalChartNumbers--> gauge chart
        Sales_Representative__c testsalesEggSplits = new Sales_Representative__c(); // for this you need to create quote
        testsalesEggSplits.Commision__c = 100;
        testsalesEggSplits.Sales_Rep__c = UserInfo.getUserId(); 
        testsalesEggSplits.Opportunity__c = testobjOppo.Id;
        insert testsalesEggSplits;
        System.debug('Sales Representative Inserted: '+testsalesEggSplits);


    }
    
    @isTest static void loadMarginGoalData()
    {
        GoalChartController goalchart = new GoalChartController();
        //for office level and master report
        goalchart.loadMarginGoalData();
        goalchart.selectedUserId = 'Saint Louis';
        goalchart.loadMarginGoalData();
        goalchart.selectedUserId = 'Midwest Machinery';
        goalchart.loadMarginGoalData();


    }
    @isTest static void loadRevGoalChart()
    {
        GoalChartController goalchart = new GoalChartController();
        goalchart.loadRevGoalChart(); 
        goalchart.selectedUserId = 'Midwest Machinery';
        goalchart.loadRevGoalChart(); 
        goalchart.selectedUserId = 'Saint Louis';
        goalchart.loadRevGoalChart();
    }
    @isTest static void loadActivityGoalChart()
    {
        GoalChartController goalchart = new GoalChartController();
        goalchart.loadActivityGoalChart();
        goalchart.selectedUserId = 'Midwest Machinery';
        goalchart.loadActivityGoalChart();  
        goalchart.selectedUserId = 'Saint Louis';
        goalchart.loadActivityGoalChart();  
    }
    @isTest static void fetchSalesRepGoals()
    {
        GoalChartController goalchart = new GoalChartController();
        goalchart.fetchSalesRepGoals();  
    }
}