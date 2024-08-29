public with sharing class OpportunityWrapper {

    @AuraEnabled public Id opportunityId;
    @AuraEnabled public String opportunityName;
    @AuraEnabled public String opportunityRecordtypeName;
    @AuraEnabled public String opportunityNumber;
    @AuraEnabled public String opportunityAccountId;
    @AuraEnabled public Datetime opportunityBidDate;
    @AuraEnabled public String opportunityConsultingEngineer;
    @AuraEnabled public String opportunityGeneralContractor;
    @AuraEnabled public String opportunityShippingName;
    @AuraEnabled public String opportunityAttentionTo;
    @AuraEnabled public String opportunitySyncQuote;
    @AuraEnabled public String opportunityApplicationEngineer;
    @AuraEnabled public Boolean isSplitEngineer;
 
    public OpportunityWrapper(Opportunity opp) {
        this.opportunityId = opp.Id;
        this.opportunityName = opp.Name;
        this.opportunityRecordtypeName = opp.RecordType.Name;
        this.opportunityNumber = opp.Opportunity_Number__c;
        this.opportunityAccountId = opp.AccountId;
        this.opportunityBidDate = opp.Bid_Date__c;
        this.opportunityConsultingEngineer = opp.Consulting_Engineer__c;
        this.opportunityGeneralContractor = opp.General_Contractor__c;
        this.opportunityShippingName = opp.Shipping_Name__c;
        this.opportunityAttentionTo = opp.Attention_to__c;
        this.opportunitySyncQuote = opp.Sync_Quote__c;
        this.opportunityApplicationEngineer = opp.Application_Engineer__c;        
    }
}