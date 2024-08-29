public with sharing class ProjectFinancials {
    public ProjectFinancials() {

    }

    @AuraEnabled
    public static Quote getQuote(Id quoteId){
       return [
           SELECT Total_Direct_Sell_Price__c,Total_Buy_Resell_Margin__c,Commissions_and_Rebates__c,Total_Buy_Resell_Price__c
           FROM Quote 
           WHERE Id = :quoteId];
    }
}