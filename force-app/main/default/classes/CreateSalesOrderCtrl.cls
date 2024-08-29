/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 12-06-2023
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class CreateSalesOrderCtrl {
    public Quote quoteRecord {get;set;}
    public AcctSeedERP__Sales_Order__c salesOrder {get;set;}
    public List<ProductGroupWrapper> productGroupDetails {get;set;}
    public Map<Id,String> productIdToName {get;set;}
    public string message{get;set;}
    public Boolean iserror {get;set;}
    public Boolean isActiveFinancial {get;set;}
    public class ChildWrapper {
        public String childGroupName{get;set;}
        public List<AcctSeedERP__Sales_Order_Line__c> orderLines{get;set;}
        public ChildWrapper() {
            orderLines = new List<AcctSeedERP__Sales_Order_Line__c>();
        }
    }
    public class ProductGroupWrapper {
        public string groupName{get;set;}
        public List<ChildWrapper> childGroupsDetail{get;set;}
        public ProductGroupWrapper() {
        }
    }
    
    public CreateSalesOrderCtrl() {
       
    }

    public CreateSalesOrderCtrl(ApexPages.StandardController controller) {
        productIdToName = new Map<Id,String>();
        message = null;
        iserror = false;
        
        Id quoteId = apexpages.currentpage().getparameters().get('quoteid');
        quoteRecord = [SELECT Id,Name,
                                Attention_to_Account__r.Name,
                                Opportunity.Name,
                                Total_Extended_Cost__c,
                                QuoteNumber,
                                Revision__c,
                                Bid_Date__c,
                                OpportunityId
                        FROM Quote
                        WHERE Id = :quoteId];
        isActiveFinancial = isActiveFinancialQuote();
        if(isActiveFinancial) {
            productGroupDetails = new List<ProductGroupWrapper>();
            fetchOrderAndLineItems();
        } else {
            iserror = true;
            message = 'you can create salesorder only from active financial quote.';
        }

    }

    public void fetchOrderAndLineItems(){
        
        salesOrder = new AcctSeedERP__Sales_Order__c(
            AcctSeedERP__Customer__c = quoteRecord.Attention_to_Account__c,
            AcctSeedERP__Ledger__c = null,
            AcctSeedERP__Opportunity__c = quoteRecord.OpportunityId,
            Quote__c = quoteRecord.Id
        );

        Map<Id,Product_Select__c> quoteLines = new Map<Id,Product_Select__c>([SELECT Id,
                                                                                Name,
                                                                                Quantity__c,
                                                                                Sales_Price__c,
                                                                                Product_Name__c,
                                                                                ProductId__c,
                                                                                ProductId__r.Name,
                                                                                Product_Group__c,
                                                                                Product_Group__r.Parent_Product_Group__c
                                                                        FROM Product_Select__c
                                                                        WHERE Quote__c = :quoteRecord.Id]);
        
        // agreegate QLs based on groups
        Map<Id, List<Product_Select__c>> grpIdToQuoteLine = new Map<Id, List<Product_Select__c>>();
        for(Product_Select__c lineItem :quoteLines.Values()) {
            productIdToName.put(lineItem.ProductId__c, lineItem.ProductId__r.Name);
            if(grpIdToQuoteLine.containsKey(lineItem.Product_Group__c)) {
                grpIdToQuoteLine.get(lineItem.Product_Group__c).add(lineItem);
            } else {
                grpIdToQuoteLine.put(lineItem.Product_Group__c, new list<Product_Select__c>{lineItem});    
            }
        }
        // construct groups
        List<Product_Group__c> allGroups = [SELECt Id,Name,
                                                    Parent_Product_Group__c,
                                                    Parent_Product_Group__r.Name
                                            FROM Product_Group__c
                                            WHERE Quote__c = :quoteRecord.Id];
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
        productGroupDetails = new List<ProductGroupWrapper>();
        for(Id parentGrpId :parentTosubGroups.keySet() ) {

            List<ChildWrapper> listOfChildData = new List<ChildWrapper>();
            for(Id childGrpId :parentTosubGroups.get(parentGrpId)) {
                ChildWrapper childGroupData = new ChildWrapper();
                childGroupData.childGroupName = productgroupNames.get(childGrpId); 

                if(grpIdToQuoteLine.containsKey(childGrpId)) {
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
                        childGroupData.orderLines.add(orderLine);
    
                    }
                }

                listOfChildData.add(childGroupData);
            }
                        
            ProductGroupWrapper productWrapper = new ProductGroupWrapper();
            productWrapper.groupName = productgroupNames.get(parentGrpId); 
            productWrapper.childGroupsDetail = listOfChildData;
            productGroupDetails.add(productWrapper);
        }
        system.debug('ProductWrapperlst=>'+productGroupDetails);

    }

    public Pagereference createSalesOrder () {
        try {
            insert salesOrder;
        } catch(Exception ex) {
            message = ex.getMessage();
            iserror = true;
            return null;
        }
        List<AcctSeedERP__Sales_Order_Line__c> orderLines = new List<AcctSeedERP__Sales_Order_Line__c>();
        List<Product_Select__c> quoteLinesToUpdate = new List<Product_Select__c>();

        for(ProductGroupWrapper productgroup :productGroupDetails) {
            System.debug(productgroup.groupName);
            for(ChildWrapper childGrp :productgroup.childGroupsDetail) {
                for(AcctSeedERP__Sales_Order_Line__c orderLine : childGrp.orderLines) {
                    orderLine.AcctSeedERP__Sales_Order__c = salesOrder.Id;

                    orderLines.add(orderLine);

                    Product_Select__c quoteLine = new Product_Select__c(Id=orderLine.Quote_Line_Item__c,SalesOrderId__c=salesOrder.Id);
                    quoteLinesToUpdate.add(quoteLine);
                }
                

            }
        }
        
        //insert orderLines;
        try {
            insert orderLines;
            update quoteLinesToUpdate;
        } catch(Exception ex) {
            message = ex.getMessage();
            System.debug(salesOrder.Id+' <<orderId');
            System.debug('error Message='+message);
            iserror = true;
            return null;
        }
        string orderUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/AcctSeedERP__Sales_Order__c/'+salesOrder.Id+'/view?0.source=alohaHeader';
        PageReference pageRef = new PageReference(orderUrl);
        pageRef.setRedirect(true);
        return pageRef;
    }

    public Boolean isActiveFinancialQuote() {
        List<Opportunity> lstActiveFinancialQuoteOpp = [Select Id From Opportunity Where Active_Financial_Quote__c =:quoteRecord.Id];
        if(lstActiveFinancialQuoteOpp.size() > 0) {
            return true;
        }
        return false;
    }
}