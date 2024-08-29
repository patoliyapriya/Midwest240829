@isTest
public with sharing class ProjectDetailsTest {
    static testMethod void testProjectDetails() {

        AcctSeed__GL_Account__c GLAcc = new AcctSeed__GL_Account__c(Name='GL Acc', 
                                                                    AcctSeed__Type__c='Balance Sheet',
                                                                    AcctSeed__Sub_Type_1__c = 'Assets',
                                                                    AcctSeed__Bank__c = true);
        insert GLAcc;

        // pdf format
        AcctSeed__Billing_Format__c pdfFormateSO = new AcctSeed__Billing_Format__c(
            name = 'pdf123',
            AcctSeed__Type__c = 'Activity Statement',
            AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStmtModernPDF',
            AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template'
        );
        insert pdfFormateSO;

        AcctSeed__Billing_Format__c pdfFormateSO2 = new AcctSeed__Billing_Format__c(
            name = 'Billing Outstanding Statement',
            AcctSeed__Type__c = 'Outstanding Statement',
            AcctSeed__Visualforce_PDF_Page__c = 'BillingOutstandingStmtModernPDF',
            AcctSeed__Default_Email_Template__c = 'Outstanding_Statement_Email_Template'
        );
        insert pdfFormateSO2;

        AcctSeed__Billing_Format__c pdfFormateSO3 = new AcctSeed__Billing_Format__c(
            name = 'Default Billing Product',
            AcctSeed__Type__c = 'Billing',
            AcctSeed__Visualforce_PDF_Page__c = 'InvoicePDFDocument',
            AcctSeed__Default_Email_Template__c = 'Billing_Email_Template'
        );
        insert pdfFormateSO3;

        AcctSeed__Billing_Format__c pdfFormateSO4 = new AcctSeed__Billing_Format__c(
            name = 'Billing Outstanding Statement',
            AcctSeed__Type__c = 'Outstanding Statement',
            AcctSeed__Visualforce_PDF_Page__c = 'BillingOutstandingStmtModernPDF',
            AcctSeed__Default_Email_Template__c = 'Outstanding_Statement_Email_Template'
        );
        insert pdfFormateSO4;

        AcctSeed__Billing_Format__c pdfFormateSO5 = new AcctSeed__Billing_Format__c(
            name = 'Default Purchase Order',
            AcctSeed__Type__c = 'Purchase Order',
            AcctSeed__Visualforce_PDF_Page__c = 'PurchaseOrderPDF',
            AcctSeed__Default_Email_Template__c = 'Purchase_Order_Email_Template'
        );
        insert pdfFormateSO5;

        AcctSeed__Billing_Format__c pdfFormateSO6 = new AcctSeed__Billing_Format__c(
            name = 'Default Packing Slip',
            AcctSeed__Type__c = 'Packing Slip',
            AcctSeed__Visualforce_PDF_Page__c = 'ShipmentPDF',
            AcctSeed__Default_Email_Template__c = 'Purchase_Order_Email_Template'
        );
        insert pdfFormateSO6;

        AcctSeed__Ledger__c ledg = new AcctSeed__Ledger__c(
                                    Name='ledger',
                                    AcctSeed__Type__c='Transactional',
                                    AcctSeed__Billing_Activity_Statement_Format__c = pdfFormateSO.Id,
                                    AcctSeed__Default_Bank_Account__c = GLAcc.Id,
                                    AcctSeed__Billing_Outstanding_Statement_Format__c = pdfFormateSO2.Id,
                                    AcctSeed__Default_Billing_Format__c = pdfFormateSO3.Id,
                                    AcctSeed__Default_Purchase_Order_Format__c = pdfFormateSO5.Id,
                                    AcctSeed__Default_Packing_Slip_Format__c = pdfFormateSO6.Id);
        insert ledg;

        Opportunity objOpportunity = new Opportunity();
        objOpportunity.closeDate = Date.today();
        objOpportunity.Name = 'Test Opportunity';
        objOpportunity.stageName = 'TARGET/NEGOTIATING';
        objOpportunity.Targeted__c = true;
        objOpportunity.Total_Project_Margin__c = 1000;
        objOpportunity.Office__c = 'MaRRs';
        insert objOpportunity;
        
        Quote newQuote = new Quote();
        newQuote.Name = 'Test Quote';
        newQuote.opportunityId = objOpportunity.Id;
        newQuote.Scope_Revision_Number__c = '01';
        newQuote.Submittal_Revision_Number__c = '01';
        newQuote.Commissions_and_Rebates__c = 500;
        newQuote.Total_Buy_Resell_Price__c = 250;
        newQuote.Total_Buy_Resell_Margin__c =100;
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
        
        //quote line item.
        Product_Select__c objParentLineItem = new Product_Select__c();
        objParentLineItem.Product_Name__c = 'Parent Product Name';
        objParentLineItem.Release_pick__c = '1.1';
        objParentLineItem.Quote__c = newQuote.Id;
        objParentLineItem.Sale_Type__c = 'B/R';
        objParentLineItem.Product_Group__c = objChildProductGroup.Id;

        insert objParentLineItem;
        
        Product_Select__c objChildLineItem = new Product_Select__c();
        objChildLineItem.Product_Name__c = 'Child Product Name';
        objChildLineItem.Quote__c = newQuote.Id;
        objParentLineItem.Release_pick__c = '2.1';
        objChildLineItem.Product_Group__c = objChildProductGroup.Id;
        insert objChildLineItem;

        AcctSeedERP__Sales_Order__c testSalesOrder = new AcctSeedERP__Sales_Order__c();
        testSalesOrder.Quote__c =  newQuote.Id;
        testSalesOrder.Sales_Order_Number__c = 'So-1234';
        testSalesOrder.AcctSeedERP__Status__c = 'Open';
        testSalesOrder.AcctSeedERP__Ledger__c = ledg.Id;
        insert testSalesOrder;

        objParentLineItem.SalesOrderId__c = testSalesOrder.Id;
        update objParentLineItem;

        Product2 productSO1 = new Product2 (
            Name = 'SA_Xyz Product',
            Manufacturer__c = 'ActiveAir',
            Product_Type__c = 'Ionizers',
            IsActive = true,
            AcctSeed__Inventory_Type__c = 'Purchased',
            AcctSeed__Expense_GL_Account__c = GLAcc.Id,
            AcctSeed__Unit_Cost__c = 10,
            AcctSeed__Revenue_GL_Account__c = GLAcc.Id,
            AcctSeed__Inventory_GL_Account__c = GLAcc.Id
        );
        insert productSO1;

        AcctSeedERP__Sales_Order_Line__c testSOLT = new AcctSeedERP__Sales_Order_Line__c();
        //testSOLT.AcctSeedERP__Comment__c = 'comment';
        testSOLT.AcctSeedERP__Sales_Order__c = testSalesOrder.Id;
        testSOLT.AcctSeedERP__Product__c = productSO1.Id;
        testSOLT.AcctSeedERP__Unit_Price__c = 20;
        testSOLT.AcctSeedERP__Quantity_Ordered__c = 2;
        //testSOLT.Sale_Type__c = 'Equipment/Projects';
        //testSOLT.Quote_Line_Item__c = objParentLineItem.Id;
        testSOLT.AcctSeedERP__Product__c = productSO1.Id;
        insert testSOLT;


        AcctSeed__Accounting_Period__c accPeriod = new AcctSeed__Accounting_Period__c(
            Name = Datetime.now().format('YYYY-MM'), 
            AcctSeed__Start_Date__c = Date.today(),
            AcctSeed__End_Date__c = Date.today().addDays(31),
            AcctSeed__Status__c = 'open'
        );
        insert accPeriod;
        
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
        Decimal grandTotalCost = 0;
        
        Project__c newProject = new Project__c();
        newProject.Name = 'Test Project';
        newProject.Receipt_of_Order_Date__c = System.Now().Date();
        newProject.Opportunity__c = objOpportunity.Id;
        //newProject.Schedule_To__c = newContact.Id;
        newProject.Schedule_On__c = todayDay;
        newProject.Schedule_End_Date__c = system.today();
        insert newProject;
        
        Project_Schdule_To__c objScheduleTo = new Project_Schdule_To__c();
        objScheduleTo.Contact__c = newContact.Id;
        objScheduleTo.Project__c = newProject.Id;
        objScheduleTo.Schedule_Type__c = 'Contact';
        insert objScheduleTo;

         Sales_Representative__c testsalesEggSplits = new Sales_Representative__c();
         testsalesEggSplits.Commision__c = 100;
         testsalesEggSplits.Sales_Rep__c = UserInfo.getUserId(); 
         
         testsalesEggSplits.Opportunity__c = objOpportunity.Id;
         insert testsalesEggSplits;

        ProjectDetails.getData(newProject.Id);


        Project_Schdule_To__c newObjScheduleTo = new Project_Schdule_To__c();
        newObjScheduleTo.Contact__c = newContact.Id;
        newObjScheduleTo.Project__c = newProject.Id;
        newObjScheduleTo.Schedule_Type__c = 'Contact';
        List<Project_Schdule_To__c> newScheduleTo = new List<Project_Schdule_To__c>{newObjScheduleTo};
        List<Project_Schdule_To__c> ScheduleToDelete = new List<Project_Schdule_To__c>{objScheduleTo};
        ProjectDetails.updateEmailSchedules(newProject, newScheduleTo, ScheduleToDelete);

        Product_Select__c objChildLineItem2 = new Product_Select__c();
        objChildLineItem2.Product_Name__c = 'Child Product Name';
        objChildLineItem2.Quote__c = newQuote.Id;
        objChildLineItem2.Release_pick__c = '2.1';
        objChildLineItem2.Product_Group__c = objChildProductGroup.Id;

        List<Product_Select__c> quoteLines = new List <Product_Select__c>{objParentLineItem};
        ProjectDetails.saveProjectStatus(quoteLines);
        
        String jsonInput = JSON.serialize(quoteLines);
        ProjectDetails.updateProjectDetails(jsonInput);

        quoteLines.add(objChildLineItem2);
        ProjectDetails.saveProjectStatus(quoteLines);
        jsonInput = JSON.serialize(quoteLines);
        ProjectDetails.updateProjectDetails(jsonInput);

        // EmailSendController.prepareEmailData(newProject.Id);

        Project__c testProject = new Project__c();
        testProject.Name = 'Test Project';
        testProject.Receipt_of_Order_Date__c = System.Now().Date();
        insert testProject;

        Cost_Posting__c testCost = new Cost_Posting__c();
        testCost.Type__c = 'Labor';
        testCost.Project__c = testProject.Id;
        insert testCost;
       List<Cost_Posting__c> deleteCost = [SELECT Id, Type__c From Cost_Posting__c WHERE Id =: testCost.Id];
        ProjectDetails.deleteCostPosting(testCost.Type__c, testCost.Id , testProject.Id);

        AcctSeed__Journal_Entry__c testjonEntry = new AcctSeed__Journal_Entry__c();
        testjonEntry.Name = 'Test journal Entry';
        testjonEntry.AcctSeed__Status__c = 'Approved';
        testjonEntry.AcctSeed__Ledger__c = ledg.Id;
        testjonEntry.AcctSeed__Journal_Date__c = System.Now().Date();
        testjonEntry.AcctSeed__Accounting_Period__c = accPeriod.Id;
        insert testjonEntry;

        AcctSeed__Journal_Entry_Line__c testJonEntline = new AcctSeed__Journal_Entry_Line__c();
        testJonEntline.AcctSeed__Journal_Entry__c = testjonEntry.Id;
        testJonEntline.AcctSeed__Debit__c = 500 ;
        testJonEntline.Projects_MMCO_Custom_Tool__c = testProject.Id;
        testJonEntline.Project_Posting_Type__c = 'Labor';
        testJonEntline.AcctSeed__GL_Account__c = GLAcc.Id;
        insert testJonEntline;
        ProjectDetails.getJournalEntryLine(testJonEntline.Project_Posting_Type__c, testProject.Id);

        ProjectDetails.getProjectFinancialDetails(newProject.Id, grandTotalCost);
        ProjectDetails.getProjectCommissionDetails(newProject.Id, grandTotalCost);

    }

    //test method for emailsendctrl
    @isTest static void testForEmailSendCtrl(){

        opportunity opprecord = new opportunity();
        opprecord.name = 'test';
        opprecord.closeDate = Date.today();
        opprecord.stageName = 'TARGET/NEGOTIATING';
        opprecord.Targeted__c = true;
        opprecord.Total_Project_Margin__c = 1000;
        opprecord.Office__c = 'MaRRs';
        insert opprecord;

        Project__c projectRecord = new Project__c();
        projectRecord.Name = 'Test Project';
        projectRecord.PO_Number__c = '15426';
        projectRecord.Receipt_of_Order_Date__c = System.Now().Date();
        projectRecord.Opportunity__c = opprecord.Id;
        insert projectRecord;
        
        Contact contactRecord = new Contact();
        contactRecord.Email = 'nilesh.badrakia@gmail.com';
        contactRecord.lastName = 'Badrakiya';
        insert contactRecord;

        EmailSendController.sendEmailWrapper strJson = new EmailSendController.sendEmailWrapper();
        strJson = EmailSendController.prepareEmailData(projectRecord.Id)[0];
        List<Id> conIds = new List<Id>();
        conIds.add(contactRecord.Id);
        strJson.contactIdList = conIds;
        strJson.targetObjectId = contactRecord.Id;
        strJson.fromAddress = strJson.orgWideFromAddress;
        strJson.fromAddressId = strJson.orgWideFromAddressId;
        strJson.projectId = projectRecord.Id;
        strJson.ccAddress = 'nilesh.badrakia@gmail.com';
        strJson.bccAddress = 'nilesh.badrakia@gmail.com';
        strJson.toAddress = 'nilesh.badrakia@gmail.com';
        system.debug('strJson value :- '+strJson);
        EmailSendController.sendMail(strJson); 

        string userId = UserInfo.getUserId();
        string subject = 'testSubject';
        string body = 'testBody';
        EmailSendController.sendMailMethod(userId,Subject,body); 
        EmailSendController.getPreviewURLForProject(projectRecord.Id); 

    }
}