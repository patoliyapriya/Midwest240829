/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 03-29-2024
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class PriceBookEntryQueryHelper {
    
    /**
    * @description : Get pricebook entries related to the Midwest Office.
    * @author Nilesh Badrakiya | 03-20-2024 
    * @param office 
    * @return List<PricebookEntry> 
    **/
    public static List<PricebookEntry> getPriceBookEnteriesByOffice(String office) {

        List<PriceBookEntry> priceBookEnteries = new Query(PriceBookEntryConstants.SOBJECT_NAME).
                                                    selectField(ManagedObject.FIELD_NAME_ID).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_NAME).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_CODE).
                                                    selectField(PriceBookEntryConstants.FIELD_NAME_LIST_PRICE).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_DESCRIPTION).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_MANUFACTURER).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_ID).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_TYPE).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_HIDE_PRODUCT).
                                                    addConditionEq(PriceBookEntryConstants.RELATIONSHIP_PRICEBOOK_IS_STANDARD,true).
                                                    addConditionIncludes(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_MIDWEST_GROUP_OFFICE,office).
                                                    orderBy(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_NAME,PriceBookEntryConstants.CONSTANT_ASC).
                                                    setLimit(20).
                                                    run();
        return priceBookEnteries;
    }

    /**
    * @description : Returns the searched PricebookEnteries 
    * @author Nilesh Badrakiya | 03-28-2024 
    * @param office 
    * @param searchKeyword 
    * @return List<PricebookEntry> 
    **/
    public static List<PricebookEntry> getSearchedPricebookEntriesByOffice(String office, String searchKeyword) {

        searchKeyword = '%' + searchKeyword + '%';
        List<PricebookEntry> priceBookEnteries = new Query(PriceBookEntryConstants.SOBJECT_NAME).
                                                    selectField(ManagedObject.FIELD_NAME_ID).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_NAME).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_CODE).
                                                    selectField(PriceBookEntryConstants.FIELD_NAME_LIST_PRICE).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_DESCRIPTION).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_MANUFACTURER).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_ID).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_TYPE).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_HIDE_PRODUCT).
                                                    addCondition(
                                                        Query.doAnd(
                                                            Query.conditionEq(PriceBookEntryConstants.RELATIONSHIP_PRICEBOOK_IS_STANDARD,true),
                                                            Query.conditionIncludes(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_MIDWEST_GROUP_OFFICE,office),
                                                            Query.doOr(
                                                                Query.conditionLike(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_NAME,searchKeyword),
                                                                Query.conditionLike(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_CODE,searchKeyword),
                                                                Query.conditionLike(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_DESCRIPTION,searchKeyword),
                                                                Query.conditionLike(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_MANUFACTURER,searchKeyword)
                                                            )
                                                        )
                                                    ).
                                                    orderBy(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_NAME,PriceBookEntryConstants.CONSTANT_ASC).
                                                    setLimit(20).
                                                    run();
        return priceBookEnteries;
    }

    /**
    * @description : Get the Next Pricebook entries
    * @author Nilesh Badrakiya | 03-25-2024 
    * @param office 
    * @param lastProductName 
    * @return List<PricebookEntry> 
    **/
    public static List<PricebookEntry> getNextPriceBookEnteriesByOffice(String office, String lastProductName) {
        
        List<PriceBookEntry> priceBookEnteries = new Query(PriceBookEntryConstants.SOBJECT_NAME).
                                                    selectField(ManagedObject.FIELD_NAME_ID).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_NAME).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_CODE).
                                                    selectField(PriceBookEntryConstants.FIELD_NAME_LIST_PRICE).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_DESCRIPTION).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_MANUFACTURER).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_ID).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_TYPE).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_HIDE_PRODUCT).
                                                    addConditionEq(PriceBookEntryConstants.RELATIONSHIP_PRICEBOOK_IS_STANDARD,true).
                                                    addConditionIncludes(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_MIDWEST_GROUP_OFFICE,office).
                                                    addConditionGt(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_NAME,lastProductName).
                                                    orderBy(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_NAME,PriceBookEntryConstants.CONSTANT_ASC).
                                                    setLimit(20).
                                                    run();
        return priceBookEnteries;
    }

    /**
    * @description : Get the Next Pricebook entries by Search Keyword
    * @author Nilesh Badrakiya | 03-28-2024 
    * @param office 
    * @param lastProductName 
    * @param searchKeyword 
    * @return List<PricebookEntry> 
    **/
    public static List<PricebookEntry> getNextPriceBookEnteriesByOffice(String office, String lastProductName, String searchKeyword) {

        searchKeyword = '%' + searchKeyword + '%';
        List<PricebookEntry> priceBookEnteries = new Query(PriceBookEntryConstants.SOBJECT_NAME).
                                                    selectField(ManagedObject.FIELD_NAME_ID).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_NAME).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_CODE).
                                                    selectField(PriceBookEntryConstants.FIELD_NAME_LIST_PRICE).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_DESCRIPTION).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_MANUFACTURER).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_ID).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_TYPE).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_HIDE_PRODUCT).
                                                    addCondition(
                                                        Query.doAnd(
                                                            Query.conditionEq(PriceBookEntryConstants.RELATIONSHIP_PRICEBOOK_IS_STANDARD,true),
                                                            Query.conditionIncludes(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_MIDWEST_GROUP_OFFICE,office),
                                                            Query.conditionGt(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_NAME,lastProductName),
                                                            Query.doOr(
                                                                Query.conditionLike(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_NAME,searchKeyword),
                                                                Query.conditionLike(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_CODE,searchKeyword),
                                                                Query.conditionLike(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_DESCRIPTION,searchKeyword),
                                                                Query.conditionLike(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_MANUFACTURER,searchKeyword)
                                                            )
                                                        )
                                                    ).
                                                    orderBy(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_NAME,PriceBookEntryConstants.CONSTANT_ASC).
                                                    setLimit(20).
                                                    run();
        return priceBookEnteries;
    }

    /**
    * @description : Get the Previous Pricebook entries
    * @author Nilesh Badrakiya | 03-25-2024 
    * @param office 
    * @param firstProductName 
    * @return List<PricebookEntry> 
    **/
    public static List<PricebookEntry> getPreviousPriceBookEnteriesByOffice(String office, String firstProductName) {

        List<PriceBookEntry> priceBookEnteries = new Query(PriceBookEntryConstants.SOBJECT_NAME).
                                                    selectField(ManagedObject.FIELD_NAME_ID).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_NAME).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_CODE).
                                                    selectField(PriceBookEntryConstants.FIELD_NAME_LIST_PRICE).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_DESCRIPTION).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_MANUFACTURER).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_ID).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_TYPE).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_HIDE_PRODUCT).
                                                    addConditionEq(PriceBookEntryConstants.RELATIONSHIP_PRICEBOOK_IS_STANDARD,true).
                                                    addConditionIncludes(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_MIDWEST_GROUP_OFFICE,office).
                                                    addConditionLt(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_NAME,firstProductName).
                                                    orderBy(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_NAME,PriceBookEntryConstants.CONSTANT_DESC).
                                                    setLimit(20).
                                                    run();
        return priceBookEnteries;
    }

    /**
    * @description  Get the Previous Pricebook entries by Search Keyword
    * @author Nilesh Badrakiya | 03-28-2024 
    * @param office 
    * @param firstProductName 
    * @param searchKeyword 
    * @return List<PricebookEntry> 
    **/
    public static List<PricebookEntry> getPreviousPriceBookEnteriesByOffice(String office, String firstProductName, String searchKeyword) {

        searchKeyword = '%' + searchKeyword + '%';
        List<PricebookEntry> priceBookEnteries = new Query(PriceBookEntryConstants.SOBJECT_NAME).
                                                    selectField(ManagedObject.FIELD_NAME_ID).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_NAME).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_CODE).
                                                    selectField(PriceBookEntryConstants.FIELD_NAME_LIST_PRICE).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_DESCRIPTION).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_MANUFACTURER).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_ID).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_TYPE).
                                                    selectField(PriceBookEntryConstants.RELATIONSHIP_HIDE_PRODUCT).
                                                    addCondition(
                                                        Query.doAnd(
                                                            Query.conditionEq(PriceBookEntryConstants.RELATIONSHIP_PRICEBOOK_IS_STANDARD,true),
                                                            Query.conditionIncludes(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_MIDWEST_GROUP_OFFICE,office),
                                                            Query.conditionLt(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_NAME,firstProductName),
                                                            Query.doOr(
                                                                Query.conditionLike(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_NAME,searchKeyword),
                                                                Query.conditionLike(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_CODE,searchKeyword),
                                                                Query.conditionLike(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_DESCRIPTION,searchKeyword),
                                                                Query.conditionLike(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_MANUFACTURER,searchKeyword)
                                                            )
                                                        )
                                                    ).
                                                    orderBy(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_NAME,PriceBookEntryConstants.CONSTANT_DESC).
                                                    setLimit(20).
                                                    run();
        return priceBookEnteries;
    }

    /**
    * @description : Get total pricebook enteries related to the Office
    * @author Nilesh Badrakiya | 03-25-2024 
    * @param office 
    * @return Integer 
    **/
    public static Integer getTotalPriceBookEnteries(String office) {

        AggregateResult result = new Query(PriceBookEntryConstants.SOBJECT_NAME).
                                    count(ManagedObject.FIELD_NAME_ID,PriceBookEntryConstants.CONSTANT_TOTAL_PRODUCTS).
                                    addConditionEq(PriceBookEntryConstants.RELATIONSHIP_PRICEBOOK_IS_STANDARD,true).
                                    addConditionIncludes(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_MIDWEST_GROUP_OFFICE,office).
                                    aggregate()[0];
        return (Integer)result.get(PriceBookEntryConstants.CONSTANT_TOTAL_PRODUCTS);
    }

    /**
    * @description : Get total pricebook enteries related to the Office by search Keyword
    * @author Nilesh Badrakiya | 03-28-2024 
    * @param office 
    * @param searchKeyword 
    * @return Integer 
    **/
    public static Integer getTotalPriceBookEnteries(String office, String searchKeyword) {

        searchKeyword = '%' + searchKeyword + '%';
        AggregateResult result = new Query(PriceBookEntryConstants.SOBJECT_NAME).
                                    count(ManagedObject.FIELD_NAME_ID,PriceBookEntryConstants.CONSTANT_TOTAL_PRODUCTS).
                                    addCondition(
                                        Query.doAnd(
                                            Query.conditionEq(PriceBookEntryConstants.RELATIONSHIP_PRICEBOOK_IS_STANDARD,true),
                                            Query.conditionIncludes(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_MIDWEST_GROUP_OFFICE,office),
                                            Query.doOr(
                                                Query.conditionLike(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_NAME,searchKeyword),
                                                Query.conditionLike(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_CODE,searchKeyword),
                                                Query.conditionLike(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_DESCRIPTION,searchKeyword),
                                                Query.conditionLike(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_MANUFACTURER,searchKeyword)
                                            )
                                        )
                                    ).
                                    aggregate()[0];
        return (Integer)result.get(PriceBookEntryConstants.CONSTANT_TOTAL_PRODUCTS);
    }

    /**
    * @description : Get the Previous Pricebook entries
    * @author Nilesh Badrakiya | 03-25-2024 
    * @param productId
    * @return List<PricebookEntry> 
    **/
    public static PricebookEntry getPriceBookEntryByProductId(Id productId) {

        List<PricebookEntry> priceBookEntries = new Query(PriceBookEntryConstants.SOBJECT_NAME).
                                                    selectField(ManagedObject.FIELD_NAME_ID).
                                                    selectField(PriceBookEntryConstants.FIELD_NAME_LIST_PRICE).
                                                    addConditionEq(PriceBookEntryConstants.RELATIONSHIP_PRICEBOOK_IS_STANDARD,true).
                                                    addConditionEq(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_ID,productId).
                                                    run();
        if (!priceBookEntries.isEmpty()) {
            return priceBookEntries[0];
        } else {
            return null;
        }
    }


    public static PricebookEntry getDefaultFreightProduct(String office) {
        PricebookEntry priceBookEntry = (PricebookEntry)new Query(PriceBookEntryConstants.SOBJECT_NAME).
                                        selectField(ManagedObject.FIELD_NAME_ID).
                                        selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_NAME).
                                        selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_CODE).
                                        selectField(PriceBookEntryConstants.FIELD_NAME_LIST_PRICE).
                                        selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_DESCRIPTION).  
                                        selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_MANUFACTURER).
                                        selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_ID).  
                                        selectField(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_TYPE).
                                        selectField(PriceBookEntryConstants.RELATIONSHIP_HIDE_PRODUCT).
                                        addConditionEq(PriceBookEntryConstants.RELATIONSHIP_PRICEBOOK_IS_STANDARD,true).
                                        addConditionEq(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_NAME,'Freight').
                                        addConditionIncludes(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_MIDWEST_GROUP_OFFICE,office).
                                        orderBy(PriceBookEntryConstants.RELATIONSHIP_PRODUCT_NAME,PriceBookEntryConstants.CONSTANT_ASC).
                                        setLimit(1).
                                        fetch();
        return priceBookEntry;
    }
}