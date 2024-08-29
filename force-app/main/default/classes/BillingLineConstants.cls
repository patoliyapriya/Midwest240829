/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 02-14-2024
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class BillingLineConstants {
    
    // sobject name
	public static final String SOBJECT_NAME = 'AcctSeed__Billing_Line__c';
	
	// field names
    public static final String FIELD_NAME_DESCRIPTION = 'Description__c';
	
    //Relationship
    public static final String RELATIONSHIP_QUOTE_LINE_ITEM = 'AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__c';
}