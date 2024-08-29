@isTest
private class PMToolAndSalesRepReportControllerTest{
    
    static testMethod void testNewProject() {
        
        Account objAccount = new Account();
        objAccount.name = 'Test Account';
        objAccount.AcctSeed__Accounting_Type__c = 'Customer and Vendor';
        insert objAccount;
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.AccountId = objAccount.Id;
        objOpportunity.closeDate = Date.today();
        objOpportunity.Name = 'Test Opportunity';
        objOpportunity.stageName = 'TARGET/NEGOTIATING';
        objOpportunity.Project_Manager__c = UserInfo.getUserId();
        objOpportunity.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(UtilitySharePointToSFIntegration.OPP_REPAIR_RECORDTYPE).getRecordTypeId();
        objOpportunity.Office__c = 'Midwest Machinery STL';
        insert objOpportunity;
        
        Quote newQuote = new Quote();
        newQuote.Name = 'Test Quote';
        newQuote.opportunityId = objOpportunity.Id;
        newQuote.Scope_Revision_Number__c = '01';
        newQuote.Submittal_Revision_Number__c = '01';
        newQuote.Is_Locked__c = true;
        insert newQuote;
        
        objOpportunity.Sync_Quote__c = newQuote.Id;
        update objOpportunity;
        
        //To cover EventRelatedToNames CodeCoverage for test class
        Event newEvent = new Event();
        newEvent.Opportunity_Name__c = objOpportunity.Name;
        newEvent.WhatId = objOpportunity.id;
        newEvent.OpportunityNumber__c = objOpportunity.Opportunity_Number__c;
        newEvent.Subject = 'Bid Due';
        newEvent.StartDateTime = datetime.newInstance(2022, 9, 12, 12, 30, 0);
        newEvent.EndDateTime = datetime.newInstance(2022, 9, 13, 13, 30, 0);
        //DurationInMinutes
        insert newEvent;

        Apexpages.currentpage().getparameters().put('Id',objOpportunity.Id);
        NewProjectController objNewProjectController = new NewProjectController();
        objNewProjectController.newProject.Name = 'Test Project';
        objNewProjectController.newProject.Receipt_of_Order_Date__c = System.Now().Date();
        objNewProjectController.newProject.Opportunity__c = objOpportunity.Id;
        objNewProjectController.saveProject();
        objNewProjectController.continueConvertToProject();
        objNewProjectController.poNumber();
        objNewProjectController.backToOpportunity();
        objNewProjectController.continueConvertToProject();
        objNewProjectController.returnToOpportunity();
        
        delete objNewProjectController.newProject;
    }
    
    static testMethod void testProjectDetails() {

        Account testAcc = new Account();
        testAcc.Name = 'newTest Acc';
        testAcc.ShippingStreet = 'Test Street';
        testAcc.ShippingCity = 'Test City';
        testAcc.ShippingState = 'Test State';
        testAcc.ShippingPostalCode = '123432';
        testAcc.ShippingCountry = 'Test country';
        insert testAcc;

        Opportunity objOpportunity = new Opportunity();
        objOpportunity.closeDate = Date.today();
        objOpportunity.Name = 'Test Opportunity';
        objOpportunity.stageName = 'TARGET/NEGOTIATING';
        objOpportunity.Targeted__c = true;
        objOpportunity.Total_Project_Margin__c = 1000;
        objOpportunity.AccountId = testAcc.Id;
        insert objOpportunity;
        
        Quote newQuote = new Quote();
        newQuote.Name = 'Test Quote';
        newQuote.opportunityId = objOpportunity.Id;
        newQuote.Scope_Revision_Number__c = '01';
        newQuote.Submittal_Revision_Number__c = '01';
        insert newQuote;
        
        Product_Group__c objParentProductGroup = new Product_Group__c();
        objParentProductGroup.Name = 'Parent Group';
        objParentProductGroup.Quote__c = newQuote.Id;
        insert objParentProductGroup;
        
        Product_Group__c objChildProductGroup = new Product_Group__c();
        objChildProductGroup.Name = 'Parent Group';
        objChildProductGroup.Quote__c = newQuote.Id;
        objChildProductGroup.Parent_Product_Group__c = objParentProductGroup.Id;
        insert objChildProductGroup;

        Product_Group__c objChildProductGroup2 = new Product_Group__c();
        objChildProductGroup2.Name = 'Child Group';
        objChildProductGroup2.Quote__c = newQuote.Id;
        objChildProductGroup2.Parent_Product_Group__c = objChildProductGroup.Id;
        insert objChildProductGroup2;
        
        Product_Select__c objParentLineItem = new Product_Select__c();
        objParentLineItem.Product_Name__c = 'Parent Product Name';
        objParentLineItem.Release_pick__c = '1.1';
        objParentLineItem.Quote__c = newQuote.Id;
        objParentLineItem.Product_Group__c = objChildProductGroup.Id;
        insert objParentLineItem;
        
        Product_Select__c objChildLineItem = new Product_Select__c();
        objChildLineItem.Product_Name__c = 'Child Product Name';
        objChildLineItem.Quote__c = newQuote.Id;
        objChildLineItem.Release_pick__c = '1.2';
        objChildLineItem.Product_Group__c = objChildProductGroup.Id;
        insert objChildLineItem;

        Product_Select__c objChildLineItem2 = new Product_Select__c();
        objChildLineItem2.Product_Name__c = 'Child Product Name2';
        objChildLineItem2.Quote__c = newQuote.Id;
        objChildLineItem2.Release_pick__c = '2.2';
        objChildLineItem2.Product_Group__c = objChildProductGroup.Id;
        insert objChildLineItem2;
        
        Contact newContact = new Contact();
        newContact.Email = 'nilesh.badrakia@gmail.com';
        newContact.lastName = 'Badrakiya';
        insert newCOntact;
 
        // createad only to get coverage in debugScheduledEmailProjectTool 
        Contact newContact2 = new Contact();
        newContact2.Email = 'nilesh.badrakia@gmail.com';
        newContact2.lastName = 'debug PM scheduleTp';
        insert newContact2 ;
 
            
        objOpportunity.Active_Financial_Quote__c = newQuote.Id;
        objOpportunity.Sync_Quote__c = newQuote.Id;
        update objOpportunity;
        
        Datetime dt = System.now();
        String todayDay = dt.format('EEEE');
        
        Project__c newProject = new Project__c();
        newProject.Name = 'Test Project';
        newProject.Receipt_of_Order_Date__c = System.Now().Date();
        newProject.Opportunity__c = objOpportunity.Id;
        //newProject.Schedule_To__c = newContact.Id;
        newProject.Schedule_On__c = todayDay;
        newProject.Schedule_End_Date__c = system.today();
        newProject.ProjectShipDate__c = system.today();
        newProject.OwnerId =  UserInfo.getUserId();
        insert newProject;

        Release_Management__c newReleaseManagement = new Release_Management__c();
        newReleaseManagement.Release__c = 'test';
        newReleaseManagement.Release_Name__c = 'Test Management';
        newReleaseManagement.Project_Id__c = newProject.Id;
        newReleaseManagement.Unique_Key__c = 'uniqueKey123';
        insert newReleaseManagement;

        Roles_With_Public_Calendars__c testCalendar = new Roles_With_Public_Calendars__c(
            Name = 'shipping null',
            Calendar_Id__c = UserInfo.getUserId() // Set the user ID as the calendar ID for testing purposes
        );
        insert testCalendar;
        
        Event newEvent = new Event();
        newEvent.Opportunity_Name__c = newProject.Name;
        newEvent.WhatId = newProject.id;
        newEvent.OwnerId = testCalendar.Calendar_Id__c;
        newEvent.OpportunityNumber__c = objOpportunity.Opportunity_Number__c;
        newEvent.Subject = 'Bid Due';
        newEvent.StartDateTime = datetime.newInstance(2022, 9, 12, 12, 30, 0);
        newEvent.EndDateTime = datetime.newInstance(2022, 9, 13, 13, 30, 0);
        insert newEvent;

        Project_Schdule_To__c objScheduleTo = new Project_Schdule_To__c();
        objScheduleTo.Contact__c = newContact.Id;
        objScheduleTo.Project__c = newProject.Id;
        objScheduleTo.Schedule_Type__c = 'Contact';
        insert objScheduleTo;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(newProject);
        ProjectDetailsController objProjectDetailsController = new ProjectDetailsController(sc);
        
        objProjectDetailsController.saveQuoteLineItemsAndReleaseManagement();
        objProjectDetailsController.scheduleEmail();
        objProjectDetailsController.doAddScheduleTo();
        objProjectDetailsController.deleteScheduleTo();
        objProjectDetailsController.FillQuoteLineItems();
        objProjectDetailsController.changeContactUser();
        objProjectDetailsController.SendEmail();
        
        
        EmailStartupStageAndWarranty objEmailStartupStageAndWarranty = new EmailStartupStageAndWarranty();
        objEmailStartupStageAndWarranty.projectId = newProject.Id;
        
        Sales_Rep_Goal__c newSalesRepGoal = new Sales_Rep_Goal__c();
        newSalesRepGoal.Sales_Rep__c = userInfo.getUserId();
        newSalesRepGoal.Revenue_Goal__c = 500000;
        newSalesRepGoal.Margin_Goal__c = 25000;
        newSalesRepGoal.Year__c = String.valueOf(System.Today().year());
        insert newSalesRepGoal;
        
        Sales_Representative__c newSalesRep = new Sales_Representative__c();
        newSalesRep.Sales_Rep__c = userInfo.getUserId();
        newSalesRep.Opportunity__c = objOpportunity.Id;
        newSalesRep.Commision__c = 20;
        insert newSalesRep;
        
        SalesRepReportController objSalesRepReportController = new SalesRepReportController();

        Apexpages.currentPage().getParameters().put('stageName', 'TARGET/NEGOTIATING');
        Apexpages.currentPage().getParameters().put('selectSalesRep', userInfo.getuserId());
        ShowAllOpportunity objShowAllOpportunity = new ShowAllOpportunity();
        objShowAllOpportunity.getSetFromStageName('TARGET/NEGOTIATING');
        objShowAllOpportunity.getOpportunity();
        objShowAllOpportunity.selectSalesRep = userInfo.getUserId();
        objShowAllOpportunity.getSalesRepOpportunityIds();
        objShowAllOpportunity.selectSalesRep = 'Midwest Machinery';
        objShowAllOpportunity.getSalesRepOpportunityIds();
        objShowAllOpportunity.next();
        objShowAllOpportunity.previous();
        objShowAllOpportunity.last();
        objShowAllOpportunity.first();
        boolean hasn = objShowAllOpportunity.hasNext;
        boolean hasp = objShowAllOpportunity.hasPrevious;
        Integer pagenumber = objShowAllOpportunity.pageNumber;

        Apexpages.currentPage().getParameters().put('stageName', 'Open Projects1');
        Apexpages.currentPage().getParameters().put('selectSalesRep', userInfo.getuserId());
        objShowAllOpportunity = new ShowAllOpportunity();

        Apexpages.currentPage().getParameters().put('stageName', 'Past Due');
        Apexpages.currentPage().getParameters().put('selectSalesRep', userInfo.getuserId());
        objShowAllOpportunity = new ShowAllOpportunity();

        STLDashboard objSTLDashboard = new STLDashboard();
        
        Test.startTest();
        
        scheduledEmailProjectTool sh1 = new scheduledEmailProjectTool();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Email ScheduleTest', sch, sh1); 
        
        debugScheduledEmailProjectTool sh2 = new debugScheduledEmailProjectTool();
        system.schedule('Email ScheduleTest debug', sch, sh2);
        
        Test.stopTest(); 
        
    }
    
    static testMethod void AddSplitEngineerOpportunity() {
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.closeDate = Date.today();
        objOpportunity.Name = 'Test Opportunity';
        objOpportunity.stageName = 'Draft';
        insert objOpportunity;
        
        Apexpages.currentpage().getparameters().put('oppId',objOpportunity.Id);
        AddEditSalesEngineerSplitController objAddEditSalesEngineerSplitController = new AddEditSalesEngineerSplitController();
        objAddEditSalesEngineerSplitController.addSalesEngineer();
        objAddEditSalesEngineerSplitController.hidRowIndex = 1;
        objAddEditSalesEngineerSplitController.deleteSalesEnginner();
        objAddEditSalesEngineerSplitController.addSalesEngineer();
        objAddEditSalesEngineerSplitController.Save();
        
        objAddEditSalesEngineerSplitController.redirectBackToOpportunity();
    }
    
}