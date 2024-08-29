/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 04-11-2024
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class GrpWrapper {

    @AuraEnabled public String groupName;
    @AuraEnabled public Id groupId;
    @AuraEnabled public Boolean isOpen;
    @AuraEnabled public Decimal groupExtendedCost;
    @AuraEnabled public Decimal totalHours;
    @AuraEnabled public Decimal groupTotal;
    @AuraEnabled public List<SubGroupWrapper> subGroupDetails;
    @AuraEnabled public Boolean pageBreak;
    @AuraEnabled public Boolean hidePricing;
    @AuraEnabled public Boolean alternate;
    
    /**
    * @description : Constructor that Map the wrapper properties to Object Field.
    * @author Nilesh Badrakiya | 03-15-2024 
    * @param grp 
    **/
    public GrpWrapper(Product_Group__c grp) {
        this.groupName = grp.Name;
        this.groupId = grp.Id;
        this.isOpen = true;
        this.groupExtendedCost = grp.Total_Group_Extended_Cost__c;
        this.totalHours = grp.Grand_Quantity_Total__c;
        this.groupTotal = grp.Total_Sub_Groups__c;
        this.pageBreak = grp.Page_Break__c;
        this.hidePricing = grp.Hide_Pricing__c;
        this.alternate = grp.Alternate__c;
        this.subGroupDetails = new List<SubGroupWrapper>();
    }

    /**
    * @description : Convert GrpWrapper into Product_Group__c 
    * @author Nilesh Badrakiya | 04-11-2024 
    * @param groupWrapper 
    * @return Product_Group__c 
    **/
    public static Product_Group__c getSObject(GrpWrapper groupWrapper) {
        Product_Group__c groupObj = new Product_Group__c();
        groupObj.Name = groupWrapper.groupName;
        groupObj.Id = groupWrapper.groupId;
        groupObj.Total_Group_Extended_Cost__c = groupWrapper.groupExtendedCost;
        groupObj.Grand_Quantity_Total__c = groupWrapper.totalHours;
        groupObj.Total_Sub_Groups__c = groupWrapper.groupTotal;
        groupObj.Page_Break__c = groupWrapper.pageBreak;
        groupObj.Hide_Pricing__c = groupWrapper.hidePricing;
        groupObj.Alternate__c = groupWrapper.alternate;
        return groupObj;
    }
}