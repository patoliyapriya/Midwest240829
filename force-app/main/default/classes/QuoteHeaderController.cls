/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 04-19-2024
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class QuoteHeaderController {

    /**
    * @description : Update the Cart Wrapper
    * @author Nilesh Badrakiya | 04-11-2024 
    * @param cartWrapperString 
    @param listGroupWrapper 
    **/
    @AuraEnabled 
    public static void quickSave(String cartWrapperString) {
        CartWrapper cartWrapper = (CartWrapper)JSON.deserialize(cartWrapperString, CartWrapper.class);
        List<GrpWrapper> listGroupWrapper = cartWrapper.groupDetails;
        QuoteWrapper quoteDetails = cartWrapper.quoteDetails;
        
        List<Product_Group__c> listGroupUpdate = new List<Product_Group__c>();
        List<Product_Group__c> listSubGroupUpdate = new List<Product_Group__c>();
        List<Product_Select__c> listLineItemsUpdate = new List<Product_Select__c>();
        List<Quote> listQuoteToUpdate = new List<Quote>();

        for (GrpWrapper groupWrapper : listGroupWrapper) {
            listGroupUpdate.add(GrpWrapper.getSObject(groupWrapper));
            for (SubGroupWrapper subGrpWrapper : groupWrapper.subGroupDetails) {
                listSubGroupUpdate.add(SubGroupWrapper.getSObject(subGrpWrapper));
                for (LineItemWrapper lineItemWrp : subGrpWrapper.lineItemDetails) {
                    listLineItemsUpdate.add(LineItemWrapper.getSObject(lineItemWrp));
                }
            }
        }

        listQuoteToUpdate.add(QuoteWrapper.getSObject(quoteDetails));
        
        GroupDomain.updateRecord(listGroupUpdate);
        GroupDomain.updateRecord(listSubGroupUpdate);
        QuoteLineItemDomain.updateLineItems(listLineItemsUpdate);
        QuoteDomain.updateRecord(listQuoteToUpdate); 
    }
}