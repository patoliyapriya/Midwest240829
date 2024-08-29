/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 03-29-2024
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class NewGroupModalController {
    
    /**
    * @description : CreateGroup and its related Subgroup.
    * @author Nilesh Badrakiya | 03-15-2024 
    * @param quoteId 
    * @param groupName 
    * @param subGroupName 
    **/
    @AuraEnabled
    public static void createGroup(Id quoteId, String groupName, String subGroupName) {
        
        Integer groupIndex = GroupQueryHelper.getCountofGroups(quoteId) + 1;
        Product_Group__c grp = GroupDomain.insertGroup(quoteId, groupName, groupIndex);
        Integer subGroupIndex = GroupQueryHelper.getCountofSubGroups(grp.Id) + 1;
        GroupDomain.insertSubGroup(quoteId, grp.Id, subGroupName, subGroupIndex);
    }
}