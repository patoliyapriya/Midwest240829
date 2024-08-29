public with sharing class ProjectQueryHelper {
    
    public static Project__c getProjectByQuoteId(Id quoteId) {
       Project__c project = (Project__c)new Query(ProjectConstant.SOBJECT_NAME).
        selectField(ManagedObject.FIELD_NAME_ID).
        lookup(ProjectConstant.RELATIONSHIP_QUOTE_ID,quoteId).
        fetch();
        return project;
    }

    public static Project__c getProjectByOppId(Id oppId) {
        Project__c project = (Project__c)new Query(ProjectConstant.SOBJECT_NAME).
         selectField(ManagedObject.FIELD_NAME_NAME).
         lookup(ProjectConstant.RELATIONSHIP_OPPORTUNITY_ID,oppId).
         fetch();
        return project;
     }
}