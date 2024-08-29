public with sharing class QuoteLineItem {

    public Boolean isSelect {get;set;}
    public Product_Select__c lineItem {get;set;}

    public QuoteLineItem(){
        
    }

    public QuoteLineItem(Boolean isSelect, Product_Select__c lineItem) {
        this.isSelect = isSelect;
        this.lineItem = lineItem;
    }
}