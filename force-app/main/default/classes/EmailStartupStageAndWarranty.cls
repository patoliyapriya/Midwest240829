public class EmailStartupStageAndWarranty{
    
    //public String projectId{get;set;}
    public Project__c currentProject{get;set;}
    public Opportunity oppDetails{get;set;}
    public List<ProductGroupWrapperClass> lstProductStageStatus{get;set;}
    public List<ProductGroupWrapperClass> lstProductStartupAndWarranty{get;set;}
    public Boolean initialized { get; set; }
    public map<Id,Stage_Startup_Warranty_History__c> mapHistoryLineItems{get;set;}
    public Set<String> setFieldChange{get;set;}
    public string isDebug{get;set;}
    
    public String projectId{ 
        get;
        set {
            projectId = value;
            init();
        }
    }
    
    public void init(){
        
        List<Project__c> lstProjects = [Select Id, Opportunity__c, Quote__r.Bid_Date__c,Project_Status__c,OwnerId,Name,Pay_Cycle__c,Notes_Details__c,   
                                        Hide_Act_Ship__c, Hide_Billing_Status__c, Hide_Date_of_Billing__c, Hide_IOM_Done__c, Hide_Note__c, Hide_Payment_Received__c,
                                         Hide_Release__c, Hide_Released_to_Mfgr__c, Hide_Tag__c
                         From Project__c
                         WHERE Id =: projectId];
        
        if(!lstProjects.isEmpty()){
            currentProject = lstProjects[0];
        
        
            List<Opportunity> lstOpportunity = [Select Id,Name,PO_Number__c, Sync_Quote__r.Bid_Date__c,Sync_Quote__r.Total_Base_Bid_Total__c,
                                                Sync_Quote__r.Total_Extended_Cost__c,Opportunity_Number__c,
                                                Sync_Quote__r.Commissions_and_Rebates__c,Sync_Quote__r.Total_Buy_Resell_Margin__c,Sync_Quote__r.Total_Buy_Resell_Margin_Percentage__c,
                                                Sync_Quote__r.Total_Project_Margin__c,Sync_Quote__r.Total_Project_Margin_Percentage__c,Account.Name,Sync_Quote__r.QuoteNumber,
                                                Active_Financial_Quote__r.Bid_Date__c,Active_Financial_Quote__r.Total_Base_Bid_Total__c,Active_Financial_Quote__r.Total_Extended_Cost__c,
                                                Active_Financial_Quote__r.Commissions_and_Rebates__c,Active_Financial_Quote__r.Total_Buy_Resell_Margin__c,Active_Financial_Quote__r.Total_Buy_Resell_Margin_Percentage__c,
                                                Active_Financial_Quote__r.Total_Project_Margin__c,Active_Financial_Quote__r.Total_Project_Margin_Percentage__c,Active_Financial_Quote__r.QuoteNumber
                                                From Opportunity
                                                WHERE Id =: currentProject.Opportunity__c];
            
            if(!lstOpportunity.isEmpty()){
                oppDetails = lstOpportunity[0];
            }
            
            if(setFieldChange == null){
                setFieldChange = new Set<String>();
            }
            if(mapHistoryLineItems == null){
                mapHistoryLineItems = new map<Id,Stage_Startup_Warranty_History__c>();
            }
            
            
            prepareLineItemHistory();
            
            if(lstProductStageStatus == null){
                lstProductStageStatus = getProductGroupStageStatus();
            }
            if(lstProductStartupAndWarranty == null){
                lstProductStartupAndWarranty = getProductGroupStartupAndWarranty();
            }
            
            
        }
    }
    
    public List<ProductGroupWrapperClass> getProductGroupStageStatus(){
        List<Product_Group__c> lstProductGroups  = [Select Id,Name, Parent_Product_Group__r.Name, Parent_Product_Group__c, 
                                                            (SELECT Original_Product_Name__c,Product_Code__c,Product_Group__c,Product_Name__c,
                                                                Submittals__c,Release_Date__c,Estimated_Ship_Date__c,Customer_PO__c,IOM_Completed__c,Billing_Status__c,Date_of_Billing__c,Payment_Received__c,Note__c,
                                                                Serial_Number__c,Schedule_Startup_Date__c,Completed_Startup_Date__c,Warranty_Term__c,Warranty_Parts_Covered__c,Warranty_Start_Date__c,Warranty_End_Date__c,
                                                                Warranty_Type__c,Act_Ship__c,Release__c,Release_pick__c,Tag__c,
                                                                Tracking_Number__c
                                                                FROM Quote_Line_Items__r
                                                                WHERE Hide_Line_On_Email__c = false
                                                                AND Hide_Line_On_Email_Startup__c = false
                                                                AND Sale_Type__c != 'C/R'
                                                                ORDER BY Row_Index__c ASC)
                                                            From Product_Group__c 
                                                            WHERE Quote__c =: oppDetails.Active_Financial_Quote__c
                                                            AND Parent_Product_Group__c != null
                                                            ORDER BY Parent_Product_Group__c,Index__c ASC];
        isDebug += 'Nilesh';
        return BuildProductGroupWrapperClass(lstProductGroups,'Stage Status');
    }
    
    public List<ProductGroupWrapperClass> getProductGroupStartupAndWarranty(){
        List<Product_Group__c> lstProductGroups = [Select Id,Name, Parent_Product_Group__r.Name, Parent_Product_Group__c, 
                                                            (SELECT Original_Product_Name__c,Product_Code__c,Product_Group__c,Product_Name__c,
                                                                Submittals__c,Release_Date__c,Estimated_Ship_Date__c,Customer_PO__c,IOM_Completed__c,Billing_Status__c,Date_of_Billing__c,Payment_Received__c,Note__c,
                                                                Serial_Number__c,Schedule_Startup_Date__c,Completed_Startup_Date__c,Warranty_Term__c,Warranty_Parts_Covered__c,Warranty_Start_Date__c,Warranty_End_Date__c,
                                                                Warranty_Type__c,Act_Ship__c,Release__c,Release_pick__c,Tag__c,
                                                                Tracking_Number__c
                                                                FROM Quote_Line_Items__r
                                                                WHERE Hide_Line_On_Email_Startup__c = false
                                                                AND Sale_Type__c != 'C/R'
                                                                ORDER BY Row_Index__c ASC)
                                                            From Product_Group__c 
                                                            WHERE Quote__c =: oppDetails.Active_Financial_Quote__c
                                                            AND Parent_Product_Group__c != null
                                                            ORDER BY Parent_Product_Group__c,Index__c ASC];
        return BuildProductGroupWrapperClass(lstProductGroups, 'Startup Warranty');
    }
    
    public void prepareLineItemHistory(){
        
        List<Stage_Startup_Warranty_History__c> lstQuoteLineItemsHistory = [Select Id, Name, Act_Ship__c, Billing_Status__c, Completed_Startup_Date__c, Date_of_Billing__c, Estimated_Ship_Date__c, IOM_Completed__c,
                                                                            Note__c, Payment_Received__c, Product_Code__c, Product_Name__c, Quote_Line_Items__c, Release__c, Release_Date__c, Schedule_Startup_Date__c,
                                                                            Serial_Number__c, Submittals__c, Tag__c, Warranty_Term__c, Warranty_End_Date__c, Warranty_Start_Date__c, Warranty_Type__c
                                                                            FROM Stage_Startup_Warranty_History__c
                                                                            WHERE Quote_Line_Items__r.Quote__c =: oppDetails.Active_Financial_Quote__c];
                                                                            
        for(Stage_Startup_Warranty_History__c historyLineItem : lstQuoteLineItemsHistory){
            mapHistoryLineItems.put(historyLineItem.Quote_Line_Items__c, historyLineItem);
        }
    }
    
    public void checkHistory(List<Product_Select__c> lstOriginalLineItem){
        
        List<Stage_Startup_Warranty_History__c> lstHistoryTOInsert = new List<Stage_Startup_Warranty_History__c>();
        
        for(Product_Select__c originalLineItem : lstOriginalLineItem){
            
            if(mapHistoryLineItems.get(originalLineItem.Id) == null){
                Stage_Startup_Warranty_History__c newHistory = new Stage_Startup_Warranty_History__c();
                newHistory.Act_Ship__c = originalLineItem.Act_Ship__c;
                newHistory.Billing_Status__c = originalLineItem.Billing_Status__c;
                newHistory.Completed_Startup_Date__c = originalLineItem.Completed_Startup_Date__c;
                newHistory.Date_of_Billing__c = originalLineItem.Date_of_Billing__c;
                newHistory.Estimated_Ship_Date__c = originalLineItem.Estimated_Ship_Date__c;
                newHistory.IOM_Completed__c = originalLineItem.IOM_Completed__c;
                newHistory.Note__c = originalLineItem.Note__c;
                newHistory.Payment_Received__c = originalLineItem.Payment_Received__c;
                newHistory.Product_Code__c = originalLineItem.Product_Code__c;
                newHistory.Product_Name__c = originalLineItem.Product_Name__c;
                newHistory.Quote_Line_Items__c = originalLineItem.Id;
                newHistory.Release__c = originalLineItem.Release__c;
                newHistory.Release_Date__c = originalLineItem.Release_Date__c;
                newHistory.Schedule_Startup_Date__c = originalLineItem.Schedule_Startup_Date__c;
                newHistory.Serial_Number__c = originalLineItem.Serial_Number__c;
                newHistory.Submittals__c = originalLineItem.Submittals__c;
                newHistory.Tag__c = originalLineItem.Tag__c;
                newHistory.Warranty_Term__c = originalLineItem.Warranty_Term__c;
                newHistory.Warranty_End_Date__c = originalLineItem.Warranty_End_Date__c;
                newHistory.Warranty_Start_Date__c = originalLineItem.Warranty_Start_Date__c;
                newHistory.Warranty_Type__c = originalLineItem.Warranty_Type__c;
                lstHistoryTOInsert.add(newHistory);
            }
            else{
                isDebug += 'JJJ';
                Stage_Startup_Warranty_History__c historyLineItem = mapHistoryLineItems.get(originalLineItem.Id);
                
                if(originalLineItem.Act_Ship__c != historyLineItem.Act_Ship__c){
                    setFieldChange.add(originalLineItem.Id + 'Act_Ship__c');
                    historyLineItem.Act_Ship__c = originalLineItem.Act_Ship__c;
                }
                if(originalLineItem.Billing_Status__c != historyLineItem.Billing_Status__c){
                    setFieldChange.add(originalLineItem.Id + 'Billing_Status__c');
                    historyLineItem.Billing_Status__c = originalLineItem.Billing_Status__c;
                }
                if(originalLineItem.Completed_Startup_Date__c != historyLineItem.Completed_Startup_Date__c){
                    setFieldChange.add(originalLineItem.Id + 'Completed_Startup_Date__c');
                    historyLineItem.Completed_Startup_Date__c = originalLineItem.Completed_Startup_Date__c;
                }
                if(originalLineItem.Date_of_Billing__c != historyLineItem.Date_of_Billing__c){
                    setFieldChange.add(originalLineItem.Id + 'Date_of_Billing__c');
                    historyLineItem.Date_of_Billing__c = originalLineItem.Date_of_Billing__c;
                }
                if(originalLineItem.Estimated_Ship_Date__c != historyLineItem.Estimated_Ship_Date__c){
                    setFieldChange.add(originalLineItem.Id + 'Estimated_Ship_Date__c');
                    historyLineItem.Estimated_Ship_Date__c = originalLineItem.Estimated_Ship_Date__c;
                }
                if(originalLineItem.IOM_Completed__c != historyLineItem.IOM_Completed__c ){
                    setFieldChange.add(originalLineItem.Id + 'IOM_Completed__c ');
                    historyLineItem.IOM_Completed__c = originalLineItem.IOM_Completed__c;
                }
                if(originalLineItem.Note__c != historyLineItem.Note__c){
                    setFieldChange.add(originalLineItem.Id + 'Note__c');
                    historyLineItem.Note__c = originalLineItem.Note__c;
                }
                if(originalLineItem.Payment_Received__c != historyLineItem.Payment_Received__c){
                    setFieldChange.add(originalLineItem.Id + 'Payment_Received__c');
                    historyLineItem.Payment_Received__c = originalLineItem.Payment_Received__c;
                }
                if(originalLineItem.Product_Code__c != historyLineItem.Product_Code__c){
                    setFieldChange.add(originalLineItem.Id + 'Product_Code__c');
                    historyLineItem.Product_Code__c = originalLineItem.Product_Code__c;
                }
                if(originalLineItem.Product_Name__c != historyLineItem.Product_Name__c){
                    setFieldChange.add(originalLineItem.Id + 'Product_Name__c');
                    historyLineItem.Product_Name__c = originalLineItem.Product_Name__c;
                }
                if(originalLineItem.Release__c != historyLineItem.Release__c){
                    setFieldChange.add(originalLineItem.Id + 'Release__c');
                    historyLineItem.Release__c = originalLineItem.Release__c;
                }
                if(originalLineItem.Release_Date__c != historyLineItem.Release_Date__c){
                    setFieldChange.add(originalLineItem.Id + 'Release_Date__c');
                    historyLineItem.Release_Date__c = originalLineItem.Release_Date__c;
                }
                if(originalLineItem.Schedule_Startup_Date__c != historyLineItem.Schedule_Startup_Date__c){
                    setFieldChange.add(originalLineItem.Id + 'Schedule_Startup_Date__c');
                    historyLineItem.Schedule_Startup_Date__c = originalLineItem.Schedule_Startup_Date__c;
                }
                if(originalLineItem.Serial_Number__c != historyLineItem.Serial_Number__c){
                    setFieldChange.add(originalLineItem.Id + 'Serial_Number__c');
                    historyLineItem.Serial_Number__c = originalLineItem.Serial_Number__c;
                }
                if(originalLineItem.Submittals__c != historyLineItem.Submittals__c){
                    isDebug += 'true';
                    setFieldChange.add(originalLineItem.Id + 'Submittals__c');
                    historyLineItem.Submittals__c = originalLineItem.Submittals__c;
                }
                if(originalLineItem.Tag__c != historyLineItem.Tag__c){
                    setFieldChange.add(originalLineItem.Id + 'Tag__c');
                    historyLineItem.Tag__c = originalLineItem.Tag__c;
                }
                if(originalLineItem.Warranty_Term__c != historyLineItem.Warranty_Term__c){
                    setFieldChange.add(originalLineItem.Id + 'Warranty_Term__c');
                    historyLineItem.Warranty_Term__c = originalLineItem.Warranty_Term__c;
                }
                if(originalLineItem.Warranty_End_Date__c != historyLineItem.Warranty_End_Date__c){
                    setFieldChange.add(originalLineItem.Id + 'Warranty_End_Date__c');
                    historyLineItem.Warranty_End_Date__c = originalLineItem.Warranty_End_Date__c;
                }
                if(originalLineItem.Warranty_Start_Date__c != historyLineItem.Warranty_Start_Date__c){
                    setFieldChange.add(originalLineItem.Id + 'Warranty_Start_Date__c');
                    historyLineItem.Warranty_Start_Date__c = originalLineItem.Warranty_Start_Date__c;
                }
                if(originalLineItem.Warranty_Type__c != historyLineItem.Warranty_Type__c){
                    setFieldChange.add(originalLineItem.Id + 'Warranty_Type__c');
                    historyLineItem.Warranty_Type__c = originalLineItem.Warranty_Type__c;
                }
                lstHistoryTOInsert.add(historyLineItem);
            }
        }
        
        if(!lstHistoryTOInsert.isEmpty()){
            isDebug += 'SF-' + setFieldChange.size();
            upsert lstHistoryTOInsert;
        }
        
    }
    
    public List<ProductGroupWrapperClass> BuildProductGroupWrapperClass(List<Product_Group__c> lstProductGroups, String isFrom){
        
        List<ProductGroupWrapperClass> lstProductGroupWrapperClass = new List<ProductGroupWrapperClass>();
        Set<Id> setParentGroupIds = new Set<Id>();
        
        for(Product_Group__c pg : lstProductGroups){
            if(pg.Parent_Product_Group__c != null){
                setParentGroupIds.add(pg.Parent_Product_Group__c);
            }
        }
        
        List<Product_Group__c> lstParentProductGroups = [Select Id,Name
                                                        FROM Product_Group__c
                                                        WHERE Id IN :setParentGroupIds];
        
        Map<Id,Product_Group__c> mapProductGroup = new Map<Id,Product_Group__c>();
        
        for(Product_Group__c pg : lstParentProductGroups){
            mapProductGroup.put(pg.Id, pg);
        }
        
        Id parentGroup = null;
        
        ProductGroupWrapperClass objProductGroupWrapperClass;
        Map<Id,ProductGroupWrapperClass> mapParentGroupIdWrapper = new Map<Id,ProductGroupWrapperClass>();
        isDebug += 'ABC'+lstProductGroups.size();
        for(Product_Group__c pg : lstProductGroups){
            
            if(parentGroup == null){
                parentGroup = pg.Parent_Product_Group__c;
            }
            
            if(parentGroup != pg.Parent_Product_Group__c && parentGroup != null){
            
                lstProductGroupWrapperClass.add(objProductGroupWrapperClass);
                objProductGroupWrapperClass = new ProductGroupWrapperClass(mapProductGroup.get(pg.Parent_Product_Group__c));
                
                parentGroup = pg.Parent_Product_Group__c;
                
            }
            
            ProductSubGroupWrapperClass objProductSubGroupWrapperClass = new ProductSubGroupWrapperClass(pg);
            
            List<Product_Select__c> lstProductSelect = pg.Quote_Line_Items__r;
            
            if(lstProductSelect.size() > 0){
                checkHistory(lstProductSelect);
            }
            
            for(Product_Select__c ql : pg.Quote_Line_Items__r){
                ProductWrapperClass objProductWrapperClass = new ProductWrapperClass(ql);
                objProductSubGroupWrapperClass.lstProductSelected.add(objProductWrapperClass);
            }
            if(mapParentGroupIdWrapper.get(pg.Parent_Product_Group__c) != null){
                objProductGroupWrapperClass = mapParentGroupIdWrapper.get(pg.Parent_Product_Group__c);
            }
            else{
                objProductGroupWrapperClass = new ProductGroupWrapperClass(mapProductGroup.get(pg.Parent_Product_Group__c));
                mapParentGroupIdWrapper.put(pg.Parent_Product_Group__c,objProductGroupWrapperClass);
            }
            objProductGroupWrapperClass.lstProductSubGroup.add(objProductSubGroupWrapperClass);    
            
        }
        
        lstProductGroupWrapperClass.add(objProductGroupWrapperClass);
        
        
        
        return lstProductGroupWrapperClass;
    }
    
    public class ProductWrapperClass{
        
        public Product_Select__c productDetails{get;set;}
        
        public ProductWrapperClass(Product_Select__c ps){
            productDetails = ps;
        }
        
    }
    
    public class ProductGroupWrapperClass{
        
        public Product_Group__c productGroup{get;set;}
        public List<ProductSubGroupWrapperClass> lstProductSubGroup{get;set;}
                
        public ProductGroupWrapperClass(Product_Group__c pg){
            productGroup = pg;
            lstProductSubGroup = new List<ProductSubGroupWrapperClass>();
        }
        
    }
    
    public class ProductSubGroupWrapperClass{
        
        public Product_Group__c productGroup{get;set;}
        public List<ProductWrapperClass> lstProductSelected{get;set;}
        
        public ProductSubGroupWrapperClass(Product_Group__c pg){
            productGroup = pg;
            lstProductSelected = new List<ProductWrapperClass>();
        }
        
    }
    
}