/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 04-12-2024
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class SubgroupHeaderController {

    /**
   * @description : Clone sub groups and their respective line items
   * @author Nilesh Badrakiya | 03-22-2024 
   * @param recordId
   * @param groupId
   **/
   @AuraEnabled
   public static void cloneSubGroup(Id recordId, Id groupId) {

       Product_Group__c subGroup = GroupQueryHelper.getGroupById(recordId);
       Product_Group__c subGroupClone = subGroup.clone(false, true, false, false);
       subGroupClone.Index__c = GroupQueryHelper.getCountofSubGroups(groupId) + 1;
       GroupDomain.insertRecords(new List<Product_Group__c>{subGroupClone});
       
       List<Product_Select__c> lineItemList = QuoteLineItemQueryHelper.getLineItemsByProductGroupId(recordId);
       if (lineitemList.size() > 0) {
           List<Product_Select__c> listLineItemInsert = new List<Product_Select__c>();

           for (Product_Select__c lineItem: lineItemList) {
               Product_Select__c lineItemClone = lineItem.clone(false, true, false, false);
               lineItemClone.Product_Group__c = subGroupClone.Id;
               listLineItemInsert.add(lineItemClone);
           }
           QuoteLineItemDomain.insertLineItems(listLineItemInsert);
       }
   }

   @AuraEnabled
   public static String getGroupDetails(Id subgroupId) {

       Product_Group__c grp = GroupQueryHelper.getGroupById(subgroupId);
       return grp.Parent_Product_Group__c;
   }

   @AuraEnabled
   public static Decimal getsubGroupRowIndex(Id subgroupId) {

       Product_Group__c grp = GroupQueryHelper.getGroupById(subgroupId);
       return grp.Index__c;
   }

   @AuraEnabled
   public static void subGrouprowIndexUpdate(Id subGroupId, Decimal rowIndex) {
       List<Product_Group__c> subGroup = [SELECT Id,Parent_Product_Group__c,Index__c FROM Product_Group__c WHERE Parent_Product_Group__c = :subGroupId ORDER BY Index__c];
       for (Product_Group__c pgrp : subGroup) {
           if (pgrp.Index__c > rowIndex) {
               pgrp.Index__c -= 1;
           }
       }
       update subGroup;

   }

   @AuraEnabled
   public static void updateRowIndex(Decimal rowIndex, Id DropGroupId, Id draggedGroupId, Decimal DraggedrowIndex) {
   
       List<Product_Group__c> DropSubGroup = [SELECT Id,Parent_Product_Group__c,Index__c FROM Product_Group__c WHERE Parent_Product_Group__c = :DropGroupId ORDER BY Index__c];
       List<Product_Group__c> DraggedSubGroup = [SELECT Id,Parent_Product_Group__c,Index__c FROM Product_Group__c WHERE Parent_Product_Group__c = :draggedGroupId ORDER BY Index__c];

       if (!DropSubGroup.isEmpty() && !DraggedSubGroup.isEmpty() && DropGroupId != draggedGroupId) {
           for (Product_Group__c pg : DropSubGroup) {
               if (pg.Index__c >= rowIndex) {
                   pg.Index__c += 1;
               }
           }
           update DropSubGroup;

           for (Product_Group__c pgrp : DraggedSubGroup) {
               if (pgrp.Index__c > DraggedrowIndex) {
                   pgrp.Index__c -= 1;
               }
           }
           update DraggedSubGroup;
       } else {
           for (Product_Group__c pg : DropSubGroup) {
               if(rowIndex > DraggedrowIndex) {
                   if (pg.Index__c <= rowIndex && pg.Index__c > DraggedrowIndex) {
                       pg.Index__c -= 1;
                   }
               }
               if(rowIndex < DraggedrowIndex) {
                   if (pg.Index__c < DraggedrowIndex && pg.Index__c >= rowIndex) {
                       pg.Index__c += 1;
                   }
               }
           }
           update DropSubGroup;
       }
   }

   @AuraEnabled
   public static void updateLineItemRowIndex(Id draggedSubGroupId, Decimal DraggedrowIndex) {
       List<Product_Select__c> DraggedlineItems = [SELECT Id, Product_Group__c, Row_Index__c FROM Product_Select__c WHERE Product_Group__c = :draggedSubGroupId ORDER BY Row_Index__c];

       if (!DraggedlineItems.isEmpty()) {
           for (Product_Select__c sp : DraggedlineItems) {
               if (sp.Row_Index__c > DraggedrowIndex) {
                   sp.Row_Index__c -= 1;
               }
           }
           update DraggedlineItems;
       }
   }

   @AuraEnabled
   public static void updateGroup(Id dropGroupId, Id draggedSubGroupId, Decimal newindex) {
       Product_Group__c subGroup = [SELECT Id, Parent_Product_Group__c FROM Product_Group__c WHERE Id = :draggedSubGroupId];
       
       subGroup.Parent_Product_Group__c = dropGroupId;   
       subGroup.Index__c = newindex;       
       
       update subGroup;
   }

   @AuraEnabled
   public static void updateSubGroup(Id dropSubGroupId, Id draggedLineItemId) {
       List<Product_Select__c> updateLineItems = [SELECT Id, Product_Group__c, Row_Index__c FROM Product_Select__c WHERE Product_Group__c = :dropSubGroupId ORDER BY Row_Index__c];
       // System.debug('updateLineItems='+updateLineItems.size());
       Product_Select__c lineItem = [SELECT Id, Product_Group__c, Row_Index__c FROM Product_Select__c WHERE Id = :draggedLineItemId];
       lineItem.Product_Group__c = dropSubGroupId;
       lineItem.Row_Index__c = updateLineItems.size() + 1;
       update lineItem;
   }
}