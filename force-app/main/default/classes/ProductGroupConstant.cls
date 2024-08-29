/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 02-13-2024
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class ProductGroupConstant {
   // sobject name
	public static final String SOBJECT_NAME = 'Product_Group__c';

    //constant
    public static final String CONSTANT_TOTAL_RECORD = 'totalRecord';
    public static final String CONSTANT_ASC = 'ASC';
	
	// field names
	public static final String FIELD_NAME_QUOTE = 'Quote__c';
	public static final String FIELD_NAME_PARENT_PRODUCT_GROUP = 'Parent_Product_Group__c';
    public static final String FIELD_NAME_INDEX = 'Index__c';

    //Relationship
    public static final String RELATIONSHIP_QUOTE_LINE_ITEMS = 'Quote_Line_Items__r';
    public static final String RELATIONSHIP_PRODUCT_GROUPS = 'ProductGroups__r';
}