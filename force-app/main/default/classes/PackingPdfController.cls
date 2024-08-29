public with sharing class PackingPdfController {

    public List<AcctSeedERP__Shipment_Line__c> lstShipmentLineItems{get;set;}

    public PackingPdfController(Apexpages.StandardController con) {
        lstShipmentLineItems = [SELECT 
                                AcctSeedERP__Product__c,
                                AcctSeedERP__Quantity_Shipped__c,
                                AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__r.Descriptions__c,
                                AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Quantity_Ordered__c,
                                AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Comment__c,
                                AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Sales_Order__r.Quote__c
                                
                                FROM AcctSeedERP__Shipment_Line__c
                                WHERE AcctSeedERP__Shipment__c = :con.getId()];
    }
}