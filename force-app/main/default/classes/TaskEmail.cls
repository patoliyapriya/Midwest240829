public class TaskEmail{

    public String strWhatId{get;set;}
    public String getopportunityNumber(){
        String oppName = '';
        List<Opportunity> lstOpportunity = [Select Id From Opportunity Where Id =: strWhatId]; //Opportunity_Number__c
        if(lstOpportunity.size() > 0){
           //oppName = lstOpportunity[0].Opportunity_Number__c;
        }
        return oppName;
    }
}