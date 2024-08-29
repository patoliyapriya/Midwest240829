public with sharing class ShowAllOpportunity{
    
    public final String TARGET_NEGOTIATING = 'TARGET/NEGOTIATING';
    public final String POST_BID = 'POST BID';
    public final String BIDDING = 'BIDDING';
    public final String LEAD_DD_BUDGET = 'LEAD, DD/BUDGET';
    
    public Final Integer PAGE_SIZE = 50;
    
    public final String SAINT_LOUIS = 'Saint Louis';
    public final String OKLAHOMA = 'Oklahoma';
    public final String KANSAS_CITY = 'Kansas City';
    public final String DENVER = 'Denver';
    
    Map<Id, Decimal> mapMargin;
    Map<Id, Decimal> mapRevenue;
    
    public String selectSalesRep{get;set;}
    public String stageName{get;set;}
    
    public  List<OpportunityWrapper> opportunity;
    
    public ShowAllOpportunity() {

    }
    
    public ShowAllOpportunity(ApexPages.StandardController controller) {

    }
    
    public Set<Id> getSalesRepOpportunityIds(){
        
        mapRevenue = new Map<Id, Decimal>();
        mapMargin = new Map<Id, Decimal>();
        
        List<AggregateResult> lstSalesRep;
        
        Set<Id> setOpportunityIds = new Set<Id>();
        
        if(selectSalesRep == 'Midwest Machinery'){
            lstSalesRep =[Select Opportunity__c, sum(Revenue__c) revenue, sum(Margin__c) Margin  
                            FROM Sales_Representative__c 
                            Where (Sales_Rep__r.Office_Location__c =: SAINT_LOUIS
                            OR Sales_Rep__r.Office_Location__c =: OKLAHOMA 
                            OR Sales_Rep__r.Office_Location__c =: KANSAS_CITY 
                            OR Sales_Rep__r.Office_Location__c =: DENVER) 
                            AND Opportunity__r.stageName != 'Closed Won' 
                            AND Opportunity__r.stageName != 'Closed/Dropped' 
                            AND (Opportunity__r.Total_Project_Margin__c != null AND Opportunity__r.Total_Project_Margin__c != 0)
                            GROUP BY Opportunity__c];
                            
        }else if(selectSalesRep == SAINT_LOUIS || selectSalesRep == OKLAHOMA || selectSalesRep == KANSAS_CITY || selectSalesRep == DENVER){
            lstSalesRep =[Select Opportunity__c, sum(Revenue__c) revenue, sum(Margin__c) Margin 
                            FROM Sales_Representative__c 
                            Where Sales_Rep__r.Office_Location__c =: selectSalesRep 
                            AND Opportunity__r.stageName != 'Closed Won' 
                            AND (Opportunity__r.Total_Project_Margin__c != null AND Opportunity__r.Total_Project_Margin__c != 0)
                            GROUP BY Opportunity__c];
        }else{
            lstSalesRep =[Select Opportunity__c, sum(Revenue__c) revenue, sum(Margin__c) Margin 
                          FROM Sales_Representative__c 
                          WHERE Sales_Rep__c =: selectSalesRep
                          AND Opportunity__r.stageName != 'Closed Won' 
                          AND (Opportunity__r.Total_Project_Margin__c != null AND Opportunity__r.Total_Project_Margin__c != 0)
                          GROUP BY Opportunity__c];
        }
        system.debug('Selected salesRep:- '+selectSalesRep);
        
        for(AggregateResult  sr : lstSalesRep){
            String oppId = (String) sr.get('Opportunity__c');
            Decimal margin = (Decimal) sr.get('Margin');
            Decimal revenue = (Decimal) sr.get('revenue');

            setOpportunityIds.add(oppId);
            if(mapMargin.get(oppId) == null){
                mapMargin.put(oppId, margin);
                mapRevenue.put(oppId, revenue);
            }else{
                mapMargin.put(oppId, mapMargin.get(oppId) + margin);
                mapRevenue.put(oppId, mapRevenue.get(oppId) + revenue);
            }
        }
        system.debug('SalesRep opportunity ids:- '+setOpportunityIds.size());
        return setOpportunityIds;
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
    
    public ApexPages.StandardSetController con {
        get {
            if(con == null) {
                stageName = Apexpages.currentPage().getParameters().get('stageName');
                selectSalesRep = Apexpages.currentPage().getParameters().get('selectSalesRep');
                if(stageName != 'Open Projects' && stageName != 'Past Due'){
                    if(stageName == TARGET_NEGOTIATING){
                        con = new ApexPages.StandardSetController(Database.getQueryLocator([Select Opportunity_Number__c,Name,Total_Project_Margin__c,Total_Base_Bid_Total_Quote__c,
                                                                                Probability,Bidders__c,Description,Owner.Name,Ship_Date__c,CloseDate,LastActivityDate,
                                                                                (Select Body From Feeds Order By LastModifiedDate desc LIMIT 1) lastChatterAction 
                                                                                From Opportunity
                                                                                WHERE Id IN: getSalesRepOpportunityIds()
                                                                                AND (StageName IN :getSetFromStageName(stageName)
                                                                                OR Targeted__c = true)
                                                                                AND Total_Project_Margin__c != null
                                                                                ORDER BY Total_Project_Margin__c desc 
                                                                                LIMIT 1000])); 
                        system.debug('In Target negotiation stage');
                    } else {
                        con = new ApexPages.StandardSetController(Database.getQueryLocator([Select Opportunity_Number__c,Name,Total_Project_Margin__c,Total_Base_Bid_Total_Quote__c,
                                                                                Probability,Bidders__c,Description,Owner.Name,Ship_Date__c,CloseDate,LastActivityDate,
                                                                                (Select Body From Feeds Order By LastModifiedDate desc LIMIT 1) lastChatterAction 
                                                                                From Opportunity
                                                                                WHERE Id IN: getSalesRepOpportunityIds()
                                                                                AND StageName IN :getSetFromStageName(stageName)
                                                                                AND Total_Project_Margin__c != null
                                                                                ORDER BY Total_Project_Margin__c desc
                                                                                LIMIT 1000]));
                        system.debug('else case getResultSize()=> '+con.getResultSize());
                        system.debug('else case stage name:- '+stageName);
                    }
                    
                }
                else if(stageName == 'Open Projects'){
                    
                    con = new ApexPages.StandardSetController(Database.getQueryLocator([Select Opportunity_Number__c,Name,Total_Project_Margin__c,Total_Base_Bid_Total_Quote__c,
                                                                                        Probability,Bidders__c,Description,Owner.Name,Ship_Date__c,CloseDate,LastActivityDate,
                                                                                        (Select Body From Feeds Order By LastModifiedDate desc LIMIT 1) lastChatterAction  
                                                                                        From Opportunity
                                                                                        WHERE Id IN (Select Opportunity__c From Project__c 
                                                                                                        WHERE Opportunity__c != null 
                                                                                                        AND Project_Stage__c != 'Archived'
                                                                                                        AND Opportunity__c IN :getSalesRepOpportunityIds())
                                                                                        AND Total_Project_Margin__c != null
                                                                                        ORDER BY Total_Project_Margin__c desc]));
                    
                }
                else if(stageName == 'Past Due'){
                    con = new ApexPages.StandardSetController(Database.getQueryLocator([Select Opportunity_Number__c,Name,Total_Project_Margin__c,Total_Base_Bid_Total_Quote__c,
                                                                                        Probability,Bidders__c,Description,Owner.Name,Ship_Date__c,CloseDate,LastActivityDate,
                                                                                        (Select Body From Feeds Order By LastModifiedDate desc LIMIT 1) lastChatterAction  
                                                                                        From Opportunity
                                                                                        WHERE Id NOT IN (Select Opportunity__c From Project__c Where Opportunity__c != null) 
                                                                                        AND Id IN :getSalesRepOpportunityIds()
                                                                                        AND Total_Project_Margin__c != null
                                                                                        AND CloseDate <= Today
                                                                                        AND (StageName = 'Bidding'
                                                                                          OR StageName = 'Post Bid'
                                                                                          OR StageName = 'TARGET/NEGOTIATING'
                                                                                          OR StageName = 'LEAD'
                                                                                          OR StageName = 'DD/BUDGET')
                                                                                        ORDER BY Total_Project_Margin__c desc]));
                }
                con.setPageSize(PAGE_SIZE);
            }
            return con;
        }
        set;
    }
    
    public List<OpportunityWrapper> getOpportunity() {
        
        opportunity = new List<OpportunityWrapper>();
        
        for (Opportunity opp : (List<Opportunity>)con.getRecords()){

            String lastChatterAction = '';
            OpportunityFeed lastOppFeed = getLastChatterDetails(opp.Feeds);
            
            if(lastOppFeed != null){
                lastChatterAction = lastOppFeed.Body.stripHtmlTags();
            }
            OpportunityWrapper objOpportunityWrapper = new OpportunityWrapper(opp, mapRevenue.get(opp.Id),mapMargin.get(opp.Id),lastChatterAction);
            opportunity.add(objOpportunityWrapper);            
        }
        system.debug('Opportunity records size for top opportunity page:- '+opportunity.size());
        return opportunity;
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
    
    public class OpportunityWrapper{
        public  Opportunity opportunity{get;set;}
        public  Decimal revenue{get;set;}
        public  Decimal margin{get;set;}
        public  String lastChatterAction{get;set;}
        
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
    

}