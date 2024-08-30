/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 03-25-2024
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class PriceBookEntryConstants {
    
    // sobject name
    public static final String SOBJECT_NAME = 'PricebookEntry';
	
    // field names
    public static final String FIELD_NAME_LIST_PRICE = 'UnitPrice';
    public static final String FIELD_NAME_TOTAL_BASE_BID_TOTAL = 'Total_Base_Bid_Total__c';

    // Relation Fields
    public static final String RELATIONSHIP_PRODUCT_NAME = 'Product2.Name';
    public static final String RELATIONSHIP_PRODUCT_CODE = 'Product2.ProductCode';
    public static final String RELATIONSHIP_PRODUCT_DESCRIPTION = 'Product2.Description';
    public static final String RELATIONSHIP_PRODUCT_MANUFACTURER = 'Product2.Manufacturer__c';
    public static final String RELATIONSHIP_PRODUCT_MIDWEST_GROUP_OFFICE = 'Product2.Midwest_Group_Office__c';
    public static final String RELATIONSHIP_PRICEBOOK_IS_STANDARD = 'Pricebook2.IsStandard';
    public static final String RELATIONSHIP_PRODUCT_ID = 'Product2.Id';
    public static final String RELATIONSHIP_PRODUCT_TYPE = 'Product2.Product_Type__c';
    public static final String RELATIONSHIP_HIDE_PRODUCT = 'Product2.HideProduct__c';

    //constant
    public static final String CONSTANT_ASC = 'ASC';
    public static final String CONSTANT_DESC = 'DESC';
    public static final String CONSTANT_TOTAL_PRODUCTS = 'totalProducts';
}