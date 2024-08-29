@isTest
public with sharing class SalesActivityCtrlTest 
{
    
    @testSetup static void setup() 
    {
        //create a SalesActivityGoal
        SalesActivityGoal__c chartTotlaListTest = new  SalesActivityGoal__c();
        //chartTotlaListTest.Name = 'Test SalesActivity Goal';
        chartTotlaListTest.ClientOfficeVisit__c = 15;
        chartTotlaListTest.EndUserVisit__c = 12;
        chartTotlaListTest.Entertainment__c = 10;
        chartTotlaListTest.FactoryVisitLocal__c = 16;
        chartTotlaListTest.FactoryVisitTravel__c = 18;
        chartTotlaListTest.HappyHour__c = 22; 
        chartTotlaListTest.Meal__c = 25;
        chartTotlaListTest.SiteVisit__c = 23;
        chartTotlaListTest.Training__c = 14;
        chartTotlaListTest.SalesRep__c = UserInfo.getUserId();
        chartTotlaListTest.Year__c = String.valueof(system.now().year());      

        insert chartTotlaListTest;
        System.debug('SalesActvityGoal new salesgoal : '+chartTotlaListTest);

        final String ACTIVITY_CLIENTOFFICE_VISIT = 'Client Office Visit';
        final String ACTIVITY_ENDUSER_VISIT = 'End User Visit';
        final String ACTIVITY_ENTERTAINMENT = 'Entertain (Hpy Hr, Glf, Gms)';
        final String ACTIVITY_HAPPY_HOUR = 'Industry Event (Ashrae etc.)';
        final String ACTIVITY_Meal = 'Meal';
        List<String> typeOfCalls = new List<String>{ACTIVITY_CLIENTOFFICE_VISIT, ACTIVITY_ENDUSER_VISIT, ACTIVITY_ENTERTAINMENT, ACTIVITY_HAPPY_HOUR, ACTIVITY_Meal};

        // create a logACall for SalesActivityGoal
        List<LogACall__c> listofLogACalls = new List<LogACall__c>();
        for (Integer i=0; i<20; i++){

            LogACall__c  testLogcall = new LogACall__c();
            testLogcall.Type_of_Call__c = typeOfCalls[Math.mod(i,5)];
            testLogcall.Assigned_To__c = UserInfo.getUserId();
            testLogcall.CreatedDate = system.now().addMonths(-(Math.mod(i,10)));
            testLogcall.Event_Date__c = system.now().addMonths(-(Math.mod(i,10))).date();
            listofLogACalls.add(testLogcall);

            System.debug('Type of call: '+testLogcall.Type_of_Call__c);
            System.debug('CreateDate: '+testLogcall.CreatedDate);
            System.debug('EventDate: '+testLogcall.CreatedDate);

        }
        // Batch query inserting 20 records at a time of logACall
        insert listofLogACalls;

        //create a ActivityGoalPoints/ points
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
                  
        
    } 
    

    @isTest static void testSalesActivity()
    {
        SalesActivityCtrl.buildSalesActivityWrapper(UserInfo.getUserId());
    }

    @isTest static void testGetRankings()
    {
        SalesActivityCtrl.getRankings();
    }
    @isTest static void getAllSalesRep()
    {
        SalesActivityCtrl SalesActivityTest = new SalesActivityCtrl();
        // because of query not working in setup method
        Profile p = [select id from profile where name='Standard User']; 
        UserRole ur = [select Id from UserRole LIMIT 1];

        User userlst = new User(alias = 'standt', email='standarduser@kwutang.demo', 
                                emailencodingkey='UTF-8', lastname='Testing1', firstname='Testing', 
                                languagelocalekey='en_US', 
                                localesidkey='en_US',
                                timezonesidkey='America/Los_Angeles', 
                                ProfileId = p.Id,
                                UserRoleId= ur.Id,
                                Office_Location__c = 'Saint Louis',
                                username='standarduser@kwutang.demo1');   
        insert userlst;

        system.debug('new user added:'  +userlst);
        userlst.Is_Manager__c = false;
        userlst.Is_Director__c= false;
        userlst.has_house_Account_Access__c= false;
        update userlst;

        SalesActivityCtrl.getAllSalesRep();
        SalesActivityCtrl.getHouseUserDetails();
        SalesActivityCtrl.getUsersByLocations(userlst.Office_Location__c);
        SalesActivityCtrl.buildUserHierarchy(UserInfo.getUserId());
    }

}