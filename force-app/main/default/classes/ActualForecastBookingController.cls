public class ActualForecastBookingController {

    public List<OpportunityWrapper> lstOpportunityWrapper;
    
    public String selectSalesRep{get;set;}

    public String selectReportType{get;set;}
    public List<SelectOption> lstReportType{get;set;}
    
    public String selectDuration{get;set;}
    public List<SelectOption> lstDuration{get;set;}

    Map<Id, Decimal> mapMargin{get;set;}
    Map<Id, Decimal> mapRevenue{get;set;}

    public final String SAINT_LOUIS = 'Saint Louis';
    public final String OKLAHOMA = 'Oklahoma';
    public final String KANSAS_CITY = 'Kansas City';
    public final String DENVER = 'Denver';

    public Final Integer PAGE_SIZE = 10;

    public ActualForecastBookingController() {

        lstReportType = new List<SelectOption>();
        lstReportType.add(new SelectOption('Actual Booking','Actual Booking'));
        lstReportType.add(new SelectOption('Forecast Booking','Forecast Booking'));

        lstDuration = new List<SelectOption>();
        lstDuration.add(new SelectOption('12','12'));
        lstDuration.add(new SelectOption('6','6'));
        lstDuration.add(new SelectOption('3','3'));
        lstDuration.add(new SelectOption('1','1'));

    }

    public ActualForecastBookingController(ApexPages.StandardController controller) {

    }

    public ApexPages.StandardSetController con {
        get {
            if(con == null) {
                if(selectSalesRep == null) {
                    selectSalesRep = Apexpages.currentPage().getParameters().get('selectSalesRep');
                }
                if(selectReportType == null) {
                    selectReportType = Apexpages.currentPage().getParameters().get('reportType');
                }
                if(selectDuration == null) {
                    selectDuration = Apexpages.currentPage().getParameters().get('duration');
                }
                
                Integer numberOfYears = Integer.valueOf(selectDuration);
                Set<Id> setSalesRepIds = getSalesRepIds();

                if(selectReportType == 'Actual Booking') {
                    setSalesRepIds = getActualBooking(numberOfYears, setSalesRepIds);
                } else if(selectReportType == 'Forecast Booking') {
                    setSalesRepIds = getForecastedBooking(numberOfYears, setSalesRepIds);
                }

                con = new ApexPages.StandardSetController(Database.getQueryLocator([Select Opportunity_Number__c,Name,Total_Project_Margin__c,Total_Base_Bid_Total_Quote__c,
                                                                                    Probability,Bidders__c,Description,Owner.Name,Ship_Date__c,CloseDate,LastModifiedDate,LastActivityDate,
                                                                                    (Select Body From Feeds Order By LastModifiedDate desc) lastChatterAction 
                                                                                    From Opportunity
                                                                                    WHERE Id IN: setSalesRepIds
                                                                                    AND Total_Project_Margin__c != null
                                                                                    ORDER BY Total_Project_Margin__c desc]));
                con.setPageSize(PAGE_SIZE);
            }
            return con;
        }
        set;
    }

    public Set<Id> getActualBooking(Integer nuberOfYears, Set<Id> setSalesRepIds) {
        
        Set<Id> setOpportunityIds = new Set<Id>();
        
        Date closeDt = Date.today().addMonths(-Integer.valueOf(nuberOfYears));
        
        List<Sales_Representative__c> lstSalesRepOpportunity = [Select Opportunity__c
                                                                FROM Sales_Representative__c
                                                                WHERE Sales_Rep__c IN :setSalesRepIds AND
                                                                Opportunity__r.CloseDate >=: closeDt AND  
                                                                Opportunity__r.CloseDate <= Today AND
                                                                Opportunity__r.StageName = 'Closed Won']; 

        for(Sales_Representative__c sr : lstSalesRepOpportunity) {
            setOpportunityIds.add(sr.Opportunity__c);
        }                              
        
        return setOpportunityIds;
    }
    
    public Set<Id> getForecastedBooking(Integer numberOfYears, Set<Id> setSalesRepIds) {
        
        Set<Id> setOpportunityIds = new Set<Id>();
        
        Date closeDt = Date.today().addMonths(Integer.valueOf(numberOfYears));
        
        List<Sales_Representative__c> lstSalesRepOpportunity = [Select Opportunity__c
                                                                FROM Sales_Representative__c
                                                                WHERE Sales_Rep__c IN :setSalesRepIds AND
                                                                Opportunity__r.CloseDate <=: closeDt AND  
                                                                Opportunity__r.CloseDate >= Today AND
                                                                (Opportunity__r.StageName = 'Bidding' OR
                                                                Opportunity__r.StageName = 'Post Bid' OR
                                                                Opportunity__r.StageName = 'TARGET/NEGOTIATING' OR
                                                                Opportunity__r.StageName = 'LEAD' OR
                                                                Opportunity__r.StageName = 'DD/BUDGET' OR
                                                                Opportunity__r.StageName = 'ENGINEERING')];
                                                    
        for(Sales_Representative__c sr : lstSalesRepOpportunity) {
            setOpportunityIds.add(sr.Opportunity__c);
        }                              
        
        return setOpportunityIds;
    }

    public Set<Id> getSalesRepIds() {
    
        Set<Id> setSalesRepIds = new Set<Id>();
        
        mapMargin = new Map<Id,Decimal>();
        mapRevenue = new Map<Id,Decimal>();

        List<Sales_Representative__c > lstSalesRep;
        
        Set<Id> setOpportunityIds = new Set<Id>();
        
        if(selectSalesRep == 'Midwest Machinery'){
            lstSalesRep =[Select Opportunity__c,Revenue__c,Margin__c,Sales_Rep__c  
                            FROM Sales_Representative__c 
                            Where (Sales_Rep__r.Office_Location__c =: SAINT_LOUIS
                            OR Sales_Rep__r.Office_Location__c =: OKLAHOMA 
                            OR Sales_Rep__r.Office_Location__c =: KANSAS_CITY 
                            OR Sales_Rep__r.Office_Location__c =: DENVER)];
                            
        }else if(selectSalesRep == SAINT_LOUIS || selectSalesRep == OKLAHOMA || selectSalesRep == KANSAS_CITY || selectSalesRep == DENVER){
            lstSalesRep =[Select Opportunity__c,Revenue__c,Margin__c,Sales_Rep__c  
                            FROM Sales_Representative__c 
                            Where Sales_Rep__r.Office_Location__c =: selectSalesRep];
        }else{
            lstSalesRep =[Select Opportunity__c,Revenue__c,Margin__c,Sales_Rep__c  
                            FROM Sales_Representative__c 
                            Where Sales_Rep__c =: selectSalesRep];
        }
        
        for(Sales_Representative__c  sr : lstSalesRep){
            setSalesRepIds.add(sr.Sales_Rep__c);
            if(mapMargin.get(sr.Opportunity__c) == null){
                mapMargin.put(sr.Opportunity__c,sr.Margin__c);
                mapRevenue.put(sr.Opportunity__c,sr.Revenue__c);
            }
            else{
                mapMargin.put(sr.Opportunity__c,mapMargin.get(sr.Opportunity__c) + sr.Margin__c);
                mapRevenue.put(sr.Opportunity__c,mapRevenue.get(sr.Opportunity__c) + sr.Revenue__c);
            }
            
        }

        return setSalesRepIds;
    }

    public void getOpportunity() {
        con = null;
        getLstOpportunityWrapper();
    }

    public List<OpportunityWrapper> getLstOpportunityWrapper() {
        
        lstOpportunityWrapper = new List<OpportunityWrapper>();
        
        for (Opportunity opp : (List<Opportunity>)con.getRecords()){

            String lastChatterAction = '';
            OpportunityFeed lastOppFeed = getLastChatterDetails(opp.Feeds);
            
            if(lastOppFeed != null){
                lastChatterAction = lastOppFeed.Body;
            }
            OpportunityWrapper objOpportunityWrapper = new OpportunityWrapper(opp, mapRevenue.get(opp.Id),mapMargin.get(opp.Id),lastChatterAction);
            lstOpportunityWrapper.add(objOpportunityWrapper);
            
        }
        return lstOpportunityWrapper;
    }

    public OpportunityFeed getLastChatterDetails(List<OpportunityFeed> lstOpportunityFeeds){
    
        for(OpportunityFeed oppfeed : lstOpportunityFeeds){
            if(oppfeed.Body != null) {
                return oppfeed;
            }
        }
        
        return null;
        
    }

    public Boolean hasNext {
        get {
            return con.getHasNext();
        }
        set;
    }
    
    public Boolean hasPrevious {
        get {
            return con.getHasPrevious();
        }
        set;
    }
    
    public Integer pageNumber {
        get {
            return con.getPageNumber();
        }
        set;
    }
    
    public void first() {
         con.first();
     }
     
     public void last() {
         con.last();
     }
     
     public void previous() {
         con.previous();
     }
     
     public void next() {
         con.next();
     }

    public class OpportunityWrapper {
        public Opportunity opportunity{get;set;}
        public Decimal revenue{get;set;}
        public Decimal margin{get;set;}
        public String lastChatterAction{get;set;}
        
        public opportunityWrapper(Opportunity opp, Decimal rev, Decimal mar, String lca) {
            opportunity = opp;
            revenue = rev;
            margin = mar;
            lastChatterAction = lca;
            
        }
        
        public opportunityWrapper(Opportunity opp) {
            opportunity = opp;
        }
    }

}