/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 04-11-2024
 * @last modified by  : Nilesh Badrakiya
**/

public with sharing class OpportunityDomain {
   
    /**
    * @description : Insert Opportunity
    * @author Nilesh Badrakiya | 03-20-2024 
    * @param opportunity 
    **/
    public static Opportunity insertOpportunity(Opportunity opportunity) {

        insert opportunity;
        return opportunity;
    }

    public static void updateRecord(List<Opportunity> opportunity) {
        if(!opportunity.isEmpty()) {
            update opportunity;
        }
    }
}