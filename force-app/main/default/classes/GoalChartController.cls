public with sharing class GoalChartController {
    public chartResponse activityChart {get;set;}
    public chartResponse marginChart {get;set;}
    public chartResponse revenueChart {get;set;}
    public Boolean isError{get;set;}
    public static Sales_Rep_Goal__c srGoal;
    public String selectedUserId {get;set;}
    public String selectedUserName {get;set;}
    public static final String SAINT_LOUIS = 'Saint Louis';
    public static final String OKLAHOMA = 'Oklahoma';
    public static final String KANSAS_CITY = 'Kansas City';
    public static final String DENVER = 'Denver';
    
    public GoalChartController() {
        
        //srGoal = new Sales_Rep_Goal__c();
        selectedUserId = UserInfo.getUserId();
        
    }

    public void loadMarginGoalData () {
        chartResponse resp = new chartResponse();
        marginChart = new chartResponse();
        isError = false;
        ApexPages.getMessages().clear();
        fetchSalesRepGoals();
        system.debug('srGoal==>>'+srGoal);
        List<AggregateResult> lstMarginGoal;
        if (srGoal != null) {

            // to calulate MarginGoal Gauge Charts from 0 to endPoint
            decimal directCommissionMarginGoal = 0;
            if (srGoal.Direct_Sales_Goal__c > 0 && srGoal.Direct_Sales_Percentage__c > 0) {
                directCommissionMarginGoal = (srGoal.Direct_Sales_Goal__c * srGoal.Direct_Sales_Percentage__c)/100;
            }
            
            decimal buyResellMarginGoal = 0;
            if (srGoal.Resell_Sales_Goal__c > 0 && srGoal.Sales_Margin_Percentage__c > 0) {
                buyResellMarginGoal = (srGoal.Resell_Sales_Goal__c * srGoal.Sales_Margin_Percentage__c)/100;
            }
            if (buyResellMarginGoal > 0 || directCommissionMarginGoal > 0) {
                resp.chartTotalInDecimal = (buyResellMarginGoal + directCommissionMarginGoal).setScale(2);
            }
            if ( resp.chartTotalInDecimal == 0) {
                isError = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'please add the details of Sales Margin & Direct Sales Margin % in Sales rep goal for selected user:- ' +  srGoal.Name +  '<a href="/lightning/r/Sales_Rep_Goal__c/'+srGoal.Id+'/view" target="_blank"> Click Here</a>'));
                return;
            }
    
            // calculate Total Margin(booked) value
            if (selectedUserId == 'Midwest Machinery') {
                lstMarginGoal = [SELECT SUM(MarginBooked__c) marginbooked
                                   FROM Sales_Representative__c
                                   WHERE (Sales_Rep__r.Office_Location__c =: SAINT_LOUIS
                                                OR Sales_Rep__r.Office_Location__c =: OKLAHOMA 
                                                OR Sales_Rep__r.Office_Location__c =: KANSAS_CITY 
                                                OR Sales_Rep__r.Office_Location__c =: DENVER) 
                                    AND Opportunity__r.StageName = 'Closed Won' 
                                    AND Opportunity__r.Active_Financial_Quote__c != null 
                                    AND Opportunity__c != null
                                    AND Opportunity__r.Project__c != null
                                    AND Opportunity__r.Project__r.CreatedDate = THIS_YEAR
                                    AND Opportunity__r.Project__r.RemoveFromSalesResult__c != true];

            } else if (selectedUserId == SAINT_LOUIS 
                        || selectedUserId == OKLAHOMA 
                        || selectedUserId == KANSAS_CITY 
                        || selectedUserId == DENVER) {
                
                lstMarginGoal = [SELECT SUM(MarginBooked__c) marginbooked
                                  FROM Sales_Representative__c
                                  WHERE Sales_Rep__r.Office_Location__c = :selectedUserId 
                                  AND Opportunity__r.StageName = 'Closed Won' 
                                  AND Opportunity__r.Active_Financial_Quote__c != null 
                                  AND Opportunity__c != null
                                  AND Opportunity__r.Project__c != null
                                  AND Opportunity__r.Project__r.CreatedDate = THIS_YEAR
                                  AND Opportunity__r.Project__r.RemoveFromSalesResult__c != true];                        
                            
            } else {
                lstMarginGoal = [SELECT SUM(MarginBooked__c) marginbooked
                                  FROM Sales_Representative__c
                                  WHERE Sales_Rep__c = :selectedUserId
                                  AND Opportunity__r.StageName = 'Closed Won'
                                  AND Opportunity__r.Active_Financial_Quote__c != null 
                                  AND Opportunity__c != null
                                  AND Opportunity__r.Project__c != null
                                  AND Opportunity__r.Project__r.CreatedDate = THIS_YEAR
                                  AND Opportunity__r.Project__r.RemoveFromSalesResult__c != true];
                                                     
             system.debug('selected sales for particular user' +lstMarginGoal);   
            }
            if(!lstMarginGoal.isEmpty() && lstMarginGoal[0].get('marginbooked') != null){
                     resp.chartActualInDecimal = (decimal)lstMarginGoal[0].get('marginbooked');
            }
            marginChart = resp;    
            system.debug('marginChart== '+resp);
        
        }
          
    }


    public void loadRevGoalChart() {
        revenueChart = new chartResponse();
        isError = false;
        ApexPages.getMessages().clear();
        fetchSalesRepGoals();
        chartResponse revChatResp = new chartResponse();
        system.debug('srGoal==>'+srGoal);
        List<AggregateResult> lstYTD;
        List<Sales_Representative__c> salesEggSplits = new List<Sales_Representative__c> ();
        if (srGoal != null) {
            // to calulate RevenueGoal Gauge Charts from 0 to endPoint
            if (srGoal.Direct_Sales_Goal__c > 0 || srGoal.Resell_Sales_Goal__c > 0) {
                revChatResp.chartTotalInDecimal = srGoal.Direct_Sales_Goal__c + srGoal.Resell_Sales_Goal__c; 
            }
            else if ( revChatResp.chartTotalInDecimal == 0) {
                isError = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'please add the details of Direct Sales Goal & Resell Sales Goal in Sales rep goal for selected user ' +  srGoal.Name + '<a href="/lightning/r/Sales_Rep_Goal__c/'+srGoal.Id+'/view" target="_blank"> Click Here</a>'));
                return;
            }
            // calculate Total Sales(booked) value
            if (selectedUserId == 'Midwest Machinery') {
                lstYTD = [SELECT SUM(TotalSalesBooked__c) totalSales
                          FROM Sales_Representative__c
                          WHERE (Sales_Rep__r.Office_Location__c =: SAINT_LOUIS
                                            OR Sales_Rep__r.Office_Location__c =: OKLAHOMA 
                                            OR Sales_Rep__r.Office_Location__c =: KANSAS_CITY 
                                            OR Sales_Rep__r.Office_Location__c =: DENVER) 
                          AND Opportunity__r.StageName = 'Closed Won' 
                          AND Opportunity__r.Active_Financial_Quote__c != null 
                          AND Opportunity__c != null
                          AND Opportunity__r.Project__c != null
                          AND Opportunity__r.Project__r.CreatedDate = THIS_YEAR
                          AND Opportunity__r.Project__r.RemoveFromSalesResult__c != true];   

            } else if (selectedUserId == SAINT_LOUIS 
                        || selectedUserId == OKLAHOMA 
                        || selectedUserId == KANSAS_CITY 
                        || selectedUserId == DENVER) {
                
                 lstYTD = [SELECT SUM(TotalSalesBooked__c) totalSales
                            FROM Sales_Representative__c
                            WHERE Sales_Rep__r.Office_Location__c = :selectedUserId 
                            AND Opportunity__r.StageName = 'Closed Won' 
                            AND Opportunity__r.Active_Financial_Quote__c != null 
                            AND Opportunity__c != null
                            AND Opportunity__r.Project__c != null
                            AND Opportunity__r.Project__r.CreatedDate = THIS_YEAR
                            AND Opportunity__r.Project__r.RemoveFromSalesResult__c != true];                                                          
            } else {
                 lstYTD  = [SELECT SUM(TotalSalesBooked__c) totalSales
                            FROM Sales_Representative__c
                            WHERE Sales_Rep__c = :selectedUserId
                            AND Opportunity__r.StageName = 'Closed Won'
                            AND Opportunity__r.Active_Financial_Quote__c != null 
                            AND Opportunity__c != null
                            AND Opportunity__r.Project__c != null
                            AND Opportunity__r.Project__r.CreatedDate = THIS_YEAR
                            AND Opportunity__r.Project__r.RemoveFromSalesResult__c != true];
            
            //AND CALENDAR_YEAR(Opportunity__r.CloseDate) =: System.Today().year() 
            system.debug('lstYTD-Revenue == '+lstYTD);   
            }
            
            if (lstYTD.isEmpty()) {
                isError = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'data for sales engineering split not found for selected user:' + selectedUserName));
            } else if (!lstYTD.isEmpty() && lstYTD[0].get('totalSales') != null) {
                revChatResp.chartActualInDecimal = (decimal)lstYTD[0].get('totalSales');
            }
            
            revenueChart = revChatResp;
            system.debug('revenueChart== '+revenueChart);
        }
        
    }


    public void loadActivityGoalChart() {
        system.debug('Activity Chart Selected User id: '+selectedUserId);
        activityChart = new chartResponse();
        Integer totalNumber = 0;
        isError = false;
        ApexPages.getMessages().clear();
        chartResponse resp = new chartResponse();
        List<SalesActivityGoal__c>  chartTotlaList = new List<SalesActivityGoal__c>();

        if(selectedUserId.startsWith('005')){ // start with 005
                chartTotlaList = [SELECT Id,
                                        Total__c
                                        FROM SalesActivityGoal__c
                                        WHERE SalesRep__c = :selectedUserId // Use selected user id instead current user id
                                        AND Year__c = :String.valueOf(system.now().year())
                                        LIMIT 1];      
                                                    
        }else{
            chartTotlaList = [SELECT Id,
                                    Total__c
                                    FROM SalesActivityGoal__c
                                    WHERE Master_Report__c = :selectedUserId //  master report
                                    AND Year__c = :String.valueOf(system.now().year())
                                    LIMIT 1];
           
        }                                                                                                                              
    
        if(chartTotlaList != null && chartTotlaList.size() > 0){

            totalNumber = Integer.valueOf(chartTotlaList[0].Total__c);                                               
            resp.chartTotalInteger = totalNumber;
            if (totalNumber != null && totalNumber > 0 ) {
                system.debug('chartTotalInteger > 0 : '+resp.chartTotalInteger);
                DateTime lastYearDate = system.now().addMonths(-12);
                List<LogACall__c> activitiesOfSalesRep;
                    // master report for
                if (selectedUserId == 'Midwest Machinery') {
                    activitiesOfSalesRep = [SELECT Id,
                                                    Assigned_To__c,
                                                    Type_of_Call__c,
                                                    CreatedDate,
                                                    Event_Date__c
                                            FROM LogACall__c
                                            WHERE (Assigned_To__r.Office_Location__c =:SAINT_LOUIS
                                                   OR Assigned_To__r.Office_Location__c =:OKLAHOMA
                                                   OR Assigned_To__r.Office_Location__c =:KANSAS_CITY
                                                   OR Assigned_To__r.Office_Location__c =:DENVER)
                                            AND CreatedDate >= :lastYearDate
                                            AND Type_of_Call__c != null];
        
                } else if (selectedUserId == SAINT_LOUIS 
                            || selectedUserId == OKLAHOMA 
                            || selectedUserId == KANSAS_CITY 
                            || selectedUserId == DENVER) {
                    
                 activitiesOfSalesRep = [SELECT Id,
                                                Assigned_To__c,
                                                Type_of_Call__c,
                                                CreatedDate,
                                                Event_Date__c
                                        FROM LogACall__c
                                        WHERE Assigned_To__r.Office_Location__c =:selectedUserId
                                         AND CreatedDate >= :lastYearDate
                                         AND Type_of_Call__c != null];
                                                                                               
                } else {
                    activitiesOfSalesRep = [SELECT Id,
                                            Assigned_To__c,
                                            Type_of_Call__c,
                                            CreatedDate,
                                            Event_Date__c
                                        FROM LogACall__c
                                        WHERE Assigned_To__c =:selectedUserId
                                        AND CreatedDate >= :lastYearDate
                                        AND Type_of_Call__c != null];
                    system.debug('selected sales ActivityGoal' +activitiesOfSalesRep);                           
                }

                if(activitiesOfSalesRep != null && activitiesOfSalesRep.size() > 0){
                    Map<String, Integer> activityTypeCount = new Map<String, Integer>();

                    for (LogACall__c activity : activitiesOfSalesRep) {
                
                        if(activity.Type_of_Call__c != 'Expense Only' && activity.Event_Date__c.Year() == System.now().year()){
                            if (!activityTypeCount.containsKey(activity.Type_of_Call__c)) {
                                activityTypeCount.put(activity.Type_of_Call__c, 1);
                                
                            } else {
                                activityTypeCount.put(activity.Type_of_Call__c, 
                                                activityTypeCount.get(activity.Type_of_Call__c) + 1);
                            } 
                        }    
                    } 
                        

                    for (String activityName : activityTypeCount.keySet()) {
                        if (activityTypeCount.containsKey(activityName)) {
                            resp.chartActualInInteger += (ActivityGoalPoints__c.getValues(activityName).Point__c != null ? ActivityGoalPoints__c.getValues(activityName).Point__c : 0)
                             * (activityTypeCount.get(activityName) != null ? activityTypeCount.get(activityName) : 0);
                        }  
                        system.debug('resp.chartActualInInteger is :' + resp.chartActualInInteger);
                    }

                    List<AggregateResult> totalPoints = [Select 
                                                            SUM(Points__c) totalPoints
                                                        FROM LogACall__c
                                                        WHERE Assigned_To__c =:selectedUserId 
                                                        AND CreatedDate >= :lastYearDate
                                                        AND Type_of_Call__c != null];
                    if (totalPoints.isEmpty()) {
                        isError = true;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'no call logged for selected user:' + selectedUserName));
                    } else if (!totalPoints.isEmpty() && totalPoints[0].get('totalPoints') != null) {
                        //resp.chartActualInInteger = Integer.valueOf(totalPoints[0].get('totalPoints'));
                    }
                    /*resp.chartActualInInteger = [SELECT Count()
                                                    FROM LogACall__c
                                                    WHERE Assigned_To__c =:selectedUserId // Use selected user id instead UserInfo.getUserId()
                                                    AND CreatedDate >= :lastYearDate
                                                    AND Type_of_Call__c != null];*/
                }
            } 
            system.debug('Final activityChart Resp: '+resp);
            activityChart = resp;
        }else{
            isError = true;
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'data for sales activity goal not found for selected user:' + selectedUserName));
        }      
    }

    public void fetchSalesRepGoals () {
        system.debug('selectedUserId=='+selectedUserId);
        try {
            if (selectedUserId.startsWith('005')) {
                srGoal = [Select Name,Margin_Goal__c,Monthly_Margin__c,
                                            Revenue_Goal__c,Monthly_Revenue__c,
                                            Direct_Sales_Goal__c,
                                            Resell_Sales_Goal__c,
                                            Direct_Sales_Percentage__c,
                                            Sales_Margin_Percentage__c
                                    FROM Sales_Rep_Goal__c
                                    WHERE Year__c =:  String.valueOf(System.Today().year())
                                    AND Sales_Rep__c =: selectedUserId];
                system.debug('sales rep for singal' + srGoal);                   
    
            } else {
                srGoal = [Select Name,Margin_Goal__c,Monthly_Margin__c,
                                            Revenue_Goal__c,Monthly_Revenue__c,Direct_Sales_Goal__c,
                                            Resell_Sales_Goal__c,
                                            Direct_Sales_Percentage__c,
                                            Sales_Margin_Percentage__c
                                    FROM Sales_Rep_Goal__c
                                    WHERE Year__c =:  String.valueOf(System.Today().year())
                                    AND Master_Report__c =: selectedUserId];
                system.debug('sales rep office level user ' + srGoal);                     
            }

           if (srGoal == null) {
                isError = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'sales rep goals are not set for selected user:' + selectedUserName));
                return;
            }

        } catch(Exception ex) {
            isError = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'sales rep goals are not set for selected user:' + selectedUserName));
            return;
           // throw new applicationException('sales rep goals are not set for selected user:' + selectedUserId);
        }
    }

    public class chartResponse{
        @AuraEnabled
        public Integer chartTotalInteger{get;set;}
        @AuraEnabled
        public Decimal chartActualInInteger{get;set;}
        @AuraEnabled
        public Decimal chartActualInDecimal{get;set;}
        @AuraEnabled
        public Decimal chartTotalInDecimal{get;set;}
        
        public chartResponse(){
            //salesActivitySO = new SalesActivityGoal__c();
            chartTotalInteger = 0;
            chartActualInInteger = 0;
            chartActualInDecimal = 0;
            chartTotalInDecimal = 0;
        }  
    }
}