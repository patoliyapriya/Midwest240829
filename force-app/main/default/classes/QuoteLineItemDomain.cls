/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 04-11-2024
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class QuoteLineItemDomain {
    
    /**
    * @description : Delete the Quote Line Items
    * @author Nilesh Badrakiya | 03-17-2024 
    * @param listLineItemsToDelete 
    **/
    public static void deleteLineItems(List<Product_Select__c> listLineItemsToDelete) {

        if (!listLineItemsToDelete.isEmpty()) {
            delete listLineItemsToDelete;
        }
    }

    /**
    * @description : Delete the Line Item of given Id
    * @author Nilesh Badrakiya | 03-18-2024 
    * @param recordId 
    **/
    public static void deleteLineItemById(Id recordId) {
        Database.delete(recordId);
    }

    /**
    * @description : Insert List Line Item
    * @author Nilesh Badrakiya | 03-20-2024 
    * @param listLineItemsToInsert 
    **/
    public static void insertLineItems(List<Product_Select__c> listLineItemsToInsert) {
        
        if (listLineItemsToInsert.size()>0) {
            insert listLineItemsToInsert;
        }    
    }

    /**
    * @description : Update list of Line Items
    * @author Nilesh Badrakiya | 04-11-2024 
    * @param listLineItemsToUpdate 
    **/
    public static void updateLineItems(List<Product_Select__c> listLineItemsToUpdate) {

        if (!listLineItemsToUpdate.isEmpty()) {
            update listLineItemsToUpdate;
        }
    }

    public static void insertDefaultLineItem(Id subGrpId, PricebookEntry priceBookEntry, Id quoteId) {
        if(priceBookEntry != null) {
            Product_Select__c lineItemObj = new Product_Select__c();
            lineItemObj.Product_Name__c = priceBookEntry.Product2.Name;
            lineItemObj.Product_Group__c = subGrpId;
            lineItemObj.Product_Code__c = priceBookEntry.Product2.ProductCode;
            lineItemObj.List_Price__c = priceBookEntry.UnitPrice;
            lineItemObj.Descriptions__c = priceBookEntry.Product2.Description;
            lineItemObj.Manufacturer__c = priceBookEntry.Product2.Manufacturer__c;
            lineItemObj.Sale_Type__c = 'B/R';
            lineItemObj.Tag__c = '';
            lineItemObj.ProductId__c = priceBookEntry.Product2.Id;
            lineItemObj.Quantity__c = 0;
            lineItemObj.Multiplier__c = 0;
            lineItemObj.Extended_Cost__c = 0;
            lineItemObj.Margin_Percentage__c = 0;
            lineItemObj.Alternate__c = false;
            lineItemObj.Sales_Price__c = 0;
            lineItemObj.CR__c = 0;
            lineItemObj.Quote__c = quoteId;
            lineItemObj.Unit_Cost__c = 0;
            lineItemObj.List_Price__c = 0;
            lineItemObj.Row_Index__c = QuoteLineItemQueryHelper.getCountofLineItems(subGrpId) + 1;
            insert lineItemObj;
        }
    }

}