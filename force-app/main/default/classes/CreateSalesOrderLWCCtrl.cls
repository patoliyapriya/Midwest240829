public with sharing class CreateSalesOrderLWCCtrl {
    public CreateSalesOrderLWCCtrl() {

    }

    /*
     * wrapper class to hold order & order line data
     */
    public class DisplayListMasterDetailStruct {
        @AuraEnabled
        public SObject parentData;
        @AuraEnabled
        public List<SObject> LineItems;
        @AuraEnabled
        public Decimal GrandTotal;
        @AuraEnabled
        public List<ProductGroupWrapper> productGroupDetails = new List<ProductGroupWrapper>();
        public DisplayListMasterDetailStruct() {
        }
    } 

    public class ChildWrapper {
        @AuraEnabled
        public String childGroupName;
        @AuraEnabled
        public List<AcctSeedERP__Sales_Order_Line__c> orderLines;
        public ChildWrapper() {
            orderLines = new List<AcctSeedERP__Sales_Order_Line__c>();
        }
    }
    public class ProductGroupWrapper {
        @AuraEnabled
        public string groupName;
        @AuraEnabled
        public List<ChildWrapper> childGroupsDetail;
        public ProductGroupWrapper() {
        }
    }

    @AuraEnabled(cacheable=true)
    public static DisplayListMasterDetailStruct fetchOrderWithLineItems (Id quoteId) {
        DisplayListMasterDetailStruct responseData = new DisplayListMasterDetailStruct();

        Quote quoteRecord = [Select Id,Name,
                                Attention_to_Account__r.Name,
                                Opportunity.Name,
                                Opportunity.Ledger__c,
                                Total_Extended_Cost__c,
                                QuoteNumber,
                                Revision__c,
                                Bid_Date__c
                                From Quote Where Id = :quoteId];
        
        AcctSeedERP__Sales_Order__c salesOrder = new AcctSeedERP__Sales_Order__c(
            AcctSeedERP__Customer__c = quoteRecord.Attention_to_Account__c,
            AcctSeedERP__Ledger__c = quoteRecord.Opportunity.Ledger__c,
            AcctSeedERP__Opportunity__c = quoteRecord.OpportunityId,
            Quote__c = quoteRecord.Id
        );
        

        Map<Id,Product_Select__c> quoteLines = new Map<Id,Product_Select__c>([SELECT Id,Name,
                                                    Quantity__c,
                                                    Sales_Price__c,
                                                    Product_Name__c,
                                                    ProductId__c,
                                                    Product_Group__c,
                                                    Product_Group__r.Parent_Product_Group__c
                                            FROM Product_Select__c
                                            WHERE Quote__c = :quoteId]);

        List<AcctSeedERP__Sales_Order_Line__c> orderLines = new List<AcctSeedERP__Sales_Order_Line__c>();
        Map<Id, List<Product_Select__c>> grpIdToQuoteLine = new Map<Id, List<Product_Select__c>>();
        for(Product_Select__c lineItem :quoteLines.Values()) {
            if(grpIdToQuoteLine.containsKey(lineItem.Product_Group__c)) {
                grpIdToQuoteLine.get(lineItem.Product_Group__c).add(lineItem);
            } else {
                grpIdToQuoteLine.put(lineItem.Product_Group__c, new list<Product_Select__c>{lineItem});    
            }
        }
        /*
        for(Product_Select__c lineItem :quoteLines) {
            Decimal unitPrice = 0;
            if(lineItem.Sales_Price__c != null && lineItem.Sales_Price__c > 0) {
                unitPrice = lineItem.Sales_Price__c;
                if(lineItem.Quantity__c != null && lineItem.Quantity__c > 0) {
                    unitPrice = (unitPrice / lineItem.Quantity__c).setScale(2);
                }
            }

            AcctSeedERP__Sales_Order_Line__c orderLine = new AcctSeedERP__Sales_Order_Line__c(
                AcctSeedERP__Quantity_Ordered__c = lineItem.Quantity__c,
                AcctSeedERP__Unit_Price__c = unitPrice,
                AcctSeedERP__Product__c = lineItem.ProductId__c,
                AcctSeedERP__Comment__c = ''
            );
            orderLines.add(orderLine);
        }       */                            
        // construct groups
        List<Product_Group__c> allGroups = [SELECt Id,Name,
                                                    Parent_Product_Group__c,
                                                    Parent_Product_Group__r.Name
                                            FROM Product_Group__c
                                            WHERE Quote__c = :quoteRecord.Id];
         system.debug('Product_Group__c qurey :- ' +allGroups);
        Map<Id,List<Id>> parentTosubGroups = new Map<Id,List<Id>>();
        Map<Id,String> productgroupNames = new Map<Id,String>();

        for(Product_Group__c grp :allGroups) {

            

            productgroupNames.put(grp.Id, grp.Name);
            if(grp.Parent_Product_Group__c == null &&
            parentTosubGroups.containsKey(grp.Parent_Product_Group__c) == false) {
                //it is parent group
                parentTosubGroups.put(grp.Id, new List<String>{});
            }

            if(grp.Parent_Product_Group__c !=null) {
                if(parentTosubGroups.containsKey(grp.Parent_Product_Group__c)) {
                    parentTosubGroups.get(grp.Parent_Product_Group__c).add(grp.Id);
                } else {
                    parentTosubGroups.put(grp.Parent_Product_Group__r.Name, new List<String>{grp.id});
                }
            }
        }

        System.debug('group=>'+parentTosubGroups);
        
        List<ProductGroupWrapper> ProductWrapperlst = new List<ProductGroupWrapper>();
        for(Id parentGrpId :parentTosubGroups.keySet() ) {


            List<ChildWrapper> listOfChildData = new List<ChildWrapper>();
            for(Id childGrpId :parentTosubGroups.get(parentGrpId)) {
                ChildWrapper childGroupData = new ChildWrapper();
                childGroupData.childGroupName = productgroupNames.get(childGrpId); 

                for(Product_Select__c lineItem : grpIdToQuoteLine.get(childGrpId)) {
                    Decimal unitPrice = 0;
                    if(lineItem.Sales_Price__c != null && lineItem.Sales_Price__c > 0) {
                        unitPrice = lineItem.Sales_Price__c;
                        if(lineItem.Quantity__c != null && lineItem.Quantity__c > 0) {
                            unitPrice = (unitPrice / lineItem.Quantity__c).setScale(2);
                        }
                    }

                    AcctSeedERP__Sales_Order_Line__c orderLine = new AcctSeedERP__Sales_Order_Line__c(
                        AcctSeedERP__Quantity_Ordered__c = lineItem.Quantity__c,
                        AcctSeedERP__Unit_Price__c = unitPrice,
                        AcctSeedERP__Product__c = lineItem.ProductId__c,
                        AcctSeedERP__Comment__c = ''
                    );

                    system.debug('Addline item in comment' + orderLine);
                    system.debug('Addline item in comment' + orderLine.AcctSeedERP__Comment__c);
                    
                    childGroupData.orderLines.add(orderLine);

                }
                listOfChildData.add(childGroupData);
                system.debug('Addline item in salesorder' +listOfChildData);
                

            }
                        
            ProductGroupWrapper productWrapper = new ProductGroupWrapper();
            productWrapper.groupName = productgroupNames.get(parentGrpId); 
            productWrapper.childGroupsDetail = listOfChildData;
            ProductWrapperlst.add(productWrapper);
        }
        system.debug('ProductWrapperlst=>'+ProductWrapperlst);
        responseData.productGroupDetails = ProductWrapperlst;
        responseData.parentData = salesOrder;
        responseData.LineItems = orderLines;
        responseData.GrandTotal = quoteRecord.Total_Extended_Cost__c;
         System.debug('responseData=>'+responseData);
        return responseData;
    }

    /*
     * wrapper class to hold order & order line data
     */
    public class ResponseCreateSalesOrder {
        @AuraEnabled
        public String errorMesage;
        @AuraEnabled
        public String errorType;
        @AuraEnabled
        public Id orderId;
        @AuraEnabled
        public Boolean isSuccess;
        public ResponseCreateSalesOrder() {
        }
    } 

    @AuraEnabled
    public static ResponseCreateSalesOrder createSalesOrderWithLineItems(List<AcctSeedERP__Sales_Order_Line__c> orderLines, 
                                                     AcctSeedERP__Sales_Order__c salesOrder) {
       
        ResponseCreateSalesOrder response = new ResponseCreateSalesOrder();
        try {
            insert salesOrder;
            System.debug('Order=>'+salesOrder);
            for(AcctSeedERP__Sales_Order_Line__c orderLine :orderLines) {
                orderLine.AcctSeedERP__Sales_Order__c = salesOrder.Id;
            }
            System.debug('orderLines=>'+orderLines);
            insert orderLines;

            response.isSuccess = true;
            response.orderId = salesOrder.Id;
            return response;
        } catch(Exception ex) {
            
            system.debug(ex);
            response.isSuccess = false;
            response.errorMesage = ex.getMessage();
            return response;
        }
    } 

}