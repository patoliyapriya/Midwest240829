public with Sharing class SalesRepReportController{
    
    public final String TARGET_NEGOTIATING = 'TARGET/NEGOTIATING';
    public final String POST_BID = 'POST BID';
    public final String BIDDING = 'BIDDING';
    public final String LEAD_DD_BUDGET = 'LEAD,DD/BUDGET';
    
    public final String SAINT_LOUIS = 'Saint Louis';
    public final String OKLAHOMA = 'Oklahoma';
    public final String KANSAS_CITY = 'Kansas City';
    public final String DENVER = 'Denver';
    
    public List<OpportunityWrapper> lstOpportunityTargetedWrapper{get;set;}
    public List<OpportunityWrapper> lstOpportunityPostBidWrapper{get;set;}
    public List<OpportunityWrapper> lstOpportunityBiddingWrapper{get;set;}
    public List<OpportunityWrapper> lstOpportunityLeadBudgetWrapper{get;set;}
    public List<OpportunityWrapper> lstOpportunityOpenProjectWrapper{get;set;}
    
    public Set<Id> setSalesRepIds{get;set;}
    
    Map<Id, Decimal> mapMargin{get;set;}
    Map<Id, Decimal> mapRevenue{get;set;}
    
    public String selectSalesRep{get;set;}
    public List<SelectOption> lstSelectSalesRep{get;set;}
    
    public List<SummaryTable> lstSummaryTable{get;set;}
    public List<SummaryTable> lstSummaryTableDetails{get;set;}
    public Sales_Rep_Goal__c salesRepGoal{get;set;}
    
    public SalesRepReportController(){
        selectSalesRep = userInfo.getUserId();
        init();
    }
    
    public void init(){
        
        setSalesRepIds = getSalesRepIds();
        salesRepGoal = getSalesRepGoals();
        lstSelectSalesRep = buildUserHierarchy();
        lstSummaryTableDetails = getSummaryTableDetails();
        
        lstOpportunityTargetedWrapper = BuildOpporunityWrapper(TARGET_NEGOTIATING);
        lstOpportunityPostBidWrapper = BuildOpporunityWrapper(POST_BID); 
        lstOpportunityBiddingWrapper = BuildOpporunityWrapper(BIDDING);
        lstOpportunityLeadBudgetWrapper = BuildOpporunityWrapper(LEAD_DD_BUDGET);
        lstOpportunityOpenProjectWrapper = getOpenProjectsOpportunity();
    }
    
    public List<SummaryTable> getSummaryTableDetails(){
        
        if(salesRepGoal == null) return null;
        
        aggregateResult pastDueForecast = getPastDueForecast();
        
        List<SummaryTable> lstSummaryTable = new List<SummaryTable>();
        
        SummaryTable stMargin = new SummaryTable();
        stMargin.Name = 'Margin';
        stMargin.Goal = salesRepGoal.Margin_Goal__c;
        
        if(pastDueForecast != null){
            stMargin.pastDueForecast = (Decimal)pastDueForecast.get('pastDueForecastMargin');
        }
        
        
        aggregateResult actualBooking12M = getActualBooking(12);
        aggregateResult actualBooking6M = getActualBooking(6);
        aggregateResult actualBooking3M = getActualBooking(3);
        aggregateResult actualBooking1M = getActualBooking(1);
        
        aggregateResult forecastedBooking12M = getForecastedBooking(12);
        aggregateResult forecastedBooking6M = getForecastedBooking(6);
        aggregateResult forecastedBooking3M = getForecastedBooking(3);
        aggregateResult forecastedBooking1M = getForecastedBooking(1);
        
        if(actualBooking12M != null){
            stMargin.actualBooking12M = (Decimal)actualBooking12M.get('marginActualBooking');    
        }
        if(actualBooking6M != null){
            stMargin.actualBooking6M = (Decimal)actualBooking6M.get('marginActualBooking');
        }
        if(actualBooking3M != null){
            stMargin.actualBooking3M = (Decimal)actualBooking3M.get('marginActualBooking');
        }
        if(actualBooking1M != null){
            stMargin.actualBooking1M = (Decimal)actualBooking1M.get('marginActualBooking');
        }
        
        
        if(forecastedBooking12M != null){
            stMargin.forecastedBooking12M = (Decimal)forecastedBooking12M.get('marginForecastedBooking');
        }
        if(forecastedBooking6M != null){
            stMargin.forecastedBooking6M = (Decimal)forecastedBooking6M.get('marginForecastedBooking');
        }
        if(forecastedBooking3M != null){
            stMargin.forecastedBooking3M = (Decimal)forecastedBooking3M.get('marginForecastedBooking');
        }
        if(forecastedBooking1M != null){
            stMargin.forecastedBooking1M = (Decimal)forecastedBooking1M.get('marginForecastedBooking');
        }
        
        
        if(null != getYTD()){
            stMargin.YTD = (Decimal)getYTD().get('marginYTD');
        }
        
        Date startDateOfYear = Date.newInstance(Integer.valueOf(System.now().year()), 1, 1);
        Decimal numberOfDays = StartDateOfYear.daysBetween(System.now().Date());
        Decimal divideBy = numberOfDays/365 * 12;
        
        SummaryTable stMarginMonthly= new SummaryTable();
        stMarginMonthly.Name = 'Margin - Monthly Avg.';
        stMarginMonthly.Goal = salesRepGoal.Monthly_Margin__c;
        
        //=E17/(($E$4-$E$5)/365*12)
        
        
        
        if(null != getYTD() && getYTD().get('marginYTD') != null){
            
            stMarginMonthly.YTD = (Decimal)getYTD().get('marginYTD')/divideBy;
            stMargin.colorYTD = stMarginMonthly.colorYTD = getColor(stMarginMonthly.Goal,stMarginMonthly.YTD);
        }
        
        if(actualBooking12M != null && actualBooking12M.get('marginActualBooking') != null){
            stMarginMonthly.actualBooking12M = (Decimal)actualBooking12M.get('marginActualBooking')/12;
            stMargin.color12M = stMarginMonthly.color12M = getColor(stMarginMonthly.Goal,stMarginMonthly.actualBooking12M );
        }
        if(actualBooking6M != null && actualBooking6M.get('marginActualBooking')  != null){
            stMarginMonthly.actualBooking6M = (Decimal)actualBooking6M.get('marginActualBooking')/6;
            stMargin.color6M = stMarginMonthly.color6M = getColor(stMarginMonthly.Goal,stMarginMonthly.actualBooking6M );
        }
        if(actualBooking3M != null && actualBooking3M.get('marginActualBooking')  != null){
            stMarginMonthly.actualBooking3M = (Decimal)actualBooking3M.get('marginActualBooking')/3;
            stMargin.color3M = stMarginMonthly.color3M = getColor(stMarginMonthly.Goal,stMarginMonthly.actualBooking3M );
        }
        if(actualBooking1M != null && actualBooking1M.get('marginActualBooking')  != null){
            stMarginMonthly.actualBooking1M = (Decimal)actualBooking1M.get('marginActualBooking');
            stMargin.color1M = stMarginMonthly.color1M = getColor(stMarginMonthly.Goal,stMarginMonthly.actualBooking1M );
        }
        
        if(forecastedBooking12M != null && forecastedBooking12M.get('marginForecastedBooking')  != null){
            stMarginMonthly.forecastedBooking12M = (Decimal)forecastedBooking12M.get('marginForecastedBooking')/12;
            stMargin.colorForecasted12M = stMarginMonthly.colorForecasted12M = getColor(stMarginMonthly.Goal,stMarginMonthly.forecastedBooking12M);
        }
        if(forecastedBooking6M != null && forecastedBooking6M.get('marginForecastedBooking') != null){
            stMarginMonthly.forecastedBooking6M = (Decimal)forecastedBooking6M.get('marginForecastedBooking')/6;
            stMargin.colorForecasted6M = stMarginMonthly.colorForecasted6M = getColor(stMarginMonthly.Goal,stMarginMonthly.forecastedBooking6M);
        }
        if(forecastedBooking3M != null && forecastedBooking3M.get('marginForecastedBooking') != null){
            stMarginMonthly.forecastedBooking3M = (Decimal)forecastedBooking3M.get('marginForecastedBooking')/3;
            stMargin.colorForecasted3M = stMarginMonthly.colorForecasted3M = getColor(stMarginMonthly.Goal,stMarginMonthly.forecastedBooking3M);
        }
        if(forecastedBooking1M != null && forecastedBooking1M.get('marginForecastedBooking') != null){
            stMarginMonthly.forecastedBooking1M = (Decimal)forecastedBooking1M.get('marginForecastedBooking');
            stMargin.colorForecasted1M = stMarginMonthly.colorForecasted1M = getColor(stMarginMonthly.Goal,stMarginMonthly.forecastedBooking1M);
        }
         
        lstSummaryTable.add(stMargin);
        lstSummaryTable.add(stMarginMonthly);
        
        SummaryTable stRevenue = new SummaryTable();
        stRevenue.Name = 'Revenue';
        stRevenue.Goal = salesRepGoal.Revenue_Goal__c;
        
        if(pastDueForecast != null && pastDueForecast.get('pastDueForecastRevenue') != null){
            stRevenue.pastDueForecast = (Decimal)pastDueForecast.get('pastDueForecastRevenue');
        }
        
        if(null != getYTD() && getYTD().get('revenueYTD') != null){
            stRevenue.YTD = (Decimal)getYTD().get('revenueYTD');
        }
        
        if(actualBooking12M != null && actualBooking12M.get('revenueActualBooking') != null){
            stRevenue.actualBooking12M = (Decimal)actualBooking12M.get('revenueActualBooking');
        }
        if(actualBooking6M != null && actualBooking6M.get('revenueActualBooking') != null){
            stRevenue.actualBooking6M = (Decimal)actualBooking6M.get('revenueActualBooking');
        }
        if(actualBooking3M != null && actualBooking3M.get('revenueActualBooking') != null){
            stRevenue.actualBooking3M = (Decimal)actualBooking3M.get('revenueActualBooking');
        }
        if(actualBooking1M != null && actualBooking1M.get('revenueActualBooking') != null){
            stRevenue.actualBooking1M = (Decimal)actualBooking1M.get('revenueActualBooking');
        }
        
        
        if(forecastedBooking12M != null && forecastedBooking12M.get('revenueForecastedBooking') != null){
            stRevenue.forecastedBooking12M = (Decimal)forecastedBooking12M.get('revenueForecastedBooking');
        }
        if(forecastedBooking6M != null && forecastedBooking6M.get('revenueForecastedBooking') != null){
            stRevenue.forecastedBooking6M = (Decimal)forecastedBooking6M.get('revenueForecastedBooking');
        }
        if(forecastedBooking3M != null && forecastedBooking3M.get('revenueForecastedBooking') != null){
            stRevenue.forecastedBooking3M = (Decimal)forecastedBooking3M.get('revenueForecastedBooking');
        }
        if(forecastedBooking1M != null && forecastedBooking1M.get('revenueForecastedBooking') != null){
            stRevenue.forecastedBooking1M = (Decimal)forecastedBooking1M.get('revenueForecastedBooking');
        }
        
        SummaryTable stRevenueMonthly = new SummaryTable();
        stRevenueMonthly.Name = 'Revenue - Monthly Avg.';
        stRevenueMonthly.Goal = salesRepGoal.Monthly_Revenue__c;
        
        if(null != getYTD() && getYTD().get('revenueYTD') != null){
            stRevenueMonthly.YTD = (Decimal)getYTD().get('revenueYTD')/divideBy;
            stRevenue.colorYTD = stRevenueMonthly.colorYTD = getColor(stRevenueMonthly.Goal,stRevenueMonthly.YTD);
        }
        
        if(actualBooking12M != null && actualBooking12M.get('revenueActualBooking') != null){
            stRevenueMonthly.actualBooking12M = (Decimal)actualBooking12M.get('revenueActualBooking')/12;
            stRevenue.color12M = stRevenueMonthly.color12M = getColor(stRevenueMonthly.Goal,stRevenueMonthly.actualBooking12M);
        }
        if(actualBooking6M != null && actualBooking6M.get('revenueActualBooking') != null){
            stRevenueMonthly.actualBooking6M = (Decimal)actualBooking6M.get('revenueActualBooking')/6;
            stRevenue.color6M = stRevenueMonthly.color6M = getColor(stRevenueMonthly.Goal,stRevenueMonthly.actualBooking6M);
        }
        if(actualBooking3M != null && actualBooking3M.get('revenueActualBooking') != null){
            stRevenueMonthly.actualBooking3M = (Decimal)actualBooking3M.get('revenueActualBooking')/3;
            stRevenue.color3M = stRevenueMonthly.color3M = getColor(stRevenueMonthly.Goal,stRevenueMonthly.actualBooking3M);
        }
        if(actualBooking1M != null && actualBooking1M.get('revenueActualBooking') != null){
            stRevenueMonthly.actualBooking1M = (Decimal)actualBooking1M.get('revenueActualBooking');
            stRevenue.color1M = stRevenueMonthly.color1M = getColor(stRevenueMonthly.Goal,stRevenueMonthly.actualBooking1M);
        }
        
        
        if(forecastedBooking1M != null && forecastedBooking1M.get('revenueForecastedBooking') != null){
            stRevenueMonthly.forecastedBooking1M = (Decimal)forecastedBooking1M.get('revenueForecastedBooking');
            stRevenue.colorForecasted1M = stRevenueMonthly.colorForecasted1M = getColor(stRevenueMonthly.Goal,stRevenueMonthly.forecastedBooking1M);
        }
        if(forecastedBooking3M != null && forecastedBooking3M.get('revenueForecastedBooking') != null){
            stRevenueMonthly.forecastedBooking3M = (Decimal)forecastedBooking3M.get('revenueForecastedBooking')/3;
            stRevenue.colorForecasted3M = stRevenueMonthly.colorForecasted3M = getColor(stRevenueMonthly.Goal,stRevenueMonthly.forecastedBooking3M);
        }
        if(forecastedBooking6M != null && forecastedBooking6M.get('revenueForecastedBooking') != null){
            stRevenueMonthly.forecastedBooking6M = (Decimal)forecastedBooking6M.get('revenueForecastedBooking')/6;
            stRevenue.colorForecasted6M = stRevenueMonthly.colorForecasted6M = getColor(stRevenueMonthly.Goal,stRevenueMonthly.forecastedBooking6M);
        }
        if(forecastedBooking12M != null && forecastedBooking12M.get('revenueForecastedBooking') != null){
            stRevenueMonthly.forecastedBooking12M = (Decimal)forecastedBooking12M.get('revenueForecastedBooking')/12;
            stRevenue.colorForecasted12M = stRevenueMonthly.colorForecasted12M = getColor(stRevenueMonthly.Goal,stRevenueMonthly.forecastedBooking12M);
        }
        
        lstSummaryTable.add(stRevenue);
        lstSummaryTable.add(stRevenueMonthly);
        
        return lstSummaryTable;
    }
    
    public List<SelectOption> buildUserHierarchy(){
        
        String secondLevel = '____';
        String thirdLevel = '________';
        
        List<SelectOption> lstHierarchyUsers = new List<SelectOption>();
        
        User currentUser = getCurrentUserDetails();
        
        if(currentUser.Is_Manager__c == false && currentUser.Is_Director__c == false){
            lstHierarchyUsers.add(new SelectOption(currentUser.Id,currentUser.Name));    
        }else if(currentUser.Is_Director__c){
            lstHierarchyUsers.add(new SelectOption('Midwest Machinery','Master Report'));         
            
            List<User> lstUsers = getAllSalesRep();
            String currentOfficeLocation = '';
            
            for(User u : lstUsers){
                if(u.Office_Location__c != currentOfficeLocation){
                    currentOfficeLocation = u.Office_Location__c;
                    lstHierarchyUsers.add(new SelectOption(u.Office_Location__c,secondLevel + u.Office_Location__c)); 
                    lstHierarchyUsers.add(new SelectOption(u.Id,thirdLevel + u.Name));  
                }else{
                    lstHierarchyUsers.add(new SelectOption(u.Id,thirdLevel + u.Name));   
                }
            }
        }else if(currentUser.Is_Manager__c){
            
            lstHierarchyUsers.add(new SelectOption(currentUser.Office_Location__c,currentUser.Office_Location__c));   
            
            List<User> lstUsers = getUsersByLocations(currentUser.Office_Location__c);
            
            for(User u : lstUsers){
                lstHierarchyUsers.add(new SelectOption(u.Id,secondLevel + u.Name));
            }
        }
        if(currentUser.has_house_Account_Access__c){
            List<User> lstUsers = getHouseUserDetails();
            
            for(User u : lstUsers){
                lstHierarchyUsers.add(new SelectOption(u.Id,secondLevel + u.Name));
            }
            
        }
        
        return lstHierarchyUsers;
    }
    
    public OpportunityFeed getLastChatterDetails(List<OpportunityFeed> lstOpportunityFeeds){
    
        for(OpportunityFeed oppfeed : lstOpportunityFeeds){
            if(oppfeed.Body != null){
                return oppfeed;
                break;
            }
        }
        
        return null;
        
    }
    
    public List<OpportunityWrapper> buildOpporunityWrapper(String stageName){
        
        List<OpportunityWrapper> lstOpportunityWrapper = new List<OpportunityWrapper>();
        
        List<Opportunity> lstOpportunity = null;
        
        if(stageName == TARGET_NEGOTIATING){
        	lstOpportunity = [Select Opportunity_Number__c,Name,Total_Project_Margin__c,Total_Base_Bid_Total_Quote__c,
                                Probability,Bidders__c,Description,Owner.Name,Ship_Date__c,CloseDate,LastModifiedDate,
                                (Select Body From Feeds Order By LastModifiedDate desc) lastChatterAction 
                                From Opportunity
                                WHERE Id IN: getSalesRepOpportunityIds()
                                AND (StageName IN :getSetFromStageName(stageName)
                                OR Targeted__c = true)
                                AND Total_Project_Margin__c != null
                                ORDER BY Total_Project_Margin__c desc
                                LIMIT 10];
        } else {
        	lstOpportunity = [Select Opportunity_Number__c,Name,Total_Project_Margin__c,Total_Base_Bid_Total_Quote__c,
	                            Probability,Bidders__c,Description,Owner.Name,Ship_Date__c,CloseDate,LastModifiedDate,
	                            (Select Body From Feeds Order By LastModifiedDate desc) lastChatterAction 
	                            From Opportunity
	                            WHERE Id IN: getSalesRepOpportunityIds()
	                            AND StageName IN :getSetFromStageName(stageName)
	                            AND Total_Project_Margin__c != null
	                            ORDER BY Total_Project_Margin__c desc
	                            LIMIT 10];
        }        
        
        
        for(Opportunity opp : lstOpportunity){
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
    
    public List<OpportunityWrapper> getOpenProjectsOpportunity(){
        
        List<OpportunityWrapper> lstOpportunityWrapper = new List<OpportunityWrapper>();
        
        List<Project__c> lstProjects = [Select Opportunity__c From Project__c 
                                        WHERE Opportunity__c != null 
                                        AND Project_Stage__c != 'Archived'
                                        AND Opportunity__c IN :getSalesRepOpportunityIds()];
                                        
        Set<Id> setOppIds = new Set<Id>();
        
        for(Project__c project : lstProjects){
            setOppIds.add(project.Opportunity__c);
        }
        
        List<Opportunity> lstOpportunity = [Select Opportunity_Number__c,Name,Total_Project_Margin__c,Total_Base_Bid_Total_Quote__c,
                                            Probability,Bidders__c,Description,Owner.Name,Ship_Date__c,CloseDate,LastModifiedDate,
                                            (Select Body From Feeds Order By LastModifiedDate desc LIMIT 1) lastChatterAction  
                                            From Opportunity
                                            WHERE Id IN: setOppIds
                                            ORDER BY Total_Project_Margin__c desc
                                            LIMIT 10];
                                            
        for(Opportunity opp : lstOpportunity){
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
    
    public AggregateResult getPastDueForecast(){
        AggregateResult pastDue = null;
        
        List<AggregateResult> lstPastDue = [Select SUM(Margin__c) pastDueForecastMargin,
                                            SUM(Revenue__c) pastDueForecastRevenue
                                            FROM Sales_Representative__c
                                            WHERE Sales_Rep__c IN :setSalesRepIds AND
                                            Opportunity__c NOT IN (Select Opportunity__c From Project__c Where Opportunity__c != null) AND
                                            Opportunity__r.CloseDate <= Today AND
                                            (Opportunity__r.StageName = 'Bidding' OR
                                            Opportunity__r.StageName = 'Post Bid' OR
                                            Opportunity__r.StageName = 'TARGET/NEGOTIATING' OR
                                            Opportunity__r.StageName = 'LEAD' OR
                                            Opportunity__r.StageName = 'DD/BUDGET')];
        
        if(!lstPastDue.isEmpty()){
            pastDue = lstPastDue[0];
        }                                
        
        return pastDue;
    }
    
    public AggregateResult getYTD(){
        
        AggregateResult objectYTD = null;
        
        List<AggregateResult> lstYTD = [Select SUM(Margin__c) marginYTD,
                                        SUM(Revenue__c) revenueYTD  
                                        FROM Sales_Representative__c
                                        WHERE Sales_Rep__c IN :setSalesRepIds AND
                                        Opportunity__r.CloseDate <= Today AND
                                        Opportunity__c IN (Select Opportunity__c From Project__c Where Opportunity__c != null) AND
                                        CALENDAR_YEAR(Opportunity__r.CloseDate) =: System.Today().year() AND  
                                        Opportunity__r.StageName = 'Closed Won'];
        
        if(!lstYTD.isEmpty()){
            objectYTD = lstYTD[0];
        }                                
        
        return objectYTD;
    }
    
    public AggregateResult getActualBooking(Integer nuberOfYears){
        
        AggregateResult actualBooking = null;
        
        Date closeDt = Date.today().addMonths(-Integer.valueOf(nuberOfYears));
        
        List<AggregateResult> lstActualBooking = [Select SUM(Margin__c) marginActualBooking,
                                                    SUM(Revenue__c) revenueActualBooking  
                                                    FROM Sales_Representative__c
                                                    WHERE Sales_Rep__c IN :setSalesRepIds AND
                                                    Opportunity__r.CloseDate >=: closeDt AND  
                                                    Opportunity__r.CloseDate <= Today AND
                                                    Opportunity__r.StageName = 'Closed Won']; 
                                                    //AND Opportunity__c IN (Select Opportunity__c From Project__c Where Opportunity__c != null)];
        if(!lstActualBooking.isEmpty()){
            actualBooking = lstActualBooking[0];    
        }                                
        
        return actualBooking;
    }
    
    public AggregateResult getForecastedBooking(Integer numberOfYears){
        
        AggregateResult forecastedBooking = null;
        
        Date closeDt = Date.today().addMonths(Integer.valueOf(numberOfYears));
        
        List<AggregateResult> lstForecastedBooking = [Select SUM(Margin__c) marginForecastedBooking,
                                                    SUM(Revenue__c) revenueForecastedBooking
                                                    FROM Sales_Representative__c
                                                    WHERE Sales_Rep__c IN :setSalesRepIds AND
                                                    //AND Opportunity__c NOT IN (Select Opportunity__c From Project__c Where Opportunity__c != null) AND
                                                    Opportunity__r.CloseDate <=: closeDt AND  
                                                    Opportunity__r.CloseDate >= Today AND
                                                    (Opportunity__r.StageName = 'Bidding' OR
                                                    Opportunity__r.StageName = 'Post Bid' OR
                                                    Opportunity__r.StageName = 'TARGET/NEGOTIATING' OR
                                                    Opportunity__r.StageName = 'LEAD' OR
                                                    Opportunity__r.StageName = 'DD/BUDGET' OR
                                                    Opportunity__r.StageName = 'ENGINEERING')];
                                                    
        if(!lstForecastedBooking.isEmpty()){
            forecastedBooking = lstForecastedBooking[0];
        }                                 
        
        return forecastedBooking;
    }
    
    public Sales_Rep_Goal__c getSalesRepGoals(){
        
        Sales_Rep_Goal__c srGoal = null;
        
        List<Sales_Rep_Goal__c> lstMarginRevenue = [Select Margin_Goal__c,Monthly_Margin__c,Revenue_Goal__c,Monthly_Revenue__c
                                                    FROM Sales_Rep_Goal__c
                                                    WHERE Year__c =:  String.valueOf(System.Today().year())
                                                    AND Sales_Rep__c =: selectSalesRep];
        if(!lstMarginRevenue.isEmpty()){
            srGoal = lstMarginRevenue[0];
        }
        else{
            lstMarginRevenue = [Select Margin_Goal__c,Monthly_Margin__c,Revenue_Goal__c,Monthly_Revenue__c
                                FROM Sales_Rep_Goal__c
                                WHERE Year__c =:  String.valueOf(System.Today().year())
                                AND Master_Report__c =: selectSalesRep];
            
            if(!lstMarginRevenue.isEmpty()){
                srGoal = lstMarginRevenue[0];
            }
        }
        
        return srGoal;
    }
    
    public Set<Id> getSalesRepOpportunityIds(){
        
        mapRevenue = new Map<Id, Decimal>();
        mapMargin = new Map<Id, Decimal>();
        
        List<Sales_Representative__c > lstSalesRep;
        
        Set<Id> setOpportunityIds = new Set<Id>();
        
        if(selectSalesRep == 'Midwest Machinery'){
            lstSalesRep =[Select Opportunity__c,Revenue__c,Margin__c 
                            FROM Sales_Representative__c 
                            Where (Sales_Rep__r.Office_Location__c =: SAINT_LOUIS
                            OR Sales_Rep__r.Office_Location__c =: OKLAHOMA 
                            OR Sales_Rep__r.Office_Location__c =: KANSAS_CITY 
                            OR Sales_Rep__r.Office_Location__c =: DENVER)];
                            
        }else if(selectSalesRep == SAINT_LOUIS || selectSalesRep == OKLAHOMA || selectSalesRep == KANSAS_CITY || selectSalesRep == DENVER){
            lstSalesRep =[Select Opportunity__c,Revenue__c,Margin__c 
                            FROM Sales_Representative__c 
                            Where Sales_Rep__r.Office_Location__c =: selectSalesRep];
        }else{
            lstSalesRep =[Select Opportunity__c,Revenue__c,Margin__c 
                            FROM Sales_Representative__c 
                            Where Sales_Rep__c =: selectSalesRep];
        }
        
        for(Sales_Representative__c  sr : lstSalesRep){
            setOpportunityIds.add(sr.Opportunity__c);
            if(mapMargin.get(sr.Opportunity__c) == null){
                mapMargin.put(sr.Opportunity__c,sr.Margin__c);
                mapRevenue.put(sr.Opportunity__c,sr.Revenue__c);
            }
            else{
                mapMargin.put(sr.Opportunity__c,mapMargin.get(sr.Opportunity__c) + sr.Margin__c);
                mapRevenue.put(sr.Opportunity__c,mapRevenue.get(sr.Opportunity__c) + sr.Revenue__c);
            }
            
        }
        
        return setOpportunityIds;
    }
    
    public Set<Id> getSalesRepIds(){
    
        Set<Id> setSalesRepIds = new Set<Id>();
        
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
        }
        
        return setSalesRepIds;
    }
    
    public Set<String> getSetFromStageName(String stageName){
        
        Set<String> setStageName = new Set<String>();
        
        if(stageName == LEAD_DD_BUDGET){
            setStageName.add('Lead');
            setStageName.add('DD/Budget');
        }else{
            setStageName.add(stageName);
        }
        
        return setStageName;
        
    }
    
    public User getCurrentUserDetails(){
        
        User currentUser = [Select Id,Name,Is_Manager__c, Is_Director__c, Office_Location__c,has_house_Account_Access__c 
                            From User
                            WHERE Id =: userInfo.getUserId()];
                            
        
        return currentUser;
    }
    
    public List<User> getHouseUserDetails(){
        
        Set<Id> setHouseUserId = new Set<Id>();
        setHouseUserId.add('00561000000gZ6D');
        setHouseUserId.add('00561000000gZ6I');
        setHouseUserId.add('00561000000gZ68');
        setHouseUserId.add('00561000000gZ3T');
        
        List<User> lstHouseUser = [Select Id,Name 
                                    From User
                                    WHERE Id IN: setHouseUserId];
                            
        
        return lstHouseUser;
    }
    
    public List<User> getAllSalesRep(){
        
        Set<String> setOfficeLocation = new Set<String>();
        setOfficeLocation.add(SAINT_LOUIS);
        setOfficeLocation.add(OKLAHOMA);
        setOfficeLocation.add(KANSAS_CITY);
        setOfficeLocation.add(DENVER);
        
        List<User> lstUsers = [Select Id,Name,Office_Location__c From User 
                                WHERE Office_Location__c IN :setOfficeLocation
                                ORDER BY Office_Location__c ASC];
        return lstUsers;
        
    } 
    
    public List<User> getUsersByLocations(String officeLocation){
        List<User> lstUsers = [Select Id,Name From User 
                                WHERE Office_Location__c = :officeLocation
                                ORDER BY Name ASC];
        return lstUsers;
    }
    
    public String getColor(Decimal goalAmount, Decimal achiveAmount){
        
        String color = '';
        
        if(achiveAmount >= goalAmount){
            color = 'green';
        }else if(achiveAmount >= goalAmount - (goalAmount * 0.10)){
            color = 'yellow';
        }else{
            color = 'red';
        }
        
        return color;
    }
    
    public class OpportunityWrapper{
        public Opportunity opportunity{get;set;}
        public Decimal revenue{get;set;}
        public Decimal margin{get;set;}
        public String lastChatterAction{get;set;}
        
        public opportunityWrapper(Opportunity opp, Decimal rev, Decimal mar, String lca){
            opportunity = opp;
            revenue = rev;
            margin = mar;
            lastChatterAction = lca;
            
        }
        
        public opportunityWrapper(Opportunity opp){
            opportunity = opp;
        }
    }
    
    public class SummaryTable{
        
        public String name{get;set;}
        public Decimal goal{get;set;}
        
        public Decimal YTD{get;set;}
        public Decimal actualBooking12M{get;set;}
        public Decimal actualBooking6M{get;set;}
        public Decimal actualBooking3M{get;set;}
        public Decimal actualBooking1M{get;set;}
        
        public Decimal forecastedBooking1M{get;set;}
        public Decimal forecastedBooking3M{get;set;}
        public Decimal forecastedBooking6M{get;set;}
        public Decimal forecastedBooking12M{get;set;}
        
        public String colorYTD{get;set;}
        public String color12M{get;set;}
        public String color6M{get;set;}
        public String color3M{get;set;}
        public String color1M{get;set;}
        
        public String colorForecastedYTD{get;set;}
        public String colorForecasted12M{get;set;}
        public String colorForecasted6M{get;set;}
        public String colorForecasted3M{get;set;}
        public String colorForecasted1M{get;set;}
        
        public Decimal pastDueForecast{get;set;}
    }
    
}