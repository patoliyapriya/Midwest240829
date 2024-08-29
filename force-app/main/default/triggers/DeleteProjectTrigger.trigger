trigger DeleteProjectTrigger on Project__c (after delete) {
	
    Set<Id> setOpportunity = new Set<Id>();
    
    for(Project__c project : trigger.Old){
        if(project.Opportunity__c != null){
        	setOpportunity.add(project.Opportunity__c);    
        }
    }
    
    List<Quote> lstQuoteToUnlock = [Select Is_Locked__c From Quote 
                                    Where OpportunityId IN :setOpportunity
                                    AND Is_Locked__c = true];
    
    for(Quote updateQuoteLocked : lstQuoteToUnlock){
        Approval.UnlockResult unlockedRersult = Approval.unlock(updateQuoteLocked);
        updateQuoteLocked.Is_Locked__c = false;
    }
    
    update lstQuoteToUnlock;
}