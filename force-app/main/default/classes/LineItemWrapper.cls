/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 04-11-2024
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class LineItemWrapper {

    @AuraEnabled public Id lineItemId;
    @AuraEnabled public String saleType;
    @AuraEnabled public String tag;
    @AuraEnabled public String productName;
    @AuraEnabled public String code;
    @AuraEnabled public Decimal quantity;
    @AuraEnabled public Decimal listPrice;
    @AuraEnabled public Decimal multiplier;
    @AuraEnabled public Decimal unitCost;
    @AuraEnabled public Decimal marginPercentage;
    @AuraEnabled public Decimal extendedCost;
    @AuraEnabled public Decimal salePrice;
    @AuraEnabled public Decimal cr;
    @AuraEnabled public Boolean alternate;
    @AuraEnabled public Id subGroupId; 
    @AuraEnabled public String description;
    @AuraEnabled public Boolean hideQuantity;
    @AuraEnabled public Boolean hideCode;
    @AuraEnabled public Boolean hideLine;
    @AuraEnabled public Boolean hidePricing;
    @AuraEnabled public Boolean pageBreak;
    @AuraEnabled public String releasepick;
    @auraEnabled public String productId;
    @AuraEnabled public Boolean isSelected;

    /**
    * @description : Constructor that Map LineItemWrapper with Quote Line Item Object
    * @author Nilesh Badrakiya | 03-15-2024 
    * @param lineItem 
    **/
    public LineItemWrapper(Product_Select__c lineItem) {
        this.lineItemId = lineItem.Id;
        this.saleType = lineItem.Sale_Type__c;
        this.tag = lineItem.Tag__c;
        this.productName = lineItem.Product_Name__c;
        this.code = lineItem.Product_Code__c;
        this.quantity = lineItem.Quantity__c;
        this.listPrice = lineItem.List_Price__c;
        this.multiplier = lineItem.Multiplier__c;
        this.unitCost = lineItem.Unit_Cost__c;
        this.marginPercentage = lineItem.Margin_Percentage__c;
        this.extendedCost = lineItem.Extended_Cost__c;
        this.salePrice = lineItem.Sales_Price__c;
        this.cr = lineItem.CR__c;
        this.alternate = lineItem.Alternate__c;
        this.subGroupId = lineItem.Product_Group__c;
        this.description = lineItem.Descriptions__c;
        this.hideQuantity = !lineItem.Hide_Quantity__c;
        this.hideCode = !lineItem.Hide_Code__c;
        this.hideLine = !lineItem.Hide_Line__c;
        this.hidePricing = !lineItem.Hide_Pricing__c;
        this.pageBreak = lineItem.Page_Break__c;
        this.releasepick = lineItem.Release_pick__c;
        this.productId = lineitem.ProductId__c;
        if(lineItem.Sales_Order_Line__c == null) {
            this.isSelected = false;
        } else {
            this.isSelected = true;
        }
    }

    /**
    * @description : Convert LineItemWrapper into Product_Select__c
    * @author Nilesh Badrakiya | 04-11-2024 
    * @param lineItemWrp 
    * @return Product_Select__c 
    **/
    public static Product_Select__c getSObject(LineItemWrapper lineItemWrp) {
        Product_Select__c lineItemObj = new Product_Select__c();
        lineItemObj.Id = lineItemWrp.lineItemId;
        lineItemObj.Sale_Type__c = lineItemWrp.saleType;
        lineItemObj.Tag__c = lineItemWrp.tag;
        lineItemObj.Product_Name__c = lineItemWrp.productName;
        lineItemObj.Product_Code__c = lineItemWrp.code;
        lineItemObj.Quantity__c = lineItemWrp.quantity;
        lineItemObj.List_Price__c = lineItemWrp.listPrice;
        lineItemObj.Multiplier__c = lineItemWrp.multiplier;
        lineItemObj.Unit_Cost__c = lineItemWrp.unitCost;
        lineItemObj.Margin_Percentage__c = lineItemWrp.marginPercentage;
        lineItemObj.Extended_Cost__c = lineItemWrp.extendedCost;
        lineItemObj.Sales_Price__c = lineItemWrp.salePrice;
        lineItemObj.CR__c = lineItemWrp.cr;
        lineItemObj.Alternate__c = lineItemWrp.alternate;
        lineItemObj.Product_Group__c = lineItemWrp.subGroupId;
        lineItemObj.Descriptions__c = lineItemWrp.description;
        lineItemObj.Hide_Quantity__c = !lineItemWrp.hideQuantity;
        lineItemObj.Hide_Code__c = !lineItemWrp.hideCode;
        lineItemObj.Hide_Line__c = !lineItemWrp.hideLine;
        lineItemObj.Hide_Pricing__c = !lineItemWrp.hidePricing;
        lineItemObj.Page_Break__c = lineItemWrp.pageBreak;
        lineItemObj.Release_pick__c = lineItemWrp.releasepick;
        return lineItemObj;
    }
}