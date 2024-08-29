public with sharing class AdditionDeductionDomain {
    
    public static void insertRecords(List<Addition_Deduction__c> recordList) {
        
        if (!recordList.isEmpty()) {
            insert recordList;
        }
    }
}