public with sharing class NewQuote {

    public static Boolean getSplitEngineer(Id oppId){
        //List<Sales_Representative__c> lstSalesRepresentative = [Select Id FROM Sales_Representative__c WHERE Opportunity__c =: oppId];  
        List<Sales_Representative__c> lstSalesRepresentative = new Query('Sales_Representative__c').
                            selectField('Id').
                            addConditionEq('Opportunity__c', oppId).
                            run();   
        if(!lstSalesRepresentative.isEmpty()){
            return true;
        }
        return false;
    }

    @AuraEnabled
    public static OpportunityWrapper getOpportunity(Id oppId) {
        Opportunity opportunityDetails = OpportunityQueryHelper.getOpportunityById(oppId);
        OpportunityWrapper opportunityWrapper = new OpportunityWrapper(opportunityDetails);
        Boolean splitEngineer = getSplitEngineer(opportunityWrapper.opportunityId);
        opportunityWrapper.isSplitEngineer = splitEngineer;
        return opportunityWrapper;
    }

    @AuraEnabled
    public static Quote insertQuote(String jsonWrapper) {
        QuoteDetailsWrapper quoteDetails = (QuoteDetailsWrapper) JSON.deserialize(jsonWrapper, QuoteDetailsWrapper.class);
        Id quoteRecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get(quoteDetails.qutRecordTypeName).getRecordTypeId();
        Quote quote = new Quote();
        Opportunity oppor = new Opportunity();

        quote.Name = quoteDetails.quoteName;
        quote.RecordTypeId = quoteRecordTypeId;
        quote.Bid_Date__c = quoteDetails.quoteDate;
        quote.Bidding_To__c = quoteDetails.quoteBiddingToC;
        quote.Submitted_By__c = quoteDetails.quoteSubmittedByC;
        quote.prepared_by_user__c = quoteDetails.quotePreparedByUser;
        quote.General_Contractor__c = quoteDetails.qutGeneralContractor;
        quote.Consulting_Engineer__c = quoteDetails.qutConsultingEngineer;
        quote.Attention_to_Account__c = quoteDetails.qutaAttentionToAccount;
        quote.OpportunityId = quoteDetails.oppId;
        if(quoteDetails.qutRecordTypeName == 'MaRRS Quote') {
            quote.ShippingName = quoteDetails.ShippingName;
        }
        UtilitySharePointToSFIntegration.quoteBulkInsertContext = true;
        Quote returnQuote = QuoteDomain.insertRecord(quote);

        if(quoteDetails.SyncOppAddress == null) {
            oppor.Id = quoteDetails.oppId;
            oppor.Sync_Quote__c = quote.Id;
            OpportunityDomain.updateRecord(new List<Opportunity>{oppor});
        } 

        //Quote quoteDetail = [Select Id, QuoteNumber From Quote Where Id =: quote.Id];
        Quote quoteDetail = (Quote)new Query('Quote').
                            selectField('Id').
                            selectField('QuoteNumber').
                            byId(quote.Id).
                            fetch();
        return quoteDetail;

    }

    public class QuoteDetailsWrapper {
        @AuraEnabled public String quoteName {get;set;}
        @AuraEnabled public String qutRecordTypeName {get;set;}
        @AuraEnabled public Date quoteDate {get;set;}
        @AuraEnabled public String quoteBiddingToC {get;set;}
        @AuraEnabled public String quoteSubmittedByC {get;set;}
        @AuraEnabled public String quotePreparedByUser {get;set;}
        @AuraEnabled public String qutGeneralContractor {get;set;}
        @AuraEnabled public String qutConsultingEngineer {get;set;}
        @AuraEnabled public Id qutaAttentionToAccount {get;set;}
        @AuraEnabled public Id oppId {get;set;} 
        @AuraEnabled public String ShippingName {get;set;}
        @AuraEnabled public String SyncOppAddress {get;set;} 
    }

    public class OpportunityDetailsWrapper {
        @AuraEnabled public boolean quoteId;

    }

    @AuraEnabled
    public static void updateQuote(String qutName, String updatedQutName,Id quoteId) {
        Quote updatequotes = new Quote(
            Id = quoteId,
            Original_Name__c = qutName,
            Name = updatedQutName
        );
        QuoteDomain.updateRecord(new List<Quote>{updatequotes});
    }

    @AuraEnabled
    public static void deleteQuote(Id quoteId) {
        try {
            // Quote deleteQuote = [SELECT Id FROM Quote WHERE Id = :quoteId LIMIT 1];
            Quote deleteQuote = (Quote)new Query('Quote').
                                byId(quoteId).
                                fetch();
            QuoteDomain.deleteRecord(deleteQuote);
        } catch (Exception e) {
            throw new AuraHandledException('Error deleting contact: ' + e.getMessage());
        }
    }
}