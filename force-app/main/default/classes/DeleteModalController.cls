/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 03-18-2024
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class DeleteModalController {
    
    /**
    * @description : Delete the Record of the Given Id
    * @author Nilesh Badrakiya | 03-17-2024 
    * @param recordId 
    **/

    @AuraEnabled
    public static String checkRecordId(Id recordId) {

        Schema.SObjectType objType = recordId.getSObjectType();

        if(objType == Schema.Product_Group__c.getSObjectType()) {
            Product_Group__c grp = GroupQueryHelper.getGroupById(recordId);
            if(grp != null) {
                return 'subGroupId';
            }
            else {
                return 'groupId';
            }
        } else if(objType == Schema.Product_Select__c.getSObjectType()){
            return 'lineitemId';
        }
        else {
            return 'unknownType';
        }
    }

    @AuraEnabled
    public static void deleteRecord(Id recordId) {

        Schema.SObjectType objType = recordId.getSObjectType();

        if(objType == Schema.Product_Group__c.getSObjectType()) {
            GroupService.deleteGroupAndLineItems(recordId);
        } else if(objType == Schema.Product_Select__c.getSObjectType()){
            QuoteLineItemDomain.deleteLineItemById(recordId);
        }
    }
}