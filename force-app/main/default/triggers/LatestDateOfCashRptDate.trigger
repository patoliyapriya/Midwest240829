trigger LatestDateOfCashRptDate on AcctSeed__Billing_Cash_Receipt__c (after insert) {
    //Set<Opportunity> mapOppIds = new Set<Opportunity>();
    Map<String, Date> mapOppIds = new Map<String, Date>();
    
    List<AcctSeed__Billing_Cash_Receipt__c> lstLatestCRR = Trigger.new;
    for(AcctSeed__Billing_Cash_Receipt__c crr : lstLatestCRR){
        system.debug('Opp Id: '+crr.Opportunity_Id__c);
        mapOppIds.put(crr.Opportunity_Id__c , null);
    }
    system.debug('MAP : '+mapOppIds);
    
    List<AcctSeed__Billing_Cash_Receipt__c> lstAllCRRForOpp = [SELECT Id, 
                                                                    AcctSeed__Cash_Receipt__r.AcctSeed__Receipt_Date__c,
                                                                    Opportunity_Id__c
                                                               FROM AcctSeed__Billing_Cash_Receipt__c 
                                                               WHERE Opportunity_Id__c IN : mapOppIds.keySet() 
                                                               AND Opportunity_Id__c != null
                                                               ORDER BY AcctSeed__Cash_Receipt__r.AcctSeed__Receipt_Date__c DESC
                                                               LIMIT 1];
    
    system.debug('All Cash receipt size: '+lstAllCRRForOpp.size());
    List<Opportunity> toBeUpdateOppList = new List<Opportunity>();
    for(AcctSeed__Billing_Cash_Receipt__c billingCR : lstAllCRRForOpp){
        Opportunity opp = new Opportunity();
        opp.Id = billingCR.Opportunity_Id__c;
        opp.Payments_Received_From_Customer__c = billingCR.AcctSeed__Cash_Receipt__r.AcctSeed__Receipt_Date__c;
        toBeUpdateOppList.add(opp);
    }
    update toBeUpdateOppList;
    system.debug('Updated Successfully');
}