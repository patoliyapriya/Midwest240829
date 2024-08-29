/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 04-11-2024
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class SubGroupWrapper {

    @AuraEnabled public String subGroupName;
    @AuraEnabled public Id subGroupId;
    @AuraEnabled public Boolean isOpen;
    @AuraEnabled public Decimal projectMargin;
    @AuraEnabled public Decimal projectMarginPercent;
    @AuraEnabled public Decimal subGroupExtendedCost;
    @AuraEnabled public Decimal subGroupTotalHours;
    @AuraEnabled public Decimal subGroupTotal;
    @AuraEnabled public Id groupId;
    @AuraEnabled public Boolean hideQuantity;
    @AuraEnabled public Boolean hideCode;
    @AuraEnabled public Boolean hideAmount;
    @AuraEnabled public Boolean hideLine;
    @AuraEnabled public Boolean hidePricing;
    @AuraEnabled public Boolean alternate;
    @AuraEnabled public List<LineItemWrapper> lineItemDetails;
    
    /**
    * @description : Constructor that Maps SubGroupWrapper to Product_Group__C
    * @author Nilesh Badrakiya | 03-15-2024 
    * @param subGroup 
    **/
    public SubGroupWrapper(Product_Group__c subGroup) {
        this.subGroupName = subGroup.Name;
        this.subGroupId = subGroup.Id;
        this.isOpen = true;
        this.projectMargin = 0;
        this.projectMarginPercent = 0;
        this.subGroupExtendedCost = subGroup.Total_Extended_Cost__c;
        this.subGroupTotalHours =  subGroup.Quantity_Total__c;
        this.subGroupTotal =  subGroup.Total_Line_Items__c;
        this.groupId = subGroup.Parent_Product_Group__c;
        this.hideQuantity = !subGroup.Hide_Quantity__c;
        this.hideCode = !subGroup.Hide_Code__c;
        this.hideAmount = !subGroup.Hide_Amount__c;
        this.hidePricing = subGroup.Hide_Pricing__c;
        this.hideLine = !subGroup.Hide_Line__c;
        this.alternate = subGroup.Alternate__c;
        this.lineItemDetails = new List<LineItemWrapper>();
    }

    /**
    * @description : Convert SubGroupWrapper into Product_Group__c 
    * @author Nilesh Badrakiya | 04-11-2024 
    * @param subGrpWrapper 
    * @return Product_Group__c 
    **/
    public static Product_Group__c getSObject(SubGroupWrapper subGrpWrapper) {
        Product_Group__c subGroupObj = new Product_Group__c();
        subGroupObj.Name = subGrpWrapper.subGroupName;
        subGroupObj.Id = subGrpWrapper.subGroupId;
        subGroupObj.Total_Extended_Cost__c = subGrpWrapper.subGroupExtendedCost;
        subGroupObj.Quantity_Total__c = subGrpWrapper.subGroupTotalHours;
        subGroupObj.Total_Line_Items__c = subGrpWrapper.subGroupTotal;
        subGroupObj.Parent_Product_Group__c = subGrpWrapper.groupId;
        subGroupObj.Hide_Quantity__c = !subGrpWrapper.hideQuantity;
        subGroupObj.Hide_Code__c = !subGrpWrapper.hideCode;
        subGroupObj.Hide_Amount__c = !subGrpWrapper.hideAmount;
        subGroupObj.Hide_Pricing__c = subGrpWrapper.hidePricing;
        subGroupObj.Hide_Line__c = !subGrpWrapper.hideLine;
        subGroupObj.Alternate__c = subGrpWrapper.alternate;
        return subGroupObj;
    }
}