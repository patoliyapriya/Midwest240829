trigger PayableLineCustom on AcctSeed__Account_Payable_Line__c (before insert) {
    if (trigger.isInsert) {
        Map<Id,String> payableIdToRecordType = new Map<Id,String>();
        set<Id> payableIds = new Set<Id>();

        for (AcctSeed__Account_Payable_Line__c line : trigger.new) {
            payableIds.add(line.AcctSeed__Account_Payable__c);
            //POIdToRecordType.put(line.AcctSeed__Account_Payable__r.AcctSeedERP__Purchase_Order__c, '');
        }
        
        for(AcctSeed__Account_Payable__c payableSO : [SELECT Id,Opportunity_Record_Type__c
                                                        FROM AcctSeed__Account_Payable__c
                                                        WHERE Id IN :payableIds]) {
            if (payableSO.Opportunity_Record_Type__c != null) {
                payableIdToRecordType.put(payableSO.Id, payableSO.Opportunity_Record_Type__c);
            }
        }
        Map<String, GLCode_System_Properties__c> GLCodeDetails;
        for (AcctSeed__Account_Payable_Line__c line : trigger.new) {
            if(payableIdToRecordType.containsKey(line.AcctSeed__Account_Payable__c)) {
                String recordType = payableIdToRecordType.get(line.AcctSeed__Account_Payable__c);
                if(GLCodeDetails == null) {
                    GLCodeDetails = GLCode_System_Properties__c.getAll();
                }

                if(recordType == UtilitySharePointToSFIntegration.OPP_EQUIPMENT_RECORDTYPE) {
                    if(GLCodeDetails.ContainsKey('Equipment Payable')) {
                        line.Revenue_GL__c = GLCodeDetails.get('Equipment Payable').Revenue_GL_AccountId__c;
                        line.AcctSeed__Expense_GL_Account__c = GLCodeDetails.get('Equipment Payable').Expense_GL_AccountId__c;
                    }                    
                } else if(recordType == UtilitySharePointToSFIntegration.OPP_PARTS_RECORDTYPE) {
                    if(GLCodeDetails.ContainsKey('Parts Payable')) {
                        line.Revenue_GL__c = GLCodeDetails.get('Parts Payable').Revenue_GL_AccountId__c;
                        line.AcctSeed__Expense_GL_Account__c = GLCodeDetails.get('Parts Payable').Expense_GL_AccountId__c;
                    }
                } else if(recordType == UtilitySharePointToSFIntegration.OPP_REPAIR_RECORDTYPE_DEV_Name) {
                    if(GLCodeDetails.ContainsKey('General Contracting Payable')) {
                        line.Revenue_GL__c = GLCodeDetails.get('General Contracting Payable').Revenue_GL_AccountId__c;
                        line.AcctSeed__Expense_GL_Account__c = GLCodeDetails.get('General Contracting Payable').Expense_GL_AccountId__c;
                    }
                }
                
            }
            
        }


    }
}