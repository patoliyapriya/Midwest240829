public with sharing class AddPOLineItemsCtrl {
    public Id orderId;
    public Id POId;
    public AcctSeedERP__Purchase_Order__c purchaseOrderSO;
    public List<OrderLineWrapper> orderLineWrapperList {get;set;}
    public Boolean isViewDraft {get;set;}
    public Map<String, List<OrderLineWrapper>> orderPOWrapperByVendor {get;set;}
    public Map<Id, Decimal> unreceivedQtyByProductId;
    public Boolean isActionDisable { get; set; }
    public AcctSeedERP__Sales_Order__c salesOrderSO = new AcctSeedERP__Sales_Order__c();

    public AddPOLineItemsCtrl(ApexPages.StandardController controller) {
        isViewDraft = false;
        isActionDisable= false;
        orderLineWrapperList = new List<OrderLineWrapper>();
        orderPOWrapperByVendor = new Map<String, List<OrderLineWrapper>> ();
        POId = controller.getId();
        purchaseOrderSO = [SELECT Sales_Order__c,Id,
                                AcctSeedERP__Vendor__c,
                                AcctSeedERP__Type__c
                            FROM AcctSeedERP__Purchase_Order__c 
                            WHERE Id = :POId];
        if (purchaseOrderSO.Sales_Order__c == null) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'The sales order is not found to pull line item from.'));            
            
        } else {
            orderId = purchaseOrderSO.Sales_Order__c;

            salesOrderSO = [SELECT Id,
                                AcctSeedERP__Ledger__c,
                                Ship_Via__c,
                                AcctSeedERP__Shipping_City__c,
                                AcctSeedERP__Shipping_Country__c,
                                AcctSeedERP__Shipping_PostalCode__c,
                                AcctSeedERP__Shipping_State__c,
                                AcctSeedERP__Shipping_Street__c,
                                Customer_PO_Number__c,
                                Shipping_Name__c
                            FROM AcctSeedERP__Sales_Order__c
                            WHERE Id = :orderId];
            //prepareDraftPO(); 
            prepOrderAndPOItems(orderId); 
        }
           
    
    }

    public void prepOrderAndPOItems (Id OrderId) {
        unreceivedQtyByProductId = new Map<Id,Decimal>();
        Map<Id, AcctSeedERP__Sales_Order_Line__c> orderLinesMap = new Map<Id, AcctSeedERP__Sales_Order_Line__c>([SELECT Id,
                                                                                Name,
                                                                                AcctSeedERP__Product__c,
                                                                                AcctSeedERP__Product__r.Name,
                                                                                AcctSeedERP__Product__r.AcctSeedERP__Minimum_Order_Quantity__c,
                                                                                AcctSeedERP__Product__r.AcctSeedERP__Safety_Stock_Quantity__c,
                                                                                AcctSeedERP__Product__r.ProductCode,
                                                                                AcctSeedERP__Product__r.Manufacturer__c,
                                                                                AcctSeedERP__Quantity_Needed__c,
                                                                                AcctSeedERP__Quantity_Ordered__c,
                                                                                AcctSeedERP__Unit_Price__c,
                                                                                Quote_Line_Item__r.Unit_Cost__c,
                                                                                AcctSeedERP__Purchase_Order_Line__c,
                                                                                AcctSeedERP__GL_Account_Variable_1__c,
                                                                                AcctSeedERP__GL_Account_Variable_2__c,
                                                                                AcctSeedERP__GL_Account_Variable_3__c,
                                                                                AcctSeedERP__GL_Account_Variable_4__c,
                                                                                AcctSeedERP__Project__c,
                                                                                AcctSeedERP__Project_Task__c,
                                                                                Quote_Line_Item__r.Tag__c
                                                                        FROM AcctSeedERP__Sales_Order_Line__c
                                                                        WHERE AcctSeedERP__Sales_Order__c = :orderId
                                                                        AND AcctSeedERP__Purchase_Order_Line__c = null
                                                                        AND AcctSeedERP__Product__r.AcctSeed__Inventory_Type__c = 'Purchased']);

        if(orderLinesMap == null || orderLinesMap.size() == 0) {
            //ApexPages.Message myMsg = new ApexPages.message(ApexPages.severity, 'To create a purchase order:');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'The sales order lines must not be associated with existing purchase order lines.'));
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'The sales order lines must not be allocated.'));
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'The products on the sales order lines must have Inventory Product checkbox checked & Inventory Type value set to "Purchased"'));
        }
        for(AcctSeedERP__Sales_Order_Line__c orderLine : orderLinesMap.Values()) {
            unreceivedQtyByProductId.put(orderLine.AcctSeedERP__Product__c,0);
        }
        List<AcctSeedERP__Purchase_Order_Line__c> POLine =[SELECT Id,
                                                                AcctSeedERP__Product__c,
                                                                AcctSeedERP__Quantity_Unreceived__c
                                                            FROM AcctSeedERP__Purchase_Order_Line__c
                                                            WHERE AcctSeedERP__Product__c IN :unreceivedQtyByProductId.keySet()];
        for(AcctSeedERP__Purchase_Order_Line__c Line :POLine) {
            Decimal quantityUnreceived = unreceivedQtyByProductId.get(Line.AcctSeedERP__Product__c);
            quantityUnreceived =+ Line.AcctSeedERP__Quantity_Unreceived__c;
            unreceivedQtyByProductId.put(Line.AcctSeedERP__Product__c, quantityUnreceived);
            
        }

        for(AcctSeedERP__Sales_Order_Line__c orderLine : orderLinesMap.Values()) {
            OrderLineWrapper orderPOWrapper = new OrderLineWrapper(orderLine, 
                                                        new AcctSeedERP__Purchase_Order__c(Sales_Order__c = orderId,
                                                                                        AcctSeedERP__Ledger__c = salesOrderSO.AcctSeedERP__Ledger__c,
                                                                                        Ship_Via__c = salesOrderSO.Ship_Via__c,
                                                                                        AcctSeedERP__Vendor__c = purchaseOrderSO.AcctSeedERP__Vendor__c,
                                                                                        AcctSeedERP__Type__c = purchaseOrderSO.AcctSeedERP__Type__c,
                                                                                        AcctSeedERP__Shipping_City__c = salesOrderSO.AcctSeedERP__Shipping_City__c,
                                                                                        AcctSeedERP__Shipping_Country__c = salesOrderSO.AcctSeedERP__Shipping_Country__c,
                                                                                        AcctSeedERP__Shipping_Postal_Code__c = salesOrderSO.AcctSeedERP__Shipping_PostalCode__c,
                                                                                        AcctSeedERP__Shipping_State__c = salesOrderSO.AcctSeedERP__Shipping_State__c,
                                                                                        AcctSeedERP__Shipping_Street__c = salesOrderSO.AcctSeedERP__Shipping_Street__c,
                                                                                        PO_Number__c = salesOrderSO.Customer_PO_Number__c,
                                                                                        Shipping_Company__c = salesOrderSO.Shipping_Name__c),
                                                        unreceivedQtyByProductId.get(orderLine.AcctSeedERP__Product__c));
            //orderPOWrapper.orderLine = orderLine;
            orderLineWrapperList.add(orderPOWrapper);
        }
        
        if(orderLineWrapperList != null) {
            orderPOWrapperByVendor = new Map<String, List<OrderLineWrapper>>();
            orderPOWrapperByVendor.put(purchaseOrderSO.AcctSeedERP__Vendor__c, orderLineWrapperList);
        }
    }

    public Pagereference createPurchaseOrderAndPOLines() {
        List<AcctSeedERP__Purchase_Order_Line__c> POLineItemListToInsert = new List<AcctSeedERP__Purchase_Order_Line__c>();
        List<AcctSeedERP__Sales_Order_Line__c> listOrderLineToUpdate = new List<AcctSeedERP__Sales_Order_Line__c>();
       
        //insert POByVendorId.values();
        Map<Id,AcctSeedERP__Purchase_Order_Line__c> OLIdToPOItem = new Map<Id,AcctSeedERP__Purchase_Order_Line__c>();

        for(Id vendorId : orderPOWrapperByVendor.keySet()) {
            system.debug('orderPOWrapperByVendor=>'+orderPOWrapperByVendor.get(vendorId));
            if(orderPOWrapperByVendor.containsKey(vendorId)) {
                for(OrderLineWrapper itemDetails :orderPOWrapperByVendor.get(vendorId)) {
                    if(itemDetails.isSelected || Test.isRunningTest()) {
                        AcctSeedERP__Purchase_Order_Line__c POItem = itemDetails.POItem;
                        POItem.AcctSeedERP__Product__c = itemDetails.orderLine.AcctSeedERP__Product__c;
                        POItem.AcctSeedERP__Purchase_Order__c = POId;
                        POLineItemListToInsert.add(POItem);
                        OLIdToPOItem.put(itemDetails.orderLine.Id,POItem);
                    }
                }
            }
            
        }
        if(OLIdToPOItem.size() > 0 && OLIdToPOItem.values() != null) {
            insert OLIdToPOItem.values();
        }
        

        for(Id orderLineId : OLIdToPOItem.keySet()) {
            AcctSeedERP__Sales_Order_Line__c orderLineToUpdate = new AcctSeedERP__Sales_Order_Line__c(
                                                                    Id = orderLineId,
                                                                    AcctSeedERP__Purchase_Order_Line__c = OLIdToPOItem.get(orderLineId).Id);
            listOrderLineToUpdate.add(orderLineToUpdate);                                                        
        }
        if(!listOrderLineToUpdate.isEmpty()) {
            update listOrderLineToUpdate;
        }
        
        Pagereference orderDetailPage = new Pagereference('/'+POId);
        orderDetailPage.setRedirect(true);
        return orderDetailPage;

    }

    public Pagereference goToOrder() {
        Pagereference orderDetailPage = new Pagereference('/'+POId);
        orderDetailPage.setRedirect(true);
        return orderDetailPage;
    }    

    public class OrderLineWrapper {
        public AcctSeedERP__Sales_Order_Line__c orderLine { get; set; }
        public AcctSeedERP__Purchase_Order__c PurchaseOrder { get; set; }
        public AcctSeedERP__Purchase_Order_Line__c POItem { get; set; }
        public Decimal QuantityNeeded { get; set; }
        public Decimal QuantityInStock { get; set; }
        public Decimal QuantityUnreceived { get; set; }
        public Decimal MinimumOrderQuantity { get; set; }
        public Decimal SafetyStockQuantity { get; set; }
        public Decimal Quantity { get; set; }
        public Boolean isSelected{get; set;}

        public OrderLineWrapper(AcctSeedERP__Sales_Order_Line__c orderLineItem, AcctSeedERP__Purchase_Order__c PO, Decimal UnreceivedQuantity) {
            orderLine = orderLineItem;
            PurchaseOrder = PO;
            isSelected = false;
            QuantityNeeded = 0;
            QuantityInStock = 0;
            QuantityUnreceived = UnreceivedQuantity; 
            MinimumOrderQuantity = 0;
            SafetyStockQuantity = 0;
            Quantity = orderLineItem.AcctSeedERP__Quantity_Ordered__c;

            POItem = new AcctSeedERP__Purchase_Order_Line__c();
            POItem.AcctSeedERP__Quantity__c = orderLineItem.AcctSeedERP__Quantity_Ordered__c;
            POItem.AcctSeedERP__Unit_Price__c = orderLineItem.Quote_Line_Item__r.Unit_Cost__c;
            if (POItem.AcctSeedERP__Unit_Price__c == null) {
                POItem.AcctSeedERP__Unit_Price__c = 0;
            }
            POItem.AcctSeedERP__GL_Account_Variable_1__c = orderLineItem.AcctSeedERP__GL_Account_Variable_1__c;
            POItem.AcctSeedERP__GL_Account_Variable_2__c = orderLineItem.AcctSeedERP__GL_Account_Variable_2__c;
            POItem.AcctSeedERP__GL_Account_Variable_3__c = orderLineItem.AcctSeedERP__GL_Account_Variable_3__c;
            POItem.AcctSeedERP__GL_Account_Variable_4__c = orderLineItem.AcctSeedERP__GL_Account_Variable_4__c;
            POItem.AcctSeedERP__Project__c = orderLineItem.AcctSeedERP__Project__c;
            POItem.AcctSeedERP__Project_Task__c = orderLineItem.AcctSeedERP__Project_Task__c;
            POItem.SalesOrderLine__c = orderLineItem.Id;
        }
    }


}