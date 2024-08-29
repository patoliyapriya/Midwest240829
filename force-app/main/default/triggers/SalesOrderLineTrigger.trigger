trigger SalesOrderLineTrigger on AcctSeedERP__Sales_Order_Line__c (before insert) {
    Set<Id> quoteLineId = new Set<Id>();
    for (AcctSeedERP__Sales_Order_Line__c SOLine : trigger.new) {
        if (SOLine.Quote_Line_Item__c != null) {
            quoteLineId.add(SOLine.Quote_Line_Item__c);    
        }
    }

    Map<Id,Product_Select__c> quoteLine = new Map<Id,Product_Select__c>([SELECT Id,
                                                                                Descriptions__c,
                                                                                Quote__c,
                                                                                Quote__r.OpportunityId,
                                                                                Quote__r.Opportunity.RecordType.Name
                                                                        FROM Product_Select__c
                                                                        WHERE Id IN :quoteLineId]);
    AcctSeed__Accounting_Variable__c GLVariable1 = null;
    for (AcctSeedERP__Sales_Order_Line__c SOLine : trigger.new) {
        if (quoteLine.containsKey(SOLine.Quote_Line_Item__c)) {
            Product_Select__c quoteLineSO = quoteLine.get(SOLine.Quote_Line_Item__c);
            SOLine.Description__c = quoteLineSO.Descriptions__c;   

            if (quoteLineSO.Quote__c != null 
                && quoteLineSO.Quote__r.OpportunityId != null
                && quoteLineSO.Quote__r.Opportunity.RecordType.Name == UtilitySharePointToSFIntegration.OPP_REPAIR_RECORDTYPE) {
                    if (GLVariable1 == null) {
                        GLVariable1 = [SELECT Id 
                                        FROM AcctSeed__Accounting_Variable__c 
                                        WHERE Name = 'MIB'
                                        AND AcctSeed__Type__c = 'GL Account Variable 1'];                        
                    }
                    SOLine.AcctSeedERP__GL_Account_Variable_1__c = GLVariable1.Id;


            }
        }
        
    }
}