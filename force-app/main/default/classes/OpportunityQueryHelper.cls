/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 04-08-2024
 * @last modified by  : Nilesh Badrakiya
**/

public with sharing class OpportunityQueryHelper {
   

    /**
    * @description : Retrieves Quote Line Item by Id
    * @author Nilesh Badrakiya | 03-22-2024 
    * @param recordId 
    * @return Opportunity
    **/
    public static Opportunity getOpportunityById(Id recordId) {

        Opportunity opportunity = (Opportunity)new Query(OpportunityConstants.SOBJECT_NAME).
                                            selectField(ManagedObject.FIELD_NAME_ID).
                                            selectField(ManagedObject.FIELD_NAME_NAME).
                                            selectField(ManagedObject.FIELD_NAME_RECORDTYPE_NAME).
                                            selectField(OpportunityConstants.FIELD_NAME_ACCOUNT).
                                            selectField(OpportunityConstants.FIELD_NAME_CLOSEDATE).
                                            selectField(OpportunityConstants.FIELD_NAME_OPPORTUNITY_NUMBER).
                                            selectField(OpportunityConstants.FIELD_NAME_BIDDATE).
                                            selectField(OpportunityConstants.FIELD_NAME_CONSULTINGENGINEER).
                                            selectField(OpportunityConstants.FIELD_NAME_GENERALCONTRACTOR).
                                            selectField(OpportunityConstants.FIELD_NAME_SHIPPINGNAME).
                                            selectField(OpportunityConstants.FIELD_NAME_ATTENTIONTO).
                                            selectField(OpportunityConstants.FIELD_NAME_SYNCQUOTE).
                                            selectField(OpportunityConstants.FIELD_NAME_APPLICATIONENGINEER).
                                            byId(recordId).
                                            fetch();
        return opportunity;
    }
}