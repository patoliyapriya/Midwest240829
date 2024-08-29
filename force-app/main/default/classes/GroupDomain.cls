/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 04-12-2024
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class GroupDomain {
    
    /**
    * @description : Creates Group
    * @author Nilesh Badrakiya | 03-15-2024 
    * @param quoteId 
    * @param groupName 
    * @param groupIndex 
    * @return Product_Group__c 
    **/
    public static Product_Group__c insertGroup(Id quoteId, String groupName, Integer groupIndex) {
        Product_Group__c objGroup = new Product_Group__c();
        objGroup.Name = groupName;
        objGroup.Quote__c = quoteId;
        objGroup.Index__c = groupIndex;
        insert objGroup;

        return objGroup;
    }

    /**
    * @description : Creates Subgroup
    * @author Nilesh Badrakiya | 03-15-2024 
    * @param quoteId 
    * @param groupId 
    * @param subGroupName 
    * @param subGroupIndex 
    **/
    public static void insertSubGroup(Id quoteId, Id groupId, String subGroupName, Integer subGroupIndex) {
        
        Product_Group__c objSubGroup = new Product_Group__c();
        objSubGroup.Name = subGroupName;
        objSubGroup.Quote__c = quoteId;
        objSubGroup.Parent_Product_Group__c = groupId;
        objSubGroup.Index__c = subGroupIndex;
        insert objSubGroup; 
    }


    /**
    * @description : Creates Subgroup and return
    * @author Nilesh Badrakiya | 03-15-2024 
    * @param quoteId 
    * @param groupId 
    * @param subGroupName 
    * @param subGroupIndex 
    **/
    public static Product_Group__c insertSubGroupDefault(Id quoteId, Id groupId, String subGroupName, Integer subGroupIndex) {
        
        Product_Group__c objSubGroup = new Product_Group__c();
        objSubGroup.Name = subGroupName;
        objSubGroup.Quote__c = quoteId;
        objSubGroup.Parent_Product_Group__c = groupId;
        objSubGroup.Index__c = subGroupIndex;
        insert objSubGroup; 

        return objSubGroup;
    }

    /**
    * @description : Delete the list of Product_Group__c
    * @author Nilesh Badrakiya | 03-17-2024 
    * @param listGroupToDelete 
    **/
    public static void deleteGroup(List<Product_Group__c> listGroupToDelete) {

        if (!listGroupToDelete.isEmpty()) {
            delete listGroupToDelete;
        }
    }

    /**
    * @description Insert List of Group
    * @author Nilesh Badrakiya | 04-12-2024 
    * @param recordList 
    **/
    public static void insertRecords(List<Product_Group__c> recordList) {
        
        if (!recordList.isEmpty()) {
            insert recordList;
        }
    }

    /**
    * @description : Update List of Record
    * @author Nilesh Badrakiya | 04-11-2024 
    * @param recordList 
    **/
    public static void updateRecord(List<Product_Group__c> recordList) {
        if(!recordList.isEmpty()) {
            update recordList;
        }
    }
}