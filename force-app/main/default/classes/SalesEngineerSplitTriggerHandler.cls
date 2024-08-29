public with sharing class SalesEngineerSplitTriggerHandler{
    
    public static Map<String,Id> mapOfficeNameSalesRepId{get;set;} 
    
    public static void fillOfficeNameSalesRepId(){
        mapOfficeNameSalesRepId = new Map<String,Id>();
        mapOfficeNameSalesRepId.put('Midwest Machinery STL','00561000000gZ3T');
        mapOfficeNameSalesRepId.put('Midwest Machinery KC','00561000000gZ6I');
        mapOfficeNameSalesRepId.put('Midwest Machinery OK','00561000000gZ68');
        mapOfficeNameSalesRepId.put('Midwest Machinery CO','00561000000gZ6D');
    }
    
    public static void createSalesRepEntry(String oppId, String oppOffice){
        
        fillOfficeNameSalesRepId();
        
        Sales_Representative__c newSalesRep = new Sales_Representative__c();
        newSalesRep.Commision__c = 100;
        newSalesRep.Opportunity__c = oppId;
        newSalesRep.Sales_Rep__c = mapOfficeNameSalesRepId.get(oppOffice);
        insert newSalesRep;
    
    }
    
    public static void updateSalesRepEntry(String oppId, String oppOffice){
        
        fillOfficeNameSalesRepId();
        
        List<Sales_Representative__c> lstSalesRep = [Select Id,Sales_Rep__c From Sales_Representative__c
                                                    WHERE Id IN :mapOfficeNameSalesRepId.values()
                                                    AND Opportunity__c =: oppId];
                                                    
        if(!lstSalesRep.isEmpty()){
            lstSalesRep[0].Sales_Rep__c = mapOfficeNameSalesRepId.get(oppOffice);
            update lstSalesRep[0];
        }
        else{
            createSalesRepEntry(oppId, oppOffice);
        }
    }
    
}