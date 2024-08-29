trigger SubmitLookupTrigger on Submit_Request__c (after update) {
	Set<Id> submitrequestid = new set<Id>();
    List<Expense__c> updatedexpence = new List<Expense__c>();
    for(Submit_Request__c submitrequestSo : trigger.new){
        if(submitrequestSo.Status__c != Trigger.oldMap.get(submitrequestSo.Id).Status__c && submitrequestSo.Status__c == 'Declined'){
                submitrequestid.add(submitrequestSo.Id);
        }
    }
    
    List<Expense__c> expensetobeupdate = [SELECT Submit_Request__c, Submit_Request__r.Id
                             	FROM Expense__c 
                             	WHERE Submit_Request__r.Id IN :submitrequestid];
    for(Expense__c expenseSo : expensetobeupdate){
        if(submitrequestid != null ){
            expenseSo.Submit_Request__c = null ; 
        }
        updatedexpence.add(expenseSo);
    }
    if(!updatedexpence.isEmpty()){
        update updatedexpence;
    }
}