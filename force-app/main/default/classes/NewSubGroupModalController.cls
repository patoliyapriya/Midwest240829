/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 03-29-2024
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class NewSubGroupModalController {
    
    /**
    * @description : Creates the Subgroup and used by LWC
    * @author Nilesh Badrakiya | 03-15-2024 
    * @param quoteId 
    * @param groupId 
    * @param subGroupName 
    **/
    @AuraEnabled
    public static void createSubGroup(Id quoteId, Id groupId, String subGroupName) {
        
        Integer subGroupIndex = GroupQueryHelper.getCountofSubGroups(groupId) + 1;
        GroupDomain.insertSubGroup(quoteId, groupId, subGroupName, subGroupIndex);
    }
}