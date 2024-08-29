trigger BiddersNamesBeforeUpdate on Opportunity (before insert,before update) {
    
    Set<Id> setBiddersId = new Set<Id>();
    
    for(Opportunity opp : trigger.new){
        if((Trigger.isInsert && opp.Consulting_Engineer_Contact_Person__c != null) || 
        		(Trigger.isUpdate && Trigger.newMap.get(opp.Id).Consulting_Engineer_Contact_Person__c != Trigger.oldMap.get(opp.Id).Consulting_Engineer_Contact_Person__c && opp.Consulting_Engineer_Contact_Person__c != null)){
            List<Contact> lstConsultingEngineer = [Select Id, AccountId 
                                                    From Contact 
                                                    Where Id =: opp.Consulting_Engineer_Contact_Person__c];
                                                    
            if(!lstConsultingEngineer.isEmpty()){
                opp.Consulting_Engineer__c = lstConsultingEngineer[0].AccountId;
            }
        }
        
        if(opp.Opportunity_Owner__c != null && Trigger.isInsert){
            opp.OwnerId = opp.Opportunity_Owner__c;
        }
        
    }
    
}