/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 04-24-2024
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class QuoteQueryHelper {
    
    /**
    * @description : Retrieve the Quote by given ID
    * @author Nilesh Badrakiya | 03-15-2024 
    * @param quoteId 
    * @return Quote 
    **/
    public static Quote getQuoteById(Id quoteId){
        
        Quote quote = (Quote)new Query(QuoteConstants.SOBJECT_NAME).
                    selectField(ManagedObject.FIELD_NAME_ID).
                    selectField(ManagedObject.FIELD_NAME_NAME).
                    selectField(ManagedObject.FIELD_NAME_RECORDTYPE_NAME).
                    selectField(QuoteConstants.FIELD_NAME_QUOTE_NUMBER).
                    selectField(QuoteConstants.FIELD_NAME_TOTAL_BASE_BID_TOTAL).
                    selectField(QuoteConstants.FIELD_NAME_HIDE_TOTAL_BASE_BID_TOTAL).
                    selectField(QuoteConstants.FIELD_NAME_TOTAL_EXTENDED_COST).
                    selectField(QuoteConstants.FIELD_NAME_TOTAL_DIRECT_SELL_PRICE).
                    selectField(QuoteConstants.FIELD_NAME_TOTAL_BUY_RESELL_PRICE).
                    selectField(QuoteConstants.FIELD_NAME_TOTAL_BUY_RESELL_MARGIN).
                    selectField(QuoteConstants.FIELD_NAME_TOTAL_BUY_RESELL_MARGIN_PERCENTAGE).
                    selectField(QuoteConstants.FIELD_NAME_COMMISSIONS_AND_REBATES).
                    selectField(QuoteConstants.FIELD_NAME_TOTAL_PROJECT_MARGIN).
                    selectField(QuoteConstants.FIELD_NAME_TOTAL_PROJECT_MARGIN_PERCENTAGE).
                    selectField(QuoteConstants.FIELD_NAME_QUANTITY_TOTAL).
                    selectField(QuoteConstants.RELATIONSHIP_OPPORTUNITY_OFFICE).
                    selectField(QuoteConstants.RELATIONSHIP_OPPORTUNITY_TAXABLE).
                    selectField(QuoteConstants.FIELD_NAME_IS_ACTIVE_PROJECT_FINANCIALS).
                    selectField(QuoteConstants.FIELD_NAME_ATTENTION_TO_ACCOUNT).
                    selectField(QuoteConstants.RELATIONSHIP_OPPORTUNITY_LEDGER).
                    selectField(QuoteConstants.RELATIONSHIP_OPPORTUNITY_ID).
                    selectField(QuoteConstants.RELATIONSHIP_OPPORTUNITY_ACCOUNT_ID).
                    byId(quoteId).
                    fetch();
        return quote;
    }


    /**
    * @description : Retrieve the Quote by given ID
    * @author Nilesh Badrakiya | 03-15-2024 
    * @param opportunityId 
    * @return Quote 
    **/
    public static List<Quote> getQuoteByOpportunityId(Id opportunityId){
        
        List<Quote> quote = new Query(QuoteConstants.SOBJECT_NAME).
                    selectField(ManagedObject.FIELD_NAME_NAME).
                    selectField(QuoteConstants.RELATIONSHIP_OPPORTUNITY_NAME).
                    lookup(QuoteConstants.RELATIONSHIP_OPPORTUNITY_ID,opportunityId).
                    run();
        return quote;
    }
}