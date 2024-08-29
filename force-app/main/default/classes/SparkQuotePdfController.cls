public with sharing class SparkQuotePdfController {

    public List<GroupWrapper> lstGroup {get;set;}

    public SparkQuotePdfController(ApexPages.StandardController cont) {
        
        lstGroup = new List<GroupWrapper>();

        Map<Id, Product_Group__c> mapSubGroup = CartQueryHelper.getSubGroupWithQuoteLineItems(cont.getId());
        Map<Id, Product_Group__c> mapParentGroup = CartQueryHelper.getParentGroups(cont.getId());
                
        Id parentGroupId = null;
        
        GroupWrapper objGroupWrapper;
        Map<Id, GroupWrapper> mapParentGroupWrapper = new Map<Id, GroupWrapper>();
        
        for(Product_Group__c grp : mapParentGroup.values()) {
            objGroupWrapper = new GroupWrapper(grp);
            for(Product_Group__c subGroup : grp.ProductGroups__r) {
                SubGroup objSubGroup = new SubGroup(subGroup);
                for(Product_Select__c lineItem : mapSubGroup.get(subGroup.Id).Quote_Line_Items__r) {
                    objSubGroup.lstQuoteLineItems.add(lineItem);
                }
                objGroupWrapper.lstSubGroups.add(objSubGroup);
            }
            lstGroup.add(objGroupWrapper);
        }
    }
}