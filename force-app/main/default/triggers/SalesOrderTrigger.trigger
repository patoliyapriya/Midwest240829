trigger SalesOrderTrigger on AcctSeedERP__Sales_Order__c (before insert, before update) {

    List<Id> opportunityIds = new List<Id>();

    if (Trigger.isUpdate) {
        for(AcctSeedERP__Sales_Order__c salesOrder : Trigger.New) {

            if (trigger.isUpdate  
                && Trigger.oldMap.get(salesOrder.Id).AcctSeedERP__Status__c !='Closed' 
                && Trigger.newMap.get(salesOrder.Id).AcctSeedERP__Status__c == 'Closed') {
                // check if user is assigened with Accounting Manager - Modified permission set
                    Integer permissionAssignmentCount = [SELECT Count() 
                                                    FROM PermissionSetAssignment 
                                                    WHERE  PermissionSet.Name = 'Accounting_Manager' 
                                                    AND PermissionSet.NamespacePrefix  = null 
                                                    AND Assignee.Id = :UserInfo.getUserId()];
                if (permissionAssignmentCount != null && permissionAssignmentCount > 0) {
                    continue;
                }  else {
                    salesOrder.adderror('only people with Accounting Manager - Modified permission can close the order');
                }                                  
                
            }
        }
    }

    if(trigger.isInsert) {
        for(AcctSeedERP__Sales_Order__c salesOrder : Trigger.New) {
        

            /*if (trigger.isUpdate  
                && Trigger.newMap.get(salesOrder.Id).AcctSeedERP__Status__c =='Closed' ) {
                    Integer permissionAssignmentCount = [SELECT Count() 
                                                        FROM PermissionSetAssignment 
                                                        WHERE  PermissionSet.Name = 'Accounting_Manager' 
                                                        AND PermissionSet.NamespacePrefix  = null 
                                                        AND Assignee.Id = UserInfo.getUserId()];
                    if (permissionAssignmentCount != null && permissionAssignmentCount > 0) {
                        contine;
                    }  else {
                        salesOrder.adderror('only people with Accounting Manager - Modified permission can close the order');
                    } 
    
                }*/
            
            opportunityIds.add(salesOrder.AcctSeedERP__Opportunity__c);
        }  
    
        Id marsOppTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('MaRRS').getRecordTypeId();
    
        if (opportunityIds.size() > 0) {
    
            Map<Id,Opportunity> oppList = new Map<Id, Opportunity>([SELECT Id,
                                                                           Destination_City__c,
                                                                           Destination_Country__c,
                                                                           Destination_PostalCode__c,
                                                                           Destination_State__c,
                                                                           Destination_Street__c,
                                                                           RecordType.Name,
                                                                           Shipping_Name__c
                                                                    FROM Opportunity
                                                                    WHERE RecordTypeId = :marsOppTypeId
                                                                    AND Id IN :opportunityIds]);
            if (!oppList.isEmpty()) {
                for(AcctSeedERP__Sales_Order__c salesOrder : Trigger.New) {
                    If (oppList.containsKey(salesOrder.AcctSeedERP__Opportunity__c)) {
                        salesOrder.AcctSeedERP__Shipping_City__c = oppList.get(salesOrder.AcctSeedERP__Opportunity__c).Destination_City__c;
                        salesOrder.AcctSeedERP__Shipping_Country__c = oppList.get(salesOrder.AcctSeedERP__Opportunity__c).Destination_Country__c;
                        salesOrder.AcctSeedERP__Shipping_PostalCode__c = oppList.get(salesOrder.AcctSeedERP__Opportunity__c).Destination_PostalCode__c;
                        salesOrder.AcctSeedERP__Shipping_State__c = oppList.get(salesOrder.AcctSeedERP__Opportunity__c).Destination_State__c;
                        salesOrder.AcctSeedERP__Shipping_Street__c = oppList.get(salesOrder.AcctSeedERP__Opportunity__c).Destination_Street__c;
                        if(oppList.get(salesOrder.AcctSeedERP__Opportunity__c).RecordType.Name == 'MaRRS'){
                            salesOrder.Shipping_Name__c = oppList.get(salesOrder.AcctSeedERP__Opportunity__c).Shipping_Name__c;
                        }
                    }
            }       
            }    
        }
        
        if(trigger.new.size() == 1) {
            SystemUtil.generateCustomAutoNumber(trigger.new[0]);
        }
    }
    
    
}