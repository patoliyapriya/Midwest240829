/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 04-22-2024
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class DesignQuoteHeaderController {
    
    @AuraEnabled
    public static String getGenerateDocument(Id quoteid) {
        String url;
        Quote RecordDetails = [Select Id, Name, RecordTypeId from Quote where Id =: quoteid];
        RecordType RecId = [Select Id, Name from RecordType where Name =: 'MaRRS Quote'];
        if (RecordDetails.RecordTypeId == RecId.Id) {
            url =  '/apex/GeneratePdfOnQuote?id='+quoteid +'&type=marrs&isfrom=designQuoteHeaderController';
        }
        else {
            url =  '/apex/GeneratePdfOnQuote?id='+quoteid +'&type=quote&isfrom=designQuoteHeaderController';
        }    
        return url;    
    }
    /**
    * @description : Update the Cart Wrapper
    * @author Nilesh Badrakiya | 04-11-2024 
    * @param listGroupWrapper 
    **/
    @AuraEnabled 
    public static void quickSave(List<GrpWrapper> listGroupWrapper) {

        List<Product_Group__c> listGroupUpdate = new List<Product_Group__c>();
        List<Product_Group__c> listSubGroupUpdate = new List<Product_Group__c>();
        List<Product_Select__c> listLineItems = new List<Product_Select__c>();

        for (GrpWrapper groupWrapper : listGroupWrapper) {
            listGroupUpdate.add(GrpWrapper.getSObject(groupWrapper));
            for (SubGroupWrapper subGrpWrapper : groupWrapper.subGroupDetails) {
                listSubGroupUpdate.add(SubGroupWrapper.getSObject(subGrpWrapper));
                for (LineItemWrapper lineItemWrp : subGrpWrapper.lineItemDetails) {
                    listLineItems.add(LineItemWrapper.getSObject(lineItemWrp));
                }
            }
        }

        GroupDomain.updateRecord(listGroupUpdate);
        GroupDomain.updateRecord(listSubGroupUpdate);
        QuoteLineItemDomain.updateLineItems(listLineItems);
    }
}