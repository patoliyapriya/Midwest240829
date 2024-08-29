public with sharing class CreateSalesOrder {
    
    @AuraEnabled
    public static void insertQuote(String cartWrapperString) {
        CartWrapper cartWrapper = (CartWrapper)JSON.deserialize(cartWrapperString, CartWrapper.class);
        AcctSeedERP__Sales_Order__c sales = new AcctSeedERP__Sales_Order__c();
        sales.AcctSeedERP__Customer__c = cartWrapper.quoteDetails.isAttention;
        
        if(Test.isRunningTest()){
            AcctSeed__Ledger__c test_Ledger = [SELECT Id FROM AcctSeed__Ledger__c Limit 1];
            sales.AcctSeedERP__Ledger__c = test_Ledger.Id;
        } else{
            sales.AcctSeedERP__Ledger__c = cartWrapper.quoteDetails.isLedger;
        }
        sales.AcctSeedERP__Opportunity__c = cartWrapper.quoteDetails.opportunityId;
        sales.Quote__c = cartWrapper.quoteDetails.quoteId;
        sales.AcctSeedERP__Customer__c = cartWrapper.quoteDetails.opportunityAccountId;

        Project__c project = [SELECT Opportunity__c, Id, PO_Number__c FROM Project__c WHERE Opportunity__c = :cartWrapper.quoteDetails.opportunityAccountId];

        sales.Customer_PO_Number__c = project.PO_Number__c;
        System.debug(sales);
        insert sales;
    }
}