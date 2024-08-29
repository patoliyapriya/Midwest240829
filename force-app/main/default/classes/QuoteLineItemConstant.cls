/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 02-13-2024
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class QuoteLineItemConstant {
    
    // sobject name
	public static final String SOBJECT_NAME = 'Product_Select__c';

    //constant
    public static final String CONSTANT_TOTAL_RECORD = 'totalRecord';
    public static final String CONSTANT_SALE_TYPE_CR = 'C/R';
    public static final String CONSTANT_SALE_TYPE_DS = 'D/S';
	
	// field names
	public static final String FIELD_NAME_PRODUCT_NAME = 'Product_Name__c';
	public static final String FIELD_NAME_PRODUCT_GROUP = 'Product_Group__c';
	public static final String FIELD_NAME_ROW_INDEX = 'Row_Index__c';
    public static final String FIELD_NAME_QUOTE = 'Quote__c';
    public static final String FIELD_NAME_ALTERNATE = 'Alternate__c';
    public static final String FIELD_NAME_SALE_TYPE = 'Sale_Type__c';
    public static final String FIELD_NAME_CR = 'CR__c';
    public static final String FIELD_NAME_SALE_PRICE = 'Sales_Price__c';
    public static final String FIELD_NAME_MARGIN = 'Margin__c';
    public static final String FIELD_NAME_IS_BILLING_CREATED = 'IsBillingCreated__c';
    public static final String FIELD_NAME_HIDE_LINE = 'Hide_Line__c';
    public static final String FIELD_NAME_HIDE_LINE_ON_EMAIL = 'Hide_Line_On_Email__c';
    public static final String FIELD_NAME_HIDE_LINE_ON_EMAIL_STARTUP = 'Hide_Line_On_Email_Startup__c';

    //Relationship
    public static final String RELATIONSHIP_PRODUCT_GROUP_ALTERNATE = 'Product_Group__r.Alternate__c';
    public static final String RELATIONSHIP_PRODUCT_GROUP_PARENT_GROUP_ALTERNATE = 'Product_Group__r.Parent_Product_Group__r.Alternate__c';
    public static final String RELATIONSHIP_QUOTE_ACTIVE_PROJECT_FINANCIALS = 'Quote__r.Is_Active_Project_Financials__c';
    public static final String RELATIONSHIP_QUOTE_OPPORTUNITY_ID = 'Quote__r.OpportunityId';
}