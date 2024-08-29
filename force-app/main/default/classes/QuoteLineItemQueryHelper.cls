/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 04-08-2024
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class QuoteLineItemQueryHelper {
    
    /**
    * @description : Retrieves the List of Line Items related to the Quote
    * @author Nilesh Badrakiya | 03-15-2024 
    * @param quoteId 
    * @return List<Product_Select__c> 
    **/
    public static List<Product_Select__c> getLineItemsByQuoteId(Id quoteId) {

        List<Product_Select__c> lineItems = new Query(QuoteLineItemConstants.SOBJECT_NAME).
                                                selectField(ManagedObject.FIELD_NAME_ID).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_PRODUCT_GROUP).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_SALE_TYPE).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_TAG).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_PRODUCT_NAME).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_PRODUCT_CODE).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_QUANTITY).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_LIST_PRICE).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_MULTIPLIER).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_UNIT_COST).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_EXTENDED_COST).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_MARGIN_PERCENTAGE).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_ALTERNATE).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_SALE_PRICE).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_CR).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_QUOTE).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_DESCRIPTION).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_HIDE_QUANTITY).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_HIDE_CODE).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_HIDE_LINE).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_HIDE_PRICING).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_PAGE_BREAK).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_RELEASEPICK).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_SALES_ORDER_LINE).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_PRODUCTID).
                                                lookup(QuoteLineItemConstants.FIELD_NAME_QUOTE, quoteId).
                                                orderBy(QuoteLineItemConstants.FIELD_NAME_ROW_INDEX).    
                                                run();
        return lineItems;
    }


    /**
    * @description : Retrieves Quote Line Item by Id
    * @author Nilesh Badrakiya | 03-22-2024 
    * @param recordId 
    * @return Product_Select__c
    **/
    public static Product_Select__c getLineItemsById(Id recordId) {

        Product_Select__c lineItem = (Product_Select__c)new Query(QuoteLineItemConstants.SOBJECT_NAME).
                                            selectField(ManagedObject.FIELD_NAME_ID).
                                            selectField(QuoteLineItemConstants.FIELD_NAME_PRODUCT_GROUP).
                                            selectField(QuoteLineItemConstants.FIELD_NAME_SALE_TYPE).
                                            selectField(QuoteLineItemConstants.FIELD_NAME_TAG).
                                            selectField(QuoteLineItemConstants.FIELD_NAME_PRODUCT_NAME).
                                            selectField(QuoteLineItemConstants.FIELD_NAME_PRODUCT_CODE).
                                            selectField(QuoteLineItemConstants.FIELD_NAME_QUANTITY).
                                            selectField(QuoteLineItemConstants.FIELD_NAME_LIST_PRICE).
                                            selectField(QuoteLineItemConstants.FIELD_NAME_MULTIPLIER).
                                            selectField(QuoteLineItemConstants.FIELD_NAME_UNIT_COST).
                                            selectField(QuoteLineItemConstants.FIELD_NAME_EXTENDED_COST).
                                            selectField(QuoteLineItemConstants.FIELD_NAME_MARGIN_PERCENTAGE).
                                            selectField(QuoteLineItemConstants.FIELD_NAME_ALTERNATE).
                                            selectField(QuoteLineItemConstants.FIELD_NAME_SALE_PRICE).
                                            selectField(QuoteLineItemConstants.FIELD_NAME_CR).
                                            selectField(QuoteLineItemConstants.FIELD_NAME_QUOTE).
                                            selectField(QuoteLineItemConstants.FIELD_NAME_DESCRIPTION).
                                            selectField(QuoteLineItemConstants.FIELD_NAME_ROW_INDEX).
                                            byId(recordId).
                                            fetch();
        return lineItem;
    }

    /**
    * @description : Returns the LineItems related to the set of GroupId
    * @author Nilesh Badrakiya | 03-16-2024 
    * @param productGroupIds 
    * @return List<Product_Select__c> 
    **/
    public static List<Product_Select__c> getLineItemsByProductGroup(Set<Id> productGroupIds) {

        List<Product_Select__c> lineItems = new Query(QuoteLineItemConstants.SOBJECT_NAME).
                                                selectField(ManagedObject.FIELD_NAME_ID).
                                                lookup(QuoteLineItemConstants.FIELD_NAME_PRODUCT_GROUP, productGroupIds).
                                                run();
        return lineItems;
    }


     /**
    * @description : Returns the LineItems related to the Product GroupId
    * @author Nilesh Badrakiya | 03-25-2024 
    * @param productGroupId 
    * @return List<Product_Select__c> 
    **/
    public static List<Product_Select__c> getLineItemsByProductGroupId(Id productGroupId) {

        List<Product_Select__c> lineItems = new Query(QuoteLineItemConstants.SOBJECT_NAME).
                                                selectField(ManagedObject.FIELD_NAME_ID).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_PRODUCT_GROUP).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_SALE_TYPE).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_TAG).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_PRODUCT_NAME).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_PRODUCT_CODE).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_QUANTITY).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_LIST_PRICE).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_MULTIPLIER).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_UNIT_COST).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_EXTENDED_COST).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_MARGIN_PERCENTAGE).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_ALTERNATE).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_SALE_PRICE).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_CR).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_QUOTE).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_ROW_INDEX).
                                                selectField(QuoteLineItemConstants.FIELD_NAME_DESCRIPTION).
                                                lookup(QuoteLineItemConstants.FIELD_NAME_PRODUCT_GROUP,productGroupId).
                                                run();
        return lineItems;
    }


    /**
    * @description : get count of line item where parent product is not null
    * @author Nilesh Badrakiya | 03-25-2024 
    * @param subGroupId 
    * @return countResult 
    **/
    public static Integer getCountofLineItems(Id subGroupId) {
                
        AggregateResult result = new Query(QuoteLineItemConstants.SOBJECT_NAME).
                                    count(ManagedObject.FIELD_NAME_ID, QuoteLineItemConstants.CONSTANT_COUNT_VALUE).
                                    lookup(QuoteLineItemConstants.FIELD_NAME_PRODUCT_GROUP, subGroupId).
                                    aggregate()[0];
        Integer countResult = (Integer)result.get(QuoteLineItemConstants.CONSTANT_COUNT_VALUE);
        return countResult;        
    }
}