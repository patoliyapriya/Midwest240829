@isTest
public with sharing class CreateSalesOrderControllerTest {
    
    @TestSetup
    static void makeData(){

        Account newAcc = new Account();
            newAcc.Name = 'Test Account';
            insert newAcc;

        Opportunity objOpportunity = new Opportunity();
            objOpportunity.closeDate = Date.today();
            objOpportunity.Name = 'Test Opportunity';
            objOpportunity.stageName = 'Draft';
            objOpportunity.Office__c = 'MaRRs';
            objOpportunity.AccountId = newAcc.Id;
            insert objOpportunity;

        Project__c proj = new Project__c();
            proj.Name = 'Test Project';
            proj.Project_Status__c = 'In Progress';
            proj.Opportunity__c = objOpportunity.Id;
            proj.Receipt_of_Order_Date__c = Date.today();
            insert proj;
            
        Quote newQuote = new Quote();
            newQuote.Name = 'Test Quote';
            newQuote.opportunityId = objOpportunity.Id;
            newQuote.Scope_Revision_Number__c = '01';
            newQuote.Submittal_Revision_Number__c = '01';
            newQuote.Attention_to_Account__c = newAcc.Id;
            insert newQuote;
            
        Product_Group__c objParentProductGroup1 = new Product_Group__c();
            objParentProductGroup1.Name = 'Parent Group 1';
            objParentProductGroup1.Quote__c = newQuote.Id;
            insert objParentProductGroup1;

        Product_Group__c objParentProductGroup2 = new Product_Group__c();
            objParentProductGroup2.Name = 'Parent Group 2';
            objParentProductGroup2.Quote__c = newQuote.Id;
            insert objParentProductGroup2;
            
        Product_Group__c objChildProductGroup1 = new Product_Group__c();
            objChildProductGroup1.Name = 'Child Group 1';
            objChildProductGroup1.Quote__c = newQuote.Id;
            objChildProductGroup1.Parent_Product_Group__c = objParentProductGroup1.Id;
            insert objChildProductGroup1;

        Product_Group__c objChildProductGroup2 = new Product_Group__c();
            objChildProductGroup2.Name = 'Child Group 2';
            objChildProductGroup2.Quote__c = newQuote.Id;
            objChildProductGroup2.Parent_Product_Group__c = objParentProductGroup2.Id;
            insert objChildProductGroup2;

        Product_Group__c objChildProductGroup3 = new Product_Group__c();
            objChildProductGroup3.Name = 'Child Group 3';
            objChildProductGroup3.Quote__c = newQuote.Id;
            objChildProductGroup3.Parent_Product_Group__c = objParentProductGroup2.Id;
            insert objChildProductGroup3;

        Product2 newProduct = new Product2(
            Name = 'Example Product',
            Description = 'This is an example product.',
            ProductCode = 'EX-123',
            IsActive = true
            );
            insert newProduct;
            
        Product_Select__c objParentLineItem = new Product_Select__c();
            objParentLineItem.Product_Name__c = 'Parent Product Name';
            objParentLineItem.Quote__c = newQuote.Id;
            objParentLineItem.Product_Group__c = objChildProductGroup1.Id;
            objParentLineItem.ProductId__c= newProduct.id;
            insert objParentLineItem;
            
        Product_Select__c objChildLineItem = new Product_Select__c();
            objChildLineItem.Product_Name__c = 'Child Product Name';
            objChildLineItem.Quote__c = newQuote.Id;
            objChildLineItem.Product_Group__c = objChildProductGroup2.Id;
            insert objChildLineItem;

        AcctSeed__Billing_Format__c[] PDFformats = new List<AcctSeed__Billing_Format__c>();
            PDFformats.add(
            new AcctSeed__Billing_Format__c(
            Name = 'Default Billing Product',
            AcctSeed__Visualforce_PDF_Page__c = 'BillingProductPDF',
            AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
            AcctSeed__Type__c = 'Billing',
            AcctSeed__Sort_Field__c = 'Name'
            )
            );
            
            PDFformats.add(
            new AcctSeed__Billing_Format__c(
            Name = 'Default Billing Service',
            AcctSeed__Visualforce_PDF_Page__c = 'BillingServicePDF',
            AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
            AcctSeed__Type__c = 'Billing',
            AcctSeed__Sort_Field__c = 'Name'
            )
            );
            
            PDFformats.add(
            new AcctSeed__Billing_Format__c (
            Name = 'Billing Outstanding Statement',
            AcctSeed__Visualforce_PDF_Page__c = 'BillingOutstandingStatementPDF',
            AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
            AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
            AcctSeed__Type__c = 'Outstanding Statement'
            )
            );
            
            PDFformats.add(
            new AcctSeed__Billing_Format__c (
            Name = 'Billing Activity Statement',
            AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF',
            AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
            AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
            AcctSeed__Type__c = 'Activity Statement'
            )
            );
            // #4
            PDFformats.add(
            new AcctSeed__Billing_Format__c(
            Name = 'Default Purchase Order',
            AcctSeed__Visualforce_PDF_Page__c = 'BillingServicePDF',
            AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
            AcctSeed__Type__c = 'Purchase Order',
            AcctSeed__Sort_Field__c = 'Name'
            )
            );
            
            PDFformats.add(
            new AcctSeed__Billing_Format__c(
            Name = 'Default Packing Slip',
            AcctSeed__Visualforce_PDF_Page__c = 'BillingServicePDF',
            AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
            AcctSeed__Type__c = 'Packing Slip',
            AcctSeed__Sort_Field__c = 'Name'
            )
            );
            
            insert PDFformats;
            
        AcctSeed__GL_Account__c[] glAccounts = new List<AcctSeed__GL_Account__c>();

            glAccounts.add(
            new AcctSeed__GL_Account__c(
            Name = '1000-Cash',
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Bank__c = true,
            AcctSeed__Sub_Type_1__c = 'Assets',
            AcctSeed__Sub_Type_2__c = 'Cash')
            );

            insert glAccounts;

        AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c(
                Name = 'Actual',
                AcctSeed__Type__c = 'Transactional',
                AcctSeed__Default_Bank_Account__c = glAccounts[0].Id,
                AcctSeed__Default_Billing_Format__c = PDFformats[0].Id,
                AcctSeed__Billing_Outstanding_Statement_Format__c = PDFformats[2].Id,
                AcctSeed__Billing_Activity_Statement_Format__c = PDFformats[3].Id,
                AcctSeed__Default_Purchase_Order_Format__c = PDFformats[4].Id,
                AcctSeed__Default_Packing_Slip_Format__c = PDFformats[5].Id);
    
            insert ledger;
            
        AcctSeedERP__Sales_Order__c salesOrder = new AcctSeedERP__Sales_Order__c( Quote__c=newQuote.Id, AcctSeedERP__Ledger__c=ledger.id);
            insert salesOrder;
            
        AcctSeedERP__Sales_Order_Line__c salesOrderLine = new AcctSeedERP__Sales_Order_Line__c(
                Quote_Line_Item__c=objParentLineItem.Id,
                AcctSeedERP__Quantity_Ordered__c=1,
                AcctSeedERP__Unit_Price__c=100,
                AcctSeedERP__Product__c=objParentLineItem.ProductId__c,
                AcctSeedERP__Sales_Order__c=salesOrder.Id
            );
            insert salesOrderLine;
            
            
            
        
    }
    
    static testMethod void testMethod1(){
        Quote testQuote = [SELECT id FROM Quote WHERE Quote.Name = 'Test Quote' limit 1];
        apexpages.currentpage().getparameters().put('id',testQuote.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        CreateSalesOrderController CreateSalesOrderController = new CreateSalesOrderController(sc);
        CreateSalesOrderController.createSalesOrder();

        PageReference backToQuotePageRef = CreateSalesOrderController.backToQuote();
        PageReference updateSalesOrderRef = CreateSalesOrderController.updateSalesOrder();
    }

    static testMethod void testMethod2(){
        Quote testQuote = [SELECT id FROM Quote WHERE Quote.Name = 'Test Quote' limit 1];
        AcctSeedERP__Sales_Order__c salesOrder = [SELECT Id FROM AcctSeedERP__Sales_Order__c WHERE Quote__c =: testQuote.Id];
        apexpages.currentpage().getparameters().put('id',testQuote.Id);
        PageReference pageRef = Page.EditSalesOrder;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.StandardController(salesOrder);
        EditSalesOrderCtrl controller = new EditSalesOrderCtrl(stdController);
        
      
        System.assertEquals(testQuote.Id, controller.quote.Id);
        System.assertEquals('edit', controller.mode);
        
       
        controller.prepareSalesOrder();
        
        PageReference backToQuotePageRef = controller.backToQuote();
        PageReference updateSalesOrderRef = controller.updateSalesOrder();
        System.assertEquals('/' + testQuote.Id, backToQuotePageRef.getUrl());
    }


}