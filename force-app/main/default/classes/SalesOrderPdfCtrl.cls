public with sharing class SalesOrderPdfCtrl {
    public List<AcctSeedERP__Sales_Order_Line__c> SOLines {get;set;}
    public Id salesOrderId;
    public AcctSeedERP__Sales_Order__c salesOrderSO{get;set;}
    public Boolean isMarsPdf{get;set;}
    public SalesOrderPdfCtrl(Apexpages.standardController controller) {
    
        //isMarsPdf = false;
        salesOrderId = apexpages.currentpage().getparameters().get('id');
        salesOrderSO = [SELECT Id,
                                Name,
                                Sales_Order_Number__c,
                                SO_Number__c,
                                AcctSeedERP__Opportunity__r.RecordType.Name,
                                AcctSeedERP__Opportunity__r.Office__c,
                                Quote__c
                        FROM AcctSeedERP__Sales_Order__c
                        WHERE Id = :salesOrderId];
        SOLines = new List<AcctSeedERP__Sales_Order_Line__c>();
        SOLines = [SELECT Id,
                        Name,
                        AcctSeedERP__Product__r.Name,
                        AcctSeedERP__Product__r.ProductCode,
                        AcctSeedERP__Quantity_Ordered__c,
                        AcctSeedERP__Quantity_Shipped__c,
                        AcctSeedERP__Quantity_Needed__c,
                        AcctSeedERP__Unit_Price__c,
                        AcctSeedERP__Total__c,
                        Quote_Line_Item__r.Descriptions__c
                FROM AcctSeedERP__Sales_Order_Line__c
                WHERE AcctSeedERP__Sales_Order__c = :salesOrderId];
    

        if(salesOrderSO.AcctSeedERP__Opportunity__r.RecordType.Name == UtilitySharePointToSFIntegration.OPP_MARRS_RECORDTYPE) {
            isMarsPdf = true;
        } else {
            isMarsPdf = false;
        }

    }
    
    
    public PageReference generateAttachment() {
            PageReference pdf = new PageReference('/apex/SalesOrderPdf?Id='+salesOrderId);
            
            Attachment SOPdf= new Attachment();
            SOPdf.Name = (salesOrderSO.Sales_Order_Number__c == null || salesOrderSO.Sales_Order_Number__c == '') ? salesOrderSO.Name : salesOrderSO.Sales_Order_Number__c + ' | Accounting Seed.pdf';
            SOPdf.IsPrivate = false;
            SOPdf.ParentId = salesOrderId;
            if(!Test.isRunningTest()){
                SOPdf.body = pdf.getContentAsPDF();
            }
            else{
                Blob content = Blob.valueOf('UNIT.TEST');
                SOPdf.body = content;
            }
            
            insert SOPdf;
            
            PageReference pr = new PageReference('/'+salesOrderId);
            pr.setRedirect(true);
            return pr;
        
    }
    /*
    public SalesOrderPdfCtrl(Apexpages.standardController stdCon){
       
    }*/
}