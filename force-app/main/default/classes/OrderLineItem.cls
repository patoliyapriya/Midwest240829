/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 12-06-2023
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class OrderLineItem {
    
    public Boolean isSelect {get;set;}
    public Boolean isAlternate {get;set;}
    public String tag {get;set;}
    public AcctSeedERP__Sales_Order_Line__c orderLineItem {get;set;}
    public String descriptions {get;set;}
  
    
    public OrderLineItem(){
        orderLineItem = new AcctSeedERP__Sales_Order_Line__c();
    }

    public OrderLineItem(Boolean isSelect, Product_Select__c lineItem) {
        
        this.isSelect = isSelect;
        
        orderLineItem = new AcctSeedERP__Sales_Order_Line__c();
        isAlternate = lineItem.Alternate__c;
        orderLineItem.AcctSeedERP__Quantity_Ordered__c = lineItem.Quantity__c;
        //orderLineItem.Sale_Type__c = lineItem.Sale_Type__c;
        orderLineItem.AcctSeedERP__Unit_Price__c  = 0;
        
        if(lineItem.Sale_Type__c == 'C/R') {
            orderLineItem.AcctSeedERP__Unit_Price__c = lineItem.CR__c;
        } else {
            if(lineItem.Sales_Price__c != null && lineItem.Sales_Price__c != 0) {
                if(lineItem.Quantity__c != null && lineItem.Quantity__c > 0) {
                    orderLineItem.AcctSeedERP__Unit_Price__c = (lineItem.Sales_Price__c / lineItem.Quantity__c).setScale(5);
                    
                }
            }
        }
        
         
        //orderLineItem.AcctSeedERP__Unit_Price__c =  lineItem.Unit_Cost__c;
        System.debug('ProductId is:::::::'+ lineItem.ProductId__c);
        orderLineItem.AcctSeedERP__Product__c = lineItem.ProductId__c;
        System.debug('AcctSeedERP__Product__c' + orderLineItem.AcctSeedERP__Product__c);
        orderLineItem.AcctSeedERP__Comment__c = '';
        orderLineItem.Quote_Line_Item__c = lineItem.Id;
        this.descriptions = lineItem.Descriptions__c;
        //orderLineItem.Quote_Line_Item__r.Descriptions__c = lineItem.Descriptions__c;
        
        tag = lineItem.Tag__c;
    }

}