/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 03-08-2024
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class QuoteDomain {
    
    /**
    * @description : Update List of Record
    * @author Nilesh Badrakiya | 04-11-2024 
    * @param recordList 
    **/
    public static void updateRecord(List<Quote> recordList) {
        if(!recordList.isEmpty()) {
            update recordList;
        }
    }

    /**
    * @description : insert quote
    * @author Nilesh Badrakiya | 04-11-2024 
    * @param record
    **/
    public static Quote insertRecord(Quote record) {
        insert record;
        return record;
    }

    public static void deleteRecord(Quote record) {
        delete record;
    }

    
}