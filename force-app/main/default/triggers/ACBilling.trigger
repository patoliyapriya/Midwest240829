trigger ACBilling on AcctSeed__Billing__c (before insert, after insert, after update, after delete, before delete) {


    List<Id> opportunityIds = new List<Id>();
    Set<Id> setSalesOrderIds = new Set<Id>();
    Id marsOppTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('MaRRS').getRecordTypeId();
    if (Trigger.isBefore && Trigger.IsInsert) {
        for(AcctSeed__Billing__c billing : Trigger.New) {
            if(billing.AcctSeed__Opportunity__c != null) {
                opportunityIds.add(billing.AcctSeed__Opportunity__c);
            }
            if(billing.AcctSeedERP__Sales_Order__c != null) {
                setSalesOrderIds.add(billing.AcctSeedERP__Sales_Order__c);
            }
            
        }  
        
        if (opportunityIds.size() > 0) {
            Map<Id,Opportunity> oppList = new Map<Id, Opportunity>([SELECT Id,
                                                                        Destination_City__c,
                                                                        Destination_Country__c,
                                                                        Destination_PostalCode__c,
                                                                        Destination_State__c,
                                                                        Destination_Street__c
                                                               FROM Opportunity
                                                               WHERE RecordTypeId = :marsOppTypeId
                                                               AND Id IN :opportunityIds]);
            if (!oppList.isEmpty()) {
                for(AcctSeed__Billing__c billing : Trigger.New) {
                    If (oppList.containsKey(billing.AcctSeed__Opportunity__c)) {
                        billing.AcctSeed__Shipping_City__c = oppList.get(billing.AcctSeed__Opportunity__c).Destination_City__c;
                        billing.AcctSeed__Shipping_Country__c = oppList.get(billing.AcctSeed__Opportunity__c).Destination_Country__c;
                        billing.AcctSeed__Shipping_PostalCode__c = oppList.get(billing.AcctSeed__Opportunity__c).Destination_PostalCode__c;
                        billing.AcctSeed__Shipping_State__c = oppList.get(billing.AcctSeed__Opportunity__c).Destination_State__c;
                        billing.AcctSeed__Shipping_Street__c = oppList.get(billing.AcctSeed__Opportunity__c).Destination_Street__c;
                    }
            }       
            }    
        }
    
        if(!setSalesOrderIds.isEmpty()) {
    
            Map<Id, AcctSeedERP__Sales_Order__c> mapSalesOrder = new Map<Id, AcctSeedERP__Sales_Order__c>();
            
            List<AcctSeedERP__Sales_Order__c> lstSalesOrder = [SELECT ID, Shipping_Name__c, 
                                                                        Customer_PO_Number__c,
                                                                        Ship_Via__c,
                                                                        Collect_Account_number__c
                                                                FROM AcctSeedERP__Sales_Order__c
                                                                WHERE ID IN :setSalesOrderIds];
            for(AcctSeedERP__Sales_Order__c so : lstSalesOrder) {
                mapSalesOrder.put(so.Id, so);
            }
    
            for(AcctSeed__Billing__c billing : Trigger.New) {
                if(billing.AcctSeedERP__Sales_Order__c != null) {
                    billing.Shipping_Name__c = mapSalesOrder.get(billing.AcctSeedERP__Sales_Order__c).Shipping_Name__c;
                    billing.AcctSeed__PO_Number__c = mapSalesOrder.get(billing.AcctSeedERP__Sales_Order__c).Customer_PO_Number__c;
                    billing.Ship_Via__c = mapSalesOrder.get(billing.AcctSeedERP__Sales_Order__c).Ship_Via__c;
                    billing.Collect_Account_number__c = mapSalesOrder.get(billing.AcctSeedERP__Sales_Order__c).Collect_Account_number__c;
                }
            }
        }
        
        if(trigger.new.size() > 0) {
            SystemUtil.generateCustomAutoNumber(trigger.new[0]);
        }

    }

    if (Trigger.isAfter && (Trigger.IsInsert || Trigger.IsUpdate || Trigger.IsDelete)) {
        set<Id> opportunityIds = new set<Id>();
        List<AcctSeed__Billing__c> billingsRecords = new List<AcctSeed__Billing__c>();
        List<Opportunity> oppListToBeUpdated = new List<Opportunity>();
        if (trigger.isInsert || trigger.isUpdate) {
            billingsRecords = trigger.new;
        }

        if (trigger.isDelete) {
            billingsRecords = trigger.old;    
        }

        for (AcctSeed__Billing__c billing : billingsRecords) {
            opportunityIds.add(billing.AcctSeed__Opportunity__c);
        }
        //billingsRecords.clear();
        List<aggregateResult> results=[SELECT AcctSeed__Opportunity__c,
                                            sum(AcctSeed__Total__c) total
                                        FROM AcctSeed__Billing__c 
                                        WHERE AcctSeed__Opportunity__c IN :opportunityIds
                                        AND AcctSeed__Opportunity__c != null
                                        GROUP BY AcctSeed__Opportunity__c];
        for (AggregateResult agResult : results) {
                Opportunity oppToUpdate = new Opportunity( Id = (Id)agResult.get('AcctSeed__Opportunity__c'),
                                                           Billings__c = (Decimal)agResult.get('total'));
                oppListToBeUpdated.add(oppToUpdate);
        }
        update oppListToBeUpdated;

        // to calcxulate Most Recent Billing Date
        if(Trigger.IsAfter && Trigger.IsInsert) {
            List<Opportunity> oppList = new List<Opportunity>();    
            for(AcctSeed__Billing__c billing : Trigger.New) {
                if (billing.AcctSeed__Opportunity__c != null) {
                    system.debug('Billing List New Size: '+Trigger.New.size());
                    Opportunity toBeUpdate = new Opportunity();
                    toBeUpdate.Id = billing.AcctSeed__Opportunity__c;
                    // Created Date will work with only after insert 
                    tobeUpdate.MostRecentBillingDate__c = billing.CreatedDate.date();
                    oppList.add(toBeUpdate);
                }
      
            }
            update oppList;    
        }

        
        if (Trigger.IsUpdate) {

            /*List<Project__c> projectListToBeUpdate = new List<Project__c>();
            for(AcctSeed__Billing__c billing : Trigger.New){
                Id oppId = billing.AcctSeed__Opportunity__c;
                Opportunity opp = [SELECT Id, Name, RecordType.Name From Opportunity where Id =: oppId];
                system.debug('the recordtype is ' + opp.RecordType.Name);
                Project__c project = [SELECT Id, Name, Project_Stage__c From Project__c where Opportunity__c =: oppId];
                if((opp.RecordType.Name == 'Parts') && (billing.AcctSeed__Opportunity__c != null) && (billing.Payment_received__c == true)){
                    system.debug('Inside the If condition');
                    project.Project_Stage__c = 'Archived';
                    projectListToBeUpdate.add(project);
                }
            }
            if(!projectListToBeUpdate.isEmpty()){
                update projectListToBeUpdate;
                system.debug('Updated List ' + projectListToBeUpdate );
            }*/
        }
        
        
    }
    
    // to calcxulate most recent billing date ( if record is Deleted then second most recent date should be update)
    if(Trigger.IsAfter && Trigger.isDelete){
  
        List<AcctSeed__Billing__c> lstBilling = Trigger.old;
        system.debug('Size of old: '+lstBilling.size());
        AcctSeed__Billing__c billing = lstBilling.get(0);
        
        List<AcctSeed__Billing__c> billingsRecords = [SELECT
                                                        CreatedDate 
                                                      FROM AcctSeed__Billing__c
                                                      WHERE AcctSeed__Opportunity__c = :billing.AcctSeed__Opportunity__c
                                                      ORDER BY CreatedDate desc limit 1];
        List<Opportunity> oppList = new List<Opportunity>(); 
        if(billingsRecords.size() > 0 &&  billing.AcctSeed__Opportunity__c != null){
            
            Opportunity oppr = new Opportunity(Id = billing.AcctSeed__Opportunity__c);
            oppr.MostRecentBillingDate__c = billingsRecords.get(0).CreatedDate.date();
            oppList.add(oppr);
            system.debug('Date updated successfully :- ' +oppList);
        }
        update oppList; 

    }

    //WhenEver user delete the Billing it releated BLT deletes and its QLT isBillingCreated field should be false
    if(Trigger.IsBefore && Trigger.isDelete){
        List<AcctSeed__Billing__c> billing = Trigger.old;
        Set<Id> QLIdsWithDeletedBilling = new Set<Id>();
        
        for (AcctSeed__Billing_Line__c billingLineItem : [SELECT ID, AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__c
                                                          FROM AcctSeed__Billing_Line__c 
                                                          WHERE AcctSeed__Billing__c IN :billing
                                                          AND AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__c != null
                                                          AND AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__r.IsBillingCreated__c = true]){
            
            QLIdsWithDeletedBilling.add(billingLineItem.AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__c);                                        
            
        }

        Set<Id> QLIdsWithExistingBilling = new Set<Id>();
        for (AcctSeed__Billing_Line__c ExistingQuoteLineWithBilling : [SELECT ID, 
                                                                        AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__c
                                                                        FROM AcctSeed__Billing_Line__c 
                                                                        WHERE AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__c IN :QLIdsWithDeletedBilling
                                                                        AND AcctSeed__Billing__c Not IN :Trigger.oldMap.keyset()]) {
            QLIdsWithExistingBilling.add(ExistingQuoteLineWithBilling.AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__c);
        }

        List<Product_Select__c> quoteLineToUpdateAfterDelete = new List<Product_Select__c>();
        for (Id QLIdToUpdate : QLIdsWithDeletedBilling) {
            if (QLIdsWithExistingBilling == null || QLIdsWithExistingBilling.size() == 0) {
                Product_Select__c quoteLineToUpdate = new Product_Select__c();
                quoteLineToUpdate.Id = QLIdToUpdate;
                quoteLineToUpdate.IsBillingCreated__c = false;  
                quoteLineToUpdateAfterDelete.add(quoteLineToUpdate);

            } else if (!QLIdsWithExistingBilling.Contains(QLIdToUpdate)) {
                Product_Select__c quoteLineToUpdate = new Product_Select__c();
                quoteLineToUpdate.Id = QLIdToUpdate;
                quoteLineToUpdate.IsBillingCreated__c = false;  
                quoteLineToUpdateAfterDelete.add(quoteLineToUpdate);
            }
        }
        system.debug('QLIdsWithExistingBilling==>'+QLIdsWithExistingBilling);
        system.debug('QLIdsWithDeletedBilling==>'+QLIdsWithDeletedBilling);
        system.debug('quoteLineToUpdateAfterDelete==>'+quoteLineToUpdateAfterDelete);
        system.debug('QLIdsWithExistingBilling==>'+QLIdsWithExistingBilling);
        if(!quoteLineToUpdateAfterDelete.isEmpty()){
            system.debug('Billing delete & QLI isBillingCreated uncheck :- ' +quoteLineToUpdateAfterDelete.size());
            update quoteLineToUpdateAfterDelete;
        }            

    }
        
}