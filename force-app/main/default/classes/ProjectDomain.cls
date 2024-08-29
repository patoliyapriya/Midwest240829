public with sharing class ProjectDomain { 
    
    /**
    * @description : insert project
    * @author Nilesh Badrakiya | 03-17-2024 
    * @param record 
    **/
    public static Project__c insertRecord(Project__c record) {
        insert record;
        return record;
    }

    /**
    * @description : update project
    * @author Nilesh Badrakiya | 03-17-2024 
    * @param record 
    **/
    public static void updateProjectRecord(Project__c record) {
        if(record!=null) {
            update record;
        }
    }
}