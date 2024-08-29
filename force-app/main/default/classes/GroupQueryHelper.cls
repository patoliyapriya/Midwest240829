/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 04-08-2024
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class GroupQueryHelper {

    /**
    * @description : Retrieve group by given Id
    * @author Nilesh Badrakiya | 03-16-2024 
    * @param recordId 
    * @return Product_Group__c 
    **/
    public static Product_Group__c getGroupById(Id recordId) {
        Product_Group__c grp = (Product_Group__c)new Query(ProductGroupConstants.SOBJECT_NAME).
                                    selectField(ManagedObject.FIELD_NAME_ID).
                                    selectField(ManagedObject.FIELD_NAME_NAME).
                                    selectField(ProductGroupConstants.FIELD_NAME_PARENT_PRODUCT_GROUP).
                                    selectField(ProductGroupConstants.FIELD_NAME_QUOTE).
                                    selectField(ProductGroupConstants.FIELD_NAME_TOTAL_GROUP_EXTENDED_COST).
                                    selectField(ProductGroupConstants.FIELD_NAME_GRAND_QUANTITY_TOTAL).
                                    selectField(ProductGroupConstants.FIELD_NAME_TOTAL_SUB_GROUPS).
                                    selectField(ProductGroupConstants.FIELD_NAME_TOTAL_EXTENDED_COST).
                                    selectField(ProductGroupConstants.FIELD_NAME_QUANTITY_TOTAL).
                                    selectField(ProductGroupConstants.FIELD_NAME_TOTAL_LINE_ITEMS).
                                    selectField(ProductGroupConstants.FIELD_NAME_ALTERNATE).
                                    selectField(ProductGroupConstants.FIELD_NAME_INDEX).
                                    byId(recordId).
                                    fetch();
        return grp;
    }
    
    /**
    * @description : Retrieves the list of Parent Group related to the Quote
    * @author Nilesh Badrakiya | 03-15-2024 
    * @param quoteId 
    * @return List<Product_Group__c> 
    **/
    public static List<Product_Group__c> getGroupsByQuoteId(Id quoteId) {
        List<Product_Group__c> listProductGroup = new Query(ProductGroupConstants.SOBJECT_NAME).
                                                    selectField(ManagedObject.FIELD_NAME_ID).
                                                    selectField(ManagedObject.FIELD_NAME_NAME).
                                                    selectField(ProductGroupConstants.FIELD_NAME_TOTAL_GROUP_EXTENDED_COST).
                                                    selectField(ProductGroupConstants.FIELD_NAME_GRAND_QUANTITY_TOTAL).
                                                    selectField(ProductGroupConstants.FIELD_NAME_TOTAL_SUB_GROUPS).
                                                    selectField(ProductGroupConstants.FIELD_NAME_PAGE_BREAK).
                                                    selectField(ProductGroupConstants.FIELD_NAME_HIDE_PRICING).
                                                    selectField(ProductGroupConstants.FIELD_NAME_ALTERNATE).
                                                    lookup(ProductGroupConstants.FIELD_NAME_QUOTE,quoteId).
                                                    addConditionNull(ProductGroupConstants.FIELD_NAME_PARENT_PRODUCT_GROUP).
                                                    orderBy(ProductGroupConstants.FIELD_NAME_INDEX).
                                                    run();
        return listProductGroup;
    }

    /**
    * @description : Retrieves the list of Sub Group related to the Quote
    * @author Nilesh Badrakiya | 03-15-2024 
    * @param quoteId 
    * @return List<Product_Group__c> 
    **/
    public static List<Product_Group__c> getSubGroupsByQuoteId(Id quoteId) {
        List<Product_Group__c> listProductGroup = new Query(ProductGroupConstants.SOBJECT_NAME).
                                                    selectField(ManagedObject.FIELD_NAME_ID).
                                                    selectField(ManagedObject.FIELD_NAME_NAME).
                                                    selectField(ProductGroupConstants.FIELD_NAME_PARENT_PRODUCT_GROUP).
                                                    selectField(ProductGroupConstants.FIELD_NAME_TOTAL_EXTENDED_COST).
                                                    selectField(ProductGroupConstants.FIELD_NAME_QUANTITY_TOTAL).
                                                    selectField(ProductGroupConstants.FIELD_NAME_TOTAL_LINE_ITEMS).
                                                    selectField(ProductGroupConstants.FIELD_NAME_HIDE_QUANTITY).
                                                    selectField(ProductGroupConstants.FIELD_NAME_HIDE_CODE).
                                                    selectField(ProductGroupConstants.FIELD_NAME_HIDE_AMOUNT).
                                                    selectField(ProductGroupConstants.FIELD_NAME_HIDE_LINE).
                                                    selectField(ProductGroupConstants.FIELD_NAME_HIDE_PRICING).
                                                    selectField(ProductGroupConstants.FIELD_NAME_ALTERNATE).
                                                    lookup(ProductGroupConstants.FIELD_NAME_QUOTE,quoteId).
                                                    addConditionNotNull(ProductGroupConstants.FIELD_NAME_PARENT_PRODUCT_GROUP).
                                                    orderBy(ProductGroupConstants.FIELD_NAME_INDEX).
                                                    run();
        return listProductGroup;
    }

    /**
    * @description : get SubGroups related to the given Parent Group Id
    * @author Nilesh Badrakiya | 03-25-2024 
    * @param parentGroupId 
    * @return List<Product_Group__c> 
    **/
    public static List<Product_Group__c> getSubGroupsByParentGroupId(Id parentGroupId) {
        List<Product_Group__c> listSubGroup = new Query(ProductGroupConstants.SOBJECT_NAME).
                                                selectField(ManagedObject.FIELD_NAME_ID).
                                                selectField(ManagedObject.FIELD_NAME_NAME).
                                                selectField(ProductGroupConstants.FIELD_NAME_QUOTE).
                                                selectField(ProductGroupConstants.FIELD_NAME_TOTAL_GROUP_EXTENDED_COST).
                                                selectField(ProductGroupConstants.FIELD_NAME_GRAND_QUANTITY_TOTAL).
                                                selectField(ProductGroupConstants.FIELD_NAME_TOTAL_SUB_GROUPS).
                                                selectField(ProductGroupConstants.FIELD_NAME_TOTAL_EXTENDED_COST).
                                                selectField(ProductGroupConstants.FIELD_NAME_QUANTITY_TOTAL).
                                                selectField(ProductGroupConstants.FIELD_NAME_TOTAL_LINE_ITEMS).
                                                selectField(ProductGroupConstants.FIELD_NAME_INDEX).
                                                selectField(ProductGroupConstants.FIELD_NAME_ALTERNATE).
                                                lookup(ProductGroupConstants.FIELD_NAME_PARENT_PRODUCT_GROUP, parentGroupId).
                                                orderBy(ProductGroupConstants.FIELD_NAME_INDEX).
                                                run();
        return listSubGroup;
    }

    /**
    * @description : get count of group related to the Quote
    * @author Nilesh Badrakiya | 03-25-2024 
    * @param quoteId 
    * @return count 
    **/
    public static Integer getCountofGroups(Id quoteId) {
                
        AggregateResult result = new Query(ProductGroupConstants.SOBJECT_NAME).
        count(ManagedObject.FIELD_NAME_ID, ProductGroupConstants.CONSTANT_COUNT_VALUE).
        lookup(ProductGroupConstants.FIELD_NAME_QUOTE, quoteId).
        addConditionNull(ProductGroupConstants.FIELD_NAME_PARENT_PRODUCT_GROUP).
        aggregate()[0];

        Integer countResult = (Integer)result.get(ProductGroupConstants.CONSTANT_COUNT_VALUE);
        return countResult;        
    }

    /**
    * @description : get count of group where parent product is not null
    * @author Nilesh Badrakiya | 03-25-2024 
    * @param groupId 
    * @return count 
    **/
    public static Integer getCountofSubGroups(Id groupId) {
                
        AggregateResult result = new Query(ProductGroupConstants.SOBJECT_NAME).
        count(ManagedObject.FIELD_NAME_ID, ProductGroupConstants.CONSTANT_COUNT_VALUE).
        lookup(ProductGroupConstants.FIELD_NAME_PARENT_PRODUCT_GROUP, groupId).
        aggregate()[0];

        Integer countResult = (Integer)result.get(ProductGroupConstants.CONSTANT_COUNT_VALUE);
        return countResult;        
    }


    /**
    * @description : Retrieves the list of all Groups related to the Quote
    * @author Nilesh Badrakiya | 03-15-2024 
    * @param quoteId 
    * @return List<Product_Group__c> 
    **/
    public static List<Product_Group__c> getAllGroupsByQuoteId(Id quoteId) {
        List<Product_Group__c> listProductGroup = new Query(ProductGroupConstants.SOBJECT_NAME).
                                                    selectField(ManagedObject.FIELD_NAME_ID).
                                                    selectField(ManagedObject.FIELD_NAME_NAME).
                                                    selectField(ProductGroupConstants.FIELD_NAME_TOTAL_GROUP_EXTENDED_COST).
                                                    selectField(ProductGroupConstants.FIELD_NAME_GRAND_QUANTITY_TOTAL).
                                                    selectField(ProductGroupConstants.FIELD_NAME_GRAND_QUANTITY_TOTAL).
                                                    selectField(ProductGroupConstants.FIELD_NAME_TOTAL_SUB_GROUPS).
                                                    selectField(ProductGroupConstants.FIELD_NAME_PAGE_BREAK).
                                                    selectField(ProductGroupConstants.FIELD_NAME_HIDE_PRICING).
                                                    selectField(ProductGroupConstants.FIELD_NAME_ALTERNATE).
                                                    lookup(ProductGroupConstants.FIELD_NAME_QUOTE,quoteId).
                                                    run();
        return listProductGroup;
    }
 
}