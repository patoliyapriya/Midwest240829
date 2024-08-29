/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 02-14-2024
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class BillingLineQueryHelper {
    
    /**
    * @description : Get the Billing Line Item Related to Quote Line Item.
    * @author Nilesh Badrakiya | 02-14-2024 
    * @param quoteLineItemId 
    * @param fieldset 
    * @return List<AcctSeed__Billing_Line__c> 
    **/
    public static List<AcctSeed__Billing_Line__c> getrecordByQuoteLineItem(Set<Id> quoteLineItemId, List<String> fieldset){
        List<AcctSeed__Billing_Line__c> lstRecord = new Query(BillingLineConstants.SOBJECT_NAME).
                                selectFields(fieldset).
                                addConditionIn(BillingLineConstants.RELATIONSHIP_QUOTE_LINE_ITEM,quoteLineItemId).debug().
                                run();
        return lstRecord;
    }
}