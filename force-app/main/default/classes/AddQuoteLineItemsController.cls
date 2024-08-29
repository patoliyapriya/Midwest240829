public with sharing class AddQuoteLineItemsController{
    public Product_Select__c rickTextAreaValue{get;set;}
    public Final Integer PAGE_SIZE = 20;
    public static GLCode_System_Properties__c GLCodeDetails = new GLCode_System_Properties__c();

    public String searchProduct{get;set;}
    
    public List<ProductWrapperClass> products;
    public List<ProductGroupWrapperClass> lstProductGroupWrapperClass{get;set;}
    Map <id,PricebookEntry> selectedProductMap{get;set;}
    
    public Boolean isSelectedProductShow{get;set;}
    
    public Integer hidGroupIndex{get;set;}
    public Integer hidSubGroupIndex{get;set;}
    public Integer hidProductRowIndex{get;set;}
    
    public Integer hidGroupIndexMoveLineItem{get;set;}
    public Integer hidSubGroupIndexMoveLineItem{get;set;}
    public String hidMoveSubGroupId{get;set;}
        
    public Id quoteId{get;set;}
    public Quote quote{get;set;}
    public List<Addition_Deduction__c> lstAdditionDuduction{get;set;}
    
    public Product2 newProduct{get;set;}
    public decimal stadardPrice{get;set;}
    public Project__c project{get;set;}
    
    public Boolean isActiveFinancialQuote{get;set;}

    public List<ProductWrapperClass> lstScratchPad{get;set;}
    
    public AddQuoteLineItemsController(ApexPages.StandardController controller) {
        quoteId = controller.getId();
        Init();
    }
    
    public AddQuoteLineItemsController(){
        quoteId = Apexpages.currentPage().getParameters().get('Id');
        Init();
    }
    
        
    public void Init(){
        
        quote = [Select Id, Hide_Price_Per__c,Total_Extended_Cost__c, Total_Base_Bid_Total__c,QuoteNumber,Name,Hide_Total_Extended_Cost__c,Hide_Total_Base_Bid_Total__c,
                Hide_All_Tags__c,Hide_All_Product_Code__c,Commissions_and_Rebates__c,Total_Buy_Resell_Margin__c,Total_Buy_Resell_Margin_Percentage__c,Total_Project_Margin__c,Total_Project_Margin_Percentage__c,
                Total_Direct_Sell_Price__c,Total_Buy_Resell_Price__c,Total_Buy_Resell_Extended_Cost__c,Quantity_Total__c,Opportunity.Active_Financial_Quote__c,
                Opportunity.Sync_Quote__c,RecordType.Name, Opportunity.Office__c,commisionCustomer__c
                FROM Quote
                WHERE Id =: quoteId];
        //fethc GL code From Custom setting
        GLCodeDetails = GLCode_System_Properties__c.getValues(quote.RecordType.Name);
        System.debug('GLCodeDetails=>'+GLCodeDetails);
        isActiveFinancialQuote = isActiveFinancialQuote();

        List<Project__c> lstProjects = [Select Id From Project__c
                                        WHERE Quote__c =: quote.Opportunity.Sync_Quote__c
                                        AND Quote__c != null];
        
        if(!lstProjects.isEmpty()){
            project = lstProjects[0];
        }
        
        if(quote.Commissions_and_Rebates__c == null){
            quote.Commissions_and_Rebates__c = 0;
        }
        
        lstProductGroupWrapperClass = new List<ProductGroupWrapperClass>();
        isSelectedProductShow = true;
        
        rickTextAreaValue = new Product_Select__c();
        newProduct = new Product2();
        lstAdditionDuduction = new List<Addition_Deduction__c>();
        lstScratchPad = new List<ProductWrapperClass>();
        selectedProductMap = new Map<Id, PricebookEntry>();
        
        //Boolean isEdit = isEditScreen();
        
        BuildProductGroupWrapperClass();
        FillAdditionDeductionList();
        
    }
    
    public void FillAdditionDeductionList(){
        lstAdditionDuduction = [Select Id,Amount__c,Quote__c,Type__c,Details__c
                                FROM Addition_Deduction__c
                                WHERE Quote__c =: quoteId];
        
    }
    
    public void addAdditionDeductionLineItem(){
        Addition_Deduction__c newAdditionDeduction = new Addition_Deduction__c();
        newAdditionDeduction.Quote__c = quoteId;
        lstAdditionDuduction.add(newAdditionDeduction);
    }
    
    public void deleteAdditionDeduction(){
        if(lstAdditionDuduction[hidProductRowIndex].Id != null){
            delete lstAdditionDuduction[hidProductRowIndex];
        }
        lstAdditionDuduction.remove(hidProductRowIndex);
    }
    
    public void BuildProductGroupWrapperClass(){
        
        List<Product_Group__c> lstProductGroups = [Select Id,Name, Parent_Product_Group__r.Name, Parent_Product_Group__c,Total_Line_Items__c,Total_Sub_Groups__c,
                                                             Hide_Pricing__c,Total_Extended_Cost__c,Hide_Base_Bid_Total__c,Total_Group_Extended_Cost__c, Index__c,
                                                             Hide_Code__c, Hide_Amount__c, Hide_Line__c,Quantity_Total__c,Grand_Quantity_Total__c,Hide_Quantity__c,Release_Number__c,
                                                             Total_Freight__c,Total_Group_Freight__c,Page_Break__c,Alternate__c, 
                                                            (SELECT Descriptions__c,Family__c,Freight__c,List_Price__c,
                                                                Margin_Percentage__c,Multiplier__c,Original_Product_Name__c,
                                                                Product_Code__c,Product_Group__c,Product_Name__c,
                                                                Quantity__c,Quote__c,Sales_Price__c,Total_Price__c,T_LBS__c,LBS__c,Tag__c,Extended_Cost__c,                                                               
                                                                Hide_Pricing__c,Hide_Line__c,Unit_Cost__c,Hide_Code__c,Row_Index__c,Page_Break__c,Alternate__c,
                                                                Is_Freight_Override__c,Release_pick__c, Sale_Type__c,CR__c,Hide_Quantity__c, Manufacturer__c,Is_SalePrice_Override__c, Product_Type__c, 

                                                                ProductId__c,
                                                                Expense_GL__c,
                                                                Inventory_GL__c,
                                                                Revenue_GL__c
                                                                FROM Quote_Line_Items__r
                                                                ORDER BY Row_Index__c ASC)
                                                            From Product_Group__c 
                                                            WHERE Quote__c =: quoteId
                                                            AND Parent_Product_Group__c != null
                                                            ORDER BY Parent_Product_Group__c,Index__c ASC];    
        
        Set<Id> setParentGroupIds = new Set<Id>();
        
        for(Product_Group__c pg : lstProductGroups){
            if(pg.Parent_Product_Group__c != null){
                setParentGroupIds.add(pg.Parent_Product_Group__c);
            }
        }
        
        List<Product_Group__c> lstParentProductGroups = [Select Id,Name,Total_Line_Items__c,Total_Sub_Groups__c,Hide_Pricing__c,Total_Extended_Cost__c,
                                                        Hide_Base_Bid_Total__c,Total_Group_Extended_Cost__c,Index__c,Grand_Quantity_Total__c,Total_Group_Freight__c,
                                                        Page_Break__c,Alternate__c   
                                                        FROM Product_Group__c
                                                        WHERE Id IN :setParentGroupIds];
        
        Map<Id,Product_Group__c> mapProductGroup = new Map<Id,Product_Group__c>();
        
        for(Product_Group__c pg : lstParentProductGroups){
            mapProductGroup.put(pg.Id, pg);
        }
        
        Id parentGroup = null;
        
        ProductGroupWrapperClass objProductGroupWrapperClass;
        Map<Id,ProductGroupWrapperClass> mapParentGroupIdWrapper = new Map<Id,ProductGroupWrapperClass>();
        
        for(Product_Group__c pg : lstProductGroups){
            
            if(parentGroup == null){
                parentGroup = pg.Parent_Product_Group__c;
            }
            
            if(parentGroup != pg.Parent_Product_Group__c && parentGroup != null){
            
                lstProductGroupWrapperClass.add(objProductGroupWrapperClass);
                objProductGroupWrapperClass = new ProductGroupWrapperClass(mapProductGroup.get(pg.Parent_Product_Group__c));
                
                parentGroup = pg.Parent_Product_Group__c;
                
            }
            
            ProductSubGroupWrapperClass objProductSubGroupWrapperClass = new ProductSubGroupWrapperClass(pg);
            
            for(Product_Select__c ql : pg.Quote_Line_Items__r){
                ProductWrapperClass objProductWrapperClass = new ProductWrapperClass(ql);
                objProductSubGroupWrapperClass.lstProductSelected.add(objProductWrapperClass);
            }
            if(mapParentGroupIdWrapper.get(pg.Parent_Product_Group__c) != null){
                objProductGroupWrapperClass = mapParentGroupIdWrapper.get(pg.Parent_Product_Group__c);
            }
            else{
                objProductGroupWrapperClass = new ProductGroupWrapperClass(mapProductGroup.get(pg.Parent_Product_Group__c));
                mapParentGroupIdWrapper.put(pg.Parent_Product_Group__c,objProductGroupWrapperClass);
            }
            if(objProductSubGroupWrapperClass.productGroup.Name == 'Please Enter Sub Group Name'){
                objProductGroupWrapperClass.isSubGroupingEnable = false;
            }
            else{
                objProductGroupWrapperClass.isSubGroupingEnable = true;
            }
            objProductGroupWrapperClass.lstProductSubGroup.add(objProductSubGroupWrapperClass);    
            
            
        }

        if(lstProductGroups.size() == 0) {
            objProductGroupWrapperClass = new ProductGroupWrapperClass();
            ProductSubGroupWrapperClass objProductSubGroupWrapperClass = new ProductSubGroupWrapperClass();
            ProductWrapperClass objProductWrapper = addDefaultFreightProduct();
            if (objProductWrapper != null) { 
                objProductSubGroupWrapperClass.lstProductSelected.add(objProductWrapper);
            }
            objProductGroupWrapperClass.lstProductSubGroup.add(objProductSubGroupWrapperClass);
        }   
        
        lstProductGroupWrapperClass.add(objProductGroupWrapperClass);
        
    }
    /*
    public Boolean isEditScreen(){
        Boolean isEdit = false;
        
        Integer numberOfLineItems = [Select count() From Product_Select__c where Quote__c =: quoteId];
        
        if(numberOfLineItems > 0){
            isEdit = true;
        }
        
        return isEdit;
    }
    */
    public ApexPages.StandardSetController con {
        get {
            if(con == null) {

                con = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id,Product2.Name,Product2.ProductCode, Product2.Family,UnitPrice,Product2.Product_Description__c,Product2.Weight__c,Product2.Description,
                                                                                     Product2.Manufacturer__c, 
                                                                                    Product2.Product_Type__c 
                                                                                    FROM PricebookEntry 
                                                                                    WHERE Pricebook2.IsStandard = true 
                                                                                    AND Product2.Midwest_Group_Office__c INCLUDES (:quote.Opportunity.Office__c)
                                                                                    ORDER BY Product2.Name asc
                                                                                    LIMIT 10000]));
                con.setPageSize(PAGE_SIZE);
            }
            return con;
        }
        set;
    }
    
    public List<ProductWrapperClass> getProducts() {
        
        getSelectedProducts();
        
        products = new List<ProductWrapperClass>();
        for (PricebookEntry pbe : (List<PricebookEntry>)con.getRecords()){
            if(selectedProductMap.ContainsKey(pbe.id)){
                products.add(new productWrapperClass(pbe,true));
            }
            else{
                products.add(new productWrapperClass(pbe,false));
            }
            
        }
        return products;
    }
    
    public void getSelectedProducts(){
        
        if(products != null){
        
            for(ProductWrapperClass prd : products){
                if(prd.isSelect){
                    selectedProductMap.put(prd.product.Id, prd.product);
                }
                else{
                    selectedProductMap.remove(prd.product.Id);
                }
            }
            
        }
        
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
    
    public void selectProducts(){
    
        if(lstProductGroupWrapperClass.isEmpty()){
        
            ProductSubGroupWrapperClass objProductSubGroupWrapperClass = new ProductSubGroupWrapperClass();
            
            for(ProductWrapperClass pwp : products){
            
                if(pwp.isSelect){        
                    objProductSubGroupWrapperClass.lstProductSelected.add(convertPricebookEntryToProductDetails(pwp));
                }
                
            }
            
            ProductGroupWrapperClass objProductGroupWrapperClass = new ProductGroupWrapperClass();
            objProductGroupWrapperClass.lstProductSubGroup.add(objProductSubGroupWrapperClass);
            lstProductGroupWrapperClass.add(objProductGroupWrapperClass);
        }
        else{
            for(ProductWrapperClass pwp : products){
                if(pwp.isSelect){
                    if(hidGroupIndex != -1 && hidSubGroupIndex != -1){
                        if(!selectedProductMap.containskey(pwp.product.Id)){
                            lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].lstProductSelected.add(convertPricebookEntryToProductDetails(pwp));
                            pwp.isSelect = false;
                        }
                    }
                    else{
                        lstScratchPad.add(convertPricebookEntryToProductDetails(pwp));
                    }        
                    
                }
            }
            
            for(PriceBookEntry pe : selectedProductMap.values()){
                lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].lstProductSelected.add(new ProductWrapperClass(pe));
            }
            
        }
        isSelectedProductShow = true;
        selectedProductMap = new Map<Id,PricebookEntry>();
        products = new List<ProductWrapperClass>();
    }   
    
    public ProductWrapperClass convertPricebookEntryToProductDetails(ProductWrapperClass pwp){
        GLCodeDetails = GLCode_System_Properties__c.getValues(quote.RecordType.Name);
        pwp.productDetails = new Product_Select__c();
        pwp.productDetails.Product_Name__c = pwp.product.Product2.Name;
        pwp.productDetails.Product_Code__c = pwp.product.Product2.ProductCode;
        pwp.productDetails.List_Price__c = pwp.product.UnitPrice;
        pwp.productDetails.Descriptions__c = pwp.product.Product2.Product_Description__c;
        pwp.productDetails.Family__c = pwp.product.Product2.Family;
        pwp.productDetails.LBS__c = pwp.product.Product2.Weight__c;
        pwp.productDetails.Manufacturer__c = pwp.product.Product2.Manufacturer__c;
        pwp.productDetails.Product_Type__c = pwp.product.Product2.Product_Type__c;
        pwp.productDetails.Sale_Type__c = 'B/R';
        pwp.productDetails.ProductId__c = pwp.product.Product2.Id;
        // assign GLCode Values
        if(GLCodeDetails != null) {
            pwp.productDetails.Revenue_GL__c = GLCodeDetails.Revenue_GL_AccountId__c;
            pwp.productDetails.Expense_GL__c = GLCodeDetails.Expense_GL_AccountId__c;
            pwp.productDetails.Inventory_GL__c = GLCodeDetails.Inventory_GL_AccountId__c;
        }
        
        return pwp;
    }
    
    public PageReference Save(){
        
        quickSave();
        return backToQuote();
        
    }
    
    public void quickSave(){
    
        List<Product_Group__c> lstProductGroupToInsert = new List<Product_Group__c>();
        List<Product_Select__c> lstQuoteLineItems = new List<Product_Select__c>();
        
        Integer count = 0;
        List<Product_Group__c > lstParentGroup = new List<Product_Group__c >();
        List<Product_Group__c > lstChildGroup = new List<Product_Group__c >();
        
        Integer parentGroupIndex = 1;
        
        for(ProductGroupWrapperClass pg : lstProductGroupWrapperClass){
      
            Product_Group__c objProductGroup = pg.productGroup;
            objProductGroup.Quote__c = quoteId;
            objProductGroup.External_Id__c = generateExternalId();
            objProductGroup.Index__c = parentGroupIndex;
            objProductGroup.Unique_Index__c = String.valueOf(parentGroupIndex);
            lstParentGroup.add(objProductGroup);
            parentGroupIndex++;
            
            Integer subGroupIndex = 1;
            
            for(ProductSubGroupWrapperClass psg : pg.lstProductSubGroup ){
            
                Product_Group__c objProductSubGroup = psg.productGroup;
                system.debug('###'+psg.productGroup.Total_Line_Items__c);
                objProductSubGroup.Quote__c = quoteId;
                objProductSubGroup.External_Id__c = generateExternalId();
                objProductSubGroup.Index__c = subGroupIndex;
                objProductSubGroup.Unique_Index__c = String.valueOf(parentGroupIndex) + String.valueOf(subGroupIndex);
                subGroupIndex++;
                if(objProductSubGroup.Parent_Product_Group__c == null){
                    objProductSubGroup.Parent_Product_Group__r = new Product_Group__c(External_Id__c = objProductGroup.External_Id__c);
                }
                
                Integer i=1;
                Boolean isHidePriceColumn = true;
                String commisionCustomer = quote.commisionCustomer__c != null ? quote.commisionCustomer__c : '';
                
                for(ProductWrapperClass pw : psg.lstProductSelected){
                    Product_Select__c objQuoteLineItem = pw.productDetails;
                    objQuoteLineItem.Unique_Index__c = String.valueOf(parentGroupIndex) + String.valueOf(subGroupIndex) + String.valueOf(i);
                    objQuoteLineItem.Row_Index__c = i;
                    i++;
                    
                    objQuoteLineItem.Quote__c = quoteId;
                    if(objQuoteLineItem.Product_Group__c == null){
                        objQuoteLineItem.Product_Group__r = new Product_Group__c(External_Id__c = objProductSubGroup.External_Id__c);
                    }
                    
                    if(!pw.productDetails.Hide_Pricing__c){
                        isHidePriceColumn = false;
                    }
                    if (objQuoteLineItem.Sale_Type__c == 'C/R' 
                            && objQuoteLineItem.Manufacturer__c != null
                            && !commisionCustomer.contains(objQuoteLineItem.Manufacturer__c)) {
                        if(commisionCustomer.length() > 0) {
                            commisionCustomer += ',';
                        }
                        commisionCustomer +=  objQuoteLineItem.Manufacturer__c;
                    }

                    lstQuoteLineItems.add(objQuoteLineItem);
                }
                quote.commisionCustomer__c = commisionCustomer;
                
                objProductSubGroup.Hide_Price_Column__c = isHidePriceColumn;
                lstChildGroup.add(objProductSubGroup);
            }
            
        }
        
        try{
        
            upsert lstParentGroup;
            upsert lstChildGroup;
            upsert lstQuoteLineItems;
            update quote;
            
            autoSyncBackToOpportunity();
            
            if(lstAdditionDuduction.size() > 0){
                upsert lstAdditionDuduction;
            }
            
        }
        catch(exception ex){
            ApexPages.addMessages(ex);
        }
        
    }
    
    public void autoSyncBackToOpportunity(){
        List<Opportunity> lstOpportunity = [Select Id,Total_Base_Bid_Total_Quote__c,Total_Extended_Cost_Quote__c,Total_Project_Margin__c
                                                From Opportunity
                                                WHERE Sync_Quote__c =: quote.Id];
            
        for(Opportunity opp : lstOpportunity){
            opp.Total_Base_Bid_Total_Quote__c = quote.Total_Base_Bid_Total__c;
            opp.Total_Extended_Cost_Quote__c = quote.Total_Extended_Cost__c;
            opp.Total_Project_Margin__c = quote.Total_Project_Margin__c;
        }
        
        if(!lstOpportunity.isEmpty()){
            update lstOpportunity;
        }
    }
    
    public String generateExternalId(){
        String hashString = Math.round(Math.random()*1000) + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        String hexDigest = EncodingUtil.convertToHex(hash);
        return hexDigest;
    }
        
    public void addProduct(){
        isSelectedProductShow = false;
        selectedProductMap = new Map<Id,PricebookEntry>();
        products = new List<ProductWrapperClass>();
    }
    /* add Custom product to Group/SubGroup Logic...
    public void addCustomProduct(){
        if(hidGroupIndex == -1){
            hidGroupIndex = 0;
        }
        if(hidSubGroupIndex == -1){
            hidSubGroupIndex = 0;
        }
        lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].lstProductSelected.add(new ProductWrapperClass());
    }
    */    
    
    public void addCustomProduct(){
        lstScratchPad.add(new ProductWrapperClass());
    }
    
    public void deleteScratchPadProductRow(){
        lstScratchPad.remove(hidProductRowIndex);
    }
    
    public void cloneGroup(){
        
        List<ProductSubGroupWrapperClass> lstProductSubGroupWrapperClass = new List<ProductSubGroupWrapperClass>();
        
        for(ProductSubGroupWrapperClass psg : lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup){
            ProductSubGroupWrapperClass objProductSubGroupWrapperClass  = new ProductSubGroupWrapperClass();
            objProductSubGroupWrapperClass.productGroup.Name = psg.productGroup.Name;
            objProductSubGroupWrapperClass.productGroup.Hide_Pricing__c = psg.productGroup.Hide_Pricing__c;
            objProductSubGroupWrapperClass.productGroup.Total_Extended_Cost__c = psg.productGroup.Total_Extended_Cost__c ;
            objProductSubGroupWrapperClass.productGroup.Total_Line_Items__c = psg.productGroup.Total_Line_Items__c;
            objProductSubGroupWrapperClass.productGroup.Hide_Amount__c = psg.productGroup.Hide_Amount__c;
            objProductSubGroupWrapperClass.productGroup.Hide_Code__c = psg.productGroup.Hide_Code__c;
            objProductSubGroupWrapperClass.productGroup.Hide_Line__c = psg.productGroup.Hide_Line__c;
            objProductSubGroupWrapperClass.productGroup.Quantity_Total__c = psg.productGroup.Quantity_Total__c;
            //objProductSubGroupWrapperClass.productGroup.Total_Group_Freight__c = psg.productGroup.Total_Group_Freight__c;
            objProductSubGroupWrapperClass.productGroup.Page_Break__c = psg.productGroup.Page_Break__c;
            objProductSubGroupWrapperClass.productGroup.Alternate__c = psg.productGroup.Alternate__c;
            
            for(ProductWrapperClass pw : psg.lstProductSelected){
                ProductWrapperClass objProductWrapper = new ProductWrapperClass(pw.productDetails,true);
                objProductSubGroupWrapperClass.lstProductSelected.add(objProductWrapper);
            }
            lstProductSubGroupWrapperClass.add(objProductSubGroupWrapperClass);
        }
        
        ProductGroupWrapperClass objProductGroupWrapperClass = new ProductGroupWrapperClass();
        objProductGroupWrapperClass.productGroup.Name = lstProductGroupWrapperClass[hidGroupIndex].productGroup.Name;
        objProductGroupWrapperClass.productGroup.Hide_Pricing__c = lstProductGroupWrapperClass[hidGroupIndex].productGroup.Hide_Pricing__c;
        objProductGroupWrapperClass.productGroup.Grand_Quantity_Total__c = lstProductGroupWrapperClass[hidGroupIndex].productGroup.Grand_Quantity_Total__c;
        objProductGroupWrapperClass.productGroup.Total_Group_Extended_Cost__c = lstProductGroupWrapperClass[hidGroupIndex].productGroup.Total_Group_Extended_Cost__c;
        objProductGroupWrapperClass.productGroup.Total_Sub_Groups__c = lstProductGroupWrapperClass[hidGroupIndex].productGroup.Total_Sub_Groups__c;
        //objProductGroupWrapperClass.productGroup.Total_Group_Freight__c = lstProductGroupWrapperClass[hidGroupIndex].productGroup.Total_Group_Freight__c;
        
        objProductGroupWrapperClass.isSubGroupingEnable = lstProductGroupWrapperClass[hidGroupIndex].isSubGroupingEnable;
        objProductGroupWrapperClass.lstProductSubGroup.addAll(lstProductSubGroupWrapperClass);
        lstProductGroupWrapperClass.add(objProductGroupWrapperClass);
    }
    /*
    public void deleteGroup(){
        if(lstProductGroupWrapperClass[hidGroupIndex].productGroup.Id != null){
            delete lstProductGroupWrapperClass[hidGroupIndex].productGroup;
        }
        lstProductGroupWrapperClass.remove(hidGroupIndex);
    }
    */
    public void newGroup(){
        ProductGroupWrapperClass objProductGroupWrapperClass = new ProductGroupWrapperClass();
        
        ProductSubGroupWrapperClass objProductSubGroupWrapperClass  = new ProductSubGroupWrapperClass();
        objProductGroupWrapperClass.lstProductSubGroup.add(objProductSubGroupWrapperClass);
        
        objProductGroupWrapperClass.isSubGroupingEnable = true;
        lstProductGroupWrapperClass.add(objProductGroupWrapperClass);
    }
    
    public void createSubGroup(){
        if(hidGroupIndex == -1){
            hidGroupIndex = 0;
        }
        if(hidSubGroupIndex == -1){
            hidSubGroupIndex = 0;
        }
        lstProductGroupWrapperClass[hidGroupIndex].isSubGroupingEnable = true;
    }
    
    public void cloneSubGroup(){
        ProductSubGroupWrapperClass objProductSubGroupWrapperClass = new ProductSubGroupWrapperClass();
        objProductSubGroupWrapperClass.productGroup.Name = lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].productGroup.Name;
        objProductSubGroupWrapperClass.productGroup.Hide_Pricing__c = lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].productGroup.Hide_Pricing__c;
        objProductSubGroupWrapperClass.productGroup.Total_Extended_Cost__c = lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].productGroup.Total_Extended_Cost__c;
        objProductSubGroupWrapperClass.productGroup.Total_Line_Items__c = lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].productGroup.Total_Line_Items__c;
        objProductSubGroupWrapperClass.productGroup.Hide_Amount__c = lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].productGroup.Hide_Amount__c;
        objProductSubGroupWrapperClass.productGroup.Hide_Code__c = lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].productGroup.Hide_Code__c;
        objProductSubGroupWrapperClass.productGroup.Hide_Line__c = lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].productGroup.Hide_Line__c;
        objProductSubGroupWrapperClass.productGroup.Quantity_Total__c = lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].productGroup.Quantity_Total__c;
        //objProductSubGroupWrapperClass.productGroup.Total_Freight__c = lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].productGroup.Total_Freight__c;
        objProductSubGroupWrapperClass.productGroup.Hide_Quantity__c = lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].productGroup.Hide_Quantity__c;
        objProductSubGroupWrapperClass.productGroup.Release_Number__c = lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].productGroup.Release_Number__c;
        objProductSubGroupWrapperClass.productGroup.Page_Break__c = lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].productGroup.Page_Break__c;
        objProductSubGroupWrapperClass.productGroup.Alternate__c = lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].productGroup.Alternate__c;

        for(ProductWrapperClass pw : lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].lstProductSelected){
            ProductWrapperClass objProductWrapper = new ProductWrapperClass(pw.productDetails,true);
            objProductSubGroupWrapperClass.lstProductSelected.add(objProductWrapper);
        }
        
        lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup.add(objProductSubGroupWrapperClass);
    }
    
    public void newSubGroup(){
        ProductSubGroupWrapperClass objProductSubGroupWrapperClass = new ProductSubGroupWrapperClass();
        objProductSubGroupWrapperClass.productGroup.Alternate__c = lstProductGroupWrapperClass[hidGroupIndex].productGroup.Alternate__c;
        ProductWrapperClass objProductWrapper = addDefaultFreightProduct();
        if (objProductWrapper != null) { 
            objProductSubGroupWrapperClass.lstProductSelected.add(objProductWrapper);
        }
        lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup.add(objProductSubGroupWrapperClass);
        
        
    }

    public ProductWrapperClass addDefaultFreightProduct() {

        List<PricebookEntry> lstPricebookEntry = [SELECT Id, Product2.Name, Product2.ProductCode, Product2.Family, UnitPrice, Product2.Product_Description__c, Product2.Weight__c, Product2.Description,
                                                        Product2.Manufacturer__c, 
                                                    Product2.Product_Type__c 
                                                    FROM PricebookEntry 
                                                    WHERE Pricebook2.IsStandard = true
                                                    AND Product2.Name = 'Freight'
                                                    AND Product2.Midwest_Group_Office__c INCLUDES (:quote.Opportunity.Office__c)
                                                    ORDER BY Product2.Name asc];

        if (!lstPricebookEntry.isEmpty()) {
            ProductWrapperClass objProductWrapper = new ProductWrapperClass(lstPricebookEntry[0]);
            objProductWrapper.productDetails.Sale_Type__c = 'B/R';
            return objProductWrapper;
        }
        
        return null;
    }
  
    /*
    public void deleteSubGroup(){
        if(lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].productGroup.Id != null){
            delete lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].productGroup;
        }
        lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup.remove(hidSubGroupIndex);
    }
    */
    public void deleteProductRow(){
        if(lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].lstProductSelected[hidProductRowIndex].productDetails.Id != null){
            delete lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].lstProductSelected[hidProductRowIndex].productDetails;
        }
        lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].lstProductSelected.remove(hidProductRowIndex);
    }
    
    public void cloneProductRow(){
        
        Product_Select__c selectedProduct = lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].lstProductSelected[hidProductRowIndex].productDetails;
        
        ProductWrapperClass objProductWrapper = new ProductWrapperClass(selectedProduct,true);
        lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].lstProductSelected.add(objProductWrapper);
        
    }
    
    public void deleteGroup(){
        if(lstProductGroupWrapperClass[hidGroupIndex].productGroup.Id != null){
            deleteAllSubGroup(hidGroupIndex,lstProductGroupWrapperClass[hidGroupIndex].productGroup);
        }
        lstProductGroupWrapperClass.remove(hidGroupIndex);
    }
    
    
    public void deleteSubGroup(){
        List<Product_Select__c> lstProductSelect = new List<Product_Select__c>();
        
        if(lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].productGroup.Id != null){
        
            for(Integer j=0;j<lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].lstProductSelected.size();j++){
                if(lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].lstProductSelected[j].productDetails.Id != null){
                    lstProductSelect.add(lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].lstProductSelected[j].productDetails);
                }
                else{
                    lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].lstProductSelected.remove(j);
                }
                
            }
            
            if(lstProductSelect.size() > 0){
                delete lstProductSelect;
            }
            
            delete lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].productGroup;
            
        }
        lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup.remove(hidSubGroupIndex);
    }
    
    
    
    public void deleteAllSubGroup(Integer GroupIndex, Product_Group__c pg){
        
        List<Product_Group__c> lstDeleteSubGroups = new List<Product_Group__c>();
        lstDeleteSubGroups.add(pg);
        
        List<Product_Select__c> lstProductSelect = new List<Product_Select__c>();
        
        for(Integer i=0;i<lstProductGroupWrapperClass[GroupIndex].lstProductSubGroup.size();i++){
            if(lstProductGroupWrapperClass[GroupIndex].lstProductSubGroup[i].productGroup.Id != null){
                lstDeleteSubGroups.add(lstProductGroupWrapperClass[GroupIndex].lstProductSubGroup[i].productGroup);
                
                for(Integer j=0;j<lstProductGroupWrapperClass[GroupIndex].lstProductSubGroup[i].lstProductSelected.size();j++){
                    if(lstProductGroupWrapperClass[GroupIndex].lstProductSubGroup[i].lstProductSelected[j].productDetails.Id != null){
                        lstProductSelect.add(lstProductGroupWrapperClass[GroupIndex].lstProductSubGroup[i].lstProductSelected[j].productDetails);
                    }
                    else{
                        lstProductGroupWrapperClass[GroupIndex].lstProductSubGroup[i].lstProductSelected.remove(j);
                    }
                }
            }
            else{
                lstProductGroupWrapperClass[GroupIndex].lstProductSubGroup.remove(i);
            }
            
        }
        
        if(lstDeleteSubGroups.size() > 0){
            delete lstDeleteSubGroups;
        }
        
        if(lstProductSelect.size() > 0){
            delete lstProductSelect;
        }
        
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
         
    public PageReference backToQuote(){
        PageReference pr = new PageReference('/'+quoteId);
        pr.setRedirect(true);
        return pr;
    }
    
    public Boolean isActiveFinancialQuote() {
        List<Opportunity> lstActiveFinancialQuoteOpp = [Select Id From Opportunity Where Active_Financial_Quote__c =:quoteId];
        if(lstActiveFinancialQuoteOpp.size() > 0) {
            return true;
        }
        return false;
    }

    public void backToCart(){
        isSelectedProductShow = true;
    }
    
    public void insertNewProduct(){
        if(newProduct.Product_Description__c == null) {
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter Account number'));
           
        } 
       Pricebook2 pb = [  SELECT id
                  FROM Pricebook2
                  WHERE isStandard=true
                  LIMIT 1
               ];
               
       insert newProduct;
             
       PricebookEntry pbe = new PricebookEntry();
       pbe.Pricebook2Id = pb.Id;
       pbe.IsActive = true;
       pbe.Product2Id = newProduct.Id;
       pbe.UnitPrice =  stadardPrice;
       insert pbe; 
       
       newProduct = new Product2();
       
    }
    
    public void saveDescription(){
        lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].lstProductSelected[hidProductRowIndex].productDetails.Descriptions__c = rickTextAreaValue.Descriptions__c;
    }
    
    public void upProductLineItem(){
        
        ProductWrapperClass tempProduct = lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].lstProductSelected[hidProductRowIndex];
        ProductWrapperClass swapProduct = lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].lstProductSelected[hidProductRowIndex-1];
        
        lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].lstProductSelected.set(hidProductRowIndex,swapProduct);
        lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].lstProductSelected.set(hidProductRowIndex-1,tempProduct);
        
    }
    
    public void downProductLineItem(){
        
        ProductWrapperClass tempProduct = lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].lstProductSelected[hidProductRowIndex];
        ProductWrapperClass swapProduct = lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].lstProductSelected[hidProductRowIndex + 1];
        
        lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].lstProductSelected.set(hidProductRowIndex,swapProduct);
        lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].lstProductSelected.set(hidProductRowIndex + 1,tempProduct);
        
    }
    
    public void upSubGroup(){
        
        ProductSubGroupWrapperClass tempSubGroup = lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex];
        ProductSubGroupWrapperClass swapSubGroup = lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex-1];
        
        lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup.set(hidSubGroupIndex,swapSubGroup);
        lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup.set(hidSubGroupIndex-1,tempSubGroup);
        
    }
    
    public void downSubGroup(){
        
        ProductSubGroupWrapperClass tempSubGroup = lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex];
        ProductSubGroupWrapperClass swapSubGroup = lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex + 1];
        
        lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup.set(hidSubGroupIndex,swapSubGroup);
        lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup.set(hidSubGroupIndex+1,tempSubGroup);
        
    }
    
    public PageReference backToProject(){
        PageReference pr = new PageReference('/'+project.Id);
        pr.setRedirect(true);
        return pr;
    }
    
    public void moveSelectedLineItemToSubGroup(){
        //Product_Select__c updateProductDetails = lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].lstProductSelected[hidProductRowIndex].productDetails;
        //updateProductDetails.Product_Group__c  = hidMoveSubGroupId;
        //update updateProductDetails;
        
        system.debug('hidGroupIndex---'+hidGroupIndex);
        system.debug('hidSubGroupIndex---'+hidSubGroupIndex);
        system.debug('hidProductRowIndex---'+hidProductRowIndex);
        system.debug('hidGroupIndexMoveLineItem---'+hidGroupIndexMoveLineItem);
        system.debug('hidSubGroupIndexMoveLineItem-----'+hidSubGroupIndexMoveLineItem);
        system.debug('hidMoveSubGroupId-----'+hidMoveSubGroupId);
        
        ProductWrapperClass toMoveProductLineItem = lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].lstProductSelected[hidProductRowIndex];
        
        lstProductGroupWrapperClass[hidGroupIndex].lstProductSubGroup[hidSubGroupIndex].lstProductSelected.remove(hidProductRowIndex);
        
        String id = String.escapeSingleQuotes(hidMoveSubGroupId);
        if((id.length() == 15 || id.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', id)) {
            toMoveProductLineItem.productDetails.Product_Group__r = null;
            toMoveProductLineItem.productDetails.Product_Group__c = hidMoveSubGroupId;
        }
        
        update toMoveProductLineItem.productDetails;
        
        if(lstProductGroupWrapperClass[hidGroupIndexMoveLineItem].lstProductSubGroup[hidSubGroupIndexMoveLineItem].lstProductSelected == null){
            system.debug('yes--');
            lstProductGroupWrapperClass[hidGroupIndexMoveLineItem].lstProductSubGroup[hidSubGroupIndexMoveLineItem].lstProductSelected = new List<ProductWrapperClass >();
        }
        lstProductGroupWrapperClass[hidGroupIndexMoveLineItem].lstProductSubGroup[hidSubGroupIndexMoveLineItem].lstProductSelected.add(toMoveProductLineItem);
        
    }
    
    public class ProductWrapperClass{
        
        public Boolean isSelect{get;set;}
        public Product_Select__c productDetails{get;set;}
        public PricebookEntry product{get;set;}
        
        public ProductWrapperClass(PricebookEntry pbe, Boolean isSelect){
            this.isSelect = isSelect;
            this.product = pbe;
        }
        
        
        public ProductWrapperClass(PricebookEntry pbe){
            
            isSelect = false;
            productDetails = new Product_Select__c();
            productDetails.Product_Name__c = pbe.Product2.Name;
            productDetails.Product_Code__c = pbe.Product2.ProductCode;
            productDetails.List_Price__c = pbe.UnitPrice;
            productDetails.Descriptions__c = pbe.Product2.Product_Description__c;
            productDetails.Family__c = pbe.Product2.Family;
            productDetails.LBS__c = pbe.Product2.Weight__c;
            productDetails.Manufacturer__c = pbe.Product2.Manufacturer__c;
            productDetails.Product_Type__c = pbe.Product2.Product_Type__c;
            productDetails.ProductId__c = pbe.Product2.Id;
            // assign GLCode Values
            if(GLCodeDetails != null) {
                productDetails.Revenue_GL__c = GLCodeDetails.Revenue_GL_AccountId__c;
                productDetails.Expense_GL__c = GLCodeDetails.Expense_GL_AccountId__c;
                productDetails.Inventory_GL__c = GLCodeDetails.Inventory_GL_AccountId__c;
            }
        }
        
        
        public ProductWrapperClass(Product_Select__c ps){
            isSelect = false;
            productDetails = ps;
            //productDetails = ps.clone(false, false, false, false);
        }
        
        public ProductWrapperClass(){
            isSelect = false;
            productDetails = new Product_Select__c();
            productDetails.Product_Name__c = 'Custom';
        }
        
        public ProductWrapperClass(Product_Select__c ps, Boolean isEdit){
            isSelect = false;
            productDetails = new Product_Select__c();
            productDetails.Tag__c = ps.Tag__c;
            productDetails.Original_Product_Name__c = ps.Original_Product_Name__c; 
            productDetails.Product_Name__c = ps.Product_Name__c;
            productDetails.Product_Code__c = ps.Product_Code__c;
            productDetails.Descriptions__c = ps.Descriptions__c;
            productDetails.Quantity__c = ps.Quantity__c;   
            productDetails.List_Price__c = ps.List_Price__c;
            productDetails.Multiplier__c = ps.Multiplier__c; 
            productDetails.LBS__c = ps.LBS__c; 
            productDetails.T_LBS__c = ps.T_LBS__c; 
            productDetails.Unit_Cost__c = ps.Unit_Cost__c; 
            //productDetails.Freight__c = ps.Freight__c; 
            productDetails.Extended_Cost__c = ps.Extended_Cost__c; 
            productDetails.Margin_Percentage__c = ps.Margin_Percentage__c; 
            productDetails.Sales_Price__c = ps.Sales_Price__c; 
            productDetails.Family__c = ps.Family__c;
            productDetails.Hide_Pricing__c = ps.Hide_Pricing__c;
            productDetails.Hide_Line__c = ps.Hide_Line__c;
            productDetails.Hide_Code__c = ps.Hide_Code__c;
            productDetails.Row_Index__c = ps.Row_Index__c;
            productDetails.Page_Break__c = ps.Page_Break__c;
            //productDetails.Is_Freight_Override__c = ps.Is_Freight_Override__c;
            productDetails.Is_SalePrice_Override__c = ps.Is_SalePrice_Override__c;
            productDetails.Sale_Type__c = ps.Sale_Type__c;
            productDetails.Manufacturer__c = ps.Manufacturer__c;
            productDetails.Release_pick__c = ps.Release_pick__c;
            productDetails.CR__c = ps.CR__c;
            productDetails.Hide_Quantity__c = ps.Hide_Quantity__c;
            productDetails.Product_Type__c = ps.Product_Type__c;
            productDetails.Alternate__c   = ps.Alternate__c;
            productDetails.ProductId__c   = ps.ProductId__c;
            // assign GLCode Values
            if(GLCodeDetails != null) {
                productDetails.Revenue_GL__c = GLCodeDetails.Revenue_GL_AccountId__c;
                productDetails.Expense_GL__c = GLCodeDetails.Expense_GL_AccountId__c;
                productDetails.Inventory_GL__c = GLCodeDetails.Inventory_GL_AccountId__c;
            }
        }
        
    }
    
    public class ProductGroupWrapperClass{
        
        public Boolean isSubGroupingEnable{get;set;}
        public Product_Group__c productGroup{get;set;}
        public List<ProductSubGroupWrapperClass> lstProductSubGroup{get;set;}
        
        public ProductGroupWrapperClass(){
            
            isSubGroupingEnable = false;
             
            productGroup = new Product_Group__c();
            productGroup.Name = '';
            lstProductSubGroup = new List<ProductSubGroupWrapperClass>(); 
            
        }
        
        public ProductGroupWrapperClass(Product_Group__c pg){
            productGroup = pg;
            lstProductSubGroup = new List<ProductSubGroupWrapperClass>();
        }
        
    }
    
    public class ProductSubGroupWrapperClass{
        
        public Product_Group__c productGroup{get;set;}
        public List<ProductWrapperClass> lstProductSelected{get;set;}
        
        public ProductSubGroupWrapperClass(){
            
            productGroup = new Product_Group__c();
            productGroup.Name = '';
            lstProductSelected = new List<ProductWrapperClass>();
            
        }
        
        public ProductSubGroupWrapperClass(Product_Group__c pg){
            productGroup = pg;
            lstProductSelected = new List<ProductWrapperClass>();
        }
        
    }
}