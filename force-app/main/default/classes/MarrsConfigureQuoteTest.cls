@isTest

private class MarrsConfigureQuoteTest {

    static testMethod void testMarsConfigureQuote2() {
        Quote newQuote = [SELECT Id,Name,opportunityId From Quote limit 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(newQuote);
        MarrsConfigureQuoteController marsQuoteConfigure = new MarrsConfigureQuoteController(sc);
        marsQuoteConfigure.subGroupNameCreateGroup = 'subGroup1';
        marsQuoteConfigure.groupName = 'grp name';
        marsQuoteConfigure.addNewGroup();
        Id groupId = [SELECT Id 
                        FROM Product_Group__c 
                        WHERE Quote__c = :newQuote.Id 
                        AND Parent_Product_Group__c = null
                        LIMIT 1].Id;
        Id hidSubGrpId = [SELECT Id 
                            FROM Product_Group__c 
                            WHERE Quote__c = :newQuote.Id 
                            AND Parent_Product_Group__c = :groupId
                            LIMIT 1].Id; 

        // line item operations
        Product_Select__c objChildLineItem = new Product_Select__c();
        objChildLineItem.Product_Name__c = 'Child Product Name';
        objChildLineItem.Quote__c = newQuote.Id;
        objChildLineItem.Product_Group__c = hidSubGrpId;
        objChildLineItem.Sales_Price__c = 10;
        insert objChildLineItem;
        marsQuoteConfigure.lstGroups = marsQuoteConfigure.prepareCartPage();     
        marsQuoteConfigure.cloneLineItem();
        marsQuoteConfigure.deleteLineItem();
        marsQuoteConfigure.hidGroupId = groupId;

        marsQuoteConfigure.cloneGroup();
        marsQuoteConfigure.subGroupNameCreateSubGroup = 'subGroup2';
        marsQuoteConfigure.addNewSubGroup();


        marsQuoteConfigure.hidSubGroupId = hidSubGrpId;
        Test.startTest();
        marsQuoteConfigure.cloneSubGroup();
        
        marsQuoteConfigure.hidSubGroupIndex = 1;
        marsQuoteConfigure.deleteSubGroup();

        marsQuoteConfigure.hidGroupIndex = 1;
        marsQuoteConfigure.deleteGroup();

        marsQuoteConfigure.saveAndExit();
        marsQuoteConfigure.redirectToQuote();
        marsQuoteConfigure.addProduct();
        marsQuoteConfigure.addProducts();
        marsQuoteConfigure.searchProduct = 'testSA';
        marsQuoteConfigure.searchProducts();
        marsQuoteConfigure.getProducts();
        marsQuoteConfigure.addProductsToCart();
      
        marsQuoteConfigure.previewQuote();

        
        marsQuoteConfigure.first();
        marsQuoteConfigure.previous();
        marsQuoteConfigure.last();
        marsQuoteConfigure.next();
        Test.stopTest();

        
    }

    static testMethod void testMarsConfigureQuote() {
        Quote newQuote = [SELECT Id,Name,opportunityId From Quote limit 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(newQuote);
        MarrsConfigureQuoteController marsQuoteConfigure = new MarrsConfigureQuoteController(sc);
        marsQuoteConfigure.subGroupNameCreateGroup = 'subGroup1';
        marsQuoteConfigure.groupName = 'grp name';
        marsQuoteConfigure.addNewGroup();
        Id groupId = [SELECT Id 
                        FROM Product_Group__c 
                        WHERE Quote__c = :newQuote.Id 
                        AND Parent_Product_Group__c = null
                        LIMIT 1].Id;
        Id hidSubGrpId = [SELECT Id 
                            FROM Product_Group__c 
                            WHERE Quote__c = :newQuote.Id 
                            AND Parent_Product_Group__c = :groupId
                            LIMIT 1].Id; 

        // line item operations
        Product_Select__c objChildLineItem = new Product_Select__c();
        objChildLineItem.Product_Name__c = 'Child Product Name';
        objChildLineItem.Quote__c = newQuote.Id;
        objChildLineItem.Product_Group__c = hidSubGrpId;
        objChildLineItem.Sales_Price__c = 10;
        insert objChildLineItem;
        marsQuoteConfigure.lstGroups = marsQuoteConfigure.prepareCartPage();
        marsQuoteConfigure.hidLineItemIndex = 0;
        marsQuoteConfigure.hidSubGroupIndex = 0;
        marsQuoteConfigure.hidGroupIndex = 0;
        system.debug('marrsQuoteConfigure=>'+marsQuoteConfigure.lstGroups.size());
        marsQuoteConfigure.updateDescription();  
    }

    static testMethod void testProductWrapper() {

        Quote newQuote = [SELECT Id,Name,opportunityId From Quote limit 1];
        PricebookEntry customPrice = [SELECT id FROM PricebookEntry WHERE UnitPrice = 12000];
        ProductWrapper productWrapper = new ProductWrapper(true, customPrice);
        List<Product_Group__c> testProductGroup = CartQueryHelper.getGroupsAndSubGroups(newQuote.Id);
        List<AcctSeedERP__Sales_Order_Line__c> testSalesOrderLine = CartQueryHelper.getAccountingSeedLineItemsForPMTool(newQuote.Id);
        // This code is for GroupWrapper And Subgroup
        GroupWrapper gp = new GroupWrapper();
        SubGroup sb = new SubGroup();
    }


    @testSetup static void createData() {
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.closeDate = Date.today();
        objOpportunity.Name = 'Test Opportunity';
        objOpportunity.stageName = 'Draft';
        objOpportunity.Office__c = 'MaRRs';
        insert objOpportunity;
        
        Quote newQuote = new Quote();
        newQuote.Name = 'Test Quote';
        newQuote.opportunityId = objOpportunity.Id;
        newQuote.Scope_Revision_Number__c = '01';
        newQuote.Submittal_Revision_Number__c = '01';
        //newQuote.recordTypeId = [SELECT ]
        insert newQuote;

        objOpportunity.Sync_Quote__c = newQuote.Id;
        update objOpportunity;

        Product2 prod = new Product2(Name = 'testSA 1', 
            Family = 'Recold', Midwest_Group_Office__c = 'MaRRs');
        insert prod;
        System.debug('Product2 :-' + prod);

        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        System.debug('PricebookEntry :-' + prod);

        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;

        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = prod.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
    }
}