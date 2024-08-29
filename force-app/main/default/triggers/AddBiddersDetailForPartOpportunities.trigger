trigger AddBiddersDetailForPartOpportunities on Opportunity (after insert, after update) {
    
    for(Opportunity opp : trigger.new){
        string recordtypename = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(opp.recordtypeid).getname();
        if(recordtypename == 'Parts'){
            if(trigger.isInsert){
                if(opp.Office__c != ''){
                    SalesEngineerSplitTriggerHandler.createSalesRepEntry(opp.Id, opp.Office__c);
                }
            }
            else if(trigger.isUpdate){
                if(trigger.newMap.get(opp.Id).Office__c != trigger.oldMap.get(opp.Id).Office__c){
                    SalesEngineerSplitTriggerHandler.updateSalesRepEntry(opp.Id, opp.Office__c);
                }
            }
        }
        
    }
    
}