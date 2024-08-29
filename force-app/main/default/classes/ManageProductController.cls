/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 04-25-2024
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class ManageProductController {
    
    /**
    * @description : Returns the List of Product Wrapper
    * @author Nilesh Badrakiya | 03-20-2024 
    * @param office 
    * @param searchKeyword
    * @return List<ProductWrapper> 
    **/
    @AuraEnabled
    public static List<ProductWrapper> getProducts(String office, String searchKeyword) {

        List<ProductWrapper> listProductWrapper = new List<ProductWrapper>();
        List<PriceBookEntry> listPriceBookEntry = (String.isBlank(searchKeyword)) ? 
                                                    PriceBookEntryQueryHelper.getPriceBookEnteriesByOffice(office) : 
                                                    PriceBookEntryQueryHelper.getSearchedPricebookEntriesByOffice(office, searchKeyword);

        for (PriceBookEntry entry : listPriceBookEntry) {
            listProductWrapper.add(new ProductWrapper(entry));
        }
        return listProductWrapper;
    }

    /**
    * @description : Returns the Next Products
    * @author Nilesh Badrakiya | 03-25-2024 
    * @param office 
    * @param lastProductName 
    * @param searchKeyword
    * @return List<ProductWrapper> 
    **/
    @AuraEnabled
    public static List<ProductWrapper> getNextProducts(String office, String lastProductName, String searchKeyword) {
        
        List<ProductWrapper> listProductWrapper = new List<ProductWrapper>();
        List<PriceBookEntry> listPriceBookEntry = (String.isBlank(searchKeyword)) ? 
                                                    PriceBookEntryQueryHelper.getNextPriceBookEnteriesByOffice(office, lastProductName) : 
                                                    PriceBookEntryQueryHelper.getNextPriceBookEnteriesByOffice(office, lastProductName, searchKeyword);

        for(PriceBookEntry entry : listPriceBookEntry) {
            listProductWrapper.add(new ProductWrapper(entry));
        }
        return listProductWrapper;
    }

    /**
    * @description : Returns the Previous Products
    * @author Nilesh Badrakiya | 03-25-2024 
    * @param office 
    * @param firstProductName
    * @param searchKeyword 
    * @return List<ProductWrapper> 
    **/
    @AuraEnabled
    public static List<ProductWrapper> getPreviousProducts(String office, String firstProductName, String searchKeyword) {
        
        List<ProductWrapper> listProductWrapper = new List<ProductWrapper>();
        List<PriceBookEntry> listPriceBookEntry = (String.isBlank(searchKeyword)) ? 
                                                    PriceBookEntryQueryHelper.getPreviousPriceBookEnteriesByOffice(office, firstProductName) : 
                                                    PriceBookEntryQueryHelper.getPreviousPriceBookEnteriesByOffice(office, firstProductName, searchKeyword);

        for(PriceBookEntry entry : listPriceBookEntry) {
            listProductWrapper.add(new ProductWrapper(entry));
        }
        return listProductWrapper;
    }

    /**
    * @description : Get the total products
    * @author Nilesh Badrakiya | 03-25-2024 
    * @param office 
    * @param searchKeyword 
    * @return Integer 
    **/
    @AuraEnabled
    public static Integer getTotalProducts(String office, String searchKeyword) {

        Integer totalProducts = (String.isBlank(searchKeyword)) ? 
                                    PriceBookEntryQueryHelper.getTotalPriceBookEnteries(office) : 
                                    PriceBookEntryQueryHelper.getTotalPriceBookEnteries(office, searchKeyword);
        return totalProducts;
    }

    
    /**
    * @description : Convert the product into Line Items and insert it in Database
    * @author Nilesh Badrakiya | 04-08-2024 
    * @param productIds 
    * @param subGroupId 
    * @param quoteId 
    * @param isMarrs 
    **/

    @AuraEnabled
    public static void addLineItems(List<Id> productIds, Id subGroupId, Id quoteId, Boolean isMarrs) {
        List<Product_Select__c> listLineItemsInsert = new List<Product_Select__c>();
        List<Product2> listProducts = ProductQueryHelper.getProductsByProductIds(productIds);
        Product_Select__c lineItem = new Product_Select__c();
        Integer initialRowIndex = QuoteLineItemQueryHelper.getCountofLineItems(subGroupId);
    
        for (Product2 product : listProducts) {
            if (isMarrs == true) {
               lineItem = convertMarrsProductToLineItem(product, subGroupId, quoteId, initialRowIndex);
            }
            else {
                lineItem = convertProductToLineItem(product, subGroupId, quoteId, initialRowIndex);
            }
            
            listLineItemsInsert.add(lineItem);
            initialRowIndex++;
        }
        
        if (listLineItemsInsert.size() > 0) {
            QuoteLineItemDomain.insertLineItems(listLineItemsInsert);
        }
    }

    
    /**
    * @description : Convert Product to Line Item
    * @author Nilesh Badrakiya | 04-08-2024 
    * @param product 
    * @param subGroupId 
    * @param quoteId 
    * @return Product_Select__c 
    **/
    private static Product_Select__c convertProductToLineItem(Product2 product,Id subGroupId,Id quoteId, Integer rowIndex) {
        Product_Select__c lineItemObj = new Product_Select__c();
        lineItemObj.Product_Group__c = subGroupId;
        lineItemObj.Sale_Type__c =  'B/R';
        lineItemObj.Tag__c = '';
        lineItemObj.Product_Name__c = product.Name;
        lineItemObj.Product_Code__c = product.ProductCode;
        lineItemObj.Quantity__c = 0;
        lineItemObj.Multiplier__c = 0;
        lineItemObj.Extended_Cost__c = 0;
        lineItemObj.Margin_Percentage__c = 0;
        lineItemObj.Descriptions__c = product.Product_Description__c;
        lineItemObj.Alternate__c = false;
        lineItemObj.Sales_Price__c = 0;
        lineItemObj.CR__c = 0;
        lineItemObj.Quote__c = quoteId;
        lineItemObj.Unit_Cost__c = 0;
        lineItemObj.List_Price__c = 0;
        lineItemObj.ProductId__c = product.Id;
        lineItemObj.Row_Index__c = rowIndex + 1; 
        return lineItemObj;
    }

    private static Product_Select__c convertMarrsProductToLineItem(Product2 product,Id subGroupId,Id quoteId, Integer rowIndex) {
        Product_Select__c lineItemObj = new Product_Select__c();

        PricebookEntry priceBookEntry = PriceBookEntryQueryHelper.getPriceBookEntryByProductId(product.Id);

        lineItemObj.Product_Group__c = subGroupId;
        lineItemObj.Tag__c = '';
        lineItemObj.Product_Name__c = product.Name;
        lineItemObj.Quantity__c = 1;
        lineItemObj.Sales_Price__c = 0;
        lineItemObj.Quote__c = quoteId;
        lineItemObj.Row_Index__c = rowIndex + 1; 
        lineItemObj.Product_Code__c = product.ProductCode;
        lineItemObj.List_Price__c = priceBookEntry.UnitPrice;
        lineItemObj.Descriptions__c = product.Product_Description__c;
        lineItemObj.Family__c = product.Family;
        lineItemObj.Manufacturer__c = product.Manufacturer__c;
        lineItemObj.Product_Type__c = product.Product_Type__c;
        lineItemObj.Sale_Type__c = 'B/R';
        lineItemObj.ProductId__c = product.Id;
        return lineItemObj;
    }

}