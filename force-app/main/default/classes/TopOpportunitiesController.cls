public with sharing class TopOpportunitiesController {
    public static final String TARGET_NEGOTIATING = 'TARGET/NEGOTIATING';
    public static final String POST_BID = 'POST BID';
    public static final String BIDDING = 'BIDDING';
    public static final String LEAD_DD_BUDGET = 'LEAD, DD/BUDGET';
    public static final String SAINT_LOUIS = 'Saint Louis';
    public static final String OKLAHOMA = 'Oklahoma';
    public static final String KANSAS_CITY = 'Kansas City';
    public static final String DENVER = 'Denver';

    public static Map<Id, Decimal> mapRevenue; 
    public static Map<Id, Decimal> mapMargin;
    //public static String selectSalesRep{get;set;}
    
    public TopOpportunitiesController() {

    }

    @AuraEnabled(cacheable=true)
    public static List<OpportunityWrapper> buildOpporunityWrapper(String stageName, String selectedUserId){
        system.debug('selectedUserId in buildOpporunityWrapper=>'+selectedUserId);
        //system.debug('selectSalesRep=>'+selectSalesRep);
        List<OpportunityWrapper> lstOpportunityWrapper = new List<OpportunityWrapper>();
        
        List<Opportunity> lstOpportunity = null;
        
        if(stageName == TARGET_NEGOTIATING){
            lstOpportunity = [Select ID, Opportunity_Number__c,Name,Total_Project_Margin__c,Total_Base_Bid_Total_Quote__c,
                                Probability,Bidders__c,Description,Owner.Name,Ship_Date__c,CloseDate,LastModifiedDate,
                                (Select Body From Feeds Order By LastModifiedDate desc) lastChatterAction 
                                From Opportunity
                                WHERE Id IN: getSalesRepOpportunityIds(selectedUserId)
                                AND (StageName IN :getSetFromStageName(stageName)
                                OR Targeted__c = true)
                                AND Total_Project_Margin__c != null
                                ORDER BY Total_Project_Margin__c desc
                                LIMIT 10];
                                
        } else {
            system.debug('stageName='+stageName);
            lstOpportunity = [Select ID, Opportunity_Number__c,Name,Total_Project_Margin__c,Total_Base_Bid_Total_Quote__c,
                                Probability,Bidders__c,Description,Owner.Name,Ship_Date__c,CloseDate,LastModifiedDate,
                                (Select Body From Feeds Order By LastModifiedDate desc) lastChatterAction 
                                From Opportunity
                                WHERE Id IN: getSalesRepOpportunityIds(selectedUserId)
                                AND StageName IN :getSetFromStageName(stageName)
                                AND Total_Project_Margin__c != null
                                ORDER BY Total_Project_Margin__c desc
                                LIMIT 10];

                                
        }        
        
        
        for(Opportunity opp : lstOpportunity){
            String lastChatterAction = '';
            OpportunityFeed lastOppFeed = getLastChatterDetails(opp.Feeds);
            
            
            if(lastOppFeed != null){
                lastChatterAction = lastOppFeed.Body.stripHtmlTags();
                system.debug('The lastChatterAction -2' +lastChatterAction);
            }
           
            system.debug('mapMargin=>'+mapMargin);
            system.debug('mapRevenue=>'+mapRevenue);
            system.debug('opp=>'+opp);
            OpportunityWrapper objOpportunityWrapper = new OpportunityWrapper(opp, mapRevenue.get(opp.Id),mapMargin.get(opp.Id),lastChatterAction);
            lstOpportunityWrapper.add(objOpportunityWrapper);
                        
        }
        
        return lstOpportunityWrapper;
    }

    public static OpportunityFeed getLastChatterDetails(List<OpportunityFeed> lstOpportunityFeeds){
        for(OpportunityFeed oppfeed : lstOpportunityFeeds){
            if(oppfeed.Body != null){
                return oppfeed;    
            }
        }
        return null;
    }

    public static Set<Id> getSalesRepOpportunityIds(String selectSalesRep){
        
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
            if(!mapMargin.containsKey(sr.Opportunity__c)){
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

    public static Set<String> getSetFromStageName(String stageName){
        
        Set<String> setStageName = new Set<String>();
        
        if(stageName == LEAD_DD_BUDGET){
            setStageName.add('Lead');
            setStageName.add('DD/Budget');
        }else{
            setStageName.add(stageName);
        }
        system.debug('setStageName==>'+setStageName);
        return setStageName;
        
    }

    public class OpportunityWrapper{
        @AuraEnabled
        public Opportunity opportunity{get;set;}
        @AuraEnabled
        public Decimal revenue{get;set;}
        @AuraEnabled
        public Decimal margin{get;set;}
        @AuraEnabled
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
}