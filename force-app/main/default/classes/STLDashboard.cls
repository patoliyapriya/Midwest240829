public with sharing class STLDashboard{
    
    public final String TARGET_NEGOTIATING = 'TARGET/NEGOTIATING';
    public final String SAINT_LOUIS = 'Saint Louis';
    
    public String selectSalesRep{get;set;}
    public List<OpportunityWrapper> lstOpportunityTargetedWrapper{get;set;}
    
    public Decimal totalTargeted{get;set;}
    
    Map<Id, Decimal> mapRevenue{get;set;}
    
    public STLDashboard(){
        refreshDashBoard();
        
    }
    
    public void refreshDashBoard(){
        totalTargeted = 0;
        selectSalesRep = SAINT_LOUIS;
        
        lstOpportunityTargetedWrapper = BuildOpporunityWrapper(TARGET_NEGOTIATING);
    }
    
    public List<OpportunityWrapper> buildOpporunityWrapper(String stageName){
    
        Id partsRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Parts').getRecordTypeId();
        List<OpportunityWrapper> lstOpportunityWrapper = new List<OpportunityWrapper>();
                
        List<Opportunity> lstOpportunity = [Select Opportunity_Number__c,Name,Total_Project_Margin__c,Total_Base_Bid_Total_Quote__c,
                                            Probability,Bidders__c,Description,Owner.Name,Ship_Date__c,CloseDate,LastModifiedDate,
                                            (Select Body From Feeds Order By LastModifiedDate desc) lastChatterAction 
                                            From Opportunity
                                            WHERE Id IN: getSalesRepOpportunityIds() AND 
                                            StageName IN :getSetFromStageName(stageName) AND
                                            RecordTypeId != :partsRecordTypeId
                                            ORDER BY Total_Project_Margin__c desc
                                            LIMIT 10];
        
        String rowColor = 'white';
        
        for(Opportunity opp : lstOpportunity){
            if(opp.Total_Base_Bid_Total_Quote__c != null){
                totalTargeted += opp.Total_Base_Bid_Total_Quote__c;
            }
            
            
            String lastChatterAction = '';
            OpportunityFeed lastOppFeed = getLastChatterDetails(opp.Feeds);
            
            if(lastOppFeed != null){
                lastChatterAction = lastOppFeed.Body;
            }
            
            if(rowColor == '#E4E3E0'){
                rowColor = 'white';
            } 
            else{
                rowColor = '#E4E3E0';
            }
            
            OpportunityWrapper objOpportunityWrapper = new OpportunityWrapper(opp, mapRevenue.get(opp.Id),lastChatterAction,rowColor);
            lstOpportunityWrapper.add(objOpportunityWrapper);
                        
        }
        
        return lstOpportunityWrapper;
    }
    
    public Set<String> getSetFromStageName(String stageName){
        
        Set<String> setStageName = new Set<String>();
        
        setStageName.add(stageName);
        
        return setStageName;
        
    }
    
    public Set<Id> getSalesRepOpportunityIds(){
        
        mapRevenue = new Map<Id, Decimal>();
        
        List<Sales_Representative__c > lstSalesRep;
        Set<Id> setOpportunityIds = new Set<Id>();
        
        if(selectSalesRep == SAINT_LOUIS){
            lstSalesRep =[Select Opportunity__c,Revenue__c,Margin__c 
                            FROM Sales_Representative__c 
                            Where Sales_Rep__r.Office_Location__c =: selectSalesRep];
        }
        
        for(Sales_Representative__c  sr : lstSalesRep){
            setOpportunityIds.add(sr.Opportunity__c);
            if(mapRevenue.get(sr.Opportunity__c) == null){
                mapRevenue.put(sr.Opportunity__c,sr.Revenue__c);
            }
            else{
                mapRevenue.put(sr.Opportunity__c,mapRevenue.get(sr.Opportunity__c) + sr.Revenue__c);
            }
        }
        
        return setOpportunityIds;
    }
    
    public OpportunityFeed getLastChatterDetails(List<OpportunityFeed> lstOpportunityFeeds){
    
        for(OpportunityFeed oppfeed : lstOpportunityFeeds){
            if(oppfeed.Body != null){
                return oppfeed;
            }
        }
        
        return null;
        
    }
    
    
    
    public class OpportunityWrapper{
        public Opportunity opportunity{get;set;}
        public Decimal revenue{get;set;}
        public String rowColor{get;set;}
        public String lastChatterAction{get;set;}
        public String strColor{get;set;}
        
        public opportunityWrapper(Opportunity opp, Decimal rev, String lca, String rc){
            opportunity = opp;
            revenue = rev;
            lastChatterAction = lca;
            rowColor = rc;
            strColor = isRowRedGreen(opp);
        }
        
        public opportunityWrapper(Opportunity opp){
            opportunity = opp;
        }
        
        public String isRowRedGreen(Opportunity opp){
        
            String strColor = 'ABC';
            
            Date todayDate = Date.today();
            String strDate = String.valueOf(opp.LastModifiedDate);
            DateTime dT = DateTime.valueOf(strDate);
            Date lastActivateDate  = date.newinstance(dT.year(), dT.month(), dT.day());
            Integer lstActivateDays = lastActivateDate.daysBetween(todayDate);
            
            if(opp.Probability >= 75 && lstActivateDays <= 14){
                strColor = '#c2f8c2';
            }
            else if(opp.Probability <= 50 && lstActivateDays > 14){
                strColor = '#d79c9c';
            }
            
            return strColor;
            
            
        }
    }
    
}