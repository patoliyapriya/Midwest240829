trigger BillingLineCustom on AcctSeed__Billing_Line__c (before insert) {
    
    if(trigger.isBefore && trigger.isInsert) {

        AcctSeed__GL_Account__c revGLIdForTaxLine;
        try {
            revGLIdForTaxLine = [SELECT Id FROM AcctSeed__GL_Account__c 
                                    WHERE Name = '225-00 Sales Tax Payable' LIMIT 1];
        } catch(Exception e) {
            revGLIdForTaxLine = new AcctSeed__GL_Account__c();
        }
        
        Set<Id> orderLineIds = new Set<Id>();
        Set<Id> opportunityIds = new Set<Id>();
        Map<Id,String> billingIdToRecordTypeMap = new Map<Id,String>();
        for(AcctSeed__Billing_Line__c billingLineSO : trigger.new) {
            billingIdToRecordTypeMap.put(billingLineSO.AcctSeed__Billing__c,null);
            orderLineIds.add(billingLineSO.AcctSeedERP__Sales_Order_Line__c);
            
            //opportunityIds.add();
            //billingLineSO.AcctSeed__Revenue_GL_Account__c = 'a1N3J0000007Bjf';
            //billingLineSO.AcctSeed__Expense_GL_Account__c = 'a1N3J0000007Bjt';
        }

        if (billingIdToRecordTypeMap.size() > 0) {

            for (AcctSeed__Billing__c billingSO : [SELECT Id,
                                                        AcctSeed__Opportunity__r.RecordType.Name,
                                                        AcctSeed__Opportunity__c
                                                    FROM AcctSeed__Billing__c
                                                    WHERE Id IN :billingIdToRecordTypeMap.KeySet()]) {
                if (billingSO.AcctSeed__Opportunity__c != null) {
                    billingIdToRecordTypeMap.put(billingSO.Id, billingSO.AcctSeed__Opportunity__r.RecordType.Name);
                }
            }
        }
        Map<String, GLCode_System_Properties__c> GLCodeDetails = GLCode_System_Properties__c.getAll();
        AcctSeed__Accounting_Variable__c GLVariable1 = [SELECT Id 
                                                        FROM AcctSeed__Accounting_Variable__c 
                                                        WHERE Name = 'MIB'
                                                        AND AcctSeed__Type__c = 'GL Account Variable 1'];
        for (AcctSeed__Billing_Line__c billingLineSO : trigger.new) {

            if (billingIdToRecordTypeMap.containsKey(billingLineSO.AcctSeed__Billing__c)
                && billingIdToRecordTypeMap.get(billingLineSO.AcctSeed__Billing__c) != null){
                    String oppRecordType = billingIdToRecordTypeMap.get(billingLineSO.AcctSeed__Billing__c);
                    if(oppRecordType == UtilitySharePointToSFIntegration.OPP_EQUIPMENT_RECORDTYPE) {
                        
                        if(GLCodeDetails.ContainsKey('Equipment Billing')) {
                            billingLineSO.AcctSeed__Revenue_GL_Account__c = GLCodeDetails.get('Equipment Billing').Revenue_GL_AccountId__c;
                            billingLineSO.AcctSeed__Expense_GL_Account__c = GLCodeDetails.get('Equipment Billing').Expense_GL_AccountId__c;
                        }
                    
                    } else if(oppRecordType == UtilitySharePointToSFIntegration.OPP_PARTS_RECORDTYPE) {
                        if(GLCodeDetails.ContainsKey('Parts Billing')) {
                            billingLineSO.AcctSeed__Revenue_GL_Account__c = GLCodeDetails.get('Parts Billing').Revenue_GL_AccountId__c;
                            billingLineSO.AcctSeed__Expense_GL_Account__c = GLCodeDetails.get('Parts Billing').Expense_GL_AccountId__c;
                        }
                    } else if(oppRecordType == UtilitySharePointToSFIntegration.OPP_REPAIR_RECORDTYPE) {
                        billingLineSO.AcctSeed__GL_Account_Variable_1__c = GLVariable1.Id;
                        if(GLCodeDetails.ContainsKey('Repair Billing')) {
                            billingLineSO.AcctSeed__Revenue_GL_Account__c = GLCodeDetails.get('Repair Billing').Revenue_GL_AccountId__c;
                            billingLineSO.AcctSeed__Expense_GL_Account__c = GLCodeDetails.get('Repair Billing').Expense_GL_AccountId__c;
                        }
                    }
            }
        }
        Map<Id,AcctSeedERP__Sales_Order_Line__c> SOLines = new Map<Id,AcctSeedERP__Sales_Order_Line__c>([SELECT Id,Quote_Line_Item__r.Descriptions__c
                                                            FROM AcctSeedERP__Sales_Order_Line__c
                                                            WHERE Id IN :orderLineIds]);
                        
        for(AcctSeed__Billing_Line__c billingLineSO : trigger.new) {
            if(billingLineSO.AcctSeedERP__Sales_Order_Line__c != null 
                && SOLines.containsKey(billingLineSO.AcctSeedERP__Sales_Order_Line__c)) {
                    
                    billingLineSO.Description__c = SOLines.get(billingLineSO.AcctSeedERP__Sales_Order_Line__c).Quote_Line_Item__r.Descriptions__c;
                }
                if (billingLineSO.AcctSeed__Tax_Line__c) {
                    billingLineSO.AcctSeed__Revenue_GL_Account__c = revGLIdForTaxLine.Id;
                }
            
        }
    }
}