/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 03-21-2024
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class QuoteConstants {
    
    // sobject name
    public static final String SOBJECT_NAME = 'Quote';
	
    // field names
    public static final String FIELD_NAME_QUOTE_NUMBER = 'QuoteNumber';
    public static final String FIELD_NAME_TOTAL_BASE_BID_TOTAL = 'Total_Base_Bid_Total__c	';
    public static final string FIELD_NAME_HIDE_TOTAL_BASE_BID_TOTAL = 'Hide_Total_Base_Bid_Total__c';
    public static final String FIELD_NAME_TOTAL_EXTENDED_COST = 'Total_Extended_Cost__c';
    public static final String FIELD_NAME_TOTAL_DIRECT_SELL_PRICE = 'Total_Direct_Sell_Price__c';
    public static final String FIELD_NAME_TOTAL_BUY_RESELL_PRICE = 'Total_Buy_Resell_Price__c';
    public static final String FIELD_NAME_TOTAL_BUY_RESELL_MARGIN = 'Total_Buy_Resell_Margin__c';
    public static final String FIELD_NAME_TOTAL_BUY_RESELL_MARGIN_PERCENTAGE = 'Total_Buy_Resell_Margin_Percentage__c';
    public static final String FIELD_NAME_COMMISSIONS_AND_REBATES = 'Commissions_and_Rebates__c';
    public static final String FIELD_NAME_TOTAL_PROJECT_MARGIN = 'Total_Project_Margin__c';
    public static final String FIELD_NAME_TOTAL_PROJECT_MARGIN_PERCENTAGE = 'Total_Project_Margin_Percentage__c';
    public static final String FIELD_NAME_QUANTITY_TOTAL = 'Quantity_Total__c';
    public static final String FIELD_NAME_IS_ACTIVE_PROJECT_FINANCIALS = 'Is_Active_Project_Financials__c';
    public static final String FIELD_NAME_ATTENTION_TO_ACCOUNT = 'Attention_to_Account__c';

    // Relation Fields
    public static final String RELATIONSHIP_OPPORTUNITY_OFFICE = 'Opportunity.Office__c';
    public static final String RELATIONSHIP_OPPORTUNITY_TAXABLE = 'Opportunity.Account.Is_Taxable__c';
    public static final String RELATIONSHIP_OPPORTUNITY_ACCOUNT_ID = 'Opportunity.AccountId';
    public static final String RELATIONSHIP_OPPORTUNITY_ID = 'OpportunityId';
    public static final String RELATIONSHIP_OPPORTUNITY_NAME = 'Opportunity_Name__c'; 
    public static final String RELATIONSHIP_OPPORTUNITY_LEDGER = 'Opportunity.Ledger__c';

}