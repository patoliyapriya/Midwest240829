/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 04-08-2024
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class ProductQueryHelper {
   
    /**
    * @description : Returns the list of Products related to the Id
    * @author Nilesh Badrakiya | 04-08-2024 
    * @param ProductIds 
    * @return List<Product2> 
    **/
    public static List<Product2> getProductsByProductIds(List<Id> ProductIds) {

        List<Product2> products = new Query(ProductConstants.SOBJECT_NAME).
                                                    selectField(ManagedObject.FIELD_NAME_ID).
                                                    selectField(ManagedObject.FIELD_NAME_NAME).
                                                    selectField(ProductConstants.FIELD_NAME_PRODUCT_CODE).
                                                    selectField(ProductConstants.FIELD_NAME_DESCRIPTION).
                                                    selectField(ProductConstants.FIELD_NAME_MANUFACTURER).
                                                    selectField(ProductConstants.FIELD_NAME_FAMILY).
                                                    selectField(ProductConstants.FIELD_NAME_HIDE_PRODUCT).
                                                    selectField(ProductConstants.FIELD_NAME_WEIGHT).
                                                    selectField(ProductConstants.FIELD_NAME_PRODUCT_TYPE).
                                                    addConditionIn(ManagedObject.FIELD_NAME_ID,ProductIds).
                                                    run();
        return products;
    }
}