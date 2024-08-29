/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 03-29-2024
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class GroupService {
    
    /**
    * @description : Delete Group Or SubGroup And Its Related Line Items
    * @author Nilesh Badrakiya | 03-17-2024 
    * @param recordId 
    **/
    public static void deleteGroupAndLineItems(Id recordId) {

        Set<Id> subGroupIds = new Set<Id>();
        List<Product_Group__c> listGroupSubgroupsDelete = new List<Product_Group__c>();
        Product_Group__c grp = GroupQueryHelper.getGroupById(recordId);
        listGroupSubgroupsDelete.add(grp);

        if(grp.Parent_Product_Group__c == null) {

            for(Product_Group__c subGroup : GroupQueryHelper.getSubGroupsByParentGroupId(recordId)) {
                
                listGroupSubgroupsDelete.add(subGroup);
                subGroupIds.add(subGroup.Id);
            }

        } else {
            subGroupIds.add(grp.Id);
        }

        List<Product_Select__c> listLineItemDelete = QuoteLineItemQueryHelper.getLineItemsByProductGroup(subGroupIds);
        GroupDomain.deleteGroup(listGroupSubgroupsDelete);
        QuoteLineItemDomain.deleteLineItems(listLineItemDelete);
    }
}