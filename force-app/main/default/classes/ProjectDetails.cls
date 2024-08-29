/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 12-02-2023
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class ProjectDetails {
    public ProjectDetails() {

    }
    // For Commission Tool.
    private static Boolean callMethod = true;
    
    @AuraEnabled(cacheable=true)
    public static ProjectDetailsWrapper getData(Id projectId){
        try {
            ProjectDetailsWrapper objProjectDetailsWrapper = new ProjectDetailsWrapper();

            //get sharepoint url
            Project__c project = [SELECT Opportunity__c, Name, Opportunity__r.Active_Financial_Quote__c, Opportunity__r.Sync_Quote__c,
                                        Schedule_End_Date__c,Schedule_On__c
                                    FROM Project__c 
                                    WHERE Id = :projectId];
                                    
            objProjectDetailsWrapper.scheduleOn = project.Schedule_On__c;
            objProjectDetailsWrapper.scheduleEndDate = project.Schedule_End_Date__c;
            objProjectDetailsWrapper.sharePointUrl = sharePointPageUrl.fetchSharePointPageUrl(project.Opportunity__c);
            
            //get list of schedule to
            objProjectDetailsWrapper.lstScheduleTo = [Select Id, Name, Contact__c, Project__c, Schedule_Type__c, User__c
                                                        FROM Project_Schdule_To__c
                                                        WHERE Project__c = :projectId];
                                                         

            //get list of so and po
            objProjectDetailsWrapper.lstSOAndPODetails = [SELECT Id, Name, AcctSeedERP__Total__c, Sales_Order_Number__c,
                                                            (SELECT Id, Name, AcctSeedERP__Total__c, Purchase_Order_Number__c FROM Purchase_Orders__r)
                                                            FROM AcctSeedERP__Sales_Order__c 
                                                            WHERE Quote__c =: project.Opportunity__r.Active_Financial_Quote__c];
                                                            
            objProjectDetailsWrapper.syncQuoteId = project.Opportunity__r.Sync_Quote__c;
            objProjectDetailsWrapper.activeFinancialQuoteId = project.Opportunity__r.Active_Financial_Quote__c;

            //Invertroy cost
            Set<Id> SalesOrderIds = new Set<Id>();
            set<Id> ProductIds = new set<Id>();

            map<Id,List<Id>> mapOfSalesorderToProduct = new map<Id,List<Id>>();
            map<Id,List<AcctSeed__Inventory_Cost__c>> mapofProductToInventory = new map<Id,List<AcctSeed__Inventory_Cost__c>>();
            map<Id,List<AcctSeed__Inventory_Cost__c>> mapofSalesorderAndInventory = new map<Id,List<AcctSeed__Inventory_Cost__c>>();

            for(AcctSeedERP__Sales_Order__c lstSoAndPoId : objProjectDetailsWrapper.lstSOAndPODetails){  
                SalesOrderIds.add(lstSoAndPoId.Id);    
            }  
            
            for(AcctSeedERP__Sales_Order_Line__c salesOrderLine : [SELECT  Id, name, AcctSeedERP__Product__c, AcctSeedERP__Sales_Order__c
                                                                    FROM AcctSeedERP__Sales_Order_Line__c 
                                                                    WHERE AcctSeedERP__Sales_Order__c IN :SalesOrderIds]){
                                                                        
                ProductIds.add(salesOrderLine.AcctSeedERP__Product__c);
                if(mapOfSalesorderToProduct.containsKey(salesOrderLine.AcctSeedERP__Sales_Order__c)){
                    list<Id> productId = mapOfSalesorderToProduct.get(salesOrderLine.AcctSeedERP__Sales_Order__c);
                    productId.add(salesOrderLine.AcctSeedERP__Product__c);
                    mapOfSalesorderToProduct.put(salesOrderLine.AcctSeedERP__Sales_Order__c,productId);
                } else {
                    mapOfSalesorderToProduct.put(salesOrderLine.AcctSeedERP__Sales_Order__c, new List<Id> {salesOrderLine.AcctSeedERP__Product__c});
                }
            }
        
            for(AcctSeed__Inventory_Cost__c InventoryCost : [SELECT Id, Name, AcctSeed__Unit_Cost__c, AcctSeed__Product__c
                                                         FROM AcctSeed__Inventory_Cost__c
                                                         WHERE AcctSeed__Product__c IN :ProductIds]){
               
                if(mapofProductToInventory.containsKey(InventoryCost.AcctSeed__Product__c)){
                    List<AcctSeed__Inventory_Cost__c> inventoryRecords = mapofProductToInventory.get(InventoryCost.AcctSeed__Product__c);
                    inventoryRecords.add(InventoryCost);
                    mapofProductToInventory.put(InventoryCost.AcctSeed__Product__c,inventoryRecords);
                } else {
                    mapofProductToInventory.put(InventoryCost.AcctSeed__Product__c, new List<AcctSeed__Inventory_Cost__c> {InventoryCost});
                }
            }                           
            system.debug('Invcost--> mapofProductToInventory :-' + mapofProductToInventory.size());
           
            for (Id SalesorderId : mapOfSalesorderToProduct.KeySet()) {
                List<AcctSeed__Inventory_Cost__c> lstInventory = new List<AcctSeed__Inventory_Cost__c>();
                for (Id productId : mapOfSalesorderToProduct.get(SalesorderId)) {
                    if(mapofProductToInventory.get(productId) != null ){
                        lstInventory.addAll(mapofProductToInventory.get(productId));
                    }
                }
                // objProjectDetailsWrapper.mapofSalesorderAndInventory.put(SalesorderId, lstInventory);
                mapofSalesorderAndInventory.put(SalesorderId, lstInventory);
                system.debug('InvCost Record mapofSalesorderAndInventory :-' +mapofSalesorderAndInventory.size());
            }

            List<InventoryCostWrapper> lstInventoryCostFinal = new List<InventoryCostWrapper> ();
            for(Id InvCostId : mapofSalesorderAndInventory.KeySet()){
                InventoryCostWrapper objInvertoryCost = new InventoryCostWrapper();
                objInvertoryCost.salesOrderID = InvCostId;
                objInvertoryCost.inventoryCostList = mapofSalesorderAndInventory.get(InvCostId);
                lstInventoryCostFinal.add(objInvertoryCost);
            }
            objProjectDetailsWrapper.lstInventoryCostWithSO = lstInventoryCostFinal;


            //get project status and startup/warraty line items.
            objProjectDetailsWrapper.lstQuoteLineItems = new List<Product_Select__c>();

            Map<Id, Product_Group__c> mapSubGroup = CartQueryHelper.getSubGroupWithQuoteLineItems(objProjectDetailsWrapper.activeFinancialQuoteId);
            Map<Id, Product_Group__c> mapParentGroup = CartQueryHelper.getParentGroups(objProjectDetailsWrapper.activeFinancialQuoteId);
            

               
            Map<Id, GroupWrapper> mapParentGroupWrapper = new Map<Id, GroupWrapper>();

            
            
            for(Product_Group__c grp : mapParentGroup.values()) {
                for(Product_Group__c subGroup : grp.ProductGroups__r) {
                    for(Product_Select__c lineItem : mapSubGroup.get(subGroup.Id).Quote_Line_Items__r) {
                        objProjectDetailsWrapper.lstQuoteLineItems.add(lineItem);
                    }
                }
            }

            Map<Id, AcctSeed__Billing_Line__c> mapBillingDetails = new Map<Id, AcctSeed__Billing_Line__c>();

            for(AcctSeed__Billing_Line__c billingLineItem : [SELECT Id, AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__c, 
                                                                    AcctSeed__Total__c,
                                                                    AcctSeed__Billing__r.AcctSeed__Total__c, 
                                                                    AcctSeed__Billing__r.AcctSeed__Received_Amount__c, 
                                                                    AcctSeed__Billing__r.Name,
                                                                    AcctSeed__Billing__r.Invoice_Number__c,
                                                                    AcctSeed__Billing__c,
                                                                    Acctseed__Billing__r.AcctSeed__Billing_Cash_Receipt_Count__c
                                                            FROM AcctSeed__Billing_Line__c
                                                            WHERE AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__r.Quote__c =: project.Opportunity__r.Active_Financial_Quote__c]) {
                mapBillingDetails.put(billingLineItem.AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__c, billingLineItem); 
            }

            Map<Id, Date> mapBillingCashReceipt = new Map<Id, Date>();

            for(AcctSeed__Billing_Cash_Receipt__c cashReceipt : [SELECT Id, AcctSeed__Billing__c, AcctSeed__Cash_Receipt__r.AcctSeed__Receipt_Date__c
                                                                    FROM AcctSeed__Billing_Cash_Receipt__c
                                                                    WHERE AcctSeed__Billing__r.AcctSeedERP__Sales_Order__r.Quote__c =: project.Opportunity__r.Active_Financial_Quote__c]) {
                mapBillingCashReceipt.put(cashReceipt.AcctSeed__Billing__c, cashReceipt.AcctSeed__Cash_Receipt__r.AcctSeed__Receipt_Date__c);
            }

            

            objProjectDetailsWrapper.laborPosting = getCostPosting('Labor', projectId);

            objProjectDetailsWrapper.otherPosting = getCostPosting('Other', projectId);

            ProjectFinancialWrapper objProjectFinancial = getProjectFinancialDetails(projectId);
            objProjectDetailsWrapper.activeFinancialQuote = objProjectFinancial.activeFinancialQuote;

            objProjectDetailsWrapper.lstJournalEntry = getJournalEntryLine('Labor', projectId);
            objProjectDetailsWrapper.lstOtherJournalEntry = getJournalEntryLine('Other Cost', projectId);

            List<GroupWrapper> lstGroupWrapper = new List<GroupWrapper>();
            for(Product_Group__c grp : mapParentGroup.values()){
                GroupWrapper objGroupWrapper = new GroupWrapper();
                objGroupWrapper.groupId = grp.Id;
                objGroupWrapper.groupName = grp.Name;
                List<SubGroupWrapper> lstSubgrp = new List<SubGroupWrapper>();
                for(Product_Group__c sb : mapSubGroup.values()){ 
                    if(sb.Parent_Product_Group__r.Id == grp.Id){
                        SubGroupWrapper objSubGroupWrapper = new SubGroupWrapper();
                        objSubGroupWrapper.subGroupId = sb.Id;
                        objSubGroupWrapper.subGroupName = sb.Name;
                        List<AccountingLineItem> objLstAccountingLineItem = new List<AccountingLineItem>(); 
                        for(Product_Select__c lineItem : mapSubGroup.get(sb.Id).Quote_Line_Items__r){
                            AccountingLineItem objAccountingLineItem = new AccountingLineItem();
                            objAccountingLineItem.id = lineItem.Id;
                            objAccountingLineItem.quantity = lineItem.Quantity__c;
                            objAccountingLineItem.code = lineItem.Product_Code__c;
                            objAccountingLineItem.description = lineItem.Descriptions__c;
                            if(lineItem.SalesOrderId__c != null) {
                                objAccountingLineItem.soName = (lineItem.SalesOrderId__r.Sales_Order_Number__c != null && lineItem.SalesOrderId__r.Sales_Order_Number__c != '') 
                                                    ? lineItem.SalesOrderId__r.Sales_Order_Number__c 
                                                    : lineItem.SalesOrderId__r.Name;
                                objAccountingLineItem.soUrl = '/' + lineItem.SalesOrderId__c;
                            } 
                            objAccountingLineItem.releaseDate = lineItem.Release_Date__c;

                            if(mapBillingDetails.containsKey(lineItem.Id) && mapBillingDetails.get(lineItem.Id).AcctSeed__Billing__c != null) {
                                AcctSeed__Billing_Line__c billingLineItem = mapBillingDetails.get(lineItem.Id);
                                objAccountingLineItem.customerInvoiceName = (billingLineItem.AcctSeed__Billing__r.Invoice_Number__c != null && billingLineItem.AcctSeed__Billing__r.Invoice_Number__c != '') 
                                                                            ? billingLineItem.AcctSeed__Billing__r.Invoice_Number__c 
                                                                            : billingLineItem.AcctSeed__Billing__r.Name;
                                objAccountingLineItem.customerInvoiceUrl = '/' + mapBillingDetails.get(lineItem.Id).AcctSeed__Billing__c;
                                if(mapBillingCashReceipt.containsKey(mapBillingDetails.get(lineItem.Id).AcctSeed__Billing__c)) {
                                    objAccountingLineItem.paymentReceivedDate = mapBillingCashReceipt.get(mapBillingDetails.get(lineItem.Id).AcctSeed__Billing__c);
                                }
                                objAccountingLineItem.invoiceAmount = mapBillingDetails.get(lineItem.Id).AcctSeed__Total__c;
                                objSubGroupWrapper.totalInvoiceAmount += mapBillingDetails.get(lineItem.Id).AcctSeed__Total__c;
                                if(mapBillingDetails.get(lineItem.Id).AcctSeed__Billing__r.AcctSeed__Received_Amount__c != null && mapBillingDetails.get(lineItem.Id).Acctseed__Billing__r.AcctSeed__Billing_Cash_Receipt_Count__c > 0 ) {
                                    objAccountingLineItem.AmountPaid = mapBillingDetails.get(lineItem.Id).AcctSeed__Total__c;
                                    objSubGroupWrapper.totalAmountPaid += mapBillingDetails.get(lineItem.Id).AcctSeed__Total__c;
                                }
                                //objAccountingLineItem.AmountPaid = mapBillingDetails.get(lineItem.Id).AcctSeed__Billing__r.AcctSeed__Received_Amount__c;
                            }
                
                            if(lineItem.Sales_Order_Line__r.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Purchase_Order__c != null) {
                                objAccountingLineItem.vendorPOName = (lineItem.Sales_Order_Line__r.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Purchase_Order__r.Purchase_Order_Number__c != null 
                                                                        && lineItem.Sales_Order_Line__r.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Purchase_Order__r.Purchase_Order_Number__c != '')
                                                                        ? lineItem.Sales_Order_Line__r.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Purchase_Order__r.Purchase_Order_Number__c
                                                                        : lineItem.Sales_Order_Line__r.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Purchase_Order__r.Name;
                    
                                objAccountingLineItem.vendorPOUrl = '/' + lineItem.Sales_Order_Line__r.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Purchase_Order__c;
                            }
                            objAccountingLineItem.submittalStatus = lineItem.Submittals__c;
                            objAccountingLineItem.tag = lineItem.Tag__c;
                            objAccountingLineItem.hideFromEmail = lineItem.Hide_Line_On_Email_Startup__c;
                            objAccountingLineItem.estimateShipDate = lineItem.Estimated_Ship_Date__c;
                            objAccountingLineItem.actShipDate = lineItem.Act_Ship__c;
                            objAccountingLineItem.tracking = lineItem.Tracking_Number__c;
                            objAccountingLineItem.stringNote = lineItem.Note__c;
                            objAccountingLineItem.serialNumber = lineItem.Serial_Number__c;
                            objAccountingLineItem.iomComplete = lineItem.IOM_Completed__c;
                            objAccountingLineItem.startupSchedule = lineItem.Schedule_Startup_Date__c;
                            objAccountingLineItem.startupCompleted = lineItem.Completed_Startup_Date__c;
                            objAccountingLineItem.warranty = lineItem.Warranty_Term__c;
                            objAccountingLineItem.warrantyType = lineItem.Warranty_Type__c;
                            objAccountingLineItem.partsCovered = lineItem.Warranty_Parts_Covered__c;
                            objAccountingLineItem.warrantyStart = lineItem.Warranty_Start_Date__c;
                            objAccountingLineItem.warrantyEnd = lineItem.Warranty_End_Date__c;
                            objAccountingLineItem.productName = lineItem.Product_Name__c;
                            objLstAccountingLineItem.add(objAccountingLineItem);
                        }
                        objSubGroupWrapper.lstQuoteLineItems = objLstAccountingLineItem; 
                        lstSubgrp.add(objSubGroupWrapper);
                    }
                }
                objGroupWrapper.subGroupList = lstSubgrp;
                lstGroupWrapper.add(objGroupWrapper);
            }
        
            objProjectDetailsWrapper.lstGroupWrapper = lstGroupWrapper;
            for(GroupWrapper gw : lstGroupWrapper){
                for(SubGroupWrapper sgw : gw.subGroupList){
                    objProjectDetailsWrapper.totalAmountPaid += sgw.totalAmountPaid;
                }
            }
            return objProjectDetailsWrapper;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // Commission Tool Code
    @AuraEnabled(cacheable=true)
    public static ProjectFinancialWrapper getProjectFinancialDetails(Id projectId, Decimal grandTotalCost) {

        //get project details
        Project__c project = [SELECT Opportunity__c, Opportunity__r.Name, Opportunity__r.Opportunity_Number__c,
                                    Opportunity__r.Ledger__r.Name, Opportunity__r.Sync_Quote__r.Total_Direct_Sell_Price__c,
                                    Opportunity__r.Project_Manager__r.Name, Opportunity__r.Sync_Quote__r.Total_Buy_Resell_Price__c,
                                    Opportunity__r.Sync_Quote__r.Commissions_and_Rebates__c,
                                    Opportunity__r.Sync_Quote__r.Total_Buy_Resell_Margin__c,
                                    Opportunity__r.Active_Financial_Quote__r.Total_Direct_Sell_Price__c,
                                    Opportunity__r.Active_Financial_Quote__r.Total_Buy_Resell_Price__c,
                                    Opportunity__r.Active_Financial_Quote__r.Commissions_and_Rebates__c,
                                    Opportunity__r.Active_Financial_Quote__r.Total_Buy_Resell_Margin__c,
                                    Opportunity__r.Active_Financial_Quote__c, Show_Commission_Table__c
                                FROM Project__c 
                                WHERE Id = :projectId];

        ProjectFinancialWrapper objProjectFinancialWrapper = new ProjectFinancialWrapper();

        objProjectFinancialWrapper.showCommissionTable = project.Show_Commission_Table__c;
        objProjectFinancialWrapper.asSoldQuote.salesDirect = project.Opportunity__r.Sync_Quote__r.Total_Direct_Sell_Price__c;
        objProjectFinancialWrapper.asSoldQuote.salesBuyReSell = project.Opportunity__r.Sync_Quote__r.Total_Buy_Resell_Price__c;
        objProjectFinancialWrapper.asSoldQuote.marginCommissionRebate = project.Opportunity__r.Sync_Quote__r.Commissions_and_Rebates__c;
        objProjectFinancialWrapper.asSoldQuote.marginBuyResell = project.Opportunity__r.Sync_Quote__r.Total_Buy_Resell_Margin__c;

        objProjectFinancialWrapper.activeFinancialQuote.salesDirect = project.Opportunity__r.Active_Financial_Quote__r.Total_Direct_Sell_Price__c;
        objProjectFinancialWrapper.activeFinancialQuote.salesBuyReSell = project.Opportunity__r.Active_Financial_Quote__r.Total_Buy_Resell_Price__c;
        objProjectFinancialWrapper.activeFinancialQuote.marginCommissionRebate = project.Opportunity__r.Active_Financial_Quote__r.Commissions_and_Rebates__c;
        objProjectFinancialWrapper.activeFinancialQuote.marginBuyResell = project.Opportunity__r.Active_Financial_Quote__r.Total_Buy_Resell_Margin__c;

        if(objProjectFinancialWrapper.asSoldQuote.salesBuyReSell != null && objProjectFinancialWrapper.asSoldQuote.marginBuyResell != null) {
            objProjectFinancialWrapper.asSoldQuote.costBuyResell = objProjectFinancialWrapper.asSoldQuote.salesBuyReSell - objProjectFinancialWrapper.asSoldQuote.marginBuyResell;
        }

        if(objProjectFinancialWrapper.activeFinancialQuote.salesBuyReSell != null && objProjectFinancialWrapper.activeFinancialQuote.marginBuyResell != null) {
            objProjectFinancialWrapper.activeFinancialQuote.costBuyResell = objProjectFinancialWrapper.activeFinancialQuote.salesBuyReSell - objProjectFinancialWrapper.activeFinancialQuote.marginBuyResell;
        }
        
        if(objProjectFinancialWrapper.asSoldQuote.salesDirect != null && objProjectFinancialWrapper.asSoldQuote.salesBuyReSell != null) {
            objProjectFinancialWrapper.asSoldQuote.totalProjectSales = objProjectFinancialWrapper.asSoldQuote.salesDirect + objProjectFinancialWrapper.asSoldQuote.salesBuyReSell;
        }

        if(objProjectFinancialWrapper.activeFinancialQuote.salesDirect != null && objProjectFinancialWrapper.activeFinancialQuote.salesBuyReSell != null) {
            objProjectFinancialWrapper.activeFinancialQuote.totalProjectSales = objProjectFinancialWrapper.activeFinancialQuote.salesDirect + objProjectFinancialWrapper.activeFinancialQuote.salesBuyReSell;
        }
        
        if(objProjectFinancialWrapper.asSoldQuote.marginCommissionRebate != null && objProjectFinancialWrapper.asSoldQuote.marginBuyResell != null) {
            objProjectFinancialWrapper.asSoldQuote.totalProjectMargin = objProjectFinancialWrapper.asSoldQuote.marginCommissionRebate + objProjectFinancialWrapper.asSoldQuote.marginBuyResell;
        }
        
        if(objProjectFinancialWrapper.activeFinancialQuote.marginCommissionRebate != null && objProjectFinancialWrapper.activeFinancialQuote.marginBuyResell != null) {
            objProjectFinancialWrapper.activeFinancialQuote.totalProjectMargin = objProjectFinancialWrapper.activeFinancialQuote.marginCommissionRebate + objProjectFinancialWrapper.activeFinancialQuote.marginBuyResell;
        }
        
        if(objProjectFinancialWrapper.asSoldQuote.marginCommissionRebate != null 
            && objProjectFinancialWrapper.asSoldQuote.marginCommissionRebate != 0
            && objProjectFinancialWrapper.asSoldQuote.salesDirect != null 
            && objProjectFinancialWrapper.asSoldQuote.salesDirect != 0) {
            objProjectFinancialWrapper.asSoldQuote.marginCommissionRebatePercentage = ((objProjectFinancialWrapper.asSoldQuote.marginCommissionRebate/objProjectFinancialWrapper.asSoldQuote.salesDirect) * 100).setScale(2);
        }
        if(objProjectFinancialWrapper.asSoldQuote.marginBuyResell != null
            && objProjectFinancialWrapper.asSoldQuote.marginBuyResell != 0
            && objProjectFinancialWrapper.asSoldQuote.salesBuyReSell != null
            && objProjectFinancialWrapper.asSoldQuote.salesBuyReSell != 0) {
            objProjectFinancialWrapper.asSoldQuote.marginBuyResellPercentage = ((objProjectFinancialWrapper.asSoldQuote.marginBuyResell/objProjectFinancialWrapper.asSoldQuote.salesBuyReSell) * 100).setScale(2);
        }
        if(objProjectFinancialWrapper.asSoldQuote.totalProjectMargin != null
        && objProjectFinancialWrapper.asSoldQuote.totalProjectMargin != 0
        && objProjectFinancialWrapper.asSoldQuote.totalProjectSales != null
        && objProjectFinancialWrapper.asSoldQuote.totalProjectSales != 0) {
            objProjectFinancialWrapper.asSoldQuote.totalProjectMarginPercentage = ((objProjectFinancialWrapper.asSoldQuote.totalProjectMargin/objProjectFinancialWrapper.asSoldQuote.totalProjectSales) * 100).setScale(2);
        }
        //TODO
        if(objProjectFinancialWrapper.activeFinancialQuote.marginCommissionRebate != null && objProjectFinancialWrapper.activeFinancialQuote.marginCommissionRebate != 0 
                && objProjectFinancialWrapper.activeFinancialQuote.salesDirect != null && objProjectFinancialWrapper.activeFinancialQuote.salesDirect != 0) {
            objProjectFinancialWrapper.activeFinancialQuote.marginCommissionRebatePercentage = ((objProjectFinancialWrapper.activeFinancialQuote.marginCommissionRebate/objProjectFinancialWrapper.activeFinancialQuote.salesDirect) * 100).setScale(2);
        } else if(objProjectFinancialWrapper.activeFinancialQuote.marginCommissionRebate != 0 && objProjectFinancialWrapper.activeFinancialQuote.salesDirect == 0) {
            objProjectFinancialWrapper.activeFinancialQuote.marginCommissionRebatePercentage = 100.00;
        } else {
            //N/A
        }

        if(objProjectFinancialWrapper.activeFinancialQuote.marginBuyResell != null && objProjectFinancialWrapper.activeFinancialQuote.marginBuyResell != 0
            && objProjectFinancialWrapper.activeFinancialQuote.salesBuyReSell != null && objProjectFinancialWrapper.activeFinancialQuote.salesBuyReSell != 0) {
            objProjectFinancialWrapper.activeFinancialQuote.marginBuyResellPercentage = ((objProjectFinancialWrapper.activeFinancialQuote.marginBuyResell/objProjectFinancialWrapper.activeFinancialQuote.salesBuyReSell) * 100).setScale(2);
        }
        
        if(objProjectFinancialWrapper.activeFinancialQuote.totalProjectMargin != null && objProjectFinancialWrapper.activeFinancialQuote.totalProjectMargin != 0 
            && objProjectFinancialWrapper.activeFinancialQuote.totalProjectSales != null && objProjectFinancialWrapper.activeFinancialQuote.totalProjectSales != 0) {
            objProjectFinancialWrapper.activeFinancialQuote.totalProjectMarginPercentage = ((objProjectFinancialWrapper.activeFinancialQuote.totalProjectMargin/objProjectFinancialWrapper.activeFinancialQuote.totalProjectSales) * 100).setScale(2);
        }
        
        if(objProjectFinancialWrapper.activeFinancialQuote.marginCommissionRebate != null && objProjectFinancialWrapper.activeFinancialQuote.marginCommissionRebate != 0){
            objProjectFinancialWrapper.finalSalesDirect = objProjectFinancialWrapper.asSoldQuote.salesDirect;
        } else {
            objProjectFinancialWrapper.finalSalesDirect = 0 ;
        }

        objProjectFinancialWrapper.finalInvoicedCommisionAndRebate = getTotalCommisionAndRebateOfBilling(project.Opportunity__r.Active_Financial_Quote__c);
        objProjectFinancialWrapper.finalInvoicedBuyResell = getTotalBuyResellOfBilling(project.Opportunity__r.Active_Financial_Quote__c);
        if(objProjectFinancialWrapper.finalInvoicedCommisionAndRebate != null && objProjectFinancialWrapper.finalInvoicedBuyResell != null) {
            objProjectFinancialWrapper.finalInvoiced = objProjectFinancialWrapper.finalInvoicedCommisionAndRebate + objProjectFinancialWrapper.finalInvoicedBuyResell;
        }
        
        if(objProjectFinancialWrapper.activeFinancialQuote.marginCommissionRebate != null && objProjectFinancialWrapper.finalInvoicedCommisionAndRebate != null) {
            objProjectFinancialWrapper.finalRevenueCommissionRebate = objProjectFinancialWrapper.activeFinancialQuote.marginCommissionRebate - objProjectFinancialWrapper.finalInvoicedCommisionAndRebate;
        }
        
        if(objProjectFinancialWrapper.activeFinancialQuote.salesBuyReSell != null && objProjectFinancialWrapper.finalInvoicedBuyResell != null) {
            objProjectFinancialWrapper.finalRevenueBuyResell = objProjectFinancialWrapper.activeFinancialQuote.salesBuyReSell - objProjectFinancialWrapper.finalInvoicedBuyResell;
        }
        if(objProjectFinancialWrapper.finalRevenueCommissionRebate != null && objProjectFinancialWrapper.finalRevenueBuyResell != null) {
            objProjectFinancialWrapper.finalRevenueSales = objProjectFinancialWrapper.finalRevenueCommissionRebate + objProjectFinancialWrapper.finalRevenueBuyResell;
        }
        objProjectFinancialWrapper.finalMarginCommissionRebate =  objProjectFinancialWrapper.finalRevenueCommissionRebate;

       
        if(objProjectFinancialWrapper.finalRevenueBuyResell == null){
            objProjectFinancialWrapper.finalRevenueBuyResell  = 0;
        }
        if(objProjectFinancialWrapper.activeFinancialQuote.marginBuyResell == 0 ||
            objProjectFinancialWrapper.activeFinancialQuote.salesBuyReSell  == 0 ||
            objProjectFinancialWrapper.finalRevenueBuyResell == 0)
        {
            objProjectFinancialWrapper.finalMarginBuyResell = 0;
        }else{
            objProjectFinancialWrapper.finalMarginBuyResell = ((objProjectFinancialWrapper.activeFinancialQuote.marginBuyResell/objProjectFinancialWrapper.activeFinancialQuote.salesBuyReSell) * objProjectFinancialWrapper.finalRevenueBuyResell).setScale(2);

        }
        
        //TOTAL BACKLOG-MARGIN
        if(objProjectFinancialWrapper.finalMarginCommissionRebate != null && objProjectFinancialWrapper.finalMarginBuyResell != null) {
            objProjectFinancialWrapper.finalMargin = objProjectFinancialWrapper.finalMarginCommissionRebate + objProjectFinancialWrapper.finalMarginBuyResell;
        }

        //Eng split on Project Financial tab
        List<SalesEngSplitWrapper> salesEngSplitFinal = new List<SalesEngSplitWrapper> ();

        List<Sales_Representative__c> SalesSplitlist = [SELECT Sales_Rep__r.Name,Commision__c
                                                        FROM Sales_Representative__c 
                                                        WHERE Opportunity__r.Active_Financial_Quote__c != null
                                                        AND Sales_Rep__c != null
                                                        AND Opportunity__c =: project.Opportunity__c];
        for(Sales_Representative__c split : SalesSplitlist){

            SalesEngSplitWrapper salesEngSplit = new SalesEngSplitWrapper();
            salesEngSplit.SplitName = split.Sales_Rep__r.Name;
            salesEngSplit.splitCommision = split.Commision__c;
            salesEngSplitFinal.add(salesEngSplit);
        }
        objProjectFinancialWrapper.salesEngSplitList = salesEngSplitFinal;
        objProjectFinancialWrapper.opportunityName = project.Opportunity__r.Name;
        objProjectFinancialWrapper.opportunityNumber = project.Opportunity__r.Opportunity_Number__c;
        objProjectFinancialWrapper.ledger = project.Opportunity__r.Ledger__r.Name;
        objProjectFinancialWrapper.projectManager = project.Opportunity__r.Project_Manager__r.Name;
        
        if (objProjectFinancialWrapper.finalInvoicedCommisionAndRebate != 0 && objProjectFinancialWrapper.finalMarginCommissionRebate != 0) {
            objProjectFinancialWrapper.commissionInvoiced = ((objProjectFinancialWrapper.finalInvoicedCommisionAndRebate / objProjectFinancialWrapper.finalMarginCommissionRebate)*100).setScale(2);
        } else {
            objProjectFinancialWrapper.commissionInvoiced = 0;
        }

        if(objProjectFinancialWrapper.finalInvoicedBuyResell != 0 && objProjectFinancialWrapper.activeFinancialQuote.salesBuyReSell != 0){
            objProjectFinancialWrapper.brInvoiced = ((objProjectFinancialWrapper.finalInvoicedBuyResell / objProjectFinancialWrapper.activeFinancialQuote.salesBuyReSell)*100).setScale(2);
        } else {
            objProjectFinancialWrapper.brInvoiced = 0;
        }

        if(callMethod){
            callMethod = false;
            ProjectCommissionWrapper objProjectCommissionData = getProjectCommissionDetails(projectId, grandTotalCost);
            objProjectFinancialWrapper.finalInvoicedPercentage = ((objProjectFinancialWrapper.finalInvoiced / objProjectCommissionData.companyBookingAmount)*100).setScale(2);
            objProjectFinancialWrapper.costToBeExpensed = (objProjectCommissionData.totalCogs * objProjectFinancialWrapper.brInvoiced)/100;
            objProjectFinancialWrapper.amountUnderBilled = (((grandTotalCost - objProjectFinancialWrapper.costToBeExpensed)/ objProjectCommissionData.totalCogs)*objProjectFinancialWrapper.activeFinancialQuote.salesBuyReSell);
            if(objProjectFinancialWrapper.amountUnderBilled > 0){
                objProjectFinancialWrapper.moveExpensesToWip = ((objProjectFinancialWrapper.amountUnderBilled / objProjectFinancialWrapper.activeFinancialQuote.salesBuyReSell)*objProjectCommissionData.totalCogs);
            } else{
                objProjectFinancialWrapper.moveExpensesToWip = 0;
            }
        }
        
        return objProjectFinancialWrapper;
    }
    
    @AuraEnabled(cacheable=true)
    public static ProjectFinancialWrapper getProjectFinancialDetails(Id projectId) {

        //get project details
        Project__c project = [SELECT Opportunity__c, Opportunity__r.Name, Opportunity__r.Opportunity_Number__c,
                                    Opportunity__r.Ledger__r.Name, Opportunity__r.Sync_Quote__r.Total_Direct_Sell_Price__c,
                                    Opportunity__r.Project_Manager__r.Name, Opportunity__r.Sync_Quote__r.Total_Buy_Resell_Price__c,
                                    Opportunity__r.Sync_Quote__r.Commissions_and_Rebates__c,
                                    Opportunity__r.Sync_Quote__r.Total_Buy_Resell_Margin__c,
                                    Opportunity__r.Active_Financial_Quote__r.Total_Direct_Sell_Price__c,
                                    Opportunity__r.Active_Financial_Quote__r.Total_Buy_Resell_Price__c,
                                    Opportunity__r.Active_Financial_Quote__r.Commissions_and_Rebates__c,
                                    Opportunity__r.Active_Financial_Quote__r.Total_Buy_Resell_Margin__c,
                                    Opportunity__r.Active_Financial_Quote__c
                                FROM Project__c 
                                WHERE Id = :projectId];

        ProjectFinancialWrapper objProjectFinancialWrapper = new ProjectFinancialWrapper();
        
        objProjectFinancialWrapper.asSoldQuote.salesDirect = project.Opportunity__r.Sync_Quote__r.Total_Direct_Sell_Price__c;
        objProjectFinancialWrapper.asSoldQuote.salesBuyReSell = project.Opportunity__r.Sync_Quote__r.Total_Buy_Resell_Price__c;
        objProjectFinancialWrapper.asSoldQuote.marginCommissionRebate = project.Opportunity__r.Sync_Quote__r.Commissions_and_Rebates__c;
        objProjectFinancialWrapper.asSoldQuote.marginBuyResell = project.Opportunity__r.Sync_Quote__r.Total_Buy_Resell_Margin__c;

        objProjectFinancialWrapper.activeFinancialQuote.salesDirect = project.Opportunity__r.Active_Financial_Quote__r.Total_Direct_Sell_Price__c;
        objProjectFinancialWrapper.activeFinancialQuote.salesBuyReSell = project.Opportunity__r.Active_Financial_Quote__r.Total_Buy_Resell_Price__c;
        objProjectFinancialWrapper.activeFinancialQuote.marginCommissionRebate = project.Opportunity__r.Active_Financial_Quote__r.Commissions_and_Rebates__c;
        objProjectFinancialWrapper.activeFinancialQuote.marginBuyResell = project.Opportunity__r.Active_Financial_Quote__r.Total_Buy_Resell_Margin__c;

        if(objProjectFinancialWrapper.asSoldQuote.salesBuyReSell != null && objProjectFinancialWrapper.asSoldQuote.marginBuyResell != null) {
            objProjectFinancialWrapper.asSoldQuote.costBuyResell = objProjectFinancialWrapper.asSoldQuote.salesBuyReSell - objProjectFinancialWrapper.asSoldQuote.marginBuyResell;
        }

        if(objProjectFinancialWrapper.activeFinancialQuote.salesBuyReSell != null && objProjectFinancialWrapper.activeFinancialQuote.marginBuyResell != null) {
            objProjectFinancialWrapper.activeFinancialQuote.costBuyResell = objProjectFinancialWrapper.activeFinancialQuote.salesBuyReSell - objProjectFinancialWrapper.activeFinancialQuote.marginBuyResell;
        }
        
        if(objProjectFinancialWrapper.asSoldQuote.salesDirect != null && objProjectFinancialWrapper.asSoldQuote.salesBuyReSell != null) {
            objProjectFinancialWrapper.asSoldQuote.totalProjectSales = objProjectFinancialWrapper.asSoldQuote.salesDirect + objProjectFinancialWrapper.asSoldQuote.salesBuyReSell;
        }

        if(objProjectFinancialWrapper.activeFinancialQuote.salesDirect != null && objProjectFinancialWrapper.activeFinancialQuote.salesBuyReSell != null) {
            objProjectFinancialWrapper.activeFinancialQuote.totalProjectSales = objProjectFinancialWrapper.activeFinancialQuote.salesDirect + objProjectFinancialWrapper.activeFinancialQuote.salesBuyReSell;
        }
        
        if(objProjectFinancialWrapper.asSoldQuote.marginCommissionRebate != null && objProjectFinancialWrapper.asSoldQuote.marginBuyResell != null) {
            objProjectFinancialWrapper.asSoldQuote.totalProjectMargin = objProjectFinancialWrapper.asSoldQuote.marginCommissionRebate + objProjectFinancialWrapper.asSoldQuote.marginBuyResell;
        }
        
        if(objProjectFinancialWrapper.activeFinancialQuote.marginCommissionRebate != null && objProjectFinancialWrapper.activeFinancialQuote.marginBuyResell != null) {
            objProjectFinancialWrapper.activeFinancialQuote.totalProjectMargin = objProjectFinancialWrapper.activeFinancialQuote.marginCommissionRebate + objProjectFinancialWrapper.activeFinancialQuote.marginBuyResell;
        }
        
        if(objProjectFinancialWrapper.asSoldQuote.marginCommissionRebate != null 
            && objProjectFinancialWrapper.asSoldQuote.marginCommissionRebate != 0
            && objProjectFinancialWrapper.asSoldQuote.salesDirect != null 
            && objProjectFinancialWrapper.asSoldQuote.salesDirect != 0) {
            objProjectFinancialWrapper.asSoldQuote.marginCommissionRebatePercentage = ((objProjectFinancialWrapper.asSoldQuote.marginCommissionRebate/objProjectFinancialWrapper.asSoldQuote.salesDirect) * 100).setScale(2);
        }
        if(objProjectFinancialWrapper.asSoldQuote.marginBuyResell != null
            && objProjectFinancialWrapper.asSoldQuote.marginBuyResell != 0
            && objProjectFinancialWrapper.asSoldQuote.salesBuyReSell != null
            && objProjectFinancialWrapper.asSoldQuote.salesBuyReSell != 0) {
            objProjectFinancialWrapper.asSoldQuote.marginBuyResellPercentage = ((objProjectFinancialWrapper.asSoldQuote.marginBuyResell/objProjectFinancialWrapper.asSoldQuote.salesBuyReSell) * 100).setScale(2);
        }
        if(objProjectFinancialWrapper.asSoldQuote.totalProjectMargin != null
        && objProjectFinancialWrapper.asSoldQuote.totalProjectMargin != 0
        && objProjectFinancialWrapper.asSoldQuote.totalProjectSales != null
        && objProjectFinancialWrapper.asSoldQuote.totalProjectSales != 0) {
            objProjectFinancialWrapper.asSoldQuote.totalProjectMarginPercentage = ((objProjectFinancialWrapper.asSoldQuote.totalProjectMargin/objProjectFinancialWrapper.asSoldQuote.totalProjectSales) * 100).setScale(2);
        }
        //TODO
        if(objProjectFinancialWrapper.activeFinancialQuote.marginCommissionRebate != null && objProjectFinancialWrapper.activeFinancialQuote.marginCommissionRebate != 0 
                && objProjectFinancialWrapper.activeFinancialQuote.salesDirect != null && objProjectFinancialWrapper.activeFinancialQuote.salesDirect != 0) {
            objProjectFinancialWrapper.activeFinancialQuote.marginCommissionRebatePercentage = ((objProjectFinancialWrapper.activeFinancialQuote.marginCommissionRebate/objProjectFinancialWrapper.activeFinancialQuote.salesDirect) * 100).setScale(2);
        } else if(objProjectFinancialWrapper.activeFinancialQuote.marginCommissionRebate != 0 && objProjectFinancialWrapper.activeFinancialQuote.salesDirect == 0) {
            objProjectFinancialWrapper.activeFinancialQuote.marginCommissionRebatePercentage = 100.00;
        } else {
            //N/A
        }

        if(objProjectFinancialWrapper.activeFinancialQuote.marginBuyResell != null && objProjectFinancialWrapper.activeFinancialQuote.marginBuyResell != 0
            && objProjectFinancialWrapper.activeFinancialQuote.salesBuyReSell != null && objProjectFinancialWrapper.activeFinancialQuote.salesBuyReSell != 0) {
            objProjectFinancialWrapper.activeFinancialQuote.marginBuyResellPercentage = ((objProjectFinancialWrapper.activeFinancialQuote.marginBuyResell/objProjectFinancialWrapper.activeFinancialQuote.salesBuyReSell) * 100).setScale(2);
        }
        
        if(objProjectFinancialWrapper.activeFinancialQuote.totalProjectMargin != null && objProjectFinancialWrapper.activeFinancialQuote.totalProjectMargin != 0 
            && objProjectFinancialWrapper.activeFinancialQuote.totalProjectSales != null && objProjectFinancialWrapper.activeFinancialQuote.totalProjectSales != 0) {
            objProjectFinancialWrapper.activeFinancialQuote.totalProjectMarginPercentage = ((objProjectFinancialWrapper.activeFinancialQuote.totalProjectMargin/objProjectFinancialWrapper.activeFinancialQuote.totalProjectSales) * 100).setScale(2);
        }
        
        if(objProjectFinancialWrapper.activeFinancialQuote.marginCommissionRebate != null && objProjectFinancialWrapper.activeFinancialQuote.marginCommissionRebate != 0){
            objProjectFinancialWrapper.finalSalesDirect = objProjectFinancialWrapper.asSoldQuote.salesDirect;
        } else {
            objProjectFinancialWrapper.finalSalesDirect = 0 ;
        }

        objProjectFinancialWrapper.finalInvoicedCommisionAndRebate = getTotalCommisionAndRebateOfBilling(project.Opportunity__r.Active_Financial_Quote__c);
        objProjectFinancialWrapper.finalInvoicedBuyResell = getTotalBuyResellOfBilling(project.Opportunity__r.Active_Financial_Quote__c);
        if(objProjectFinancialWrapper.finalInvoicedCommisionAndRebate != null && objProjectFinancialWrapper.finalInvoicedBuyResell != null) {
            objProjectFinancialWrapper.finalInvoiced = objProjectFinancialWrapper.finalInvoicedCommisionAndRebate + objProjectFinancialWrapper.finalInvoicedBuyResell;
        }
        
        if(objProjectFinancialWrapper.activeFinancialQuote.marginCommissionRebate != null && objProjectFinancialWrapper.finalInvoicedCommisionAndRebate != null) {
            objProjectFinancialWrapper.finalRevenueCommissionRebate = objProjectFinancialWrapper.activeFinancialQuote.marginCommissionRebate - objProjectFinancialWrapper.finalInvoicedCommisionAndRebate;
        }
        
        if(objProjectFinancialWrapper.activeFinancialQuote.salesBuyReSell != null && objProjectFinancialWrapper.finalInvoicedBuyResell != null) {
            objProjectFinancialWrapper.finalRevenueBuyResell = objProjectFinancialWrapper.activeFinancialQuote.salesBuyReSell - objProjectFinancialWrapper.finalInvoicedBuyResell;
        }
        if(objProjectFinancialWrapper.finalRevenueCommissionRebate != null && objProjectFinancialWrapper.finalRevenueBuyResell != null) {
            objProjectFinancialWrapper.finalRevenueSales = objProjectFinancialWrapper.finalRevenueCommissionRebate + objProjectFinancialWrapper.finalRevenueBuyResell;
        }
        objProjectFinancialWrapper.finalMarginCommissionRebate =  objProjectFinancialWrapper.finalRevenueCommissionRebate;

        
        //final-MARGIN-BUY/RESELL
        if(objProjectFinancialWrapper.finalRevenueBuyResell == null){
            objProjectFinancialWrapper.finalRevenueBuyResell  = 0;
        }
        if(objProjectFinancialWrapper.activeFinancialQuote.marginBuyResell == 0 ||
            objProjectFinancialWrapper.activeFinancialQuote.salesBuyReSell  == 0 ||
            objProjectFinancialWrapper.finalRevenueBuyResell == 0)
        {
            objProjectFinancialWrapper.finalMarginBuyResell = 0;
        }else{
            objProjectFinancialWrapper.finalMarginBuyResell = ((objProjectFinancialWrapper.activeFinancialQuote.marginBuyResell/objProjectFinancialWrapper.activeFinancialQuote.salesBuyReSell) * objProjectFinancialWrapper.finalRevenueBuyResell).setScale(2);
        }
        
        //TOTAL BACKLOG-MARGIN
        if(objProjectFinancialWrapper.finalMarginCommissionRebate != null && objProjectFinancialWrapper.finalMarginBuyResell != null) {
            
            objProjectFinancialWrapper.finalMargin = objProjectFinancialWrapper.finalMarginCommissionRebate + objProjectFinancialWrapper.finalMarginBuyResell;
        }

        //Eng split on Project Financial tab
        List<SalesEngSplitWrapper> salesEngSplitFinal = new List<SalesEngSplitWrapper> ();

        List<Sales_Representative__c> SalesSplitlist = [SELECT Sales_Rep__r.Name,Commision__c
                                                        FROM Sales_Representative__c 
                                                        WHERE Opportunity__r.Active_Financial_Quote__c != null
                                                        AND Sales_Rep__c != null
                                                        AND Opportunity__c =: project.Opportunity__c];
        for(Sales_Representative__c split : SalesSplitlist){

            SalesEngSplitWrapper salesEngSplit = new SalesEngSplitWrapper();
            salesEngSplit.SplitName = split.Sales_Rep__r.Name;
            salesEngSplit.splitCommision = split.Commision__c;
            salesEngSplitFinal.add(salesEngSplit);
        }
        objProjectFinancialWrapper.salesEngSplitList = salesEngSplitFinal;
        return objProjectFinancialWrapper;
    }

    //Commission Tools Code
    @AuraEnabled(cacheable=true)
    public static ProjectCommissionWrapper getProjectCommissionDetails(Id projectId , Decimal grandTotalCost) {
        Project__c project = [SELECT Project_Stage__c,	Opportunity__c,  Opportunity__r.Name, Opportunity__r.Opportunity_Number__c,
                                    Opportunity__r.Ledger__r.Name, Show_Commission_Table__c
                                FROM Project__c 
                                WHERE Id = :projectId];

        ProjectCommissionWrapper objProjectCommissionWrapper = new ProjectCommissionWrapper();
        objProjectCommissionWrapper.showCommissionTable = project.Show_Commission_Table__c;
        objProjectCommissionWrapper.opportunityName = project.Opportunity__r.Name;
        objProjectCommissionWrapper.opportunityNumber = project.Opportunity__r.Opportunity_Number__c;
        objProjectCommissionWrapper.ledger = project.Opportunity__r.Ledger__r.Name;

        ProjectFinancialWrapper objProjectFinancial = getProjectFinancialDetails(projectId,grandTotalCost);
        objProjectCommissionWrapper.totalBooking = objProjectFinancial.activeFinancialQuote.totalProjectSales;
        objProjectCommissionWrapper.companyBookingAmount = (objProjectFinancial.activeFinancialQuote.salesBuyReSell + objProjectFinancial.activeFinancialQuote.marginCommissionRebate);
        objProjectCommissionWrapper.salesEngSplitList = objProjectFinancial.salesEngSplitList;
        if (objProjectFinancial.activeFinancialQuote.costBuyResell >= grandTotalCost ) {
            objProjectCommissionWrapper.totalCogs = objProjectFinancial.activeFinancialQuote.costBuyResell;            
        } else{
            objProjectCommissionWrapper.totalCogs = grandTotalCost;
        }
        objProjectCommissionWrapper.invoicedAmount = objProjectFinancial.finalInvoiced;
        objProjectCommissionWrapper.totalMargin = (objProjectCommissionWrapper.companyBookingAmount - objProjectCommissionWrapper.totalCogs);
        if (objProjectCommissionWrapper.companyBookingAmount != 0) {
            objProjectCommissionWrapper.invoicePercentage = ((objProjectCommissionWrapper.invoicedAmount / objProjectCommissionWrapper.companyBookingAmount)*100).setScale(2);
        } else {
            objProjectCommissionWrapper.invoicePercentage = 0;
        }
        
        ProjectDetailsWrapper objProjectDetail = getData(projectId);
        objProjectCommissionWrapper.amountPaid = objProjectDetail.totalAmountPaid;
        
        If(objProjectCommissionWrapper.invoicedAmount != 0){
            objProjectCommissionWrapper.amountInvoicedPaidOn = ((objProjectCommissionWrapper.amountPaid / objProjectCommissionWrapper.invoicedAmount)*100).setScale(2);
        } else{
            objProjectCommissionWrapper.amountInvoicedPaidOn = 0;
        }

        if (objProjectCommissionWrapper.companyBookingAmount != 0) {
            objProjectCommissionWrapper.companyBookingsPaidOn = ((objProjectCommissionWrapper.amountPaid / objProjectCommissionWrapper.companyBookingAmount)*100).setScale(2);
        } else{
            objProjectCommissionWrapper.companyBookingsPaidOn = 0;
        }
        
        

        if(project.Project_Stage__c == 'Archived'){
            objProjectCommissionWrapper.archived = 'Yes';
        } else{
            objProjectCommissionWrapper.archived = 'No';
        }
        
        return objProjectCommissionWrapper;
    }


    private static Decimal getTotalCommisionAndRebateOfBilling(Id quoteId) {
        List<AggregateResult> lstCommissionAndRebate = [SELECT SUM(AcctSeed__Total__c) total
                                                        FROM AcctSeed__Billing_Line__c
                                                        WHERE AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__r.Sale_Type__c = 'C/R'
                                                        AND AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__r.Quote__c =: quoteId];

        if(!lstCommissionAndRebate.isEmpty() && lstCommissionAndRebate[0].get('total') != null) {
            Decimal totalCommisionAndRebate = (Decimal) lstCommissionAndRebate[0].get('total');
            return totalCommisionAndRebate;
        }

        return 0;
    }

    private static Decimal getTotalBuyResellOfBilling(Id quoteId) {
        List<AggregateResult> lstBuyAndResell = [SELECT SUM(AcctSeed__Total__c) total
                                                        FROM AcctSeed__Billing_Line__c
                                                        WHERE AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__r.Sale_Type__c = 'B/R'
                                                        AND AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__r.Quote__c =: quoteId];

        if(!lstBuyAndResell.isEmpty() && lstBuyAndResell[0].get('total') != null) {
            Decimal totalBuyAndResell = (Decimal) lstBuyAndResell[0].get('total');
            return totalBuyAndResell;
        }

        return 0;
    }

    @AuraEnabled
    public static CostPosting deleteCostPosting(String type, String costId, String projectId){
        
        delete [SELECT Id From Cost_Posting__c WHERE Id =: costId];

        return getCostPosting(type, projectId);
    }

    @AuraEnabled
    public static CostPosting getCostPosting(String type, ID projectId) {
        
        CostPosting objCostPosting = new CostPosting();

        objCostPosting.lstCostPosting = [SELECT ID, 
                                            Type__c,
                                            Quantity__c, 
                                            Unit_Cost__c, 
                                            Total_Cost__c,
                                            Description__c
                                        FROM Cost_Posting__c
                                        WHERE Type__c =: type
                                        AND Project__c =: projectId];
        
        objCostPosting.totalCost = 0;
        for (Cost_Posting__c cost : objCostPosting.lstCostPosting) {
            objCostPosting.totalCost += cost.Total_Cost__c;
        }

        return objCostPosting;
    }

    @AuraEnabled
    public static List<JournalEntryLineWrapper> getJournalEntryLine(String type, Id projectId) {
        List<JournalEntryLineWrapper> lstJournalWrapper = new List<JournalEntryLineWrapper>();

        List<AcctSeed__Journal_Entry_Line__c> lstJournalEntryRecord = [SELECT id, Projects_MMCO_Custom_Tool__c, AcctSeed__Debit__c,
                                                                              AcctSeed__Credit__c, AcctSeed__Units__c, 
                                                                              AcctSeed__Reference__c,Project_Posting_Type__c
                                                                       FROM AcctSeed__Journal_Entry_Line__c  
                                                                       WHERE Projects_MMCO_Custom_Tool__c != null 
                                                                       AND Project_Posting_Type__c =: type 
                                                                       AND Projects_MMCO_Custom_Tool__c  = :projectId];

        for(AcctSeed__Journal_Entry_Line__c jornalEntry : lstJournalEntryRecord){
            JournalEntryLineWrapper objJourEntryWrapper = new JournalEntryLineWrapper ();
            if(jornalEntry.Project_Posting_Type__c == 'Labor'){
                objJourEntryWrapper.hourQuantity = jornalEntry.AcctSeed__Units__c;
                objJourEntryWrapper.debit = jornalEntry.AcctSeed__Debit__c;
                objJourEntryWrapper.credit = jornalEntry.AcctSeed__Credit__c;
                objJourEntryWrapper.reference = jornalEntry.AcctSeed__Reference__c;
                

            }else if(jornalEntry.Project_Posting_Type__c == 'Other Cost') {
                objJourEntryWrapper.hourQuantity = jornalEntry.AcctSeed__Units__c;
                objJourEntryWrapper.debit = jornalEntry.AcctSeed__Debit__c;
                objJourEntryWrapper.credit = jornalEntry.AcctSeed__Credit__c;
                objJourEntryWrapper.reference = jornalEntry.AcctSeed__Reference__c;
                
            }
           
            lstJournalWrapper.add(objJourEntryWrapper);
        }
        
        return lstJournalWrapper;
    }


    @AuraEnabled
    public static void updateEmailSchedules(Project__c project, List<Project_Schdule_To__c> emailSchedules, List<Project_Schdule_To__c> emailScheduleToDelete) {
        
        update project;
        upsert emailSchedules;
        delete emailScheduleToDelete;
    }    

    @AuraEnabled
    public static String saveProjectStatus(Object data) {
        
        List <Product_Select__c> lstLineItems = (List<Product_Select__c>) JSON.deserialize(JSON.serialize(data), List<Product_Select__c>.class);
        
        try {
            update lstLineItems;
            return 'Success: Account(s) updated successfully';
        }
        catch (Exception e) {
            return 'The following exception has occurred: ' + e.getMessage();
        }
    }

    @AuraEnabled
    public static string updateProjectDetails(String data) {
        
        try {
            List<Product_Select__c> lstLineItemsToUpdate = (List<Product_Select__c>) JSON.deserialize(JSON.serialize(data), List<Product_Select__c>.class);
            
            update lstLineItemsToUpdate;

            return 'Success: Quote line items updated successfully';
        }
        catch (Exception e) {
            return 'The following exception has occurred: ' + e.getMessage();
        }
    }

    public class ProjectDetailsWrapper {
        @AuraEnabled public String sharePointUrl {get; set;}
        @AuraEnabled public String scheduleOn {get; set;}
        @AuraEnabled public Date scheduleEndDate {get; set;}
        @AuraEnabled public List<Project_Schdule_To__c> lstScheduleTo {get; set;}
        @AuraEnabled public List<AcctSeedERP__Sales_Order__c> lstSOAndPODetails {get; set;}
        @AuraEnabled public String syncQuoteId {get; set;}
        @AuraEnabled public String activeFinancialQuoteId {get; set;}
        @AuraEnabled public List<Product_Select__c> lstQuoteLineItems {get; set;}
        @AuraEnabled public List<AccountingLineItem> lstAccountingLineItem {get; set;}
        @AuraEnabled public Decimal totalInvoiceAmount {get; set;}
        @AuraEnabled public Decimal totalAmountPaid {get; set;}
        @AuraEnabled public CostPosting laborPosting {get; set;}
        @AuraEnabled public CostPosting otherPosting {get; set;}
        @AuraEnabled public QuoteFinancialWrapper activeFinancialQuote {get; set;}
        @AuraEnabled public List<JournalEntryLineWrapper> lstJournalEntry {get; set;}
        @AuraEnabled public List<JournalEntryLineWrapper> lstOtherJournalEntry {get; set;}
        @AuraEnabled public List<InventoryCostWrapper> lstInventoryCostWithSO {get; set;}
        @AuraEnabled public Map<Id, List<AcctSeed__Inventory_Cost__c>> mapofSalesorderAndInventory {get; set;}
        @AuraEnabled public List<GroupWrapper> lstGroupWrapper {get; set;}

        public ProjectDetailsWrapper() {
            this.totalInvoiceAmount = 0;
            this.totalAmountPaid = 0;
        }
    }

    public class ProjectFinancialWrapper {
        @AuraEnabled public QuoteFinancialWrapper asSoldQuote {get;set;} 
        @AuraEnabled public QuoteFinancialWrapper activeFinancialQuote {get;set;} 

        @AuraEnabled public Decimal finalSalesDirect {get;set;}

        @AuraEnabled public Decimal finalInvoicedCommisionAndRebate {get;set;}
        @AuraEnabled public Decimal finalInvoicedBuyResell {get;set;}
        @AuraEnabled public Decimal finalInvoiced {get;set;}

        @AuraEnabled public Decimal finalRevenueCommissionRebate {get;set;}
        @AuraEnabled public Decimal finalRevenueBuyResell {get;set;}
        @AuraEnabled public Decimal finalRevenueSales {get;set;}

        @AuraEnabled public Decimal finalMarginCommissionRebate {get;set;}
        @AuraEnabled public Decimal finalMarginBuyResell {get;set;}
        @AuraEnabled public Decimal finalMargin {get;set;}
        @AuraEnabled public List<SalesEngSplitWrapper> salesEngSplitList{get;set;}

        @AuraEnabled public String opportunityName {get;set;}
        @AuraEnabled public String opportunityNumber {get;set;}
        @AuraEnabled public String ledger {get;set;}
        @AuraEnabled public String projectManager {get;set;}
        @AuraEnabled public Decimal finalInvoicedPercentage {get;set;}
        @AuraEnabled public Decimal commissionInvoiced {get;set;}
        @AuraEnabled public Decimal brInvoiced {get;set;}
        @AuraEnabled public Decimal costToBeExpensed {get;set;}
        @AuraEnabled public Decimal actualExpensedCost {get;set;}
        @AuraEnabled public Decimal ExpensesToAccrue {get;set;}
        @AuraEnabled public Decimal moveExpensesToWip {get;set;}
        @AuraEnabled public Decimal amountUnderBilled {get;set;}
        @AuraEnabled public Boolean showCommissionTable {get;set;}

        public ProjectFinancialWrapper() {
            asSoldQuote = new QuoteFinancialWrapper();
            activeFinancialQuote = new QuoteFinancialWrapper();
        }
        
    }

    public class SalesEngSplitWrapper{
        @AuraEnabled public String SplitName {get;set;}
        @AuraEnabled public Decimal splitCommision {get;set;}
    }

    public class InventoryCostWrapper{
        @AuraEnabled public Id salesOrderID {get; set;}
        @AuraEnabled public List<AcctSeed__Inventory_Cost__c> inventoryCostList {get;set;}
    }

    public class QuoteFinancialWrapper {
        
        @AuraEnabled public Decimal salesDirect {get;set;}
        @AuraEnabled public Decimal salesBuyReSell {get;set;}
        @AuraEnabled public Decimal marginCommissionRebate {get;set;}
        @AuraEnabled public Decimal marginBuyResell {get;set;}
        @AuraEnabled public Decimal costBuyResell {get;set;}

        @AuraEnabled public Decimal totalProjectSales {get;set;}
        @AuraEnabled public Decimal totalProjectMargin {get;set;}
        
        @AuraEnabled public Decimal marginCommissionRebatePercentage {get;set;}
        @AuraEnabled public Decimal marginBuyResellPercentage {get;set;}
        @AuraEnabled public Decimal totalProjectMarginPercentage {get;set;}

        public QuoteFinancialWrapper() {
            this.salesDirect = 0;
            this.salesBuyReSell = 0;
            this.marginCommissionRebate = 0;
            this.marginBuyResell = 0;
            this.costBuyResell = 0;
            this.totalProjectSales = 0;
            this.totalProjectMargin = 0;
            this.marginCommissionRebatePercentage = 0;
            this.marginBuyResellPercentage = 0;
            this.totalProjectMarginPercentage = 0; 
        }

    }

    public class AccountingLineItem {
        @AuraEnabled public Id id;
        @AuraEnabled public Decimal quantity;
        @AuraEnabled public String code;
        @AuraEnabled public String description;
        @AuraEnabled public String soName;
        @AuraEnabled public String soUrl;
        @AuraEnabled public Date releaseDate;
        @AuraEnabled public String customerInvoiceName;
        @AuraEnabled public String customerInvoiceUrl;
        @AuraEnabled public Decimal invoiceAmount;
        @AuraEnabled public Date paymentReceivedDate;
        @AuraEnabled public Decimal AmountPaid;
        @AuraEnabled public String vendorPOName;
        @AuraEnabled public String vendorPOUrl;
        @AuraEnabled public String submittalStatus;
        @AuraEnabled public String tag;
        @AuraEnabled public Boolean hideFromEmail;
        @AuraEnabled public Date estimateShipDate;
        @AuraEnabled public Date actShipDate;
        @AuraEnabled public String tracking;
        @AuraEnabled public String stringNote;
        @AuraEnabled public String serialNumber;
        @AuraEnabled public Boolean iomComplete;
        @AuraEnabled public Date startupSchedule;
        @AuraEnabled public Date startupCompleted;
        @AuraEnabled public String warranty;
        @AuraEnabled public String warrantyType;
        @AuraEnabled public String partsCovered;
        @AuraEnabled public Date warrantyStart;
        @AuraEnabled public Date warrantyEnd;
        @AuraEnabled public String productName;
        @AuraEnabled public List<String> pickListOptions;
        
    }

    public class CostPosting {
        @AuraEnabled public Decimal totalCost {get; set;}
        @AuraEnabled public List<Cost_Posting__c> lstCostPosting {get; set;}
    }
    public class JournalEntryLineWrapper {
        @AuraEnabled public Decimal hourQuantity {get; set;}
        @AuraEnabled public Decimal debit {get; set;}
        @AuraEnabled public Decimal credit {get; set;}
        @AuraEnabled public String reference {get; set;}
        @AuraEnabled public String  ProjectPostingType {get; set;}
    }

    Public class ProjectCommissionWrapper{
        @AuraEnabled public String opportunityName {get; set;}
        @AuraEnabled public String opportunityNumber {get; set;}
        @AuraEnabled public String ledger {get; set;}
        @AuraEnabled public List<SalesEngSplitWrapper> salesEngSplitList{get;set;}
        @AuraEnabled public Decimal totalBooking {get; set;}
        @AuraEnabled public Decimal companyBookingAmount {get; set;}
        @AuraEnabled public Decimal totalCogs {get; set;}
        @AuraEnabled public Decimal totalMargin {get; set;}
        @AuraEnabled public Decimal invoicedAmount {get; set;}
        @AuraEnabled public Decimal invoicePercentage {get; set;}
        @AuraEnabled public Decimal amountPaid {get; set;}
        @AuraEnabled public Decimal amountInvoicedPaidOn {get; set;}
        @AuraEnabled public Decimal companyBookingsPaidOn {get; set;}
        @AuraEnabled public String archived {get; set;} 
        @AuraEnabled public Boolean showCommissionTable {get;set;}
    }

    Public class GroupWrapper{
        @AuraEnabled public Id groupId {get; set;}
        @AuraEnabled public String groupName {get; set;}
        @AuraEnabled public List<SubGroupWrapper> subGroupList {get; set;}
    }

    Public class SubGroupWrapper{
        @AuraEnabled public Id subGroupId {get; set;}
        @AuraEnabled public String subGroupName {get; set;}
        @AuraEnabled public List<AccountingLineItem> lstQuoteLineItems {get; set;}
        @AuraEnabled public Decimal totalInvoiceAmount {get; set;}
        @AuraEnabled public Decimal totalAmountPaid {get; set;}
        public SubGroupWrapper() {
            this.totalInvoiceAmount = 0;
            this.totalAmountPaid = 0;
        }
    }

}