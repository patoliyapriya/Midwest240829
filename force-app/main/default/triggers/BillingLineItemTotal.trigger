trigger BillingLineItemTotal on AcctSeed__Billing_Line__c (after insert, after update, after delete) {
    
    Set<ID> setBillingId = new Set<ID>();

    List<AcctSeed__Billing_Line__c> lstBillingLine = (Trigger.isInsert || Trigger.isUpdate) ? Trigger.new : Trigger.old;

    for (AcctSeed__Billing_Line__c billingLineItem : lstBillingLine) {
        setBillingId.add(billingLineItem.AcctSeed__Billing__c);
    }

    List<AcctSeed__Billing__c> lstBilling = [SELECT AcctSeed__Opportunity__c
                                            FROM AcctSeed__Billing__c
                                            WHERE ID IN : setBillingId
                                            AND AcctSeed__Opportunity__c != NULL];
    
    Set<ID> setOpportunityId = new Set<ID>();
    for (AcctSeed__Billing__c billing : lstBilling) {
        setOpportunityId.add(billing.AcctSeed__Opportunity__c);
    }

    List<AggregateResult> lstTotalBillingLineCR = [SELECT AcctSeed__Billing__r.AcctSeed__Opportunity__c,
                                                    SUM(AcctSeed__Total__c) total
                                                    FROM AcctSeed__Billing_Line__c
                                                    WHERE AcctSeed__Billing__r.AcctSeed__Opportunity__c IN :setOpportunityId
                                                    AND AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__r.Sale_Type__c = 'C/R'
                                                    GROUP BY AcctSeed__Billing__r.AcctSeed__Opportunity__c];

    List<AggregateResult> lstTotalBillingLineBR = [SELECT AcctSeed__Billing__r.AcctSeed__Opportunity__c,
                                                    SUM(AcctSeed__Total__c) total
                                                    FROM AcctSeed__Billing_Line__c
                                                    WHERE AcctSeed__Billing__r.AcctSeed__Opportunity__c IN :setOpportunityId
                                                    AND AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__r.Sale_Type__c = 'B/R'
                                                    GROUP BY AcctSeed__Billing__r.AcctSeed__Opportunity__c];

    Map<Id, Opportunity> mapOpporunityTotal = new Map<Id, Opportunity>();
    for (AggregateResult result : lstTotalBillingLineCR) {

        //AcctSeed__Billing__c objBilling = (AcctSeed__Billing__c) result.get('AcctSeed__Billing__c');
        system.debug('result==>'+result);
        ID opportunityId = (ID)result.get('AcctSeed__Opportunity__c');

        Opportunity objOpporutnity = new Opportunity();
        objOpporutnity.ID = opportunityId;
        objOpporutnity.C_R_BillingLine_Total__c = (Decimal) result.get('total');

        mapOpporunityTotal.put(opportunityId, objOpporutnity);
    }  
    
    for (AggregateResult result : lstTotalBillingLineBR) {
        //AcctSeed__Billing__c objBilling = (AcctSeed__Billing__c) result.get('AcctSeed__Billing__r');
        ID opportunityId = (ID)result.get('AcctSeed__Opportunity__c');

        Opportunity objOpporutnity = new Opportunity();

        if (mapOpporunityTotal.containsKey(opportunityId)) {
            objOpporutnity = mapOpporunityTotal.get(opportunityId);
        } else {
              objOpporutnity.ID = opportunityId;
        }
        objOpporutnity.B_R_BillingLine_Total__c = (Decimal) result.get('total');
        mapOpporunityTotal.put(opportunityId, objOpporutnity);
    } 

    List<Opportunity> lstOpportunity = mapOpporunityTotal.values();

    if (!lstOpportunity.isEmpty()) {
        update lstOpportunity;
    }

  //QuoteLineItem field isBillingCreated Checkbox is true when user create Billing & false when user delete
    if(Trigger.isAfter){
        List<Product_Select__c> tobeUpdateQuoteLineItem = new List<Product_Select__c>();
        List<AcctSeed__Billing_Line__c> billingLineItemRecord = new List<AcctSeed__Billing_Line__c>();

        if(Trigger.isInsert){
            billingLineItemRecord = Trigger.new;

            Set<ID> setBillingLineId = new Set<ID>();
            for (AcctSeed__Billing_Line__c billingLine : billingLineItemRecord) {
                setBillingLineId.add(billingLine.Id);
            }
           
            billingLineItemRecord = [SELECT id, AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__c 
                                    FROM  AcctSeed__Billing_Line__c 
                                    WHERE ID IN :setBillingLineId
                                    AND AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__c  != null];
        }else if(Trigger.isDelete){
            billingLineItemRecord = Trigger.old;
        }

        Set<Id> salesOrderLineIds = new set<Id>();
        for(AcctSeed__Billing_Line__c billingLineItem : billingLineItemRecord){
            Product_Select__c quoteLineToUpdate = new Product_Select__c();
            
            if(Trigger.isInsert){

                quoteLineToUpdate.Id = billingLineItem.AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__c;
                quoteLineToUpdate.IsBillingCreated__c = true;
            }else if(Trigger.isDelete){

                salesOrderLineIds.add(billingLineItem.AcctSeedERP__Sales_Order_Line__c);
            
            }
            tobeUpdateQuoteLineItem.add(quoteLineToUpdate);
        }
        if(Trigger.isDelete){
            List<Product_Select__c> quoteLineToUpdateAfterDelete = new List<Product_Select__c>();
            for(AcctSeedERP__Sales_Order_Line__c salesOrderLine : [SELECT Id, Quote_Line_Item__c FROM AcctSeedERP__Sales_Order_Line__c 
                                                                    WHERE Id IN :salesOrderLineIds AND Quote_Line_Item__c!= null]){
                Product_Select__c quoteLineToUpdate = new Product_Select__c();
                quoteLineToUpdate.Id = salesOrderLine.Quote_Line_Item__c;
                quoteLineToUpdate.IsBillingCreated__c = false;  
                quoteLineToUpdateAfterDelete.add(quoteLineToUpdate);    
                
            } 
            if(!quoteLineToUpdateAfterDelete.isEmpty()){
                system.debug('BiliningLineItemTrigger deleted record :- ' +quoteLineToUpdateAfterDelete.size());
                update quoteLineToUpdateAfterDelete;
            } 
        }
        
        if(Trigger.isInsert && !tobeUpdateQuoteLineItem.isEmpty()){
            system.debug('BillingLineItem update successfully :- ' +tobeUpdateQuoteLineItem.size()); 
            update tobeUpdateQuoteLineItem;
        }
    }
}