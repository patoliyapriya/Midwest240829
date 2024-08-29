/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 01-04-2024
 * @last modified by  : Nilesh Badrakiya
**/
trigger QuoteLineItemTrigger on Product_Select__c (after update, before delete) {

    if(Trigger.isUpdate && Trigger.isAfter){
        set<Id> quoteLineWithUpdatedDescription = new set<Id>();

        for (Product_Select__c QL : trigger.new) {
            if (trigger.newMap.get(QL.Id).Descriptions__c 
                != trigger.oldMap.get(QL.Id).Descriptions__c) {
                    quoteLineWithUpdatedDescription.add(QL.Id);
            }
        }
        if(!quoteLineWithUpdatedDescription.isEmpty()) {
            List<AcctSeedERP__Sales_Order_Line__c> SOLinesToUpdate = new List<AcctSeedERP__Sales_Order_Line__c>();
            List<AcctSeed__Billing_Line__c> billingLinesToUpdate = new List<AcctSeed__Billing_Line__c>();

            for (AcctSeedERP__Sales_Order_Line__c lineItem : [SELECT Id,
                                                                Description__c,
                                                                Quote_Line_Item__c
                                                            FROM AcctSeedERP__Sales_Order_Line__c
                                                            WHERE Quote_Line_Item__c IN :quoteLineWithUpdatedDescription]) {
                
                lineItem.Description__c = trigger.newMap.get(lineItem.Quote_Line_Item__c).Descriptions__c;
                SOLinesToUpdate.add(lineItem);
            }

            for (AcctSeed__Billing_Line__c lineItem : [SELECT Id,
                                                                Description__c,
                                                                AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__c
                                                            FROM AcctSeed__Billing_Line__c
                                                            WHERE AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__c IN :quoteLineWithUpdatedDescription]) {
                lineItem.Description__c = trigger.newMap.get(lineItem.AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__c).Descriptions__c;
                billingLinesToUpdate.add(lineItem);
            }

            if(!SOLinesToUpdate.isEmpty()) {
                update SOLinesToUpdate;
            }
            if (!billingLinesToUpdate.isEmpty()) {
                update billingLinesToUpdate;
            }
        }
    }

    if(Trigger.isDelete && Trigger.isBefore){
        Set<Id> lockedQuoteLineItems = new Set<Id>();

        for (Product_Select__c deletedQuoteLineItem : Trigger.old) {
            if (deletedQuoteLineItem.Is_Locked__c) {
                // Add the Id of locked Quote Line Item to the set
                lockedQuoteLineItems.add(deletedQuoteLineItem.Id);
            }
        }

        if (!lockedQuoteLineItems.isEmpty()) {
            for (Id lockedId : lockedQuoteLineItems) {
                Trigger.oldMap.get(lockedId).addError('Cannot delete a locked Quote Line Item.');
            }
        }
    }
    

}