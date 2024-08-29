@isTest
private class ActualForecastBookingControllerTest {

    @TestSetup
    static void createData(){

        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        objAccount.AcctSeed__Accounting_Type__c = 'Customer';
        insert objAccount;

        Opportunity objOpportunityActual = new Opportunity();
        objOpportunityActual.AccountId = objAccount.Id;
        objOpportunityActual.Name = 'Test Opportuntiy Actual Booking';
        objOpportunityActual.StageName = 'Closed Won';
        objOpportunityActual.Project_Manager__c = UserInfo.getUserId();
        objOpportunityActual.CloseDate = Date.Today();
        objOpportunityActual.Total_Base_Bid_Total_Quote__c = 10000;
        objOpportunityActual.Total_Project_Margin__c = 20000;
        objOpportunityActual.Office__c = 'Midwest Machinery STL';
        
        Opportunity objOpportunityForecast = new Opportunity();
        objOpportunityForecast.AccountId = objAccount.Id;
        objOpportunityForecast.Name = 'Test Opportuntiy Forecast Booking';
        objOpportunityForecast.StageName = 'Bidding';
        objOpportunityForecast.Project_Manager__c = UserInfo.getUserId();
        objOpportunityForecast.CloseDate = Date.Today();
        objOpportunityForecast.Total_Base_Bid_Total_Quote__c = 10000;
        objOpportunityForecast.Total_Project_Margin__c = 20000;
        
        insert new List<Opportunity>{objOpportunityActual, objOpportunityForecast};

        Sales_Representative__c objSalesRep = new Sales_Representative__c();
        objSalesRep.Commision__c = 100;
        objSalesRep.Opportunity__c = objOpportunityActual.Id;
        objSalesRep.Sales_Rep__c = UserInfo.getUserId();

        Sales_Representative__c objSalesRep1 = new Sales_Representative__c();
        objSalesRep1.Commision__c = 100;
        objSalesRep1.Opportunity__c = objOpportunityForecast.Id;
        objSalesRep1.Sales_Rep__c = UserInfo.getUserId();
        insert new List<Sales_Representative__c>{objSalesRep, objSalesRep1};
    }

	static testMethod void testActualBooking() {
        Apexpages.currentpage().getparameters().put('selectSalesRep', UserInfo.getUserId());
        Apexpages.currentpage().getparameters().put('reportType','Actual Booking');
        Apexpages.currentpage().getparameters().put('duration','12');
        ActualForecastBookingController objActualForecastBookingController = new ActualForecastBookingController();
        objActualForecastBookingController.getOpportunity();
        
    }

    static testMethod void testForecastBooking() {
        Apexpages.currentpage().getparameters().put('selectSalesRep', UserInfo.getUserId());
        Apexpages.currentpage().getparameters().put('reportType','Forecast Booking');
        Apexpages.currentpage().getparameters().put('duration','12');
        ActualForecastBookingController objActualForecastBookingController = new ActualForecastBookingController();
        objActualForecastBookingController.getOpportunity();
    }
}