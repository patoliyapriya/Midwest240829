/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 03-20-2024
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class QuoteWrapper {

    @AuraEnabled public String quoteId;
    @AuraEnabled public String quoteName;
    @AuraEnabled public String quoteNumber;
    @AuraEnabled public Decimal sellPrice;
    @AuraEnabled public Boolean grandTotal;
    @AuraEnabled public Decimal extendedCost;
    @AuraEnabled public Decimal directSellPrice;
    @AuraEnabled public Decimal buyResellPrice;
    @AuraEnabled public Decimal buyResellMargin;
    @AuraEnabled public Decimal buyResellMarginPercent;
    @AuraEnabled public Decimal commissionAndRebates;
    @AuraEnabled public Decimal projectMargin;
    @AuraEnabled public Decimal projectMarginPercent;
    @AuraEnabled public Decimal totalHours;
    @AuraEnabled public String office;
    @AuraEnabled public Boolean isActiveProjectFinancials;
    @AuraEnabled public Boolean isTaxable;
    @AuraEnabled public String isAttention;
    @AuraEnabled public String isLedger;
    @AuraEnabled public String opportunityId;
    @AuraEnabled public String opportunityAccountId;
    
    /**
    * @description : Constructor that Map QuoteWrapper to quote
    * @author Nilesh Badrakiya | 03-15-2024 
    * @param quote 
    **/
    public QuoteWrapper(Quote quote) {
        this.quoteId = quote.Id;
        this.quoteName = quote.Name;
        this.quoteNumber = quote.QuoteNumber;
        this.sellPrice = quote.Total_Base_Bid_Total__c;
        this.grandTotal = quote.Hide_Total_Base_Bid_Total__c;
        this.extendedCost = quote.Total_Extended_Cost__c;
        this.directSellPrice = quote.Total_Direct_Sell_Price__c;
        this.buyResellPrice = quote.Total_Buy_Resell_Price__c;
        this.buyResellMargin = quote.Total_Buy_Resell_Margin__c;
        this.buyResellMarginPercent = quote.Total_Buy_Resell_Margin_Percentage__c;
        this.commissionAndRebates = quote.Commissions_and_Rebates__c;
        this.projectMargin = quote.Total_Project_Margin__c;
        this.projectMarginPercent = quote.Total_Project_Margin_Percentage__c;
        this.totalHours = quote.Quantity_Total__c;
        this.office = quote.Opportunity.Office__c;
        this.isActiveProjectFinancials = quote.Is_Active_Project_Financials__c;
        this.isTaxable = quote.Opportunity.Account.Is_Taxable__c;
        this.isAttention = quote.Attention_to_Account__c;
        this.isLedger = quote.Opportunity.Ledger__c;
        this.opportunityId = quote.OpportunityId;
        this.opportunityAccountId = quote.Opportunity.AccountId;
    }

    /**
    * @description : Convert GrpWrapper into Product_Group__c 
    * @author Nilesh Badrakiya | 04-11-2024 
    * @param quoteWrapper 
    * @return Product_Group__c 
    **/
    public static Quote getSObject(QuoteWrapper quoteWrapper) {
        Quote quoteObj = new Quote(); 
        quoteObj.Id = quoteWrapper.quoteId;
        quoteObj.Total_Base_Bid_Total__c = quoteWrapper.sellPrice;
        quoteObj.Hide_Total_Base_Bid_Total__c = quoteWrapper.grandTotal;
        quoteObj.Total_Extended_Cost__c = quoteWrapper.extendedCost;
        quoteObj.Total_Direct_Sell_Price__c = quoteWrapper.directSellPrice;
        quoteObj.Total_Buy_Resell_Price__c = quoteWrapper.buyResellPrice;
        quoteObj.Total_Buy_Resell_Margin__c = quoteWrapper.buyResellMargin;
        quoteObj.Total_Buy_Resell_Margin_Percentage__c = quoteWrapper.buyResellMarginPercent;
        quoteObj.Commissions_and_Rebates__c = quoteWrapper.commissionAndRebates;
        quoteObj.Total_Project_Margin__c = quoteWrapper.projectMargin;
        quoteObj.Total_Project_Margin_Percentage__c = quoteWrapper.projectMarginPercent;
        quoteObj.Quantity_Total__c = quoteWrapper.totalHours;
        
        return quoteObj;
    }
}