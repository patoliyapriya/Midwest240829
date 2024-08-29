trigger POLineCustom on AcctSeedERP__Purchase_Order_Line__c (before insert) {
    Set<Id> orderLineId = new Set<Id>();
    Set<Id> productId = new Set<Id>();
    for(AcctSeedERP__Purchase_Order_Line__c POLine : Trigger.new) {
        if(POLine.SalesOrderLine__c != null) {
            orderLineId.add(POLine.SalesOrderLine__c);
        } else if(POLine.AcctSeedERP__Product__c != null) {
            productId.add(POLine.AcctSeedERP__Product__c);
        }
    }

    if(orderLineId.size() > 0) {
        Map<Id,AcctSeedERP__Sales_Order_Line__c> SOLines = new Map<Id,AcctSeedERP__Sales_Order_Line__c>([
            SELECT Id,
                    Quote_Line_Item__r.Descriptions__c,
                    AcctSeedERP__Sales_Order__r.AcctSeedERP__Opportunity__c,
                    AcctSeedERP__Sales_Order__r.AcctSeedERP__Opportunity__r.RecordType.Name
            FROM AcctSeedERP__Sales_Order_Line__c
            WHERE Id IN :orderLineId
        ]);

        AcctSeed__Accounting_Variable__c GLVariable1 = null;
        for(AcctSeedERP__Purchase_Order_Line__c POLine : Trigger.new) {
            AcctSeedERP__Sales_Order_Line__c orderLineSO = new AcctSeedERP__Sales_Order_Line__c();
            if (SOLines.containsKey(POLine.SalesOrderLine__c)) {
                orderLineSO = SOLines.get(POLine.SalesOrderLine__c);

                if (orderLineSO.Quote_Line_Item__c != null) {
                    POLine.Description__c = orderLineSO.Quote_Line_Item__r.Descriptions__c; 
                }
                if (orderLineSO.AcctSeedERP__Sales_Order__r.AcctSeedERP__Opportunity__c != null
                    && orderLineSO.AcctSeedERP__Sales_Order__r.AcctSeedERP__Opportunity__r.RecordType.Name == UtilitySharePointToSFIntegration.OPP_REPAIR_RECORDTYPE) {
                    if (GLVariable1 == null) {
                        GLVariable1 = [SELECT Id 
                                        FROM AcctSeed__Accounting_Variable__c 
                                        WHERE Name = 'MIB'
                                        AND AcctSeed__Type__c = 'GL Account Variable 1'];                        
                    }
                    POLine.AcctSeedERP__GL_Account_Variable_1__c = GLVariable1.Id;

                }
            }
        }
    }
    
    if(productId.size() > 0) {
        Map<Id, Product2> ProductList = new Map<Id, Product2>([SELECT Id,ProductCode,Description FROM Product2 WHERE Id IN :productId]);
        for(AcctSeedERP__Purchase_Order_Line__c POLine : Trigger.new) {
            if(ProductList.containsKey(POLine.AcctSeedERP__Product__c)) {
                POLine.Description__c = ProductList.get(POLine.AcctSeedERP__Product__c).Description; 
            }
        }        
    
    }


}