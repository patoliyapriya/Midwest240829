@isTest
private class OpportunityTriggerTest {
    static testMethod void myUnitTest(){
        // Create Account
        Account acc = createAccount();
        
        // get Logged in users role
        User user = [Select Id, Name, UserRole.Name from User where Id =: Userinfo.getUserId()];
        
        // Create custom setting. 
        Roles_With_Public_Calendars__c calendar = createPublicCalendarConfiguration(user.UserRole.Name);
        
        // Create new opportunity.
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.StageName = 'Bidding';
        opp.Name = 'Test Opp 01';
        opp.CloseDate = system.today().addDays(30);
        opp.Bid_Date__c = system.today().addDays(3);
        
        insert opp;
        
        List<Event> newEvents = [Select Id, StartDateTime from Event where WhatId =: opp.Id];
        //system.assert(newEvents.size() > 0);
        //system.assertEquals(opp.Bid_Date__c, newEvents.get(0).StartDateTime);
        
        // Update Opportunity Bid Date.
        opp.Bid_Date__c = system.today().addDays(5);
        update opp;
        
        List<Event> updatedEvents = [Select Id, StartDateTime from Event where WhatId =: opp.Id];
        //system.assert(updatedEvents.size() > 0);
        //system.assertEquals(opp.Bid_Date__c, updatedEvents.get(0).StartDateTime);
    }
    
    private static Account createAccount(){
        Account acc = new Account();
        acc.Name = 'Test Account 01';
        
        insert acc;
        
        return acc;
    }
    
    private static Roles_With_Public_Calendars__c createPublicCalendarConfiguration(String roleName){
        Roles_With_Public_Calendars__c config = new Roles_With_Public_Calendars__c();
        config.Calendar_Id__c = Userinfo.getUserId();
        if(roleName == '' || roleName == null) roleName = 'Test Role';
        config.Name = roleName;
        
        insert config;
        
        return config;
    }

    //SalesEngineerSplitTriggerHandler controller.
    static testMethod void testSaleEngieerSplit(){

        Opportunity opp1 = new Opportunity();
        opp1.StageName = 'Bidding';
        opp1.Name = 'Test Split Opportunity';
        opp1.CloseDate = system.today().addDays(30);
        opp1.Office__c ='Midwest Machinery STL';
        insert opp1;

        SalesEngineerSplitTriggerHandler.updateSalesRepEntry(opp1.Id, 'Midwest Machinery STL');

         List<Sales_Representative__c> salesReps = [SELECT Id, Sales_Rep__c FROM Sales_Representative__c 
                                                    WHERE Opportunity__c = :opp1.Id Limit 1];                                       
         System.assertEquals(1, salesReps.size());
         System.assertEquals('00561000000gZ3T', salesReps[0].Sales_Rep__c);
    }
}