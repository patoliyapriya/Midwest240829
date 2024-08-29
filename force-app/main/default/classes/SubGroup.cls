public with sharing class SubGroup {

    public Product_Group__c subGroup {get;set;}
    public List<Product_Select__c> lstQuoteLineItems {get;set;}
    public List<OrderLineItem> lstOrderLineItems {get;set;}

    public SubGroup() {
        subGroup = new Product_Group__c();
        subGroup.Name = '';
        lstQuoteLineItems = new List<Product_Select__c>();
        lstOrderLineItems = new List<OrderLineItem>();
    }
    
    public SubGroup(Product_Group__c subGroup){
        this.subGroup = subGroup;
        lstQuoteLineItems = new List<Product_Select__c>();
        lstOrderLineItems = new List<OrderLineItem>();
    }

}