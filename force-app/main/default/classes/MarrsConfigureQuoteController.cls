public with sharing class MarrsConfigureQuoteController {

    public Quote quote {get;set;}
    public Product_Select__c rickTextAreaValue{get;set;}

    public List<GroupWrapper> lstGroups {get;set;}
    public List<ProductWrapper> lstProducts {get;set;}
    private Map<Id, PricebookEntry> mapSelectedProduct {get;set;}
    
    public String hidGroupId {get;set;}
    public String hidSubGroupId {get;set;}
    public String hidLineItemId {get;set;}

    public Integer hidGroupIndex {get;set;}
    public Integer hidSubGroupIndex {get;set;}
    public Integer hidLineItemIndex {get;set;}

    public final Integer PAGE_SIZE = 20;
    public String searchProduct{get;set;}

    private final String ACTION_DELETE_GROUP = 'DELETEGROUP';
    private final String ACTION_DELETE_SUBGROUP = 'DELETESUBGROUP';
    private final String ACTION_DELETE_LINEITEM = 'DELETELINEITEM';
    
    public String groupName {get;set;}
    public String subGroupNameCreateGroup {get;set;}
    public String subGroupNameCreateSubGroup {get;set;}

    public MarrsConfigureQuoteController(ApexPages.StandardController controller) {
        Id quoteId = controller.getId();
        quote = CartQueryHelper.getQuote(quoteId);
        lstGroups = prepareCartPage();
        rickTextAreaValue = new Product_Select__c();
        mapSelectedProduct = new Map<Id, PricebookEntry>();
    }

    @TestVisible
    private List<GroupWrapper> prepareCartPage() {

        List<GroupWrapper> lstGroupWrapper = new List<GroupWrapper>();

        Map<Id, Product_Group__c> mapSubGroup = CartQueryHelper.getSubGroupWithQuoteLineItems(quote.Id);
        Map<Id, Product_Group__c> mapParentGroup = CartQueryHelper.getParentGroups(quote.Id);
                
        Id parentGroupId = null;
        
        GroupWrapper objGroupWrapper;
        Map<Id, GroupWrapper> mapParentGroupWrapper = new Map<Id, GroupWrapper>();
        
        for(Product_Group__c grp : mapParentGroup.values()) {
            objGroupWrapper = new GroupWrapper(grp);
            for(Product_Group__c subGroup : grp.ProductGroups__r) {
                SubGroup objSubGroup = new SubGroup(subGroup);
                for(Product_Select__c lineItem : mapSubGroup.get(subGroup.Id).Quote_Line_Items__r) {
                    objSubGroup.lstQuoteLineItems.add(lineItem);
                }
                objGroupWrapper.lstSubGroups.add(objSubGroup);
            }
            lstGroupWrapper.add(objGroupWrapper);
        }

        return lstGroupWrapper;
    }

    public void addNewGroup() {
        try {

            quickSave();

            Product_Group__c objGroup = new Product_Group__c();
            objGroup.Name = 'Freight';
            objGroup.Quote__c = quote.Id;
            objGroup.External_Id__c = QuoteUtils.generateExternalId();
            objGroup.Index__c = CartQueryHelper.getTotalGroups(quote.Id) + 1;
            
            insert objGroup;

            Product_Group__c objSubGroup = new Product_Group__c();
            objSubGroup.Name = subGroupNameCreateGroup;
            objSubGroup.Quote__c = quote.Id;
            objSubGroup.Index__c = 1;
            objSubGroup.Parent_Product_Group__c = objGroup.Id;
            insert objSubGroup;

            subGroupNameCreateGroup = '';

            lstGroups = prepareCartPage();
        } catch(Exception ex) {
            ApexPages.addMessages(ex);
        }
    }

    public void cloneGroup() {
        try {

            quickSave();

            List<Product_Group__c > lstSubGroupsToInsert = new List<Product_Group__c >();
            List<Product_Select__c> lstQuoteLineItemsToInsert = new List<Product_Select__c>();

            Product_Group__c grp = CartQueryHelper.getGroupToClone(hidGroupId);
            
            Product_Group__c groupToClone = QuoteUtils.cloneGroup(grp);
            groupToClone.Index__c = CartQueryHelper.getTotalGroups(quote.Id) + 1;
            
            List<Product_Group__c> lstSubGroups = CartQueryHelper.getSubGroupsToClone(hidGroupId);
            for(Integer i=0; i< lstSubGroups.size(); i++) {
                Product_Group__c subGroupToClone = QuoteUtils.cloneGroup(lstSubGroups[i]);
                subGroupToClone.Index__c = i + 1;
                subGroupToClone.Parent_Product_Group__r = new Product_Group__c(External_Id__c = groupToClone.External_Id__c);
                lstSubGroupsToInsert.add(subGroupToClone);

                for(Integer j=0; j<lstSubGroups[i].Quote_Line_Items__r.size(); j++) {
                    Product_Select__c lineItem = lstSubGroups[i].Quote_Line_Items__r[j];
                    Product_Select__c lineItemToClone = QuoteUtils.cloneLineItem(lineItem);
                    lineItemToClone.Row_Index__c = J + 1;
                    lineItemToClone.Product_Group__r = new Product_Group__c(External_Id__c = subGroupToClone.External_Id__c);
                    lstQuoteLineItemsToInsert.add(lineItemToClone);
                }
            }

            upsert groupToClone;
            upsert lstSubGroupsToInsert;
            upsert lstQuoteLineItemsToInsert;

            lstGroups = prepareCartPage();

            calculatePricing(null);

            quickSave();

            lstGroups = prepareCartPage();

        } catch(Exception ex) {
            ApexPages.addMessages(ex);
        }
    }

    public void deleteGroup() {
        
        calculatePricing(hidGroupId);

        quickSave();
        
        delete [SELECT Id 
                    FROM Product_Select__c 
                    WHERE Product_Group__c IN: [SELECT Id FROM Product_Group__c WHERE Parent_Product_Group__c =: hidGroupId]];
        
        delete [SELECT Id FROM Product_Group__c WHERE Parent_Product_Group__c =: hidGroupId OR Id =: hidGroupId];

        reOrderGroup(hidGroupIndex);

        lstGroups = prepareCartPage();
        
    }

    public void addNewSubGroup() {
        try {

            quickSave();

            Product_Group__c objSubGroup = new Product_Group__c();
            objSubGroup.Name = subGroupNameCreateSubGroup;
            objSubGroup.Quote__c = quote.Id;
            objSubGroup.Index__c = CartQueryHelper.getTotalSubGroups(hidGroupId) + 1;
            objSubGroup.Parent_Product_Group__c = hidGroupId;
            insert objSubGroup;

            subGroupNameCreateSubGroup = '';

            lstGroups = prepareCartPage();
        } catch(Exception ex) {
            ApexPages.addMessages(ex);
        }
    }

    public void cloneSubGroup() {
        try {

            quickSave();

            List<Product_Select__c> lstLineItemsToInsert = new List<Product_Select__c>();

            Product_Group__c objSubGroup = CartQueryHelper.getSubGroupToClone(hidSubGroupId);

            Product_Group__c objSubGroupToClone = objSubGroup.clone(false, true, false, false);
            objSubGroupToClone.Quote__c = quote.Id;
            objSubGroupToClone.Index__c = CartQueryHelper.getTotalSubGroups(hidGroupId) + 1;
            //objSubGroupToClone.Unique_Index__c = String.valueOf(hidGroupIndex + 1) + String.valueOf(objSubGroup.Index__c);
            insert objSubGroupToClone;

            if(!objSubGroup.Quote_Line_Items__r.isEmpty()) {
                for(Integer i=0; i<objSubGroup.Quote_Line_Items__r.size();i++) {
                    Product_Select__c lineItem = objSubGroup.Quote_Line_Items__r[i];
                    
                    Product_Select__c lineItemToClone = lineItem.clone(false, true, false, false);
                    lineItemToClone.Is_SalePrice_Override__c = false;
                    lineItemToClone.Product_Group__c = objSubGroupToClone.Id;
                    lineItemToClone.Row_Index__c = i + 1; 
                    lstLineItemsToInsert.add(lineItemToClone);
                }
                
                insert lstLineItemsToInsert;
            }

            lstGroups = prepareCartPage();

            calculatePricing(null);

            quickSave();

            lstGroups = prepareCartPage();

        } catch(Exception ex) {
            ApexPages.addMessages(ex);
        }
        
    }

    public void deleteSubGroup() {
        
        calculatePricing(hidGroupId);

        quickSave();

        delete [SELECT Id FROM Product_Select__c WHERE Product_Group__c =: hidGroupId];
        
        delete [SELECT Id FROM Product_Group__c WHERE Id =: hidGroupId];

        reOrderSubGroup(hidGroupId, hidSubGroupIndex);

        lstGroups = prepareCartPage();
    }

    public void cloneLineItem() {

        try{

            quickSave();

            Product_Select__c lineItem = CartQueryHelper.getLineItemToClone(hidLineItemId);

            Product_Select__c lineItemToClone = lineItem.clone(false, true, false, false);
            lineItemToClone.Product_Group__c = hidSubGroupId;
            lineItemToClone.Row_Index__c = CartQueryHelper.getTotalLineItems(hidSubGroupId) + 1;

            insert lineItemToClone;

            lstGroups = prepareCartPage();

            calculatePricing(null);

            quickSave();

            lstGroups = prepareCartPage();
        } catch(Exception ex) {
            ApexPages.addMessages(ex);
        }
    }

    public void deleteLineItem() {

        try{

            calculatePricing(hidLineItemId);

            quickSave();

            delete [SELECT Id FROM Product_Select__c WHERE Id =: hidLineItemId];
            
            reOrderLineItem(hidSubGroupId, hidLineItemIndex);

            lstGroups = prepareCartPage();

        } catch(Exception ex) {
            ApexPages.addMessages(ex);
        }
    }

    public void quickSave() {
        try {

            List<Product_Group__c> lstGroupsToUpsert = new List<Product_Group__c>();
            List<Product_Group__c > lstSubGroupsToUpsert = new List<Product_Group__c >();
            List<Product_Select__c> lstQuoteLineItemsToUpsert = new List<Product_Select__c>();
            
            for(GroupWrapper grp : lstGroups) {
                lstGroupsToUpsert.add(grp.grp);
                for(SubGroup subGroup : grp.lstSubGroups ) {
                    Product_Group__c objSubGroup = subGroup.subGroup;
                    lstSubGroupsToUpsert.add(objSubGroup);
                    lstQuoteLineItemsToUpsert.addAll(subGroup.lstQuoteLineItems);
                }
                
            }
        
            upsert lstGroupsToUpsert;
            upsert lstSubGroupsToUpsert;
            upsert lstQuoteLineItemsToUpsert;
            update quote;
            
            autoSyncBackToOpportunity();

        } catch(exception ex) {
            ApexPages.addMessages(ex);
        }
    }

    private void calculatePricing(Id deletedId) {

        Decimal grandTotal = 0;

        for (GroupWrapper grp : lstGroups) {

            Decimal groupTotal = 0;

            for (SubGroup subGrp : grp.lstSubGroups) {

                Decimal subGroupTotal = 0;

                for (Product_Select__c lineItem : subGrp.lstQuoteLineItems) {
                    if(deletedId != lineItem.Id && lineItem.Sales_Price__c != null) {
                        subGroupTotal += lineItem.Sales_Price__c;
                    }
                    
                }

                subGrp.subGroup.Total_Line_Items__c = subGroupTotal;

                if(deletedId != subGrp.subGroup.Id) {
                    groupTotal += subGroupTotal;    
                }

            }

            grp.grp.Total_Sub_Groups__c = groupTotal;

            if(deletedId != grp.grp.Id) {
                grandTotal += groupTotal;
            }
            
        }

        quote.Total_Base_Bid_Total__c = grandTotal;

    }

    public Pagereference saveAndExit() {

        quickSave();

        return redirectToQuote();
    }

    public Pagereference redirectToQuote() {
        PageReference pr = new PageReference('/' + quote.Id);
        pr.setRedirect(true);
        return pr;
    }

    private void autoSyncBackToOpportunity() {
        try {
            Opportunity opp = CartQueryHelper.getOpportunity(quote.Id);
            
            opp.Total_Base_Bid_Total_Quote__c = quote.Total_Base_Bid_Total__c;
            opp.Total_Extended_Cost_Quote__c = quote.Total_Extended_Cost__c;
            opp.Total_Project_Margin__c = quote.Total_Project_Margin__c;
            
            update opp;
        } catch(exception ex) {
            ApexPages.addMessages(ex);
        }
    }

    public void addProduct() {

        quickSave();

        mapSelectedProduct = new Map<Id, PricebookEntry>();
        lstProducts = new List<ProductWrapper>();
    }

    public ApexPages.StandardSetController con {
        get {
            if(con == null) {
                con = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT 
                                                                                        Id,
                                                                                        Product2.Name,
                                                                                        Product2.ProductCode,
                                                                                        Product2.Family,
                                                                                        UnitPrice,
                                                                                        Product2.Product_Description__c,
                                                                                        Product2.Weight__c,
                                                                                        Product2.Description,
                                                                                        Product2.Manufacturer__c,
                                                                                        Product2.Product_Type__c  
                                                                                    FROM PricebookEntry 
                                                                                    WHERE Pricebook2.IsStandard = true 
                                                                                    AND Product2.Midwest_Group_Office__c INCLUDES (:quote.Opportunity.Office__c)
                                                                                    ORDER BY Product2.Name asc]));
                con.setPageSize(PAGE_SIZE);
            }
            return con;
        }
        set;
    }
    
    public void searchProducts(){
    
        getSelectedProducts();
        
        String searchString = '%' + searchProduct + '%';

        con = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id,Product2.Name,Product2.ProductCode, Product2.Family,UnitPrice,Product2.Product_Description__c,Product2.Weight__c,Product2.Description,
                                                                            Product2.Manufacturer__c, 
                                                                            Product2.Product_Type__c 
                                                                            FROM PricebookEntry 
                                                                            WHERE Pricebook2.IsStandard = true
                                                                            AND (Product2.Name LIkE :searchString  OR
                                                                            Product2.ProductCode LIkE :searchString OR
                                                                            Product2.Family LIkE :searchString OR
                                                                            Product2.Description LIkE :searchString) 
                                                                            AND Product2.Midwest_Group_Office__c INCLUDES (:quote.Opportunity.Office__c)
                                                                            ORDER BY Product2.Name asc]));
    }

    public List<ProductWrapper> getProducts() {

        getSelectedProducts();

        lstProducts = new List<ProductWrapper>();
        
        for (PricebookEntry pbe : (List<PricebookEntry>)con.getRecords()) {
            if(mapSelectedProduct.ContainsKey(pbe.id)) {
                lstProducts.add(new ProductWrapper(true, pbe));
            } else {
                lstProducts.add(new ProductWrapper(false, pbe));
            }
            
        }
        return lstProducts;
    }
    
    public void getSelectedProducts() {
        
        if(lstProducts != null) {
            for(ProductWrapper prd : lstProducts) {
                if(prd.isSelect) {
                    mapSelectedProduct.put(prd.product.Id, prd.product);
                } else {
                    mapSelectedProduct.remove(prd.product.Id);
                }
            }
        }
    }

    public void addProducts() {
        mapSelectedProduct = new Map<Id, PricebookEntry>();
        lstProducts = new List<ProductWrapper>();
    }

    public void addProductsToCart() {
        try {

            List<Product_Select__c> lstLineItemsToInsert = new List<Product_Select__c>();

            for(ProductWrapper pwp : lstProducts) {
                if(pwp.isSelect) {
                    Product_Select__c lineItem = convertPricebookEntryToQuoteLineItem(pwp);

                    if(!mapSelectedProduct.containskey(pwp.product.Id)) {
                        lstLineItemsToInsert.add(lineItem);
                    }   
                    
                }
            }

            for(PriceBookEntry pe : mapSelectedProduct.values()) {
                ProductWrapper objProductWrapper = new ProductWrapper(false, pe);
                Product_Select__c lineItem = convertPricebookEntryToQuoteLineItem(objProductWrapper);
                lstLineItemsToInsert.add(lineItem);
            }

            Integer totalLineItems = CartQueryHelper.getTotalLineItems(hidSubGroupId);
            
            for(Integer i=0; i<lstLineItemsToInsert.size(); i++) {
                Product_Select__c lineItem = lstLineItemsToInsert[i];
                lineItem.Product_Group__c = hidSubGroupId;
                lineItem.Row_Index__c = totalLineItems + i + 1;
                lineItem.Quantity__c = 1;
                lineItem.Quote__c = quote.Id;
            }

            insert lstLineItemsToInsert;

            lstGroups = prepareCartPage();

            mapSelectedProduct = new Map<Id, PricebookEntry>();
            lstProducts = new List<ProductWrapper>();

        } catch(Exception ex) {
            ApexPages.addMessages(ex);
        }
    }

    public void updateDescription() {

        quickSave();

        Product_Select__c lineItemToUpdate = lstGroups[hidGroupIndex].lstSubGroups[hidSubGroupIndex].lstQuoteLineItems[hidLineItemIndex];
        lineItemToUpdate.Descriptions__c = rickTextAreaValue.Descriptions__c;
        update lineItemToUpdate;

        lstGroups = prepareCartPage();
    }

    private void reOrderGroup(Integer groupIndex) {
        List<Product_Group__c> lstGroupsToReOrder = CartQueryHelper.getGroupsToReOrder(groupIndex);
        if(!lstGroupsToReOrder.isEmpty()) {
            for(Product_Group__c grp : lstGroupsToReOrder) {
                system.debug('grp=>'+grp);
                system.debug('grpIndex__c=>'+grp.Index__c);
                grp.Index__c = grp.Index__c - 1;
            }
    
            update lstGroupsToReOrder;
        }
    }

    private void reOrderSubGroup(Id groupId, Integer subGroupIndex) {
        List<Product_Group__c> lstSubGroupToReOrder = CartQueryHelper.getSubGroupsToReOrder(groupId, subGroupIndex);
        if(!lstSubGroupToReOrder.isEmpty()) {
            for(Product_Group__c subGroup : lstSubGroupToReOrder) {
                subGroup.Index__c = subGroup.Index__c - 1;
            }
    
            update lstSubGroupToReOrder;
        }
    }

    private void reOrderLineItem(Id subGroupId, Integer lineItemIndex) {
        List<Product_Select__c> lstLineItems = CartQueryHelper.getLineItemsToReOrder(subGroupId, lineItemIndex);
        if(!lstLineItems.isEmpty()) {
            for(Product_Select__c lineItem : lstLineItems) {
                lineItem.Row_Index__c = lineItem.Row_Index__c - 1;
            }
            
            update lstLineItems;
        }
    }

    public PageReference previewQuote() {
        PageReference pr = new PageReference('MarrsQuotePdf?Id='+quote.Id);
        return pr;
    }

    public Boolean hasNext {
        get {
            return con.getHasNext();
        }
        set;
    }
    
    public Boolean hasPrevious {
        get {
            return con.getHasPrevious();
        }
        set;
    }
    
    public Integer pageNumber {
        get {
            return con.getPageNumber();
        }
        set;
    }

    public Integer totalPageNumber {
        get {
            Decimal totalRecords = (Decimal)con.getResultSize();
            Decimal pageSize = (Decimal) PAGE_SIZE;
            Decimal dectotalPages = totalRecords.divide(pageSize, 2);
            Integer totalPages = (Integer)dectotalPages.round(System.RoundingMode.CEILING);
            return totalPages;
        }
        set;
    }
    
    public void first() {
         con.first();
     }
     
     public void last() {
         con.last();
     }
     
     public void previous() {
         con.previous();
     }
     
     public void next() {
         con.next();
     }

     public Product_Select__c convertPricebookEntryToQuoteLineItem(ProductWrapper pwp) {

        Product_Select__c lineItem = new Product_Select__c();
        lineItem.Product_Name__c = pwp.product.Product2.Name;
        lineItem.Product_Code__c = pwp.product.Product2.ProductCode;
        lineItem.List_Price__c = pwp.product.UnitPrice;
        lineItem.Descriptions__c = pwp.product.Product2.Product_Description__c;
        lineItem.Family__c = pwp.product.Product2.Family;
        lineItem.LBS__c = pwp.product.Product2.Weight__c;
        lineItem.Manufacturer__c = pwp.product.Product2.Manufacturer__c;
        lineItem.Product_Type__c = pwp.product.Product2.Product_Type__c;
        lineItem.Sale_Type__c = 'B/R';
        lineItem.ProductId__c = pwp.product.Product2.Id;
        
        //assign GLCode Values
        GLCode_System_Properties__c GLCodeDetails = GLCode_System_Properties__c.getValues(quote.RecordType.Name);
        if(GLCodeDetails != null) {
            lineItem.Revenue_GL__c = GLCodeDetails.Revenue_GL_AccountId__c;
            lineItem.Expense_GL__c = GLCodeDetails.Expense_GL_AccountId__c;
            lineItem.Inventory_GL__c = GLCodeDetails.Inventory_GL_AccountId__c;
        }

        return lineItem;
        
    }
}