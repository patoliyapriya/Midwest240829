/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 02-13-2024
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class ProductGroupQueryHelper {
    
    /**
    * @description : Get all the Subgroup and its related Quote Line Items  on the Quote
    * @author Nilesh Badrakiya | 02-13-2024 
    * @param quoteId 
    * @param quoteLineFieldset 
    * @param fieldset 
    * @return List<Product_Group__c> 
    **/
    public static List<Product_Group__c> getSubgroupAndRelatedQuoteLineOnQuoteByOrder(Id quoteId, List<String> quoteLineFieldset, List<String> fieldset){
        List<Product_Group__c> lstProductGroup = new Query(ProductGroupConstant.SOBJECT_NAME).
                                                    selectFields(fieldset).
                                                    addSubquery(
                                                        Query.subquery(ProductGroupConstant.RELATIONSHIP_QUOTE_LINE_ITEMS).
                                                        selectFields(quoteLineFieldset).
                                                        orderBy(QuoteLineItemConstant.FIELD_NAME_ROW_INDEX,ProductGroupConstant.CONSTANT_ASC)).
                                                    lookup(ProductGroupConstant.FIELD_NAME_QUOTE,quoteId).
                                                    addConditionNotNull(ProductGroupConstant.FIELD_NAME_PARENT_PRODUCT_GROUP).
                                                    orderBy(ProductGroupConstant.FIELD_NAME_PARENT_PRODUCT_GROUP).
                                                    orderBy(ProductGroupConstant.FIELD_NAME_INDEX,ProductGroupConstant.CONSTANT_ASC).debug().
                                                    run();
        return lstProductGroup;
    }

    /**
    * @description : get all the Subgroup and related Quote Line Items whose Hide Line field is false on the Quote
    * @author Nilesh Badrakiya | 02-13-2024 
    * @param quoteId 
    * @param quoteLineFieldset 
    * @param fieldset 
    * @return List<Product_Group__c> 
    **/
    public static List<Product_Group__c> getSubgroupAndRelatedNotHideQuoteLineOnQuoteByOrder(Id quoteId, List<String> quoteLineFieldset, List<String> fieldset){
        List<Product_Group__c> lstProductGroup = new Query(ProductGroupConstant.SOBJECT_NAME).
                                                    selectFields(fieldset).
                                                    addSubquery(
                                                        Query.subquery(ProductGroupConstant.RELATIONSHIP_QUOTE_LINE_ITEMS).
                                                        selectFields(quoteLineFieldset).
                                                        addConditionEq(QuoteLineItemConstant.FIELD_NAME_HIDE_LINE,false).
                                                        orderBy(QuoteLineItemConstant.FIELD_NAME_ROW_INDEX,ProductGroupConstant.CONSTANT_ASC)).
                                                    lookup(ProductGroupConstant.FIELD_NAME_QUOTE,quoteId).
                                                    addConditionNotNull(ProductGroupConstant.FIELD_NAME_PARENT_PRODUCT_GROUP).
                                                    orderBy(ProductGroupConstant.FIELD_NAME_PARENT_PRODUCT_GROUP).
                                                    orderBy(ProductGroupConstant.FIELD_NAME_INDEX,ProductGroupConstant.CONSTANT_ASC).debug().
                                                    run();
        return lstProductGroup;
    }

    /**
    * @description : Gets the Product Group and related Quote Line Items (Hide Line field is false) On Quote by recordId
    * @author Nilesh Badrakiya | 02-13-2024 
    * @param quoteId 
    * @param recordId 
    * @param quoteLineFieldset 
    * @param fieldset 
    * @return List<Product_Group__c> 
    **/
    public static List<Product_Group__c> getProductgroupAndRelatedNotHideQuoteLineOnQuoteByIdInOrder(Id quoteId, String recordId, List<String> quoteLineFieldset, List<String> fieldset){
        List<Product_Group__c> lstProductGroup = new Query(ProductGroupConstant.SOBJECT_NAME).
                                                    selectFields(fieldset).
                                                    addSubquery(
                                                        Query.subquery(ProductGroupConstant.RELATIONSHIP_QUOTE_LINE_ITEMS).
                                                        selectFields(quoteLineFieldset).
                                                        addConditionEq(QuoteLineItemConstant.FIELD_NAME_HIDE_LINE,false).
                                                        orderBy(QuoteLineItemConstant.FIELD_NAME_ROW_INDEX,ProductGroupConstant.CONSTANT_ASC)).
                                                    lookup(ProductGroupConstant.FIELD_NAME_QUOTE,quoteId).
                                                    addConditionEq(ManagedObject.FIELD_NAME_ID,recordId).
                                                    orderBy(ProductGroupConstant.FIELD_NAME_PARENT_PRODUCT_GROUP).
                                                    orderBy(ProductGroupConstant.FIELD_NAME_INDEX,ProductGroupConstant.CONSTANT_ASC).debug().
                                                    run();
        return lstProductGroup;
    }

    /**
    * @description : Get the Sub Groups and related Quote Line Items(SaleType != D/S) on the Quote
    * @author Nilesh Badrakiya | 02-13-2024 
    * @param quoteId 
    * @param quoteLineFieldset 
    * @param fieldset 
    * @return List<Product_Group__c> 
    **/
    public static List<Product_Group__c> getSubgroupAndRelatedQuoteLineSaleTypeNotDsOnQuoteByOrder(Id quoteId, List<String> quoteLineFieldset, List<String> fieldset){
        List<Product_Group__c> lstProductGroup = new Query(ProductGroupConstant.SOBJECT_NAME).
                                                    selectFields(fieldset).
                                                    addSubquery(
                                                        Query.subquery(ProductGroupConstant.RELATIONSHIP_QUOTE_LINE_ITEMS).
                                                        selectFields(quoteLineFieldset).
                                                        addConditionNotEq(QuoteLineItemConstant.FIELD_NAME_SALE_TYPE,QuoteLineItemConstant.CONSTANT_SALE_TYPE_DS).
                                                        orderBy(QuoteLineItemConstant.FIELD_NAME_ROW_INDEX,ProductGroupConstant.CONSTANT_ASC)).
                                                    lookup(ProductGroupConstant.FIELD_NAME_QUOTE,quoteId).
                                                    addConditionNotNull(ProductGroupConstant.FIELD_NAME_PARENT_PRODUCT_GROUP).
                                                    orderBy(ProductGroupConstant.FIELD_NAME_PARENT_PRODUCT_GROUP).
                                                    orderBy(ProductGroupConstant.FIELD_NAME_INDEX,ProductGroupConstant.CONSTANT_ASC).debug().
                                                    run();
        return lstProductGroup;
    }

    /**
    * @description : Get the Sub Group and its related Quote Line Items(SaleType != C/R And HideLineOnEmail = false And HideLineOnEmailStartup = false) on the Quote
    * @author Nilesh Badrakiya | 02-13-2024 
    * @param quoteId 
    * @param quoteLineFieldset 
    * @param fieldset 
    * @return List<Product_Group__c> 
    **/
    public static List<Product_Group__c> getSubgroupForStageStatus(Id quoteId, List<String> quoteLineFieldset, List<String> fieldset){
        List<Product_Group__c> lstProductGroup = new Query(ProductGroupConstant.SOBJECT_NAME).
                                                    selectFields(fieldset).
                                                    addSubquery(
                                                        Query.subquery(ProductGroupConstant.RELATIONSHIP_QUOTE_LINE_ITEMS).
                                                        selectFields(quoteLineFieldset).
                                                        addConditionNotEq(QuoteLineItemConstant.FIELD_NAME_SALE_TYPE,QuoteLineItemConstant.CONSTANT_SALE_TYPE_CR).
                                                        addConditionEq(QuoteLineItemConstant.FIELD_NAME_HIDE_LINE_ON_EMAIL,false).
                                                        addConditionEq(QuoteLineItemConstant.FIELD_NAME_HIDE_LINE_ON_EMAIL_STARTUP,false).
                                                        orderBy(QuoteLineItemConstant.FIELD_NAME_ROW_INDEX,ProductGroupConstant.CONSTANT_ASC)).
                                                    lookup(ProductGroupConstant.FIELD_NAME_QUOTE,quoteId).
                                                    addConditionNotNull(ProductGroupConstant.FIELD_NAME_PARENT_PRODUCT_GROUP).
                                                    orderBy(ProductGroupConstant.FIELD_NAME_PARENT_PRODUCT_GROUP).
                                                    orderBy(ProductGroupConstant.FIELD_NAME_INDEX,ProductGroupConstant.CONSTANT_ASC).debug().
                                                    run();
        return lstProductGroup;
    }

    /**
    * @description : Get the Sub Group and its related Quote Line Items(SaleType != C/R And HideLineOnEmailStartup = false) on the Quote
    * @author Nilesh Badrakiya | 02-13-2024 
    * @param quoteId 
    * @param quoteLineFieldset 
    * @param fieldset 
    * @return List<Product_Group__c> 
    **/
    public static List<Product_Group__c> getSubgroupForStartUpWarranty(Id quoteId, List<String> quoteLineFieldset, List<String> fieldset){
        List<Product_Group__c> lstProductGroup = new Query(ProductGroupConstant.SOBJECT_NAME).
                                                    selectFields(fieldset).
                                                    addSubquery(
                                                        Query.subquery(ProductGroupConstant.RELATIONSHIP_QUOTE_LINE_ITEMS).
                                                        selectFields(quoteLineFieldset).
                                                        addConditionNotEq(QuoteLineItemConstant.FIELD_NAME_SALE_TYPE,QuoteLineItemConstant.CONSTANT_SALE_TYPE_CR).
                                                        addConditionEq(QuoteLineItemConstant.FIELD_NAME_HIDE_LINE_ON_EMAIL_STARTUP,false).
                                                        orderBy(QuoteLineItemConstant.FIELD_NAME_ROW_INDEX,ProductGroupConstant.CONSTANT_ASC)).
                                                    lookup(ProductGroupConstant.FIELD_NAME_QUOTE,quoteId).
                                                    addConditionNotNull(ProductGroupConstant.FIELD_NAME_PARENT_PRODUCT_GROUP).
                                                    orderBy(ProductGroupConstant.FIELD_NAME_PARENT_PRODUCT_GROUP).
                                                    orderBy(ProductGroupConstant.FIELD_NAME_INDEX,ProductGroupConstant.CONSTANT_ASC).debug().
                                                    run();
        return lstProductGroup;
    }

    /**
    * @description : get List of record by the set of Id
    * @author Nilesh Badrakiya | 02-13-2024 
    * @param recordId 
    * @param fieldset 
    * @return List<Product_Group__c> 
    **/
    public static List<Product_Group__c> getRecordById(Set<Id> recordId, List<String> fieldset){
        List<Product_Group__c> lstProductGroup = new Query(ProductGroupConstant.SOBJECT_NAME).
                                                    selectFields(fieldset).
                                                    byId(recordId).debug().
                                                    run();
        return lstProductGroup;
    }

    /**
    * @description : Get the record of specific id
    * @author Nilesh Badrakiya | 02-13-2024 
    * @param recordId 
    * @param fieldset 
    * @return Product_Group__c 
    **/
    public static Product_Group__c getRecordById(Id recordId, List<String> fieldset){
        Product_Group__c productGroup = (Product_Group__c)new Query(ProductGroupConstant.SOBJECT_NAME).
                                                    selectFields(fieldset).
                                                    byId(recordId).debug().
                                                    fetch();
        return productGroup;
    }

    /**
    * @description : get the record and its related QuoteLine Items of the specific record id
    * @author Nilesh Badrakiya | 02-13-2024 
    * @param recordId 
    * @param quoteLineFieldset 
    * @param fieldset 
    * @return Product_Group__c 
    **/
    public static Product_Group__c getRecordAndRelatedQuoteLineItemsById(Id recordId, List<String> quoteLineFieldset, List<String> fieldset){
        Product_Group__c productGroup = (Product_Group__c)new Query(ProductGroupConstant.SOBJECT_NAME).
                                                    selectFields(fieldset).
                                                    addSubquery(
                                                        Query.subquery(ProductGroupConstant.RELATIONSHIP_QUOTE_LINE_ITEMS).
                                                        selectFields(quoteLineFieldset)).
                                                    byId(recordId).debug().
                                                    fetch();
        return productGroup;
    }

    /**
    * @description : get the subgroups of the specific Parent Group
    * @author Nilesh Badrakiya | 02-13-2024 
    * @param parentGroupId 
    * @param fieldset 
    * @return List<Product_Group__c> 
    **/
    public static List<Product_Group__c> getRecordByParentProductGroup(Id parentGroupId, List<String> fieldset){
        List<Product_Group__c> lstProductGroup = new Query(ProductGroupConstant.SOBJECT_NAME).
                                                    selectFields(fieldset).
                                                    lookup(ProductGroupConstant.FIELD_NAME_PARENT_PRODUCT_GROUP,parentGroupId).debug().
                                                    run();
        return lstProductGroup;
    }

    /**
    * @description : Get the Parent Product Group and its related Subgroup from the specific quote
    * @author Nilesh Badrakiya | 02-13-2024 
    * @param quoteId 
    * @param subGroupFieldset 
    * @param fieldset 
    * @return List<Product_Group__c> 
    **/
    public static List<Product_Group__c> getParentGroupAndRelatedSubGroupOnQuoteByOrder(Id quoteId, List<String> subGroupFieldset, List<String> fieldset){
        List<Product_Group__c> lstProductGroup = new Query(ProductGroupConstant.SOBJECT_NAME).
                                                    selectFields(fieldset).
                                                    addSubquery(
                                                        Query.subquery(ProductGroupConstant.RELATIONSHIP_PRODUCT_GROUPS).
                                                        selectFields(subGroupFieldset).
                                                        orderBy(ProductGroupConstant.FIELD_NAME_INDEX,ProductGroupConstant.CONSTANT_ASC)).
                                                    lookup(ProductGroupConstant.FIELD_NAME_QUOTE,quoteId).
                                                    addConditionNull(ProductGroupConstant.FIELD_NAME_PARENT_PRODUCT_GROUP).
                                                    orderBy(ProductGroupConstant.FIELD_NAME_INDEX,ProductGroupConstant.CONSTANT_ASC).debug().
                                                    run();
        return lstProductGroup;
    }

    /**
    * @description : get all Product Group and its related Product Group on the specific quote
    * @author Nilesh Badrakiya | 02-13-2024 
    * @param quoteId 
    * @param subGroupFieldset 
    * @param fieldset 
    * @return List<Product_Group__c> 
    **/
    public static List<Product_Group__c> getProductGroupAndSubGroups(Id quoteId, List<String> subGroupFieldset, List<String> fieldset){
        List<Product_Group__c> lstProductGroup = new Query(ProductGroupConstant.SOBJECT_NAME).
                                                    selectFields(fieldset).
                                                    addSubquery(
                                                        Query.subquery(ProductGroupConstant.RELATIONSHIP_PRODUCT_GROUPS).
                                                        selectFields(subGroupFieldset)).
                                                    lookup(ProductGroupConstant.FIELD_NAME_QUOTE,quoteId).debug().
                                                    run();
        return lstProductGroup;
    }

    /**
    * @description : Returns the number of Parent Group on specific Quote
    * @author Nilesh Badrakiya | 02-13-2024 
    * @param quoteId 
    * @return Integer 
    **/
    public static Integer getTotalGroupsByQuote(Id quoteId){
        AggregateResult result = new Query(ProductGroupConstant.SOBJECT_NAME).
                                    count(ManagedObject.FIELD_NAME_ID,ProductGroupConstant.CONSTANT_TOTAL_RECORD).
                                    lookup(ProductGroupConstant.FIELD_NAME_QUOTE,quoteId).
                                    addConditionNull(ProductGroupConstant.FIELD_NAME_PARENT_PRODUCT_GROUP).debug().
                                    aggregate()[0];
        return (Integer)result.get(ProductGroupConstant.CONSTANT_TOTAL_RECORD);
    }

    /**
    * @description : Returns the total subgroup of the specific parent group
    * @author Nilesh Badrakiya | 02-13-2024 
    * @param groupId 
    * @return Integer 
    **/
    public static Integer getTotalSubGroupsByGroup(Id groupId){
        AggregateResult result = new Query(ProductGroupConstant.SOBJECT_NAME).
                                count(ManagedObject.FIELD_NAME_ID,ProductGroupConstant.CONSTANT_TOTAL_RECORD).
                                lookup(ProductGroupConstant.FIELD_NAME_PARENT_PRODUCT_GROUP,groupId).debug().
                                aggregate()[0];
        return (Integer)result.get(ProductGroupConstant.CONSTANT_TOTAL_RECORD);
    }

    /**
    * @description : get the parent product groups with greater index 
    * @author Nilesh Badrakiya | 02-13-2024 
    * @param index 
    * @param fieldset 
    * @return List<Product_Group__c> 
    **/
    public static List<Product_Group__c> getGroupByIndex(Integer index, List<String> fieldset){
        List<Product_Group__c> lstProductGroup = new Query(ProductGroupConstant.SOBJECT_NAME).
                                                    selectFields(fieldset).
                                                    addConditionNull(ProductGroupConstant.FIELD_NAME_PARENT_PRODUCT_GROUP).
                                                    addConditionGt(ProductGroupConstant.FIELD_NAME_INDEX,index).debug().
                                                    run();
        return lstProductGroup;
    }

    /**
    * @description :Get the Subgroups from the specific parent Group with greater index
    * @author Nilesh Badrakiya | 02-13-2024 
    * @param index 
    * @param groupId 
    * @param fieldset 
    * @return List<Product_Group__c> 
    **/
    public static List<Product_Group__c> getSubGroupByIndex(Integer index, Id groupId, List<String> fieldset){
        List<Product_Group__c> lstProductGroup = new Query(ProductGroupConstant.SOBJECT_NAME).
                                                    selectFields(fieldset).
                                                    lookup(ProductGroupConstant.FIELD_NAME_PARENT_PRODUCT_GROUP,groupId).
                                                    addConditionGt(ProductGroupConstant.FIELD_NAME_INDEX,index).debug().
                                                    run();
        return lstProductGroup;
    }

    /**
    * @description : Get the subgroups from the specific parent group Excluding the specific id
    * @author Nilesh Badrakiya | 02-13-2024 
    * @param groupId 
    * @param recordId 
    * @param fieldset 
    * @return List<Product_Group__c> 
    **/
    public static List<Product_Group__c> getSubGroupByGroupExcludingId(Id groupId, Id recordId, List<String> fieldset){
        List<Product_Group__c> lstProductGroup = new Query(ProductGroupConstant.SOBJECT_NAME).
                                                    selectFields(fieldset).
                                                    lookup(ProductGroupConstant.FIELD_NAME_PARENT_PRODUCT_GROUP,groupId).
                                                    addConditionNotEq(ManagedObject.FIELD_NAME_ID,recordId).debug().
                                                    run();
        return lstProductGroup;
    }

    /**
    * @description : Get the Parentgroups from the specific Quote Excluding the specific id
    * @author Nilesh Badrakiya | 02-13-2024 
    * @param quoteId 
    * @param recordId 
    * @param fieldset 
    * @return List<Product_Group__c> 
    **/
    public static List<Product_Group__c> getGroupsByQuoteExcludingId(Id quoteId, Id recordId, List<String> fieldset){
        List<Product_Group__c> lstProductGroup = new Query(ProductGroupConstant.SOBJECT_NAME).
                                                    selectFields(fieldset).
                                                    lookup(ProductGroupConstant.FIELD_NAME_QUOTE,quoteId).
                                                    addConditionNotEq(ManagedObject.FIELD_NAME_ID,recordId).debug().
                                                    run();
        return lstProductGroup;
    }

    /**
    * @description : Get the SubGroups and related QuoteLineItems from the specific parentGroup
    * @author Nilesh Badrakiya | 02-13-2024 
    * @param parentId 
    * @param quoteLineFieldset 
    * @param fieldset 
    * @return List<Product_Group__c> 
    **/
    public static List<Product_Group__c> getSubgroupsAndRelatedQuoteLineByParentGroup(Id parentId, List<String> quoteLineFieldset, List<String> fieldset){
        List<Product_Group__c> lstProductGroup = new Query(ProductGroupConstant.SOBJECT_NAME).
                                                    selectFields(fieldset).
                                                    addSubquery(
                                                        Query.subquery(ProductGroupConstant.RELATIONSHIP_QUOTE_LINE_ITEMS).
                                                        selectFields(quoteLineFieldset)).
                                                    lookup(ProductGroupConstant.FIELD_NAME_PARENT_PRODUCT_GROUP,parentId).debug().
                                                    run();
        return lstProductGroup;
    }

    /**
    * @description :get Product Groups on the Quote
    * @author Nilesh Badrakiya | 02-13-2024 
    * @param quoteId 
    * @param fieldset 
    * @return List<Product_Group__c> 
    **/
    public static List<Product_Group__c> getRecordByQuote(Id quoteId, List<String> fieldset){
        List<Product_Group__c> lstProductGroup = new Query(ProductGroupConstant.SOBJECT_NAME).
                                                    selectFields(fieldset).
                                                    lookup(ProductGroupConstant.FIELD_NAME_QUOTE,quoteId).debug().
                                                    run();
        return lstProductGroup;
    }

    /**
    * @description :get all ProductGroup under a specific parent group
    * @author Nilesh Badrakiya | 02-13-2024 
    * @param recordId 
    * @param fieldset 
    * @return List<Product_Group__c> 
    **/
    public static List<Product_Group__c> getProductGroupAndRelatedSubGroupById(Id recordId, List<String> fieldset){
        List<Product_Group__c> lstProductGroup = new Query(ProductGroupConstant.SOBJECT_NAME).
                                                    selectFields(fieldset).
                                                    addCondition(
                                                        Query.doOr(
                                                            Query.ConditionEq(ProductGroupConstant.FIELD_NAME_PARENT_PRODUCT_GROUP,recordId),
                                                            Query.ConditionEq(ManagedObject.FIELD_NAME_ID,recordId))).debug().
                                                    run();
        return lstProductGroup;

    }

    /**
    * @description : Get the Subgroup on specific Quote of Specific parent Group.
    * @author Nilesh Badrakiya | 02-13-2024 
    * @param quoteId 
    * @param parentGroupId 
    * @param fieldset 
    * @return Product_Group__c 
    **/
    public static Product_Group__c getrecordByParentProductGroupAndQuote(Id quoteId, Id parentGroupId, List<String> fieldset){
        Product_Group__c productGroup = (Product_Group__c)new Query(ProductGroupConstant.SOBJECT_NAME).
                                                                selectFields(fieldset).
                                                                lookup(ProductGroupConstant.FIELD_NAME_QUOTE,quoteId).
                                                                lookup(ProductGroupConstant.FIELD_NAME_PARENT_PRODUCT_GROUP,parentGroupId).debug().
                                                                fetch();
        return productGroup;

    }

    /**
    * @description : Get the Parent Group from the specific Quote
    * @author Nilesh Badrakiya | 02-13-2024 
    * @param quoteId 
    * @param fieldset 
    * @return Product_Group__c 
    **/
    public static Product_Group__c getParentGroupByQuote(Id quoteId, List<String> fieldset){
        Product_Group__c productGroup = (Product_Group__c)new Query(ProductGroupConstant.SOBJECT_NAME).
                                                                selectFields(fieldset).
                                                                lookup(ProductGroupConstant.FIELD_NAME_QUOTE,quoteId).
                                                                addConditionNotNull(ProductGroupConstant.FIELD_NAME_PARENT_PRODUCT_GROUP).debug().
                                                                fetch();
        return productGroup;
    }

    
}