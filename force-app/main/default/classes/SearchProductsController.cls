Public With Sharing Class SearchProductsController {
    public Map<Id,Project__c> quoteLineToProduct {get;set;}
    public SearchProductsController() {
        searchProducts();
    }
    public string SerialNumber {
        get
        {
            if(SerialNumber == null)
                SerialNumber = '';
            return SerialNumber;
        }
        set;
    }
    
    public List<Product_Select__c> quoteLineItems {
        get
        {
            if(quoteLineItems == null)
                quoteLineItems = new List<Product_Select__c>();
            return quoteLineItems;
        }
        set;
    }
    
    public void searchProducts () {
        
        if (quoteLineItems != null) {
            quoteLineItems.clear();
        }
        quoteLineToProduct = new Map<Id,Project__c>();
        System.Debug('Initializing search, keyword is : ' + SerialNumber);   
        if(SerialNumber == '') {
            return;
        }    
        String finalSearchValue = '%' + SerialNumber + '%';
        List<Product_Select__c> quoteLines = new List<Product_Select__c>();
        
        // add all the required fields
        String QL_Query = 'SELECT Id,Name,Warranty_Start_Date__c,Warranty_End_Date__c,Warranty_Type__c';
        QL_Query  += ',Product_Group__r.Name,Tag__c,Hide_Line_On_Email__c,Product_Code__c,Warranty_Parts_Covered__c';
        QL_Query  += ',Serial_Number__c,Schedule_Startup_Date__c,Completed_Startup_Date__c,Warranty_Term__c,Quote__r.OpportunityId ';
        
        // add conditions
        QL_Query  += 'FROM Product_Select__c WHERE ';
        if(SerialNumber != '' && SerialNumber != null && 
           String.isNotBlank(SerialNumber) && String.isNotEmpty(SerialNumber)) {
            QL_Query  += 'Serial_Number__c like :finalSearchValue ';
            QL_Query  += 'OR Tracking_Number__c like :finalSearchValue ';
        } else {
            QL_Query  += 'Warranty_End_Date__c != null  Order By Warranty_End_Date__c ASC';
        }

        quoteLines  = database.query(QL_Query);
        quoteLineToProduct = fetchProjectsForQL(quoteLines);
        quoteLineItems = quoteLines;
    }
    
    public Map<Id,Project__c> fetchProjectsForQL(List<Product_Select__c> quoteLines) {
        Map<Id,Project__c> quoteLineToProduct = new Map<Id,Project__c>();
        Transient Map<Id,Project__c> OpportunityIdToProject = new Map<Id,Project__c>();
        Transient List<Project__c> projects = new List<Project__c>();
        Transient Project__c Blankproj = new Project__c (Name='Not Found');
        Transient set<Id> OpportunityIds = new set<Id>();

        for(Product_Select__c ql : quoteLines) {
            OpportunityIds.add(ql.Quote__r.OpportunityId);
            quoteLineToProduct.put(ql.Id,Blankproj);
        }
        projects = [SELECT Id,Opportunity__c,Name From Project__c WHERE Opportunity__c IN :OpportunityIds];
        if(projects.size() > 0) {
            for(Project__c prj : projects) {
                OpportunityIdToProject.put(prj.Opportunity__c, prj);
            }
    
            for(Product_Select__c ql : quoteLines) {
                if(OpportunityIdToProject.containsKey(ql.Quote__r.OpportunityId)) {
                    Project__c prjectForQL = OpportunityIdToProject.get(ql.Quote__r.OpportunityId);
                    quoteLineToProduct.put(ql.Id,prjectForQL);
                }
                
            }
        }

        return quoteLineToProduct;
    }
}