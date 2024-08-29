@isTest
public class BillingPdfPreviewCtrlTest {

    //BillingPdfPreviewCtrl --> BillingPreviewCustomPage(VF page)
    static testMethod void testMethod1(){
        //createData();
        AcctSeed__Billing__c billingSO = [SELECT Id FROM AcctSeed__Billing__c limit 1];
        
        PageReference BillingPdfCustomPage = Page.BillingPreviewCustomPage; 
        Test.setCurrentPage(BillingPdfCustomPage);
        BillingPdfCustomPage.getParameters().put('id', billingSO.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(billingSO);
        BillingPdfPreviewCtrl ctrl = new BillingPdfPreviewCtrl(sc);
        ctrl.getOrgWideEmailSelectOptions();
        List<BillingPdfPreviewCtrl.CustomFileStruct> wrapperList = new List<BillingPdfPreviewCtrl.CustomFileStruct>();
        ctrl.attachmetsWrapperList = wrapperList;
        Long size = 1025;
        BillingPdfPreviewCtrl.FileSizeToString(size);
        
        size = 1023;
        BillingPdfPreviewCtrl.FileSizeToString(size);
        
        size = 1048577;
        BillingPdfPreviewCtrl.FileSizeToString(size);
        
        size = 1070596098;
        BillingPdfPreviewCtrl.FileSizeToString(size);
      
         BillingPdfPreviewCtrl.sharepointUpdate();
         ctrl.saveAttach();
        ctrl.saveAndEmail();
         //AcctSeed__Billing__c billingSO = ctrl.billingSO;
        Boolean sendccUser = ctrl.sendccUser;
        String ccAddresses = ctrl.ccAddresses;
        String pdfName = ctrl.pdfName;
        String emailBody = ctrl.emailBody;
        String emailsubject = ctrl.emailsubject;
        Id billingId = ctrl.billingId;
        String EmailSelectorLink = ctrl.EmailSelectorLink;
        Boolean showSendEmail= ctrl.showSendEmail;
        Boolean showSendContactError = ctrl.showSendContactError;
        Contact ContactSO= ctrl.ContactSO;
        EmailTemplate emailTemplateSO = ctrl.emailTemplateSO;
        Boolean displayPopUp = ctrl.displayPopUp;
        Blob fileData = ctrl.fileData;
        String fileName = ctrl.fileName;
        Integer fileSize = ctrl.fileSize;
        Boolean isFileSizeLimitExceeded = ctrl.isFileSizeLimitExceeded;
        String fileSizeLimitErrorMessage = ctrl.fileSizeLimitErrorMessage;
        Boolean ShowAttachments = ctrl.ShowAttachments;

        Test.StartTest();
        AcctSeedInvociePDFCtrl ctrlBillingPdf = new AcctSeedInvociePDFCtrl(sc);
        AcctSeedInvociePDFCtrl.sharepointUpdate();
        Test.StopTest();
        
    }

     //BillingPDFManagerCustomCtrl-->  BillingPDFManagerCustom(VF page)
      static testMethod void testMethodPDFCustom(){
       // createData();
        AcctSeed__Billing__c billingSO = [SELECT Id FROM AcctSeed__Billing__c limit 1];
        AcctSeed__GL_Account__c Glacc = [SELECT Id FROM AcctSeed__GL_Account__c WHERE Name='GLAcc Active' limit 1];
        PageReference BillingPdfCustomPage = Page.BillingPDFManagerCustom; 
        Test.setCurrentPage(BillingPdfCustomPage);
        BillingPdfCustomPage.getParameters().put('id', billingSO.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(billingSO);
      
        BillingPDFManagerCustomCtrl PDFManagerctrl = new BillingPDFManagerCustomCtrl(sc);
        PDFManagerctrl.getOrgWideEmailSelectOptions();

        List<BillingPDFManagerCustomCtrl.CustomFileStruct> wrapperList = new List<BillingPDFManagerCustomCtrl.CustomFileStruct>();
        PDFManagerctrl.attachmetsWrapperList = wrapperList;

        Long size = 1025;
        BillingPDFManagerCustomCtrl.FileSizeToString(size);
        
        size = 1023;
        BillingPDFManagerCustomCtrl.FileSizeToString(size);
        
        size = 1048577;
        BillingPDFManagerCustomCtrl.FileSizeToString(size);
        
        size = 1070596098;
        BillingPDFManagerCustomCtrl.FileSizeToString(size);
      
        BillingPDFManagerCustomCtrl.sharepointUpdate();
        PDFManagerctrl.saveAttach();
        PDFManagerctrl.saveAndEmail();
        PDFManagerctrl.cancel();
        PDFManagerctrl.setContact();
        //PDFManagerctrl.attachCustomFile();
       
        String selectedOrgWideEmailAddress = PDFManagerctrl.selectedOrgWideEmailAddress;
        Boolean sendccUser = PDFManagerctrl.sendccUser;
        String ccAddresses = PDFManagerctrl.ccAddresses;
        String pdfName = PDFManagerctrl.pdfName;
        String emailBody = PDFManagerctrl.emailBody;
        String emailsubject = PDFManagerctrl.emailsubject;
        Id billingId = PDFManagerctrl.billingId;
        String EmailSelectorLink = PDFManagerctrl.EmailSelectorLink;
        Boolean showSendEmail= PDFManagerctrl.showSendEmail;
        Boolean showSendContactError = PDFManagerctrl.showSendContactError;
        Contact ContactSO= PDFManagerctrl.ContactSO;
        EmailTemplate emailTemplateSO = PDFManagerctrl.emailTemplateSO;
        Boolean displayPopUp = PDFManagerctrl.displayPopUp;
        Blob fileData = PDFManagerctrl.fileData;
        String fileName = PDFManagerctrl.fileName;
        Integer fileSize = PDFManagerctrl.fileSize;
        Boolean isFileSizeLimitExceeded = PDFManagerctrl.isFileSizeLimitExceeded;
        String fileSizeLimitErrorMessage = PDFManagerctrl.fileSizeLimitErrorMessage;
        Boolean ShowAttachments = PDFManagerctrl.ShowAttachments;

        // AcctSeedInvociePDFCtrl ctrlBillingPdf = new AcctSeedInvociePDFCtrl(sc);
        // AcctSeedInvociePDFCtrl.sharepointUpdate();
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        Test.StartTest();
        PDFManagerctrl.getOrgWideEmailSelectOptions();
        Id partRecID = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Parts').getRecordTypeId();
        Opportunity opp3 = new Opportunity(); 
        opp3.Name = 'Test Opp3';
        opp3.closedate = System.today();
        // opp3.StageName = 'Non Qualified';
        opp3.StageName = 'Bidding';
        opp3.RecordTypeId = partRecID;
        opp3.Office__c = 'Midwest Machinery STL';
        opp3.AccountId = acc.Id;
        insert opp3;

        /*AcctSeed__Billing__c billingSO2 = [SELECT ID FROM AcctSeed__Billing__c limit 1];
        billingSO.AcctSeed__Opportunity__c = opp3.Id;
        update billingSO2;*/

        AcctSeed__Billing_Line__c objBillingLine2 = new AcctSeed__Billing_Line__c();
        objBillingLine2.AcctSeed__Billing__c = billingSO.id;
        objBillingLine2.AcctSeed__Date__c = System.today();
        objBillingLine2.AcctSeed__Rate__c = 25;
        objBillingLine2.AcctSeed__Hours_Units__c = 1;
        objBillingLine2.AcctSeed__Revenue_GL_Account__c	= Glacc.id;
        insert objBillingLine2;
        Test.StopTest();

    }

    static testMethod void deleteTestMethod(){
        //createData();
        //trigger test class for delete Most recent date 
        AcctSeed__Billing__c billingSO = [SELECT Id FROM AcctSeed__Billing__c limit 1];
        if(billingSO != null){
            delete billingSO;
        }
        else{
            system.debug(' No Record to Delete');
        }
        
    }

    static testMethod void cashReciptTest(){
        //createData();

        Test.StartTest();
        AcctSeed__Billing__c billingSOForCR = [SELECT Id,
                                                    AcctSeed__Opportunity__c,
                                                    AcctSeed__Customer__c,
                                                    AcctSeed__Total__c
                                                FROM AcctSeed__Billing__c
                                                WHERE AcctSeed__Opportunity__r.Name = 'Test Opp2'
                                                LIMIT 1];
        AcctSeed__Accounting_Period__c accPeriod = [SELECT Id FROM AcctSeed__Accounting_Period__c WHERE Name = :Datetime.now().format('YYYY-MM') LIMIT 1];

        AcctSeed__Ledger__c ledg = [SELECT Id FROM AcctSeed__Ledger__c LIMIT 1];

        AcctSeed__GL_Account__c[] glAccount = new List<AcctSeed__GL_Account__c>();
        //0
        glAccount.add(
                        new AcctSeed__GL_Account__c(
                        Name = '1000-Cash',
                        AcctSeed__Active__c = true,
                        AcctSeed__Type__c = 'Balance Sheet',
                        AcctSeed__Bank__c = true,
                        AcctSeed__Sub_Type_1__c = 'Assets',
                        AcctSeed__Sub_Type_2__c = 'Cash')
                    );
			
        //1
        glAccount.add(
                        new AcctSeed__GL_Account__c(
                        Name = '1205-Unapplied A/R',
                        AcctSeed__Active__c = true,
                        AcctSeed__Type__c = 'Balance Sheet',
                        AcctSeed__Sub_Type_1__c = 'Assets',
                        AcctSeed__Sub_Type_2__c = 'Cash')
                        );
        insert glAccount;

        AcctSeed__Cash_Receipt__c CashRept = new AcctSeed__Cash_Receipt__c(
                                        AcctSeed__Account__c = billingSOForCR.AcctSeed__Customer__c,
                                        AcctSeed__Amount__c = billingSOForCR.AcctSeed__Total__c,
                                        AcctSeed__Payment_Reference__c = 'REFFF',
                                        AcctSeed__Bank_Account__c = glAccount[0].Id, //'1000-Cash'
                                        AcctSeed__Credit_GL_Account__c = glAccount[1].Id, //'1200-Accounts Receivable'
                                        AcctSeed__Accounting_Period__c = accPeriod.Id,
                                        AcctSeed__Ledger__c = ledg.id
        );      
        insert CashRept;

        AcctSeed__Billing_Cash_Receipt__c BillingCashRpt = new AcctSeed__Billing_Cash_Receipt__c();
        BillingCashRpt.AcctSeed__Billing__c = billingSOForCR.id;
        BillingCashRpt.AcctSeed__Cash_Receipt__c = CashRept.id; 
        BillingCashRpt.AcctSeed__Accounting_Period__c = accPeriod.Id;
        BillingCashRpt.AcctSeed__Applied_Amount__c = CashRept.AcctSeed__Amount__c; // pass the total from billing line item 
        insert BillingCashRpt;
        Test.StopTest();
        
    }

    // This test method is For marsInvoicePdfCtrl.cls
    @isTest static void testGenerateAttachment() {
        AcctSeed__Billing__c billing = [SELECT Id,Name FROM AcctSeed__Billing__c limit 1];

        PageReference pageRef = Page.MarrsInvoicePdf2;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', billing.Id);

        // set the expected PDF content
        Blob expectedContent = Blob.valueOf('UNIT.TEST');

        // start the test
        Test.startTest();
        // generate the attachment
        marsInvoicePdfCtrl controller = new marsInvoicePdfCtrl();
        
        controller.generateAttachment();
        Attachment attachment = [SELECT Id, Name, Body FROM Attachment WHERE ParentId =: billing.Id ];
        System.assertEquals(expectedContent, attachment.Body);
        Test.stopTest();
    }

    //This test method is for PackingPdfController.cls
    @isTest static void testPackingPdfController() {
        AcctSeedERP__Shipment__c shipment = [SELECT id FROM AcctSeedERP__Shipment__c WHERE AcctSeedERP__Status__c = 'Shipped' limit 1];

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(shipment);
        PackingPdfController controller = new PackingPdfController(sc);
        List<AcctSeedERP__Shipment_Line__c> shipmentLineItems = controller.lstShipmentLineItems;
        System.assertEquals(shipmentLineItems[0].AcctSeedERP__Quantity_Shipped__c,0);
        Test.stopTest();
    }
    
    @testSetup static void setup() 
    { 
        createData();
    }
    private static void createData() {
   
        system.debug('used query limit 0='+limits.getQueries());
        AcctSeed__GL_Account__c GLAcc = new AcctSeed__GL_Account__c(Name='GL Acc', 
                                                                    AcctSeed__Type__c='Balance Sheet',
                                                                    AcctSeed__Sub_Type_1__c = 'Assets',
                                                                    AcctSeed__Bank__c = true);
        insert GLAcc;

        AcctSeed__GL_Account__c[] glAccounts = new List<AcctSeed__GL_Account__c>();
            // 0
            glAccounts.add(
            new AcctSeed__GL_Account__c(
            Name = '1000-Cash',
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Bank__c = true,
            AcctSeed__Sub_Type_1__c = 'Assets',
            AcctSeed__Sub_Type_2__c = 'Cash')
            );
            
            // 1
            glAccounts.add(
            new AcctSeed__GL_Account__c(
            Name = '1205-Unapplied A/R',
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Sub_Type_1__c = 'Assets',
            AcctSeed__Sub_Type_2__c = 'Cash'
            )
            );
            
            // 2
            glAccounts.add(
            new AcctSeed__GL_Account__c(
            Name = '1200-Accounts Receivable',
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Sub_Type_1__c = 'Assets',
            AcctSeed__Sub_Type_2__c = 'Current Assets'
            )
            );
            
            // 3
            glAccounts.add(
            new AcctSeed__GL_Account__c(
            Name = '2000-Accounts Payable',
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Sub_Type_1__c = 'Liabilities',
            AcctSeed__Sub_Type_2__c = 'Current Liabilities'
            )
            );
            
            // 4
            glAccounts.add(
            new AcctSeed__GL_Account__c(
            Name = '3050-Retained Earnings',
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Sub_Type_1__c = 'Owners Equity',
            AcctSeed__Sub_Type_2__c = 'Equity'
            )
            );
            
            // 5
            glAccounts.add(
            new AcctSeed__GL_Account__c(
            Name = '3060-Current Year Earnings',
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Sub_Type_1__c = 'Owners Equity',
            AcctSeed__Sub_Type_2__c = 'Equity'
            )
            );
            
            // 6
            glAccounts.add(
            new AcctSeed__GL_Account__c(
            Name = '4000-Product Revenue',
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Revenue',
            AcctSeed__Sub_Type_1__c = 'Product Revenue',
            AcctSeed__Sub_Type_2__c = 'Product Family 1'
            )
            );
            
            // 7
            glAccounts.add(
            new AcctSeed__GL_Account__c(
            Name = '5010-Inventory Cost Variance',
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Expense',
            AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold',
            AcctSeed__Sub_Type_2__c = 'Materials'
            )
            );
            
            // 8
            glAccounts.add(
            new AcctSeed__GL_Account__c(
            Name = '5040-Vendor Payment Discounts',
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Expense',
            AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold',
            AcctSeed__Sub_Type_2__c = 'Materials'
            )
            );
            
            // 9
            glAccounts.add(
            new AcctSeed__GL_Account__c(
            Name = 'zLabor Clearing',
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Expense'
            )
            );
            
            // 10
            glAccounts.add(
            new AcctSeed__GL_Account__c(
            Name = 'zProject Labor',
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Expense'
            )
            );
            
            insert glAccounts;
        
        AcctSeed__GL_Account__c GLAccActive = new AcctSeed__GL_Account__c(Name='GLAcc Active', 
        AcctSeed__Type__c='Balance Sheet',
        AcctSeed__Sub_Type_1__c = 'Assets',
        AcctSeed__Bank__c = false,
        AcctSeed__Active__c = true);
        insert GLAccActive;

        system.debug('used query limit 1='+limits.getQueries());
        AcctSeed__Accounting_Variable__c GLAVar = new AcctSeed__Accounting_Variable__c(
            Name = 'MIB',
            AcctSeed__Type__c = 'GL Account Variable 1'
        );
        system.debug('used query limit 2='+limits.getQueries());

        insert GLAVar;
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

        // insert 1 Ledger records
        AcctSeed__Ledger__c ledg = new AcctSeed__Ledger__c(
                                    Name = 'Actual',
                                    AcctSeed__Type__c = 'Transactional',
                                    AcctSeed__Default_Bank_Account__c = glAccounts[0].Id,
                                    AcctSeed__Default_Billing_Format__c = pdfFormateSO3.Id,
                                    AcctSeed__Billing_Outstanding_Statement_Format__c = pdfFormateSO2.Id,
                                    AcctSeed__Billing_Activity_Statement_Format__c = pdfFormateSO.Id,
                                    AcctSeed__Default_Purchase_Order_Format__c = pdfFormateSO5.Id,
                                    AcctSeed__Default_Packing_Slip_Format__c = pdfFormateSO6.Id);
    
        insert ledg;

        // create product
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
        
		List<Account> listOfAccInsert = new List<Account>();
        // insert account
        Account acc = new Account();
        acc.Name = 'Test Account';
        listOfAccInsert.add(acc);
		
		Account billingAcc = new Account(Name='Billing Acc',
								AcctSeed__Accounting_Type__c = 'Vendor',
								AcctSeed__Accounting_Active__c = true,
								BillingCity ='city',
								BillingCountry = 'contry',
								BillingState = 'state',
								BillingPostalCode = '1232',
								BillingStreet= 'street');
        listOfAccInsert.add(billingAcc);
        insert listOfAccInsert;
		
        Contact con = new Contact();
        con.FirstName ='TestFname';
        con.LastName = 'LastNm';
        con.AccountId = acc.Id;
        con.Email = 'SA@test.com';
        insert con;
        
        List<Opportunity> oppListInsert = new List<Opportunity>();
        // inser mars opportunity
        Id marsOppTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('MaRRS').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.closedate = System.today();
        opp.StageName = 'Non Qualified';
        opp.RecordTypeId = marsOppTypeId;
        opp.Office__c = 'MaRRs';
        opp.AccountId = acc.Id;
        oppListInsert.add(opp);

        Id equepmentRecID = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Equipment').getRecordTypeId();
    
        Opportunity opp2 = new Opportunity(); 
        opp2.Name = 'Test Opp2';
        opp2.closedate = System.today();
        opp2.StageName = 'Non Qualified';
        opp2.RecordTypeId = equepmentRecID;
        opp2.Office__c = 'Midwest Machinery STL';
        opp2.AccountId = acc.Id;
        oppListInsert.add(opp2);


        
        insert oppListInsert;
        system.debug('used query limit opp='+limits.getQueries() + opp.Id);

        Quote newQuote = new Quote();
        newQuote.Name = 'Test Quote';
        newQuote.opportunityId = opp.Id;
        newQuote.Scope_Revision_Number__c = '01';
        newQuote.Submittal_Revision_Number__c = '01';
        insert newQuote;
        system.debug('used query limit 4='+limits.getQueries());

        
        Product_Group__c objParentProductGroup = new Product_Group__c();
        objParentProductGroup.Name = 'Parent Group';
        objParentProductGroup.Quote__c = newQuote.Id;
        insert objParentProductGroup;
        system.debug('used query limit 5='+limits.getQueries());
        
        Product_Group__c objChildProductGroup = new Product_Group__c();
        objChildProductGroup.Name = 'Parent Group';
        objChildProductGroup.Quote__c = newQuote.Id;
        objChildProductGroup.Parent_Product_Group__c = objParentProductGroup.Id;
        insert objChildProductGroup;
        system.debug('used query limit 6='+limits.getQueries());
        
        Product_Select__c objParentLineItem = new Product_Select__c();
        objParentLineItem.Product_Name__c = 'Parent Product Name';
        objParentLineItem.Quote__c = newQuote.Id;
        objParentLineItem.Sale_Type__c = 'B/R';
        objParentLineItem.Product_Group__c = objChildProductGroup.Id;
        insert objParentLineItem;
        system.debug('used query limit 7='+limits.getQueries());
        

        
        //create sales order
        AcctSeedERP__Sales_Order__c orderSO = new AcctSeedERP__Sales_Order__c();
        orderSO.AcctSeedERP__Customer__c = acc.Id;
        orderSO.AcctSeedERP__Status__c = 'Open';
        orderSO.AcctSeedERP__Ledger__c = ledg.ID;
        orderSO.AcctSeedERP__Opportunity__c = opp.Id;
        insert orderSO;
        system.debug('used query limit 8='+limits.getQueries());

        // create sales order line item
        AcctSeedERP__Sales_Order_Line__c orderLine1 = new AcctSeedERP__Sales_Order_Line__c(
            AcctSeedERP__Comment__c = 'comment',
            AcctSeedERP__Sales_Order__c = orderSO.Id,
            AcctSeedERP__Product__c = productSO1.Id,
            AcctSeedERP__Unit_Price__c = 20,
            AcctSeedERP__Quantity_Ordered__c = 2,
            Sale_Type__c = 'Equipment/Projects',
            Quote_Line_Item__c = objParentLineItem.Id
        );
        insert orderLine1;
        system.debug('used query limit 9='+limits.getQueries());

        

        System.debug('Name: '+Datetime.now().format('YYYY-MM'));
        AcctSeed__Accounting_Period__c accPeriod = new AcctSeed__Accounting_Period__c(
            Name = Datetime.now().format('YYYY-MM'), // text value
            AcctSeed__Start_Date__c = Date.today(),
            AcctSeed__End_Date__c = Date.today().addDays(31),
            AcctSeed__Status__c = 'open'
        );
        system.debug('used query limit 10='+limits.getQueries());

        insert accPeriod;
        system.debug('Test Account peroid' + accPeriod );
        system.debug('used query limit 11='+limits.getQueries());
        

        system.debug('used query limit 14='+limits.getQueries());
        AcctSeed__Accounting_Settings__c setting = new AcctSeed__Accounting_Settings__c(
                                                Name = 'Account Setting',
                                                AcctSeed__AP_Control_GL_Account__c = glAccounts[3].Id,
                                                AcctSeed__AR_Control_GL_Account__c = glAccounts[2].Id,
                                                AcctSeed__Current_Year_Earnings_GL_Account__c = glAccounts[7].Id,
                                                AcctSeed__Default_Ledger__c = ledg.Id,
                                                AcctSeed__Retained_Earnings_GL_Account__c = glAccounts[6].Id,
                                                AcctSeed__Revenue_GL_Account__c = glAccounts[8].Id,
                                                AcctSeed__Unapplied_Cash_GL_Account__c = glAccounts[0].Id
                                                );
        insert setting;
        
        system.debug('used query limit 15='+limits.getQueries());
        List<AcctSeed__Billing__c> billingList = new List<AcctSeed__Billing__c>();
         AcctSeed__Billing__c billingSO = new AcctSeed__Billing__c(
            AcctSeedERP__Sales_Order__c = orderSO.Id,
            AcctSeed__Opportunity__c = opp.Id,
            AcctSeed__Billing_Format__c = pdfFormateSO3.Id,
            AcctSeed__Date__c = date.today(),
            AcctSeed__Customer__c = billingAcc.Id,
            AcctSeed__Due_Date2__c = Date.today(),
            AcctSeed__Status__c = 'In Process',
            AcctSeed__PDF_Email_Status__c = 'Unsent',
            AcctSeed__Accounting_Period__c = accPeriod.Id,
            AcctSeed__Billing_Contact__c = con.Id ,
            Posting_Status__c = 'Posted');
       // insert billingSO;
       billingList.add(billingSO);

        system.debug('used query limit 16='+limits.getQueries());
        AcctSeedERP__Shipment__c shipmentSO = new AcctSeedERP__Shipment__c(
            AcctSeedERP__Status__c = 'Shipped',
            AcctSeedERP__Sales_Order__c = orderSO.Id
        );
        insert shipmentSO;
        system.debug('used query limit 17='+limits.getQueries());

        AcctSeedERP__Shipment_Line__c shipmentLine = new AcctSeedERP__Shipment_Line__c(
            AcctSeedERP__Quantity_Shipped__c = 0,
            AcctSeedERP__Sales_Order_Line__c = orderLine1.Id,
            AcctSeedERP__Shipment__c = shipmentSO.Id
        );
        insert shipmentLine;

        ApexPages.StandardController shipmentPDFStdCtrl = new ApexPages.StandardController(shipmentSO);
        PickTicketPdfCtrl shipmentPDFCtrl = new PickTicketPdfCtrl(shipmentPDFStdCtrl);


        AcctSeed__Billing__c billingSO2 = new AcctSeed__Billing__c(
            AcctSeedERP__Sales_Order__c = orderSO.Id,
            AcctSeed__Opportunity__c = opp2.Id,
            AcctSeed__Billing_Format__c = pdfFormateSO3.Id,
            AcctSeed__Date__c = date.today(),
            AcctSeed__Customer__c = billingAcc.Id,
            AcctSeed__Due_Date2__c = Date.today(),
            AcctSeed__Status__c = 'Approved',
            //AcctSeed__PDF_Email_Status__c = 'Unsent',
            AcctSeed__Accounting_Period__c = accPeriod.Id,
            AcctSeed__Shipping_PostalCode__c = '63132',
            AcctSeed__Shipping_City__c = '	St. Louis',
            AcctSeed__Shipping_Street__c = '1340 North Price Road',
            AcctSeed__Shipping_State__c = 'Missouri',
            AcctSeed__Shipping_Country__c = 'United States'
        );
        //insert billingSO2;
        billingList.add(billingSO2);
        insert billingList;
        
        //create purchase order
        AcctSeedERP__Purchase_Order__c purchaseOrder = new AcctSeedERP__Purchase_Order__c();
        purchaseOrder.AcctSeedERP__Type__c = 'Standard';
        purchaseOrder.AcctSeedERP__Order_Date__c = date.today();
        purchaseOrder.AcctSeedERP__Status__c = 'Open';
        purchaseOrder.AcctSeedERP__Vendor__c = acc.Id;
        purchaseOrder.Office__c = 'MaRRS';
        insert purchaseOrder;
        
		List<AcctSeed__GL_Account__c> GLToInsert = new List<AcctSeed__GL_Account__c>();
        AcctSeed__GL_Account__c GLAccRev = new AcctSeed__GL_Account__c(Name='GL Acc', 
        AcctSeed__Type__c='Revenue',
        AcctSeed__Sub_Type_1__c = 'Operating Revenue',
        AcctSeed__Bank__c = false);
        GLToInsert.add(GLAccRev);

        AcctSeed__GL_Account__c GLAccExp = new AcctSeed__GL_Account__c(Name='GL Acc', 
        AcctSeed__Type__c='Expense',
        AcctSeed__Sub_Type_1__c = 'Operating Expenses',
        AcctSeed__Bank__c = false);
        GLToInsert.add(GLAccExp);
		insert GLToInsert;

        GLCode_System_Properties__c glDetail = new GLCode_System_Properties__c(Name = 'Equipment Billing',
                                                                                    Revenue_GL_AccountId__c = GLAccRev.Id,
                                                                                    Expense_GL_AccountId__c = GLAccExp.Id);
        insert glDetail; 

        GLCode_System_Properties__c glDetail2 = new GLCode_System_Properties__c(Name = 'Parts Billing',
                                                                                Revenue_GL_AccountId__c = GLAccRev.Id,
                                                                                Expense_GL_AccountId__c = GLAccExp.Id);
        insert glDetail2;    
       
        AcctSeed__Billing_Line__c objBillingLine = new AcctSeed__Billing_Line__c();
        objBillingLine.AcctSeed__Billing__c = billingSO2.id;
        objBillingLine.AcctSeed__Date__c = System.today();
        objBillingLine.AcctSeed__Rate__c = 25;
        objBillingLine.AcctSeed__Hours_Units__c = 10;
        objBillingLine.AcctSeedERP__Sales_Order_Line__c = orderLine1.Id;
        objBillingLine.AcctSeed__Tax_Amount2__c = 20;
        insert objBillingLine;

        
        Product2 AvalaraTax = new Product2();
        AvalaraTax.ProductCode = 'AVATAX';
        AvalaraTax.Name = 'Avalara Tax';
        AvalaraTax.AcctSeed__Expense_GL_Account__c = GLAcc.Id;
        AvalaraTax.AcctSeed__Revenue_GL_Account__c =glAccounts[8].Id;
        AvalaraTax.Description = 'test';
        AvalaraTax.Product_Description__c = 'test';
        insert AvalaraTax;

        //this test is for AvalaraTaxServiceCustom and PostUnPostTransactionCtrl 
		test.startTest();

            ApexPages.StandardController sc2 = new ApexPages.standardController(billingSO);
            PageReference pageRef1 = Page.PostUnPostBillingTransaction; 
            pageRef1.getParameters().put('isPost','true');
            Test.setCurrentPage(pageRef1);
            PostUnPostTransactionCtrl controller1 = new PostUnPostTransactionCtrl(sc2);
            controller1.validateBeforePost();
            controller1.post();
            controller1.unPost();
            controller1.cancel();

            ApexPages.StandardController sc1 = new ApexPages.standardController(billingSO2);
                    
            PageReference pageRef = Page.PostUnPostBillingTransaction; 
            pageRef.getParameters().put('isPost','true');
            Test.setCurrentPage(pageRef);

            Test.setMock(HttpCalloutMock.Class, new PostUnPostTransactionCtrlTest());
        
            PostUnPostTransactionCtrl controller = new PostUnPostTransactionCtrl(sc1);
            controller.validateBeforePost();
            controller.post();
            controller.unPost();
            controller.cancel();

            objParentLineItem.Descriptions__c = 'description update value';
        update objParentLineItem;

    
        test.stopTest();
        delete objBillingLine;
    }
}