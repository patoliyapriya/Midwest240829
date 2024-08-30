/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 03-21-2024
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class ProductWrapper {

    public Boolean isSelect {get;set;}
    public PricebookEntry product {get;set;}
    @AuraEnabled public Id productId;
    @AuraEnabled public String manufacturer;
    @AuraEnabled public String name;
    @AuraEnabled public String productCode;
    @AuraEnabled public Decimal listPrice;
    @AuraEnabled public String productSummary;
    @AuraEnabled public String productType;
    @AuraEnabled public Boolean hideProduct;

    /**
    * @description : Constructor
    * @author Nilesh Badrakiya | 03-19-2024 
    * @param isSelect 
    * @param product 
    **/
    public ProductWrapper(Boolean isSelect, PricebookEntry product) {
        this.isSelect = isSelect;
        this.product = product;
    }

    /**
    * @description : Constructor to convert pricebook entry into product
    * @author Nilesh Badrakiya | 03-19-2024 
    * @param priceBookEntry 
    **/
    public ProductWrapper(PricebookEntry priceBookEntry) {
        this.productId = priceBookEntry.Product2.Id;
        this.name = priceBookEntry.Product2.Name;
        this.productCode = priceBookEntry.Product2.ProductCode;
        this.productSummary = priceBookEntry.Product2.Description;
        this.manufacturer = priceBookEntry.Product2.Manufacturer__c;
        this.listPrice = priceBookEntry.UnitPrice;
        this.hideProduct = priceBookEntry.Product2.HideProduct__c;
        this.productType=priceBookEntry.Product2.Product_Type__c;
    }
}