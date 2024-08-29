/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 03-29-2024
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class QuoteLineitemsController {
    
     /**
    * @description : Retrieve the Quote by given ID
    * @author Nilesh Badrakiya | 03-21-2024 
    * @param lineItemId
    * @param subGroupId
    **/
    @AuraEnabled
    public static void cloneLineItem(Id lineItemId, Id subGroupId) {

        Product_Select__c lineItem = QuoteLineItemQueryHelper.getLineItemsById(lineItemId);
        Product_Select__c cloneLineItem = lineItem.clone(false, true, false, false);
        cloneLineItem.Row_Index__c = QuoteLineItemQueryHelper.getCountofLineItems(subGroupId) + 1;
        QuoteLineItemDomain.insertLineItems(new List<Product_Select__c>{cloneLineItem});
    }

    @AuraEnabled
    public static void rowIndexUpdate(Id subGroupId, Decimal rowIndex) {
        List<Product_Select__c> lineItems = [SELECT Id, Product_Group__c, Row_Index__c FROM Product_Select__c WHERE Product_Group__c = :subGroupId ORDER BY Row_Index__c];

            for (Product_Select__c sp : lineItems) {
                if (sp.Row_Index__c > rowIndex) {
                    sp.Row_Index__c -= 1;
                }
            }
            update lineItems;

    }

    
    @AuraEnabled
    public static String getLineItemDetails(Id lineItemId) {

        Product_Select__c lineItem = QuoteLineItemQueryHelper.getLineItemsById(lineItemId);
        return lineitem.Product_Group__c;
    }

    @AuraEnabled
    public static Decimal getLineItemRowIndex(Id lineItemId) {

        Product_Select__c lineItem = QuoteLineItemQueryHelper.getLineItemsById(lineItemId);
        return lineitem.Row_Index__c;
    }

    @AuraEnabled
    public static String getGroupDetails(Id subgroupId) {

        Product_Group__c grp = GroupQueryHelper.getGroupById(subgroupId);
        return grp.Parent_Product_Group__c;
    }
    
    // @AuraEnabled
    // public static void updateRowIndex(Decimal rowIndex, Id DropsubGroupId, Id draggedSubGroupId, Decimal DraggedrowIndex) {
    //     List<Product_Select__c> lineItems = [SELECT Id, Product_Group__c, Row_Index__c FROM Product_Select__c WHERE Product_Group__c = :DropsubGroupId];
    //     for (Product_Select__c ps : lineItems) {
    //        if(ps.Row_Index__c == rowIndex) {
    //             for(Integer i = (Integer) ps.Row_Index__c; i<=lineItems.size(); i++) {
    //                 lineItems[i].Row_Index__c +=1;
    //                 update lineItems;
    //             }
    //        }
    //     }

    @AuraEnabled
    public static void updateRowIndex(Decimal rowIndex, Id DropsubGroupId, Id draggedSubGroupId, Decimal DraggedrowIndex) {
        List<Product_Select__c> DroplineItems = [SELECT Id, Product_Group__c, Row_Index__c FROM Product_Select__c WHERE Product_Group__c = :DropsubGroupId ORDER BY Row_Index__c];
        List<Product_Select__c> DraggedlineItems = [SELECT Id, Product_Group__c, Row_Index__c FROM Product_Select__c WHERE Product_Group__c = :draggedSubGroupId ORDER BY Row_Index__c];
        Decimal rowIndexIncrement = rowIndex + 1;
        if (!DroplineItems.isEmpty() && !DraggedlineItems.isEmpty() && DropsubGroupId != draggedSubGroupId) {
            for (Product_Select__c ps : DroplineItems) {
                if (ps.Row_Index__c >= rowIndex) {
                    ps.Row_Index__c += 1;
                }
            }
            update DroplineItems;

            for (Product_Select__c sp : DraggedlineItems) {
                if (sp.Row_Index__c > DraggedrowIndex) {
                    sp.Row_Index__c -= 1;
                }
            }
            update DraggedlineItems;
        } else {
            for (Product_Select__c ps : DroplineItems) {
                if(rowIndex > DraggedrowIndex) {
                    if (ps.Row_Index__c <= rowIndex && ps.Row_Index__c > DraggedrowIndex) {
                        ps.Row_Index__c -= 1;
                    }
                }
                if(rowIndex < DraggedrowIndex) {
                    if (ps.Row_Index__c < DraggedrowIndex && ps.Row_Index__c >= rowIndex) {
                        ps.Row_Index__c += 1;
                    }
                }
                // else {
                //     ps.Row_Index__c += 1;
                // }
                // if (ps.Row_Index__c == rowIndexIncrement) {
                //     ps.Row_Index__c += 1;
                // }

            }
            update DroplineItems;
        }
        // if (!DroplineItems.isEmpty() && DropsubGroupId != draggedSubGroupId) {
        //     for (Product_Select__c ps : DroplineItems) {
        //         if (ps.Row_Index__c >= rowIndex) {
        //             ps.Row_Index__c += 1;
        //         }
        //     }
        //     update DroplineItems;
    }

        // List<Product_Select__c> DraggedlineItems = [SELECT Id, Product_Group__c, Row_Index__c FROM Product_Select__c WHERE Product_Group__c = :draggedSubGroupId ORDER BY Row_Index__c];

        // if (!DraggedlineItems.isEmpty() && DropsubGroupId != draggedSubGroupId) {
        //     for (Product_Select__c ps : DraggedlineItems) {
        //         if (ps.Row_Index__c > DraggedrowIndex) {
        //             ps.Row_Index__c -= 1;
        //         }
        //     }
        //     update DraggedlineItems;
        // }
        

    // }

    //     Product_Select__c DraggedLineItem = [SELECT id,name,Row_Index__c,Product_Group__c from Product_Select__c where Product_Group__c = :draggedSubGroupId AND = Row_Index__c:DraggedrowIndex];
    //     DraggedLineItem.Row_Index__c =2;
    //     delete DraggedLineItem;

    //     List<Product_Select__c> DraggedLineItem = [SELECT Id, Product_Group__c, Row_Index__c FROM Product_Select__c WHERE Id = :draggedSubGroupId];
    //     for (Product_Select__c ps : DraggedLineItem) {
    //        if(ps.Row_Index__c == rowIndex) {
    //             for(Integer i = (Integer) ps.Row_Index__c; i<=DraggedLineItem.size(); i++) {
    //                 DraggedLineItem[i].Row_Index__c = i;
    //             }
    //             break;
    //        }
    //     }

    // }

    @AuraEnabled
    public static void updateSubgroup(Id lineItemId, Id DropsubGroupId, Id draggedSubGroupId, Decimal newindex) {
        Product_Select__c lineItem = [SELECT Id, Product_Group__c, Row_Index__c FROM Product_Select__c WHERE Id = :lineItemId];
        // if(DropsubGroupId != draggedSubGroupId) {
            lineItem.Product_Group__c = DropsubGroupId;
            lineItem.Row_Index__c = newindex;            
        // }
        // else {
        //     lineItem.Row_Index__c = newindex - 1;
        // }
        update lineItem;
    }
}