/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 04-08-2024
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class QuoteController {

    /**
    * @description : Returns CartWrapper to the LWC
    * @author Nilesh Badrakiya | 03-15-2024 
    * @param quoteId 
    * @return CartWrapper 
    **/
    @AuraEnabled
    public static CartWrapper getCartWrapper(Id quoteId) {
        
        Quote quote = QuoteQueryHelper.getQuoteById(quoteId);
        CartWrapper cartWrapper = new CartWrapper(quote);
        cartWrapper.groupDetails = getGroupWrapper(quoteId);
        if(cartWrapper.groupDetails.size() == 0){
            createDefaultData(quoteId, quote.Opportunity.Office__c);
            cartWrapper.groupDetails = getGroupWrapper(quoteId);
        }
        return cartWrapper;
    }
    
    /**
    * @description : Prepare the list Of GrpWrapper.
    * @author Nilesh Badrakiya | 03-15-2024 
    * @param quoteId 
    * @return List<GrpWrapper> 
    **/
    private static List<GrpWrapper> getGroupWrapper(Id quoteId) {

        Map<Id, List<SubGroupWrapper>> mapGroupIdSubGroups = prepareGroupIdSubGroups(quoteId);
        Map<Id, List<LineItemWrapper>> mapSubGroupIdLineItems = prepareSubGroupIdLineItems(quoteId);
        List<GrpWrapper> lstGroupWrapper = prepareGroupWrapper(quoteId,mapGroupIdSubGroups,mapSubGroupIdLineItems);
        
        return lstGroupWrapper;
    }

    /**
    * @description : Prepare Map of Group Id to SubGroups
    * @author Nilesh Badrakiya | 03-15-2024 
    * @param quoteId 
    * @return Map<Id, List<SubGroupWrapper>> 
    **/
    private static Map<Id, List<SubGroupWrapper>> prepareGroupIdSubGroups(Id quoteId) {
        
        Map<Id, List<SubGroupWrapper>> mapGroupIdSubGroups = new Map<Id, List<SubGroupWrapper>>();
        
        for (Product_Group__c subGroup : GroupQueryHelper.getSubGroupsByQuoteId(quoteId)) {
            
            if (!mapGroupIdSubGroups.containsKey(subGroup.Parent_Product_Group__c)) {
                mapGroupIdSubGroups.put(subGroup.Parent_Product_Group__c, new List<SubGroupWrapper>{new SubGroupWrapper(subGroup)});
            } else {
                mapGroupIdSubGroups.get(subGroup.Parent_Product_Group__c).add(new SubGroupWrapper(subGroup));
            }
        }

        return mapGroupIdSubGroups;
    }

    /**
    * @description : Prepare Map of SubGroup Id to Line Items
    * @author Nilesh Badrakiya | 03-15-2024 
    * @param quoteId 
    * @return Map<Id, List<LineItemWrapper>> 
    **/
    private static Map<Id, List<LineItemWrapper>> prepareSubGroupIdLineItems(Id quoteId) {
        
        Map<Id, List<LineItemWrapper>> mapSubGroupIdLineItems = new Map<Id, List<LineItemWrapper>>();
        
        for (Product_select__c lineItem : QuoteLineItemQueryHelper.getLineItemsByQuoteId(quoteId)) {

            if (!mapSubGroupIdLineItems.containsKey(lineItem.Product_Group__c)){
                mapSubGroupIdLineItems.put(lineItem.Product_Group__c, new List<LineItemWrapper>{new LineItemWrapper(lineItem)});
            } else {
                mapSubGroupIdLineItems.get(lineItem.Product_Group__c).add(new LineItemWrapper(lineItem));
            }
        }

        return mapSubGroupIdLineItems;
    }

    /**
    * @description : Prepare the list of GroupWrapper
    * @author Nilesh Badrakiya | 03-15-2024 
    * @param quoteId 
    * @param mapGroupIdSubGroups 
    * @param mapSubGroupIdLineItems 
    * @return List<GrpWrapper> 
    **/
    private static List<GrpWrapper> prepareGroupWrapper(Id quoteId, Map<Id, List<SubGroupWrapper>> mapGroupIdSubGroups, Map<Id, List<LineItemWrapper>> mapSubGroupIdLineItems) {

        List<GrpWrapper> lstGroupWrapper = new List<GrpWrapper>();

        for (Product_Group__c parentGroup : GroupQueryHelper.getGroupsByQuoteId(quoteId)) {

            GrpWrapper objGroup = new GrpWrapper(parentGroup);

            if (mapGroupIdSubGroups.containsKey(parentGroup.Id)) {

                objGroup.subGroupDetails = mapGroupIdSubGroups.get(parentGroup.Id);
                
                for (SubGroupWrapper subGroup : objGroup.subGroupDetails) {

                    if (mapSubGroupIdLineItems.containsKey(subGroup.subGroupId)) {
                        subGroup.lineItemDetails = mapSubGroupIdLineItems.get(subGroup.subGroupId);
                    }
                }
            }
            lstGroupWrapper.add(objGroup);
        }

        return lstGroupWrapper;
    }

    /**
    * @description : CreateGroup and its related Subgroup and LineItem.
    * @author Nilesh Badrakiya | 03-15-2024 
    * @param quoteId
    **/
    @AuraEnabled
    public static void createDefaultData(Id quoteId, String office) {
        Integer groupIndex = GroupQueryHelper.getCountofGroups(quoteId) + 1;
        Product_Group__c grp = GroupDomain.insertGroup(quoteId, '', groupIndex);
        Integer subGroupIndex = GroupQueryHelper.getCountofSubGroups(grp.Id) + 1;
        Product_Group__c subGrp = GroupDomain.insertSubGroupDefault(quoteId, grp.Id, '', subGroupIndex);
        PricebookEntry priceBookEntry = PriceBookEntryQueryHelper.getDefaultFreightProduct(office);
        QuoteLineItemDomain.insertDefaultLineItem(subGrp.Id, priceBookEntry, quoteId);
    }
}