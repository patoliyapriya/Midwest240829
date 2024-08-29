/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 02-14-2024
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class SalesOrderLineQueryHelper {
    
    /**
    * @description : Get the Sales Order Line Item Related to QuoteLineItem
    * @author Nilesh Badrakiya | 02-14-2024 
    * @param quoteLineItemId 
    * @param fieldset 
    * @return List<AcctSeedERP__Sales_Order_Line__c> 
    **/
    public static List<AcctSeedERP__Sales_Order_Line__c> getrecordByQuoteLineItem(Set<Id> quoteLineItemId, List<String> fieldset){
        List<AcctSeedERP__Sales_Order_Line__c> lstRecord = new Query(SalesOrderLineConstants.SOBJECT_NAME).
                                selectFields(fieldset).
                                lookup(SalesOrderLineConstants.FIELD_NAME_QUOTE_LINE_ITEM,quoteLineItemId).debug().
                                run();
        return lstRecord;
    }
}