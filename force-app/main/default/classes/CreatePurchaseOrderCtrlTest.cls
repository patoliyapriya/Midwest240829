@isTest
public with sharing class CreatePurchaseOrderCtrlTest {
    @TestSetup
    public static void createData() {
        AcctSeed__GL_Account__c GLAcc = new AcctSeed__GL_Account__c(Name='GL Acc', 
                                                                    AcctSeed__Type__c='Balance Sheet',
                                                                    AcctSeed__Sub_Type_1__c = 'Assets',
                                                                    AcctSeed__Bank__c = true);
        insert GLAcc;
        AcctSeed__Accounting_Variable__c GLAVar = new AcctSeed__Accounting_Variable__c(
            Name = 'MIB',
            AcctSeed__Type__c = 'GL Account Variable 1'
        );
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

        AcctSeed__Ledger__c ledg = new AcctSeed__Ledger__c(
                                    Name='Actual',
                                    AcctSeed__Type__c='Transactional',
                                    AcctSeed__Billing_Activity_Statement_Format__c = pdfFormateSO.Id,
                                    AcctSeed__Default_Bank_Account__c = GLAcc.Id,
                                    AcctSeed__Billing_Outstanding_Statement_Format__c = pdfFormateSO2.Id,
                                    AcctSeed__Default_Billing_Format__c = pdfFormateSO3.Id,
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
        
        // insert account
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

		// inser mars opportunity
		Id marsOppTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('MaRRS').getRecordTypeId();
		Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.closedate = System.today();
        opp.StageName = 'Non Qualified';
        opp.RecordTypeId = marsOppTypeId;
        opp.Office__c = 'MaRRs';
        opp.AccountId = acc.Id;
        insert opp;
        
        //create sales order
        AcctSeedERP__Sales_Order__c orderSO = new AcctSeedERP__Sales_Order__c();
        orderSO.AcctSeedERP__Customer__c = acc.Id;
        orderSO.AcctSeedERP__Status__c = 'Open';
        orderSO.AcctSeedERP__Ledger__c = ledg.ID;
        orderSO.AcctSeedERP__Opportunity__c = opp.Id;
        insert orderSO;

        // create sales order line item
        AcctSeedERP__Sales_Order_Line__c orderLine1 = new AcctSeedERP__Sales_Order_Line__c(
            AcctSeedERP__Comment__c = 'comment',
            AcctSeedERP__Sales_Order__c = orderSO.Id,
            AcctSeedERP__Product__c = productSO1.Id,
            AcctSeedERP__Unit_Price__c = 20,
            AcctSeedERP__Quantity_Ordered__c = 2,
            Sale_Type__c = 'Equipment/Projects'
        );
        insert orderLine1;

        AcctSeedERP__Sales_Order_Line__c orderLine2 = new AcctSeedERP__Sales_Order_Line__c(
            AcctSeedERP__Comment__c = 'comment',
            AcctSeedERP__Sales_Order__c = orderSO.Id,
            AcctSeedERP__Product__c = productSO1.Id,
            AcctSeedERP__Unit_Price__c = 20,
            AcctSeedERP__Quantity_Ordered__c = 2,
            Sale_Type__c = 'Equipment/Projects'
        );
        insert orderLine2;

    }

    
    static testMethod void testMethod1(){
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        	PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Accounting_Manager' AND NamespacePrefix  = null ];
			insert new PermissionSetAssignment(AssigneeId = userinfo.getuserid(), PermissionSetId = ps.Id);
        }
        
        Test.startTest();
        AcctSeedERP__Sales_Order__c orderSO = [SELECT Id FROM AcctSeedERP__Sales_Order__c limit 1];
        apexpages.currentpage().getparameters().put('id',orderSO.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(orderSO);
        CreatePurchaseOrderCtrl ctrl = new CreatePurchaseOrderCtrl(sc);

        ctrl.prepOrderAndPOItems(orderSO.Id);
        //ctrl.prepOrderAndPOItems(orderSO.Id);
        
        system.debug('orderLineWrapperList=>'+ctrl.orderLineWrapperList);
        Account acc = [SELECT Id From Account limit 1];
        ctrl.orderLineWrapperList[0].PurchaseOrder.AcctSeedERP__Vendor__c = acc.Id;

        AcctSeed__Billing_Format__c pdfFormate = [SELECT Id 
                                                    FROM AcctSeed__Billing_Format__c
                                                    WHERE AcctSeed__Type__c = 'Purchase Order'
                                                    limit 1];
        ctrl.orderLineWrapperList[0].PurchaseOrder.AcctSeedERP__Purchase_Order_Format__c = pdfFormate.Id;

        AcctSeed__Ledger__c ledg = [SELECT Id From AcctSeed__Ledger__c limit 1];
        ctrl.orderLineWrapperList[0].PurchaseOrder.AcctSeedERP__Ledger__c = ledg.Id;

        ctrl.orderLineWrapperList[0].POItem.AcctSeedERP__Unit_Price__c = 10;

        ctrl.prepareDraftPO();
        ctrl.createPurchaseOrderAndPOLines();
        ctrl.goToOrder();

        AcctSeedERP__Purchase_Order__c PO = [SELECT Id,AcctSeedERP__Vendor__c FROM AcctSeedERP__Purchase_Order__c limit 1];
        system.debug('PO==>'+PO);
        ApexPages.StandardController scForPO = new ApexPages.StandardController(PO); 
        AddPOLineItemsCtrl addPOLineCtrl = new AddPOLineItemsCtrl(scForPO);
        addPOLineCtrl.createPurchaseOrderAndPOLines();
        addPOLineCtrl.goToOrder();
        AcctSeedERP__Sales_Order__c orderSO2 = new AcctSeedERP__Sales_Order__c(
            AcctSeedERP__Customer__c =  acc.Id,
            AcctSeedERP__Status__c = 'Open',
            AcctSeedERP__Ledger__c = ledg.Id
        );
        insert orderSO2;

        ApexPages.StandardController sc2 = new ApexPages.StandardController(orderSO2);
        CreatePurchaseOrderCtrl ctrl2 = new CreatePurchaseOrderCtrl(sc2);

        ApexPages.StandardController pdfSetcon = new ApexPages.StandardController(orderSO);
        SalesOrderPdfCtrl ctrlSOPDF = new SalesOrderPdfCtrl(pdfSetcon);
        ctrlSOPDF.generateAttachment();
        
        AcctSeedERP__Purchase_Order__c POSObject = [SELECT Id,Sales_Order__c FROM AcctSeedERP__Purchase_Order__c limit 1];
        ApexPages.StandardController poPDF = new ApexPages.StandardController(POSObject);
        PurchaseOrderPDFCtrl POPDFCtrl = new PurchaseOrderPDFCtrl(poPDF);
        POSObject.Sales_Order__c = null;
        POSObject.Office__c = 'Midwest Machinery KC';
        update POSObject;

        PurchaseOrderPDFCtrl POPDFCtrl2 = new PurchaseOrderPDFCtrl(poPDF);

        AcctSeed__Accounting_Period__c acctPeriod = new AcctSeed__Accounting_Period__c(
            Name = '1991-10',
            AcctSeed__Start_Date__c = Date.newinstance(1991, 10, 1),
            AcctSeed__End_Date__c = Date.newinstance(1991, 10, 31),
            AcctSeed__Status__c = 'Open');
    insert acctPeriod;

    AcctSeed__GL_Account__c GLAcc2 = new AcctSeed__GL_Account__c(Name='GL Acc', 
        AcctSeed__Type__c='Balance Sheet',
        AcctSeed__Sub_Type_1__c = 'Assets',
        AcctSeed__Bank__c = false);
        insert GLAcc2;

        AcctSeed__GL_Account__c GLAcc3 = new AcctSeed__GL_Account__c(Name='GL Acc', 
        AcctSeed__Type__c='Balance Sheet',
        AcctSeed__Sub_Type_1__c = 'Assets',
        AcctSeed__Bank__c = false);
        insert GLAcc3;

        AcctSeed__GL_Account__c GLAcc4 = new AcctSeed__GL_Account__c(Name='GL Acc', 
        AcctSeed__Type__c='Balance Sheet',
        AcctSeed__Sub_Type_1__c = 'Assets',
        AcctSeed__Bank__c = false);
        insert GLAcc4;

        AcctSeed__GL_Account__c GLAcc5 = new AcctSeed__GL_Account__c(Name='GL Acc', 
        AcctSeed__Type__c='Balance Sheet',
        AcctSeed__Sub_Type_1__c = 'Assets',
        AcctSeed__Bank__c = false);
        insert GLAcc5;

        AcctSeed__GL_Account__c GLAcc6 = new AcctSeed__GL_Account__c(Name='GL Acc', 
        AcctSeed__Type__c='Balance Sheet',
        AcctSeed__Sub_Type_1__c = 'Assets',
        AcctSeed__Bank__c = false);
        insert GLAcc6;

        AcctSeed__GL_Account__c GLAcc7 = new AcctSeed__GL_Account__c(Name='GL Acc', 
        AcctSeed__Type__c='Balance Sheet',
        AcctSeed__Sub_Type_1__c = 'Assets',
        AcctSeed__Bank__c = false);
        insert GLAcc7;

        AcctSeed__Accounting_Settings__c setting = new AcctSeed__Accounting_Settings__c(
            Name='Account Setting',
            AcctSeed__AP_Control_GL_Account__c = GLAcc2.Id,
            AcctSeed__AR_Control_GL_Account__c =  GLAcc3.Id,
            AcctSeed__Current_Year_Earnings_GL_Account__c = GLAcc4.Id,
            AcctSeed__Default_Ledger__c = ledg.Id,
            AcctSeed__Retained_Earnings_GL_Account__c = GLAcc5.Id,
            AcctSeed__Revenue_GL_Account__c = GLAcc6.Id,
            AcctSeed__Unapplied_Cash_GL_Account__c = GLAcc7.Id);
        insert setting;

        AcctSeed__Account_Payable__c acPayable = new AcctSeed__Account_Payable__c(
            AcctSeed__Payee_Reference__c = '1',
            AcctSeed__Vendor__c = acc.Id,
            AcctSeed__Ledger__c = ledg.Id,
            AcctSeedERP__Purchase_Order__c = POSObject.Id,
            AcctSeed__Accounting_Period__c = acctPeriod.Id);
        insert acPayable;

        Id partsOppTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Parts').getRecordTypeId();
        Id eqOppTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Equipment').getRecordTypeId();
        Id GenralContractingOppTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('General Contracting').getRecordTypeId();

        Opportunity opp = [SELECT Id FROM Opportunity limit 1];

       // AcctSeedERP__Sales_Order__c orderSO = [SELECT ID FROM AcctSeedERP__Sales_Order__c limit 1];

        POSObject.Sales_Order__c = orderSO.Id;
        update POSObject;

        opp.RecordTypeId = partsOppTypeId;
        update opp;

        AcctSeed__Account_Payable_Line__c payableLine = new AcctSeed__Account_Payable_Line__c(
            AcctSeed__Account_Payable__c = acPayable.Id,
            AcctSeed__Expense_GL_Account__c = GLAcc6.Id,
            AcctSeed__Unit_Cost__c = 2
        );
        insert payableLine;

        opp.RecordTypeId = eqOppTypeId;
        update opp;
        AcctSeed__Account_Payable_Line__c payableLine2 = new AcctSeed__Account_Payable_Line__c(
            AcctSeed__Account_Payable__c = acPayable.Id,
            AcctSeed__Expense_GL_Account__c = GLAcc6.Id,
            AcctSeed__Unit_Cost__c = 2
        );
        insert payableLine2;

        
        opp.RecordTypeId = GenralContractingOppTypeId;
        update opp;

        product2 prod = [SELECT Id From Product2 WHERE Name = 'SA_Xyz Product'];
        AcctSeedERP__Purchase_Order_Line__c poLine = new AcctSeedERP__Purchase_Order_Line__c(
            AcctSeedERP__Purchase_Order__c = PO.Id,
            AcctSeedERP__Quantity__c = 1,
            AcctSeedERP__Unit_Price__c = 10,
            AcctSeedERP__Product__c = prod.Id

        );
        insert poLine;

        AcctSeed__Account_Payable_Line__c payableLine3 = new AcctSeed__Account_Payable_Line__c(
            AcctSeed__Account_Payable__c = acPayable.Id,
            AcctSeed__Expense_GL_Account__c = GLAcc6.Id,
            AcctSeed__Unit_Cost__c = 2
        );
        insert payableLine3;

        // to cover SalesOrderTrigger
        orderSO.AcctSeedERP__Status__c = 'Closed';
        update orderSO;
        Test.stopTest();
    }
}