public with sharing class SalesActivityCtrl {
    public static final String ACTIVITY_CLIENTOFFICE_VISIT = 'Client Office Visit';
    public static final String ACTIVITY_ENDUSER_VISIT = 'End User Visit';
    public static final String ACTIVITY_ENTERTAINMENT = 'Entertain (Hpy Hr, Glf, Gms)';
    public static final String ACTIVITY_FACTORY_VISIT_LOCAL = 'Factory Visit (Local)';
    public static final String ACTIVITY_FACTORY_VISIT_TRAVEL = 'Factory Visit (Travel)';
    public static final String ACTIVITY_HAPPY_HOUR = 'Industry Event (Ashrae etc.)';
    public static final String ACTIVITY_Meal = 'Meal';
    public static final String ACTIVITY_SITE_VISIT = 'Site Visit (Project Related)';
    public static final String ACTIVITY_TRAININ = 'Training (L-N-L, Seminar)';
    public static final String SAINT_LOUIS = 'Saint Louis';
    public static final String OKLAHOMA = 'Oklahoma';
    public static final String KANSAS_CITY = 'Kansas City';
    public static final String DENVER = 'Denver';

    public static Map<String, Integer> activityTypeCount = new Map<String, Integer>();
    public static Map<String, Integer> activityTypeCountLast1Month = new Map<String, Integer>();
    public static Map<String, Integer> activityTypeCountLast3Month = new Map<String, Integer>();
    public static Map<String, Integer> activityTypeCountLast6Month = new Map<String, Integer>();
    public static Map<String, Integer> activityTypeCountLast12Month = new Map<String, Integer>(); 

    public class applicationException extends Exception {}

    public SalesActivityCtrl() {

    }

    public static List<User> getAllSalesRep(){
        
        Set<String> setOfficeLocation = new Set<String>();
        setOfficeLocation.add(SAINT_LOUIS);
        setOfficeLocation.add(OKLAHOMA);
        setOfficeLocation.add(KANSAS_CITY);
        setOfficeLocation.add(DENVER);
        
        List<User> lstUsers = [Select Id,Name,Office_Location__c,IsActive  From User 
                                WHERE Office_Location__c IN :setOfficeLocation
                                AND IsActive = true
                                ORDER BY Office_Location__c ASC];
        return lstUsers;
        
    } 

    public static List<User> getHouseUserDetails(){
        
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

    public static List<User> getUsersByLocations(String officeLocation){
        List<User> lstUsers = [Select Id,Name From User 
                                WHERE Office_Location__c = :officeLocation
                                ORDER BY Name ASC];
        return lstUsers;
    }

    @AuraEnabled(cacheable=true)
    public Static Map<String, String> buildUserHierarchy(Id salesRep){
        
        Map<String,String> userDetails = new Map<String, String>();
        String secondLevel = '____';
        String thirdLevel = '________';
        
        List<SelectOption> lstHierarchyUsers = new List<SelectOption>();
        
        User currentUser = [SELECT Id,
                                    Name,
                                    Is_Manager__c, 
                                    Is_Director__c, 
                                    Office_Location__c,
                                    has_house_Account_Access__c 
                            FROM  User
                            WHERE Id = :salesRep];
        
        if(currentUser.Is_Manager__c == false && currentUser.Is_Director__c == false){
            userDetails.put(currentUser.Id, currentUser.Name);
            lstHierarchyUsers.add(new SelectOption(currentUser.Id,currentUser.Name));    
        }else if(currentUser.Is_Director__c){
            userDetails.put('Midwest Machinery','Master Report');
            lstHierarchyUsers.add(new SelectOption('Midwest Machinery','Master Report'));         
            
            List<User> lstUsers = getAllSalesRep();
            String currentOfficeLocation = '';
            
            for(User u : lstUsers){
                if(u.Office_Location__c != currentOfficeLocation){
                    currentOfficeLocation = u.Office_Location__c;
                    userDetails.put(u.Office_Location__c, secondLevel + u.Office_Location__c);
                    userDetails.put(u.Id, thirdLevel + u.Name);

                    lstHierarchyUsers.add(new SelectOption(u.Office_Location__c,secondLevel + u.Office_Location__c)); 
                    lstHierarchyUsers.add(new SelectOption(u.Id,thirdLevel + u.Name));  
                }else{
                    userDetails.put(u.Id, thirdLevel + u.Name);
                    lstHierarchyUsers.add(new SelectOption(u.Id,thirdLevel + u.Name));   
                }
            }
        }else if(currentUser.Is_Manager__c){
            userDetails.put(currentUser.Office_Location__c, currentUser.Office_Location__c);

            lstHierarchyUsers.add(new SelectOption(currentUser.Office_Location__c,currentUser.Office_Location__c));   
            
            List<User> lstUsers = getUsersByLocations(currentUser.Office_Location__c);
            
            for(User u : lstUsers){
                userDetails.put(u.Id, secondLevel + u.Name);

                lstHierarchyUsers.add(new SelectOption(u.Id,secondLevel + u.Name));
            }
        }
        if(currentUser.has_house_Account_Access__c){
            List<User> lstUsers = getHouseUserDetails();
            
            for(User u : lstUsers){
                userDetails.put(u.Id,secondLevel + u.Name);

                lstHierarchyUsers.add(new SelectOption(u.Id,secondLevel + u.Name));
            }
            
        }
        
        return userDetails;
    }

    @AuraEnabled(cacheable=true)
    public static List<salesActivityResponse> buildSalesActivityWrapper(String salesRep){
        system.debug('buildSalesActivityWrapper: '+salesRep);
        List<salesActivityResponse> responseWrapperList = new List<salesActivityResponse>();
        List<LogACall__c> activitiesOfSalesRep = new List<LogACall__c>();
        Map<String, Decimal> goalsForEachActivity = new Map<String, Decimal>(); 
        DateTime lastYearDate = system.now().addMonths(-12);
        // in dashoboard for particular user like brian, Bob log call
        if (salesRep == 'Midwest Machinery') {
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
                                    AND CreatedDate >= :lastYearDate];

         System.debug('selected sales rep is midwest' +activitiesOfSalesRep);   

        } else if (salesRep == SAINT_LOUIS 
                    || salesRep == OKLAHOMA 
                    || salesRep == KANSAS_CITY 
                    || salesRep == DENVER) {
            
         activitiesOfSalesRep = [SELECT Id,
                                        Assigned_To__c,
                                        Type_of_Call__c,
                                        CreatedDate,
                                        Event_Date__c
                                FROM LogACall__c
                                WHERE Assigned_To__r.Office_Location__c =:salesRep
                                 AND CreatedDate >= :lastYearDate];

         System.debug('selected sales rep else if  saint louis part' +activitiesOfSalesRep);                                                             
        } else {
            activitiesOfSalesRep = [SELECT Id,
                                    Assigned_To__c,
                                    Type_of_Call__c,
                                    CreatedDate,
                                    Event_Date__c
                                FROM LogACall__c
                                WHERE Assigned_To__c =:salesRep
                                AND CreatedDate >= :lastYearDate];  
        }                               
        constructActivityContMaps(activitiesOfSalesRep);
        SalesActivityGoal__c activity = new SalesActivityGoal__c();
        try {
            // in dashoboard for particular user like brian, Bob sales Activity
            if(salesRep.startsWith('005')){
                activity  = [SELECT Id,Name,
                                ClientOfficeVisit__c,
                                EndUserVisit__c,
                                Entertainment__c,
                                FactoryVisitLocal__c,
                                FactoryVisitTravel__c,
                                HappyHour__c,
                                Meal__c,
                                SalesRep__c,
                                SiteVisit__c,
                                Training__c,
                                Year__c
                            FROM SalesActivityGoal__c
                            WHERE SalesRep__c = :salesRep
                            AND Year__c = :String.valueOf(system.now().year())
                            LIMIT 1];
            }else{
                //master report ex:- Saint Louis for sales Activity in dashboard
                activity  = [SELECT Id,Name,
                                ClientOfficeVisit__c,
                                EndUserVisit__c,
                                Entertainment__c,
                                FactoryVisitLocal__c,
                                FactoryVisitTravel__c,
                                HappyHour__c,
                                Meal__c,
                                SalesRep__c,
                                SiteVisit__c,
                                Training__c,
                                Year__c
                            FROM SalesActivityGoal__c
                            WHERE Master_Report__c = :salesRep  //  SalesRep__c = :salesRep
                            AND Year__c = :String.valueOf(system.now().year())
                            LIMIT 1];
            }
                
                system.debug('Sales activity' +activity);
        } catch(Exception e) {
            throw new applicationException('sales activity goals are not set for selected user: ' + salesRep);
        }

        goalsForEachActivity.put(ACTIVITY_CLIENTOFFICE_VISIT, activity.ClientOfficeVisit__c);
        goalsForEachActivity.put(ACTIVITY_ENDUSER_VISIT, activity.EndUserVisit__c);
        goalsForEachActivity.put(ACTIVITY_ENTERTAINMENT, activity.Entertainment__c);
        goalsForEachActivity.put(ACTIVITY_FACTORY_VISIT_LOCAL, activity.FactoryVisitLocal__c);
        goalsForEachActivity.put(ACTIVITY_FACTORY_VISIT_TRAVEL, activity.FactoryVisitTravel__c);
        goalsForEachActivity.put(ACTIVITY_HAPPY_HOUR, activity.HappyHour__c);
        goalsForEachActivity.put(ACTIVITY_Meal, activity.Meal__c);
        goalsForEachActivity.put(ACTIVITY_SITE_VISIT, activity.SiteVisit__c);
        goalsForEachActivity.put(ACTIVITY_TRAININ, activity.Training__c);
        salesActivityResponse totalLine = new salesActivityResponse();
        totalLine.activityName = 'Sales Activity Score';
        for (String activityType : goalsForEachActivity.keySet()) {
    
            decimal totalGoal = goalsForEachActivity.containsKey(activityType) ? goalsForEachActivity.get(activityType) : 0;
            
            salesActivityResponse resp = new salesActivityResponse();
            resp.activityGoal = Integer.valueOf(totalGoal);
            totalLine.activityGoal += resp.activityGoal;

            resp.activityName = activityType;
            //.round(System.RoundingMode.DOWN));
            resp.ytdGoal = (Integer.valueOf(System.today().dayOfYear()) * totalGoal) / 365;
            resp.ytdGoal = resp.ytdGoal.setScale(1);
            totalLine.ytdGoal += resp.ytdGoal;
            
            //resp.ytdGoal = resp.ytdGoal.round(System.RoundingMode.DOWN);
            system.debug('resp.ytdGoal='+resp.ytdGoal);
            if (activityTypeCount.containsKey(activityType) && activityTypeCount.get(activityType) > 0) {
                resp.ytdActual = activityTypeCount.get(activityType);
                totalLine.ytdActual += resp.ytdActual;
                if (activityType == ACTIVITY_ENTERTAINMENT) {
                    resp.points = ActivityGoalPoints__c.getValues( 'Entertain (Hpy Hr, Glf, Gms)').Point__c * resp.ytdActual;
                } else {
                    system.debug('activity type: '+ activityType);
                    system.debug('resp.ytdActual: '+ resp.ytdActual);
                    system.debug('Point__c: '+ ActivityGoalPoints__c.getValues(activityType).Point__c);

                    resp.points = ActivityGoalPoints__c.getValues(activityType).Point__c * resp.ytdActual;
                }
                totalLine.points +=  resp.points;
                
                if(resp.ytdActual > 0 && resp.ytdGoal > 0) {
                    //Decimal.valueOf(String.valueOf(resp.ytdActual));
                    resp.PercentageOfYtdGoal = resp.ytdActual / resp.ytdGoal;
                    resp.PercentageOfYtdGoal = resp.PercentageOfYtdGoal.setScale(2);
                    totalLine.PercentageOfYtdGoal += resp.PercentageOfYtdGoal;
                } else {
                    resp.PercentageOfYtdGoal = 0;
                }
                
                resp.lastOneMotnh = activityTypeCountLast1Month.containsKey(activityType) ? activityTypeCountLast1Month.get(activityType) : 0;
                totalLine.lastOneMotnh += resp.lastOneMotnh;
                
                resp.lastThreeMotnh = activityTypeCountLast3Month.containsKey(activityType) ? activityTypeCountLast3Month.get(activityType) : 0;
                totalLine.lastThreeMotnh += resp.lastThreeMotnh;

                resp.lastSixMotnh = activityTypeCountLast6Month.containsKey(activityType) ? activityTypeCountLast6Month.get(activityType) : 0;
                totalLine.lastSixMotnh += resp.lastSixMotnh;

                resp.lastTwelveMonth = activityTypeCountLast12Month.containsKey(activityType) ? activityTypeCountLast12Month.get(activityType) : 0;
                totalLine.lastTwelveMonth += resp.lastTwelveMonth;
            }
            responseWrapperList.add(resp);
        }
        responseWrapperList.add(totalLine);
        return responseWrapperList;

    }

    public static void constructActivityContMaps(List<LogACall__c> activities) {

        for(LogACall__c activity : activities) {
            if (activity.Event_Date__c.Year() == System.now().year()) {
                if (!activityTypeCount.containsKey(activity.Type_of_Call__c)) {
                    activityTypeCount.put(activity.Type_of_Call__c, 1);
                } else {
                    activityTypeCount.put(activity.Type_of_Call__c, 
                                    activityTypeCount.get(activity.Type_of_Call__c) + 1);
                }

            }

            // activities for last month
            if(activity.Event_Date__c < system.now() 
                && activity.Event_Date__c > system.now().addMonths(-1)) {

                    if(activityTypeCountLast1Month.containsKey(activity.Type_of_Call__c)) {
                        
                        activityTypeCountLast1Month.put(activity.Type_of_Call__c, 
                            activityTypeCountLast1Month.get(activity.Type_of_Call__c) + 1);
                    } else {
                        activityTypeCountLast1Month.put(activity.Type_of_Call__c, 1);
                    }

            }

            // activities for last 3 month
            if(activity.Event_Date__c < system.now() 
                && activity.Event_Date__c > system.now().addMonths(-3)) {
        
                if(activityTypeCountLast3Month.containsKey(activity.Type_of_Call__c)) {
                    
                    activityTypeCountLast3Month.put(activity.Type_of_Call__c, 
                        activityTypeCountLast3Month.get(activity.Type_of_Call__c) + 1);
                } else {
                    activityTypeCountLast3Month.put(activity.Type_of_Call__c, 1);
                }
        
            }
            // activities for last 6 month
            if(activity.Event_Date__c < system.now() 
                && activity.Event_Date__c > system.now().addMonths(-6)) {
        
                if(activityTypeCountLast6Month.containsKey(activity.Type_of_Call__c)) {
                    
                    activityTypeCountLast6Month.put(activity.Type_of_Call__c, 
                        activityTypeCountLast6Month.get(activity.Type_of_Call__c) + 1);
                } else {
                    activityTypeCountLast6Month.put(activity.Type_of_Call__c, 1);
                }
        
            }
            // activities for last 12 month
            if(activity.Event_Date__c < system.now() 
                && activity.Event_Date__c > system.now().addMonths(-12)) {
        
                if(activityTypeCountLast12Month.containsKey(activity.Type_of_Call__c)) {
                    
                    activityTypeCountLast12Month.put(activity.Type_of_Call__c, 
                        activityTypeCountLast12Month.get(activity.Type_of_Call__c) + 1);
                } else {
                    activityTypeCountLast12Month.put(activity.Type_of_Call__c, 1);
                }
        
            }

        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<SalesRep> getRankings() {

        List<SalesRep> lstSalesRepNames = new List<SalesRep>();

        for (AggregateResult result : [SELECT Assigned_To__r.Name, SUM(Points__c) totalPoints 
                                        FROM LogACall__c 
                                        WHERE CreatedDate = THIS_YEAR
                                        AND Assigned_To__c != NULL
                                        AND Type_of_Call__c != 'Expense Only'
                                        GROUP BY Assigned_To__r.Name 
                                        ORDER BY SUM(Points__c) DESC 
                                        LIMIT 5]) {
            System.debug('###-111--'+result);
            System.debug('###--222-'+JSON.serializePretty(result));   
            lstSalesRepNames.add(new SalesRep((String)result.get('Name')));
        }

        return lstSalesRepNames;
    }
    public class salesActivityResponse{
        @AuraEnabled
        public String activityName{get;set;}
        @AuraEnabled
        public Integer activityGoal{get;set;}
        @AuraEnabled
        public Decimal ytdGoal{get;set;}
        @AuraEnabled
        public Decimal ytdActual{get;set;}
        @AuraEnabled
        public Decimal PercentageOfYtdGoal{get;set;}
        @AuraEnabled
        public Decimal lastOneMotnh{get;set;}
        @AuraEnabled
        public Decimal lastThreeMotnh{get;set;}
        @AuraEnabled
        public Decimal lastSixMotnh{get;set;}
        @AuraEnabled
        public Decimal lastTwelveMonth {get;set;}
        @AuraEnabled
        public Decimal points {get;set;}
        
        public salesActivityResponse(){
            //salesActivitySO = new SalesActivityGoal__c();
            activityGoal = 0;
            activityName = '';
            PercentageOfYtdGoal = 0;
            ytdGoal = 0;
            lastOneMotnh = 0;
            lastTwelveMonth = 0;
            lastSixMotnh = 0;
            lastThreeMotnh = 0;
            ytdActual = 0;
            points = 0;
            
        }
        
    }

    public with sharing class SalesRep {
        @AuraEnabled public String SalesRepName {get;set;}

        public SalesRep(String salesRepName) {
            this.SalesRepName = salesRepName;
        }
    }
}