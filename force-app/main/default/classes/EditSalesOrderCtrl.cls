public with sharing class EditSalesOrderCtrl {

    public List<GroupWrapper> lstGroups {get;set;}

    public Quote quote {get;set;}
    public String mode {get;set;}
    public string message {get;set;}
    public Boolean iserror {get;set;}
    public AcctSeedERP__Sales_Order__c orderSobject {get;set;}
    public Boolean isActiveFinancial {get;set;}

    public EditSalesOrderCtrl(ApexPages.StandardController controller) {
        orderSobject = [SELECT Id,Name,Quote__c From AcctSeedERP__Sales_Order__c WHERE Id =: controller.getId()];
        quote = CartQueryHelper.getQuote(orderSobject.Quote__c);
        mode = 'edit';

        isActiveFinancial = QuoteUtils.isActiveFinancialQuote(quote.Id);
        lstGroups = prepareSalesOrder();
    }

    public List<GroupWrapper> prepareSalesOrder() {
        List<GroupWrapper> lstGroupWrapper = new List<GroupWrapper>();

        List<Product_Group__c> lstSubGroups = getQuoteLineItems(quote.Id);

        
        Set<Id> setParentGroupIds = new Set<Id>();
        for(Product_Group__c subGroup : lstSubGroups){
            if(subGroup.Parent_Product_Group__c != null){
                setParentGroupIds.add(subGroup.Parent_Product_Group__c);
            }
        }
        
        //List<Product_Group__c> lstParentGroups = CartQueryHelper.getParentGroups(setParentGroupIds);
        Map<Id, Product_Group__c> parentGroupsMap = CartQueryHelper.getParentGroups(quote.Id); 
        List<Product_Group__c> lstParentGroups = parentGroupsMap.values();
        
        Map<Id, Product_Group__c> mapParentGroup = new Map<Id, Product_Group__c>();
        for(Product_Group__c pg : lstParentGroups) {
            mapParentGroup.put(pg.Id, pg);
        }
        
        Id parentGroupId = null;
        
        GroupWrapper objGroupWrapper;
        Map<Id, GroupWrapper> mapParentGroupWrapper = new Map<Id, GroupWrapper>();
        Map<Id, AcctSeedERP__Sales_Order_Line__c> mapCreatedSalesOrderLine = new Map<Id, AcctSeedERP__Sales_Order_Line__c>();
        List<AcctSeedERP__Sales_Order_Line__c> CreatedSalesOrderLine = [SELECT Id,
                                                                                Quote_Line_Item__c,
                                                                                AcctSeedERP__Quantity_Ordered__c,
                                                                                AcctSeedERP__Unit_Price__c,
                                                                                AcctSeedERP__Product__c,
                                                                                AcctSeedERP__Comment__c,
                                                                                AcctSeedERP__Sales_Order__c,
                                                                                AcctSeedERP__Total__c
                                                                                FROM AcctSeedERP__Sales_Order_Line__c
                                                                                WHERE  AcctSeedERP__Sales_Order_Line__c.Quote_Line_Item__c in (
                                                                                    SELECT Id
                                                                                    FROM Product_Select__c 
                                                                                    WHERE Product_Select__c.Quote__c = :quote.Id
                                                                                )];

        for(AcctSeedERP__Sales_Order_Line__c salesorderline : CreatedSalesOrderLine){
            mapCreatedSalesOrderLine.put(salesorderline.Quote_Line_Item__c, salesorderline);
        }
        for(Product_Group__c pg : lstSubGroups) {
            
            if(parentGroupId == null) {
                parentGroupId = pg.Parent_Product_Group__c;
            }
            
            if(parentGroupId != pg.Parent_Product_Group__c && parentGroupId != null) {
            
                lstGroupWrapper.add(objGroupWrapper);
                objGroupWrapper = new GroupWrapper(mapParentGroup.get(pg.Parent_Product_Group__c));
                
                parentGroupId = pg.Parent_Product_Group__c;
                
            }
            
            
            SubGroup objSubGroup = new SubGroup(pg);
            for(Product_Select__c lineItem : pg.Quote_Line_Items__r) {

                //system.debug('mapCreatedSalesOrderLine ==' mapCreatedSalesOrderLine + ' lineItem.Id == ' + lineItem.Id );
          
                If(mapCreatedSalesOrderLine.get(lineItem.Id) != null){
                    if(mapCreatedSalesOrderLine.get(lineItem.Id).AcctSeedERP__Sales_Order__c == orderSobject.Id) {
                        OrderLineItem objOrderLineItem = new OrderLineItem();
                        objOrderLineItem.isAlternate = false;
                        objOrderLineItem.isSelect = true;
                        objOrderLineItem.tag = lineItem.Tag__c;
                        objOrderLineItem.orderLineItem = mapCreatedSalesOrderLine.get(lineItem.Id);
                        /*
                        objOrderLineItem.orderLineItem.Id = mapCreatedSalesOrderLine.get(lineItem.Id).Id;
                        objOrderLineItem.orderLineItem.AcctSeedERP__Quantity_Ordered__c = mapCreatedSalesOrderLine.get(lineItem.Id).AcctSeedERP__Quantity_Ordered__c;
                        objOrderLineItem.orderLineItem.AcctSeedERP__Unit_Price__c = mapCreatedSalesOrderLine.get(lineItem.Id).AcctSeedERP__Unit_Price__c;
                        objOrderLineItem.orderLineItem.AcctSeedERP__Product__c = mapCreatedSalesOrderLine.get(lineItem.Id).AcctSeedERP__Product__c;
                        objOrderLineItem.orderLineItem.AcctSeedERP__Comment__c = mapCreatedSalesOrderLine.get(lineItem.Id).AcctSeedERP__Comment__c;
                        objOrderLineItem.orderLineItem.Quote_Line_Item__c = mapCreatedSalesOrderLine.get(lineItem.Id).Quote_Line_Item__c;
                        objOrderLineItem.orderLineItem.AcctSeedERP__Total__c = mapCreatedSalesOrderLine.get(lineItem.Id).AcctSeedERP__Total__c;
                        */
                        objSubGroup.lstOrderLineItems.add(objOrderLineItem);
                    }
 
                }
                else {
                    OrderLineItem objOrderLineItem = new OrderLineItem(false, lineItem);
                    objSubGroup.lstOrderLineItems.add(objOrderLineItem);
                }

                
            }
             if(mapParentGroupWrapper.get(pg.Parent_Product_Group__c) != null) {
                objGroupWrapper = mapParentGroupWrapper.get(pg.Parent_Product_Group__c);
            } else {
                objGroupWrapper = new GroupWrapper(mapParentGroup.get(pg.Parent_Product_Group__c));
                mapParentGroupWrapper.put(pg.Parent_Product_Group__c, objGroupWrapper);
            }

            objGroupWrapper.lstSubGroups.add(objSubGroup);

        }
        
        lstGroupWrapper.add(objGroupWrapper);

        return lstGroupWrapper;
    }

   /* public PageReference createSalesOrder() {

        try {

            List<AcctSeedERP__Sales_Order_Line__c> lstOrderLineItemsToInsert = new List<AcctSeedERP__Sales_Order_Line__c>();

            AcctSeedERP__Sales_Order__c objSalesOrder = new AcctSeedERP__Sales_Order__c();

            objSalesOrder.AcctSeedERP__Customer__c = quote.Attention_to_Account__c;
            If(Test.isRunningTest()){
                AcctSeed__Ledger__c test_Ledger = new AcctSeed__Ledger__c(Name = 'Test', AcctSeed__Type__c = 'Transactional');
                insert test_Ledger;
                objSalesOrder.AcctSeedERP__Ledger__c = test_Ledger.Id;
            }else{
                objSalesOrder.AcctSeedERP__Ledger__c = null;
            }
            objSalesOrder.AcctSeedERP__Opportunity__c = quote.OpportunityId;
            objSalesOrder.Quote__c = quote.Id;
            objSalesOrder.AcctSeedERP__Customer__c = quote.Opportunity.AccountId;

            system.debug('Sales order > ' + objSalesOrder);
            insert objSalesOrder;

            for(GroupWrapper grp : lstGroups) {
                for(SubGroup subGroup : grp.lstSubGroups) {
                    for(OrderLineItem lineItem : subGroup.lstOrderLineItems) {
                       
                        if(lineItem.isSelect && lineItem.orderLineItem.Id == null) {
                            lineItem.orderLineItem.AcctSeedERP__Sales_Order__c = objSalesOrder.Id;
                            lstOrderLineItemsToInsert.add(lineItem.orderLineItem);
                        }
                    }
                }
            }

            if(!lstOrderLineItemsToInsert.isEmpty()) {
                insert lstOrderLineItemsToInsert;
            }

            string saleOrderUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/AcctSeedERP__Sales_Order__c/'+objSalesOrder.Id+'/view?0.source=alohaHeader';
            PageReference pageRef = new PageReference(saleOrderUrl);
            pageRef.setRedirect(true);
            return pageRef;

        } catch(Exception ex) {
            message = ex.getMessage();
            iserror = true;
            return null;
        }
        
    }*/

    public PageReference backToQuote() {
        PageReference pr = new PageReference('/' + quote.Id);
        pr.setRedirect(true);
        return pr;
    }

    public List<Product_Group__c> getQuoteLineItems(Id quoteId) {
        List<Product_Group__c> lstSubGroup = [SELECT
                                                    Id,
                                                    Name,
                                                    Parent_Product_Group__r.Name,
                                                    Parent_Product_Group__c,
                                                    Total_Line_Items__c,
                                                    Total_Sub_Groups__c,
                                                    Hide_Pricing__c,
                                                    Total_Extended_Cost__c,
                                                    Hide_Base_Bid_Total__c,
                                                    Total_Group_Extended_Cost__c,
                                                    Index__c,
                                                    Hide_Code__c,
                                                    Hide_Amount__c,
                                                    Hide_Line__c,
                                                    Quantity_Total__c,
                                                    Grand_Quantity_Total__c,
                                                    Hide_Quantity__c,
                                                    Release_Number__c,
                                                    Total_Freight__c,
                                                    Total_Group_Freight__c,
                                                    Page_Break__c,Alternate__c, 
                                                    Is_Section_Closed__c,
                                                        (SELECT 
                                                            Id,
                                                            Descriptions__c,
                                                            Family__c,
                                                            Freight__c,
                                                            List_Price__c,
                                                            Margin_Percentage__c,
                                                            Multiplier__c,
                                                            Original_Product_Name__c,
                                                            Product_Code__c,
                                                            Product_Group__c,
                                                            Product_Name__c,
                                                            Quantity__c,
                                                            Quote__c,
                                                            Sales_Price__c,
                                                            Total_Price__c,
                                                            T_LBS__c,
                                                            LBS__c,
                                                            Tag__c,
                                                            Extended_Cost__c,
                                                            Hide_Pricing__c,
                                                            Hide_Line__c,
                                                            Unit_Cost__c,
                                                            Hide_Code__c,
                                                            Row_Index__c,
                                                            Unique_Index__c,
                                                            Page_Break__c,
                                                            Alternate__c,
                                                            Is_Freight_Override__c,
                                                            Release_pick__c,
                                                            Sale_Type__c,CR__c,
                                                            Hide_Quantity__c,
                                                            Manufacturer__c,
                                                            Is_SalePrice_Override__c,
                                                            Product_Type__c,
                                                            ProductId__c
                                                        FROM Quote_Line_Items__r
                                                        WHERE Sale_Type__c != 'D/S'
                                                        ORDER BY Row_Index__c ASC)
                                                FROM Product_Group__c 
                                                WHERE Quote__c =: quoteId
                                                AND Parent_Product_Group__c != null
                                                ORDER BY Parent_Product_Group__c,Index__c ASC];
    
        return lstSubGroup;
    }

    public Pagereference updateSalesOrder() {
        
            List<AcctSeedERP__Sales_Order_Line__c> lstOrderLineItemsToCreate = new List<AcctSeedERP__Sales_Order_Line__c>();   
        
            for(GroupWrapper grp : lstGroups) {
                for(SubGroup subGroup : grp.lstSubGroups) {
                    for(OrderLineItem lineItem : subGroup.lstOrderLineItems) {
                    
                        if(lineItem.isSelect && lineItem.orderLineItem.Id == null) {
                            
                            lineItem.orderLineItem.AcctSeedERP__Sales_Order__c = orderSobject.Id;
                            lstOrderLineItemsToCreate.add(lineItem.orderLineItem);
                        }
                    }
                }
            }

            if(!lstOrderLineItemsToCreate.isEmpty()) {
                try {
                    insert lstOrderLineItemsToCreate;
                } catch (System.DmlException ex ) {
                     message = ex.getDmlMessage(0);
                     return null;
                }

                Map<ID, AcctSeedERP__Sales_Order_Line__c> productIdToOrderline = new Map<ID, AcctSeedERP__Sales_Order_Line__c>();
                List<Product_Select__c> quoteLinesToUpdate = new List<Product_Select__c>();
                
                for(AcctSeedERP__Sales_Order_Line__c orderLine : lstOrderLineItemsToCreate) {
                    //productIdToOrderline.put(orderLine.AcctSeedERP__Product__c, orderLine);
                    Product_Select__c quoteLine = new Product_Select__c(
                                                    Id=orderLine.Quote_Line_Item__c,
                                                    SalesOrderId__c=orderSobject.Id,
                                                    Sales_Order_Line__c = orderLine.Id);
                    quoteLinesToUpdate.add(quoteLine); 
                }

                try {
                    update quoteLinesToUpdate;
                } catch (System.DmlException ex ) {
                     message = ex.getDmlMessage(0);
                     return null;
                }
                

            }
            string saleOrderUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/AcctSeedERP__Sales_Order__c/'+orderSobject.Id+'/view?0.source=alohaHeader';
            PageReference pageRef = new PageReference(saleOrderUrl);
            pageRef.setRedirect(true);
            return pageRef;
            
        
    }
}