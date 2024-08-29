public with sharing class PurchaseOrderPDFCtrl {
    
    public String salesOrderName{get;set;}
    public string officeName{get;set;}
    public Boolean withoutQuote{get;set;}
    public String salesOrderPONumber{get;set;}
    //public Boolean isEPUser {get;set;}
    public AcctSeedERP__Purchase_Order__c objPurchaseOrder{get;set;}
    public List<AcctSeedERP__Sales_Order_Line__c> lstLineItems{get;set;}
    public List<AcctSeedERP__Purchase_Order_Line__c> poLineItems{get;set;}

    public PurchaseOrderPDFCtrl(ApexPages.StandardController controller) {

        //withQuote = Boolean.valueOf(apexpages.currentpage().getparameters().get('isWithoutQuote'));
        objPurchaseOrder = [SELECT Id, Sales_Order__r.Name, Sales_Order__r.Sales_Order_Number__c,
                                    Sales_Order__c,
                                    Sales_Order__r.Quote__c, Sales_Order__r.Customer_PO_Number__c,
                                    Sales_Order__r.AcctSeedERP__Opportunity__r.Office__c,
                                    Office__c
                            FROM AcctSeedERP__Purchase_Order__c 
                            WHERE Id =: controller.getId()];
        //isEPUser = UtilitySharePointToSFIntegration.isCurrentUserFromEngineeredProducts();
        salesOrderPONumber = objPurchaseOrder.Sales_Order__r.Customer_PO_Number__c;
        if (objPurchaseOrder.Sales_Order__c != null) {
            officeName = objPurchaseOrder.Sales_Order__r.AcctSeedERP__Opportunity__r.Office__c;
        } else if(objPurchaseOrder.Office__c != null){
            officeName = objPurchaseOrder.Office__c;
        } else {
            officeName = 'Midwest Machinery STL';
        }
        if(objPurchaseOrder.Sales_Order__c == null) {
            withoutQuote = true;
            poLineItems = [SELECT Id,
                                AcctSeedERP__Product__r.Name,
                                AcctSeedERP__Product__r.ProductCode,
                                AcctSeedERP__Quantity__c,
                                AcctSeedERP__Unit_Price__c,
                                AcctSeedERP__Total__c
                            FROM AcctSeedERP__Purchase_Order_Line__c
                            WHERE AcctSeedERP__Purchase_Order__c = :objPurchaseOrder.Id];
        } else {
            withoutQuote = false;
        }
        if(withoutQuote == false) {
            salesOrderName = (objPurchaseOrder.Sales_Order__r.Sales_Order_Number__c == null || objPurchaseOrder.Sales_Order__r.Sales_Order_Number__c == '') 
                                ? objPurchaseOrder.Sales_Order__r.Name 
                                : objPurchaseOrder.Sales_Order__r.Sales_Order_Number__c;

            Map<Id, AcctSeedERP__Purchase_Order_Line__c> mapPurchaseOrder = new Map<Id, AcctSeedERP__Purchase_Order_Line__c>([SELECT Id
                                                                                                                                FROM AcctSeedERP__Purchase_Order_Line__c
                                                                                                                                WHERE AcctSeedERP__Purchase_Order__c = :controller.getId()]);

            lstLineItems = [SELECT Id,
                                    Name,
                                    AcctSeedERP__Purchase_Order_Line__r.Name,
                                    AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Quantity_Received__c,
                                    AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Total__c,
                                    AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Unit_Price__c,
                                    AcctSeedERP__Product__r.ProductCode,
                                    AcctSeedERP__Quantity_Ordered__c,
                                    Quote_Line_Item__r.Descriptions__c,
                                    AcctSeedERP__Product__r.Name
                                FROM AcctSeedERP__Sales_Order_Line__c
                                WHERE AcctSeedERP__Purchase_Order_Line__c IN :mapPurchaseOrder.keySet()];
        }
    }
        

    
}