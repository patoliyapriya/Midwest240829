public with sharing class PickTicketPdfCtrl {
    
    public AcctSeedERP__Sales_Order__c orderSO{get;set;}
    public List<AcctSeedERP__Shipment_Line__c> shipmentLines{get;set;}
    public AcctSeedERP__Shipment__c shipmentSO{get;set;}
    public Id shipmentId = null;
    public PickTicketPdfCtrl(ApexPages.StandardController controller) {
        shipmentId = controller.getId();

        orderSO = new AcctSeedERP__Sales_Order__c();
        shipmentSO = new AcctSeedERP__Shipment__c();
        shipmentLines = new List<AcctSeedERP__Shipment_Line__c>();
            
        shipmentSO = [SELECT Id,
                            AcctSeedERP__Sales_Order__c,
                            AcctSeedERP__Shipment_Date__c
                        FROM AcctSeedERP__Shipment__c
                        WHERE Id = :shipmentId];

        shipmentLines = [SELECT Id,
                                AcctSeedERP__Product__c,
                                AcctSeedERP__Quantity_Shipped__c,
                                AcctSeedERP__Sales_Order_Line__c,
                                AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.ProductCode,
                                AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__r.Descriptions__c,
                                AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.Name,
                                AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Quantity_Allocated__c
                        FROM AcctSeedERP__Shipment_Line__c
                        WHERE AcctSeedERP__Shipment__c = :shipmentSO.Id];

        orderSO = [SELECT Id, 
                        Name,
                        CreatedDate,
                        AcctSeedERP__Customer__r.Name,
                        AcctSeedERP__Billing_City__c,
                        AcctSeedERP__Billing_Country__c,
                        AcctSeedERP__Billing_PostalCode__c,
                        AcctSeedERP__Billing_State__c,
                        AcctSeedERP__Billing_Street__c,
                        Shipping_Name__c,
                        AcctSeedERP__Shipping_Street__c,
                        AcctSeedERP__Shipping_City__c,
                        AcctSeedERP__Shipping_State__c,
                        AcctSeedERP__Shipping_PostalCode__c,
                        Customer_PO_Number__c,
                        Ship_Via__c,
                        freight_cost__c,
                        Freight_Terms__c,
                        Quote__c,
                        Sales_Order_Number__c,
                        SO_Number__c
                FROM AcctSeedERP__Sales_Order__c
                WHERE Id = :shipmentSO.AcctSeedERP__Sales_Order__c];
    }

}