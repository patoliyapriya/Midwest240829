public with sharing class ProjectDetailsController{
    
    public Id projectId{get;set;}
    public Project__c currentProject{get;set;}
    public List<Project__c> lstProjects{get;set;}
    public Opportunity oppDetails{get;set;}
    public String endUserAddress{get;set;}
    
    public Product_Select__c qliSelectAll{get;set;}

    public List<ProductGroupWrapperClass> lstProductGroupWrapperClass{get;set;}
    public List<Product_Select__c> lstProductSelect{get;set;}
    public List<releaseManagementWrapperClass> lstReleases{get;set;}
    
    public String emailURL{get;set;}
    public String selectContactUser{get;set;}
    
    public List<Project_Schdule_To__c> lstScheduleTo{get;set;}
    public Integer removeIndex{get;set;}
    public Set<Id> setDelProjectSChedule{get;set;}

    public ProjectDetailsController(Apexpages.StandardController stdCon){
        selectContactUser = 'Contact';
        projectId = stdCon.getId();
        init();
    } 

    public void doAddScheduleTo() {
        Project_Schdule_To__c objProjectSchdule = new Project_Schdule_To__c();
        objProjectSchdule.Schedule_Type__c = 'Contact';
        objProjectSchdule.Project__c = projectId;
        lstScheduleTo.add(objProjectSchdule);
    }

    public List<Project_Schdule_To__c> loadScheduleTo() {
        List<Project_Schdule_To__c> lstProjectScheduleTo = [Select Id, Name, Contact__c, Project__c, Schedule_Type__c, User__c
                                                            FROM Project_Schdule_To__c
                                                            WHERE Project__c = :projectId];
        return lstProjectScheduleTo;
    }

    public void doRemoveScheduleTo() {

        Project_Schdule_To__c delProjectSChedule = lstScheduleTo[removeIndex - 1];
        if(delProjectSChedule.Id != null) {
            setDelProjectSChedule.add(delProjectSChedule.Id);
        }
        lstScheduleTo.remove(removeIndex - 1);
        if(!setDelProjectSChedule.isEmpty()) {
            deleteScheduleTo();
        }
        
    }

    public void deleteScheduleTo() {
        if(!setDelProjectSChedule.isEmpty()) {
            delete [Select Id From Project_Schdule_To__c WHERE ID IN: setDelProjectSChedule];
        }
        //lstScheduleTo = loadScheduleTo();
        setDelProjectSChedule = new Set<Id>();
    }

    public void init(){
        qliSelectAll = new Product_Select__c();
        lstReleases = new List<releaseManagementWrapperClass>();
        setDelProjectSChedule = new Set<Id>();

        lstScheduleTo = loadScheduleTo();
        if(lstScheduleTo.isEmpty()) {
            doAddScheduleTo();
        }

        currentProject = [SELECT Id, Opportunity__c, Quote__r.Bid_Date__c,Project_Status__c,OwnerId,Name,Pay_Cycle__c,Notes_Details__c,
                                Schedule_To__c, Schedule_On__c, Schedule_End_Date__c,Schedule_To__r.Name,Schedule_To__r.Email,
                                Hide_Act_Ship__c, Hide_Billing_Status__c, Hide_Date_of_Billing__c, Hide_IOM_Done__c, Hide_Note__c, Hide_Payment_Received__c,
                                Hide_Release__c, Hide_Released_to_Mfgr__c, Hide_Tag__c,
                                ProjectShipDate__c, PO_Number__c
                         FROM Project__c
                         WHERE Id =: projectId];
        
        oppDetails = [Select Id,Name,PO_Number__c, Sync_Quote__r.Bid_Date__c,Sync_Quote__r.Total_Base_Bid_Total__c,Sync_Quote__r.Total_Extended_Cost__c,Opportunity_Number__c,
                        Sync_Quote__r.Commissions_and_Rebates__c,Sync_Quote__r.Total_Buy_Resell_Margin__c,Sync_Quote__r.Total_Buy_Resell_Margin_Percentage__c,
                        Sync_Quote__r.Total_Project_Margin__c,Sync_Quote__r.Total_Project_Margin_Percentage__c,Account.Name,Sync_Quote__r.QuoteNumber,
                        Active_Financial_Quote__r.Bid_Date__c,Active_Financial_Quote__r.Total_Base_Bid_Total__c,Active_Financial_Quote__r.Total_Extended_Cost__c,
                        Active_Financial_Quote__r.Commissions_and_Rebates__c,Active_Financial_Quote__r.Total_Buy_Resell_Margin__c,Active_Financial_Quote__r.Total_Buy_Resell_Margin_Percentage__c,
                        Active_Financial_Quote__r.Total_Project_Margin__c,Active_Financial_Quote__r.Total_Project_Margin_Percentage__c,Active_Financial_Quote__r.QuoteNumber,End_User_Contact_Name__r.Name,
                        Account.ShippingCity,Account.ShippingStreet, Account.ShippingState, Account.ShippingCountry, Account.ShippingPostalCode, Account.Payment_and_Accounting_Notes__c, Account.Credit_Limit__c 
                        From Opportunity
                        WHERE Id =: currentProject.Opportunity__c];
        
        EmailTemplate et = [Select Id From EmailTemplate Where DeveloperName = 'Stage_Startup_and_Warranty'];
        
        emailURL = '/_ui/core/email/author/EmailAuthor?p3_lkid=' + currentProject.Id + '&template_id=' + et.Id + '&retURL=/' + currentProject.Id;
        
        getEndUserAddress();
        FillQuoteLineItems();
        BuildProductGroupWrapperClass();
        getAllLineItemsOfReleases();
    }
    
    public void changeContactUser() {
        System.debug('###---'+selectContactUser);
    }

    public void getEndUserAddress(){
        
        endUserAddress = '';
        
        if(!String.isEmpty(oppDetails.Account.ShippingStreet)) {
            if(endUserAddress == ''){
                endUserAddress = oppDetails.Account.ShippingStreet;
            } else {
                endUserAddress += ' ,' + oppDetails.Account.ShippingStreet;
            }    

        }
        
        if(!String.isEmpty(oppDetails.Account.ShippingCity)) {
            if(endUserAddress == ''){
                endUserAddress = oppDetails.Account.ShippingCity;
            } else {
                endUserAddress += ' ,' + oppDetails.Account.ShippingCity;
            }    
            
        }
        
        if(!String.isEmpty(oppDetails.Account.ShippingState)) {
            if(endUserAddress == ''){
                endUserAddress = oppDetails.Account.ShippingState;
            } else {
                endUserAddress += ' ,' + oppDetails.Account.ShippingState;
            }    
            
        }
        
        if(!String.isEmpty(oppDetails.Account.ShippingPostalCode)) {
            if(endUserAddress == ''){
                endUserAddress = oppDetails.Account.ShippingPostalCode;
            } else {
                endUserAddress += '-' + oppDetails.Account.ShippingPostalCode;
            }    
            
        }
        
        if(!String.isEmpty(oppDetails.Account.ShippingCountry)) {
            if(endUserAddress == ''){
                endUserAddress = oppDetails.Account.ShippingCountry;
            } else {
                endUserAddress += '.' + oppDetails.Account.ShippingCountry;
            }    
            
        }
        
    }
    
    //public void quickSave(){}
    
    public void saveQuoteLineItemsAndReleaseManagement(){
        
        updateQuoteLineItems();
        updateReleaseManagement();
        System.debug('currentproject==>'+currentProject.ProjectShipDate__c);

        
        // create/update calender event for ship date
        Map<String, Roles_With_Public_Calendars__c> calendarMap = Roles_With_Public_Calendars__c.getAll();
        Set<Id> publicCalendarIds = new Set<Id>();
        for(Roles_With_Public_Calendars__c calendar : calendarMap.values()){
            publicCalendarIds.add(calendar.Calendar_Id__c);
        }
       
        
        Project__c projectToUpsertEventFor = [SELECT Id,
                                                    Name,
                                                    ProjectShipDate__c,
                                                    Owner.UserRole.Name
                                             FROM Project__c
                                             WHERE Id = :projectId];
        if(projectToUpsertEventFor.ProjectShipDate__c == null) {
            return;
        }
        System.debug('projectToUpsertEventFor==>'+projectToUpsertEventFor.Owner.UserRole.Name);                                     
        Event evt;                                     
        try {
            evt = [Select Id, OwnerId, 
                            StartDateTime, WhatId 
                    FROM Event 
                    WHERE OwnerId In :publicCalendarIds 
                    AND WhatId = :projectToUpsertEventFor.Id
                    LIMIT 1];

        } catch(Exception ex) {
            evt = null;

        }                                  
         
        Roles_With_Public_Calendars__c calendarWithProjectOwnerRole = calendarMap.get('shipping '+projectToUpsertEventFor.Owner.UserRole.Name);
        System.debug('project ship date value==>'+projectToUpsertEventFor.ProjectShipDate__c);                                     
        if(evt != null) {
            if(evt.OwnerId == calendarWithProjectOwnerRole.Calendar_Id__c) {
                evt.StartDateTime = projectToUpsertEventFor.ProjectShipDate__c;
                evt.EndDateTime = projectToUpsertEventFor.ProjectShipDate__c;
                
                System.debug('event date date value==>'+evt.StartDateTime);                                     
                System.debug('event id==>'+evt.Id);                                     
                update evt;
            } else {
                // Salesforce is not allowing to change event owner.
                // if project owner has changed then we will have to re-create event 
                delete evt;

                // create new event record
                Event ev = new Event();
                ev.StartDateTime = projectToUpsertEventFor.ProjectShipDate__c;
                ev.EndDateTime = projectToUpsertEventFor.ProjectShipDate__c;
                ev.WhatId = projectToUpsertEventFor.Id;
                ev.OwnerId = calendarWithProjectOwnerRole.Calendar_Id__c;
                ev.Subject = ' Proj. Ship: ' + projectToUpsertEventFor.Name;

                insert ev;
            }
         } else if(calendarWithProjectOwnerRole != null){
            Event ev = new Event();
            ev.StartDateTime = projectToUpsertEventFor.ProjectShipDate__c;
            ev.EndDateTime = projectToUpsertEventFor.ProjectShipDate__c;
            ev.WhatId = projectToUpsertEventFor.Id;
            ev.OwnerId = calendarWithProjectOwnerRole.Calendar_Id__c;
            ev.Subject = ' Proj. Ship: ' + projectToUpsertEventFor.Name;

            insert ev;
        }            


    }
    
    public void updateQuoteLineItems(){
        
        List<Product_Select__c> lstProductSelectToUpdate = new List<Product_Select__c>();
        
        for(ProductGroupWrapperClass pg : lstProductGroupWrapperClass){
            if(pg!= null) {
                for(ProductSubGroupWrapperClass psg : pg.lstProductSubGroup){
                    for(ProductWrapperClass pw : psg.lstProductSelected){
                        lstProductSelectToUpdate.add(pw.productDetails);
                    }
                }
            }

        }
        
        update lstProductSelectToUpdate;
        
    }
    
    public void updateReleaseManagement(){
        
        List<Release_Management__c> lstReleaseManagementToUpsert = new List<Release_Management__c>();
        
        for(releaseManagementWrapperClass rm : lstReleases){
            for(releaseManagement r : rm.lstReleases){
                lstReleaseManagementToUpsert.add(r.release);
            }
            
        }
        if(lstReleaseManagementToUpsert.size() > 0){
            upsert lstReleaseManagementToUpsert;
        }
        
    }
    
    public void FillQuoteLineItems(){
        lstProductSelect = [Select Product_Name__c,Product_Code__c,Quantity__c,List_Price__c,Multiplier__c,Freight__c,Extended_Cost__c,Margin_Percentage__c,Sales_Price__c
                            FROM Product_Select__c
                            WHERE Quote__c =: oppDetails.Active_Financial_Quote__c];
    }
    
    public void SendEmail(){
        
    }
    
    public void getAllLineItemsOfReleases(){
        List<Product_Select__c> lstLineItems = [Select Manufacturer__c,Product_Name__c,Product_Code__c,Sale_Type__c,Quantity__c,List_Price__c,Multiplier__c,Freight__c,Extended_Cost__c,Margin_Percentage__c,Sales_Price__c,CR__c,Release_pick__c,
                                                Hide_Line_On_Email__c,Hide_Line_On_Email_Startup__c 
                                                FROM Product_Select__c
                                                WHERE Quote__c =: oppDetails.Active_Financial_Quote__c
                                                ORDER BY Release_pick__c ASC];
                                                
        List<Release_Management__c> lstReleaseManagement = [Select Id,Release_Name__c,Release__c,Project_Id__c,Midwest_Machinery_PO__c,Customer_PO__c,Unique_Key__c,Sage__c
                                                            FROM Release_Management__c
                                                            WHERE Project_Id__c =: projectId];
        
        Map<String, Release_Management__c> mapReleaseManagement = new Map<String, Release_Management__c>();
        
        for(Release_Management__c rm : lstReleaseManagement){
            mapReleaseManagement.put(rm.Release__c, rm);
        }
        
        Integer parentRelease = null;
        
        releaseManagement rm = new releaseManagement();
        releaseManagementWrapperClass release = new releaseManagementWrapperClass();
        
        for(Product_Select__c ps : lstLineItems){
            
            if(parentRelease == null && !String.isBlank(ps.Release_pick__c)){
                parentRelease = Integer.valueOf(ps.Release_pick__c.substring(0,1));
                
                release.parentReleaseNumber = parentRelease;
                
                rm.releaseNumber = ps.Release_pick__c;
                if(mapReleaseManagement.get(ps.Release_pick__c) != null){
                    rm.release = mapReleaseManagement.get(ps.Release_pick__c);
                }
                else{
                    rm.release = new Release_Management__c();
                    rm.release.Release__c = ps.Release_pick__c;
                    rm.release.Project_Id__c = projectId;
                    rm.release.Unique_Key__c = ps.Release_pick__c + projectId;
                }
                rm.lstProductDetails = new List<Product_Select__c>();
                rm.lstProductDetails.add(ps);
            }
            else{
                if(!String.isBlank(ps.Release_pick__c) && rm.releaseNumber == ps.Release_pick__c){
                    rm.lstProductDetails.add(ps);
                }
                else if(!String.isBlank(ps.Release_pick__c) && rm.releaseNumber != ps.Release_pick__c && parentRelease == Integer.valueOf(ps.Release_pick__c.substring(0,1))){
                    release.lstReleases.add(rm);
                    
                    rm = new releaseManagement();
                    rm.releaseNumber = ps.Release_pick__c;
                    if(mapReleaseManagement.get(ps.Release_pick__c) != null){
                        rm.release = mapReleaseManagement.get(ps.Release_pick__c);
                    }
                    else{
                        rm.release = new Release_Management__c();
                        rm.release.Release__c = ps.Release_pick__c;
                        rm.release.Project_Id__c = projectId;
                        rm.release.Unique_Key__c = ps.Release_pick__c + projectId;
                    }
                    rm.lstProductDetails = new List<Product_Select__c>();
                    rm.lstProductDetails.add(ps);
                }
                else if(!String.isBlank(ps.Release_pick__c) && rm.releaseNumber != ps.Release_pick__c && parentRelease != Integer.valueOf(ps.Release_pick__c.substring(0,1))){
                    release.lstReleases.add(rm);
                    lstReleases.add(release);
                    
                    release = new releaseManagementWrapperClass();
                    
                    parentRelease = Integer.valueOf(ps.Release_pick__c.substring(0,1));
                    release.parentReleaseNumber = parentRelease;
                    
                    rm = new releaseManagement();
                    rm.releaseNumber = ps.Release_pick__c;
                    if(mapReleaseManagement.get(ps.Release_pick__c) != null){
                        rm.release = mapReleaseManagement.get(ps.Release_pick__c);
                    }
                    else{
                        rm.release = new Release_Management__c();
                        rm.release.Release__c = ps.Release_pick__c;
                        rm.release.Project_Id__c = projectId;
                        rm.release.Unique_Key__c = ps.Release_pick__c + projectId;
                    }
                    rm.lstProductDetails = new List<Product_Select__c>();
                    rm.lstProductDetails.add(ps);
                    
                }
            }
            
            
        }
        if(rm.releaseNumber != '' && rm.releaseNumber != null){
            release.lstReleases.add(rm);
            lstReleases.add(release);
        }

        
    }
    
    public void BuildProductGroupWrapperClass(){
        
        lstProductGroupWrapperClass = new List<ProductGroupWrapperClass>();
        
        List<Product_Group__c> lstProductGroups = [Select Id,Name, Parent_Product_Group__r.Name, Parent_Product_Group__c, 
                                                            (SELECT Original_Product_Name__c,Product_Code__c,Product_Group__c,Product_Name__c,
                                                                Submittals__c,Release_Date__c,Estimated_Ship_Date__c,Customer_PO__c,IOM_Completed__c,Billing_Status__c,Date_of_Billing__c,Payment_Received__c,Note__c,
                                                                Serial_Number__c,Schedule_Startup_Date__c,Completed_Startup_Date__c,Warranty_Term__c,Warranty_Parts_Covered__c,Warranty_Start_Date__c,Warranty_End_Date__c,
                                                                Warranty_Type__c,Act_Ship__c,Release__c,Release_pick__c,Hide_Line_On_Email__c,Hide_Line_On_Email_Startup__c,Tag__c, Tracking_Number__c
                                                                FROM Quote_Line_Items__r
                                                                ORDER BY Row_Index__c ASC)
                                                            From Product_Group__c 
                                                            WHERE Quote__c =: oppDetails.Active_Financial_Quote__c
                                                            AND Parent_Product_Group__c != null
                                                            ORDER BY Parent_Product_Group__c,Index__c ASC];    
        
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
        
    }
    
    public void scheduleEmail(){
        if(!lstScheduleTo.isEmpty()){
            upsert lstScheduleTo;
        }
        update currentProject;
        
        currentProject = [SELECT Id, Opportunity__c, Quote__r.Bid_Date__c,Project_Status__c,OwnerId,Name,Pay_Cycle__c,Notes_Details__c,
                                Schedule_To__c, Schedule_On__c, Schedule_End_Date__c,Schedule_To__r.Name,Schedule_To__r.Email,
                                ProjectShipDate__c   
                         FROM Project__c
                         WHERE Id =: projectId];
    }
    
    public class releaseManagementWrapperClass{
        public Integer parentReleaseNumber{get;set;}
        public List<releaseManagement> lstReleases{get;set;}
        
        public releaseManagementWrapperClass(){
            lstReleases = new List<releaseManagement>();
        }
    }
    
    public class releaseManagement{
        
        public List<Product_Select__c> lstProductDetails{get;set;}
        public Release_Management__c release{get;set;}
        public String releaseNumber{get;set;}
        
        public releaseManagement(){
            lstProductDetails = new List<Product_Select__c>();
        }
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