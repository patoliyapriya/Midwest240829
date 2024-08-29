/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 04-12-2024
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class GroupHeaderController {

     /**
    * @description : Retrieve the Quote by given ID
    * @author Nilesh Badrakiya | 03-22-2024 
    * @param groupId
    * @param quoteId
    **/
    @AuraEnabled
    public static void cloneGroup(Id groupId, Id quoteId) {
        
            Product_Group__c grp = GroupQueryHelper.getGroupById(groupId);            
            Product_Group__c clonedGroup = grp.clone(false, true, false, false);
            clonedGroup.External_Id__c = generateExternalId();
            clonedGroup.Index__c =  GroupQueryHelper.getCountofGroups(quoteId) + 1;        
            
            List<Product_Group__c> subGroupList = GroupQueryHelper.getSubGroupsByParentGroupId(groupId);           
            List<Product_Group__c> listSubGroupInsert = new List<Product_Group__c>();
            List<Product_Select__c> listLineItemInsert = new List<Product_Select__c>();

            if (subGroupList.size() > 0) {                

                Map<Id, List<Product_Select__c>> mapSubGroupIdLineItems = prepareSubGroupIdLineItems(quoteId);
                
                for (Product_Group__c subGroup: subGroupList) {
                    Product_Group__c cloneSubGroup = dosubgroupClone(subGroup, clonedGroup.External_Id__c);
                    
                    if (mapSubGroupIdLineItems.get(subGroup.Id) != null) {
                        for (Product_Select__c lineItem: mapSubGroupIdLineItems.get(subGroup.Id)) {        
                            Product_Select__c newlineItem = dolineitemClone(lineItem, cloneSubGroup.External_Id__c);
                            listLineItemInsert.add(newlineItem);
                        }
                    }
                    listSubGroupInsert.add(cloneSubGroup);
                }                
            } 

            GroupDomain.insertRecords(new List<Product_Group__c>{clonedGroup});
            GroupDomain.insertRecords(listSubGroupInsert);
            QuoteLineItemDomain.insertLineItems(listLineItemInsert);
    }

    /**
    * @description : Prepare Map of SubGroup Id to Line Items
    * @author Nilesh Badrakiya | 03-25-2024 
    * @param quoteId 
    * @return Map<Id, List<Product_Select__c>> 
    **/
    private static Map<Id, List<Product_Select__c>> prepareSubGroupIdLineItems(Id quoteId) {

        List<Product_Select__c> lineItemList = QuoteLineItemQueryHelper.getLineItemsByQuoteId(quoteId);                                                    
        Map<Id, List<Product_Select__c>> mapSubGroupIdLineItems = new Map<Id, List<Product_Select__c>>();

        for (Product_Select__c lineItem : lineItemList) {
            
            if (!mapSubGroupIdLineItems.containsKey(lineItem.Product_Group__c)) {
                mapSubGroupIdLineItems.put(lineItem.Product_Group__c, new List<Product_Select__c>{lineItem});
            } else {
                mapSubGroupIdLineItems.get(lineItem.Product_Group__c).add(lineItem);
            }
        }  
        return mapSubGroupIdLineItems;
    }

    /**
    * @description : Prepare Line Item
    * @author Nilesh Badrakiya | 03-22-2024 
    * @param lineItem
    * @param externalId
    * @return Product_Select__c
    **/
    private static Product_Select__c dolineitemClone(Product_Select__c lineItem, String externalId) {
        Product_Select__c objProduct = new Product_Select__c();
        objProduct.Product_Group__r = new Product_Group__c(External_Id__c = externalId);
        objProduct.Sale_Type__c = lineItem.Sale_Type__c;
        objProduct.Tag__c = lineItem.Tag__c;
        objProduct.Product_Name__c = lineItem.Product_Name__c;
        objProduct.Product_Code__c = lineItem.Product_Code__c;
        objProduct.Quantity__c = lineItem.Quantity__c;
        objProduct.List_Price__c = lineItem.List_Price__c;
        objProduct.Multiplier__c = lineItem.Multiplier__c;
        objProduct.Unit_Cost__c = lineItem.Unit_Cost__c;
        objProduct.Extended_Cost__c = lineItem.Extended_Cost__c;
        objProduct.Margin_Percentage__c = lineItem.Margin_Percentage__c;
        objProduct.Alternate__c = lineItem.Alternate__c;
        objProduct.Sales_Price__c = lineItem.Sales_Price__c;
        objProduct.CR__c = lineItem.CR__c;
        objProduct.Quote__c = lineItem.Quote__c;
        return objProduct;
    }

    /**
    * @description : Prepare Product Group
    * @author Nilesh Badrakiya | 03-22-2024 
    * @param subGroup
    * @param externalId
    * @return Product_Group__c
    **/
    private static Product_Group__c dosubgroupClone(Product_Group__c subGroup, String externalId) {
        Product_Group__c objSubgroup = new Product_Group__c();
        objSubgroup.Parent_Product_Group__r = new Product_Group__c(External_Id__c = externalId);
        objSubgroup.Name = subGroup.Name;
        objSubgroup.External_Id__c = generateExternalId();
        objSubgroup.Quote__c = subGroup.Quote__c;
        objSubgroup.Total_Group_Extended_Cost__c = subGroup.Total_Group_Extended_Cost__c;
        objSubgroup.Grand_Quantity_Total__c = subGroup.Grand_Quantity_Total__c;
        objSubgroup.Total_Sub_Groups__c = subGroup.Total_Sub_Groups__c;
        objSubgroup.Total_Extended_Cost__c = subGroup.Total_Extended_Cost__c;
        objSubgroup.Quantity_Total__c = subGroup.Quantity_Total__c;
        objSubgroup.Total_Line_Items__c = subGroup.Total_Line_Items__c;
        objSubgroup.Index__c = subGroup.Index__c;
        objSubgroup.Alternate__c = subGroup.Alternate__c;
        return objSubgroup;
    }

    /**
    * @description : Random number generation for external Id
    * @author Nilesh Badrakiya | 03-21-2024 
    * @param 
    * @return Random String 
    **/
    private static String generateExternalId() {
        String hashString = Math.round(Math.random()*1000) + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        String hexDigest = EncodingUtil.convertToHex(hash);
        return hexDigest;
    }
}