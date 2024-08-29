public with sharing class SystemUtil {
    
    public class customNumberingException extends Exception {} 

    public static void generateCustomAutoNumber(AcctSeedERP__Sales_Order__c salesOrder) {

        if(salesOrder.AcctSeedERP__Opportunity__c != null) {

            List<Opportunity> lstOpportunity = [SELECT Office__c, Opportunity_Number__c
                                            FROM Opportunity 
                                            WHERE Id =: salesOrder.AcctSeedERP__Opportunity__c
                                            AND Office__c != null];

            if(lstOpportunity.isEmpty()) {
                throw new customNumberingException('Please select office on opportunity.');
            }

            Integer totalSONumber = 1;

            AggregateResult totalSalesOrders;

            if(salesOrder.Quote__c != null) {
                totalSalesOrders = [SELECT Count(Id) totalSO 
                                    FROM AcctSeedERP__Sales_Order__c 
                                    WHERE Quote__c =: salesOrder.Quote__c];
                
                if(totalSalesOrders != null) {
                    totalSONumber += Integer.valueOf(totalSalesOrders.get('totalSO'));
                }
            } else {
                totalSalesOrders = [SELECT Count(Id) totalSO 
                                    FROM AcctSeedERP__Sales_Order__c 
                                    WHERE AcctSeedERP__Opportunity__c =: salesOrder.AcctSeedERP__Opportunity__c];

                if(totalSalesOrders != null) {
                    totalSONumber += Integer.valueOf(totalSalesOrders.get('totalSO'));
                }
            }

            salesOrder.Sales_Order_Number__c = 'S' + getOfficeCode(lstOpportunity[0].Office__c) 
                                                    + lstOpportunity[0].Opportunity_Number__c 
                                                    + '-' + String.valueOf(totalSONumber);
        }

    }

    public static void generateCustomAutoNumber(List<AcctSeedERP__Purchase_Order__c> lstPurchaseOrder) {
        system.debug('before if condition');
            system.debug('in else condition');
            String opportunityNumber = '';
        String office = '';
        string salesOrderNumber = '';

        List<AcctSeedERP__Sales_Order__c> lstSalesOrder = [SELECT AcctSeedERP__Opportunity__r.Office__c, Sales_Order_Number__c,
                                                                AcctSeedERP__Opportunity__r.Opportunity_Number__c
                                                            FROM AcctSeedERP__Sales_Order__c 
                                                            WHERE Id =: lstPurchaseOrder[0].Sales_Order__c
                                                            AND AcctSeedERP__Opportunity__r.Office__c != null];
        if(!lstSalesOrder.isEmpty()) {
            opportunityNumber = lstSalesOrder[0].AcctSeedERP__Opportunity__r.Opportunity_Number__c;
            office = lstSalesOrder[0].AcctSeedERP__Opportunity__r.Office__c;
            salesOrderNumber = lstSalesOrder[0].Sales_Order_Number__c.substringAfter('-').substringAfter('-');
            system.debug('Sonumber:- '+salesOrderNumber);

            AggregateResult totalPurchaseOrders = [SELECT Count(Id) totalPO 
                                                        FROM AcctSeedERP__Purchase_Order__c 
                                                        WHERE Sales_Order__c =: lstPurchaseOrder[0].Sales_Order__c];

            if(totalPurchaseOrders != null) {

                Integer totalPONumber = Integer.valueOf(totalPurchaseOrders.get('totalPO'));

                for(AcctSeedERP__Purchase_Order__c purchaseOrder : lstPurchaseOrder) {
                    
                    totalPONumber++;
                    
                    purchaseOrder.Purchase_Order_Number__c = 'P' + getOfficeCode(office) 
                                                            + opportunityNumber + '-'
                                                            +'S' + salesOrderNumber
                                                            + '-' + String.valueOf(totalPONumber);
                }
            }
        }else if(lstPurchaseOrder[0].office__c != null && lstPurchaseOrder[0].Sales_Order__c == null){
                system.debug('in if condition');
                office = lstPurchaseOrder[0].Office__c;
    
                AggregateResult totalPurchaseOrders = [SELECT Count(Id) totalPO 
                                                            FROM AcctSeedERP__Purchase_Order__c 
                                                            WHERE Sales_Order__c = null
                                                            AND office__c != null];
                    Integer totalPONumber = Integer.valueOf(totalPurchaseOrders.get('totalPO'));
    
                    for(AcctSeedERP__Purchase_Order__c purchaseOrder : lstPurchaseOrder) {
                        
                        totalPONumber++;
                        
                        purchaseOrder.Purchase_Order_Number__c = 'P' + getOfficeCode(office) 
                                                                + '-' + String.valueOf(totalPONumber);
                        system.debug('purchase order number:- ' + purchaseOrder.Purchase_Order_Number__c);
                    }
            } else {
            throw new customNumberingException('Please select office on opportunity.');
        }
    }

    public static void generateCustomAutoNumber(AcctSeed__Billing__c invoice) {

        if(invoice.AcctSeed__Opportunity__c != null) {

            List<Opportunity> lstOpportunity = [SELECT Office__c, Opportunity_Number__c
                                                    FROM Opportunity 
                                                    WHERE Id =: invoice.AcctSeed__Opportunity__c
                                                    AND Office__c != null];

            if(lstOpportunity.isEmpty()) {
                throw new customNumberingException('Please select office on opportunity.');
            }

            Integer totalInvoicesNumber = 1;

            if(invoice.AcctSeedERP__Sales_Order__c != null){
                AggregateResult totalInvoices = [SELECT Count(Id) totalInvoice
                                                FROM AcctSeed__Billing__c 
                                                WHERE AcctSeedERP__Sales_Order__c =: invoice.AcctSeedERP__Sales_Order__c];

                if(totalInvoices != null) {
                    totalInvoicesNumber += Integer.valueOf(totalInvoices.get('totalInvoice'));
                }

                AcctSeedERP__Sales_Order__c salesOrder = [SELECT  Sales_Order_Number__c
                                                                FROM AcctSeedERP__Sales_Order__c 
                                                                WHERE Id =: invoice.AcctSeedERP__Sales_Order__c];
                string salesOrderNumber = salesOrder.Sales_Order_Number__c.substringAfter('-').substringAfter('-');
                invoice.Invoice_Number__c = 'I' + getOfficeCode(lstOpportunity[0].Office__c) 
                                                    + lstOpportunity[0].Opportunity_Number__c 
                                                    + '-' + 'S' + salesOrderNumber
                                                    + '-' + String.valueOf(totalInvoicesNumber);
            }else{
                AggregateResult totalInvoices = [SELECT Count(Id) totalInvoice
                                                FROM AcctSeed__Billing__c 
                                                WHERE AcctSeed__Opportunity__c =: invoice.AcctSeed__Opportunity__c];

                if(totalInvoices != null) {
                    totalInvoicesNumber += Integer.valueOf(totalInvoices.get('totalInvoice'));
                }

                invoice.Invoice_Number__c = 'I' + getOfficeCode(lstOpportunity[0].Office__c) 
                                                    + lstOpportunity[0].Opportunity_Number__c 
                                                    + '-' + String.valueOf(totalInvoicesNumber);
            }
        }
    }

    public static String getOfficeCode(String officeName) {

        Map<String, String> mapOfficeCodes = new Map<String, String>();
        mapOfficeCodes.put('Midwest Machinery STL', 'M');
        mapOfficeCodes.put('Midwest Machinery KC', 'K');
        mapOfficeCodes.put('Midwest Machinery OK', 'P');
        mapOfficeCodes.put('Engineered Products', 'E');
        mapOfficeCodes.put('MaRRS', 'R');
        mapOfficeCodes.put('Midwest Industrial Builders', 'B');
        mapOfficeCodes.put('Spark', 'S');

        return mapOfficeCodes.get(officeName);
        
    } 

}