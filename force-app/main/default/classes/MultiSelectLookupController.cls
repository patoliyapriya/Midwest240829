/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-29-2023
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class MultiSelectLookupController {
    //This method retrieves the data from database table. It search input is '*', then retrieve all records
    @AuraEnabled (cacheable=true)
    public static List<SObjectQueryResult> retrieveRecords(String objectName, 
                                                    String fieldAPINames,
                                                    String filterFieldAPIName,
                                                    String strInput,
                                                    List<Id> preSelectedIds){
        system.debug('preSelectedIds=='+preSelectedIds);
        List<SObjectQueryResult> lstReturnResult = new List<SObjectQueryResult>();
        if(strInput.equals('*')){
            strInput = '';
        }
        String str = strInput + '%';
        String strQueryField = '';
        List<String> fieldList = fieldAPINames.split(',');
                                                       System.debug('the list is ' + fieldList);

        //check if Id is already been passed
        if(!fieldList.contains('Id')){
            fieldList.add('Id');
            strQueryField = String.join(fieldList, ',');
        }else {
            strQueryField = fieldAPINames;
        }

        String strQuery = 'SELECT ' + String.escapeSingleQuotes(strQueryField) 
                        + ' FROM ' 
                        + String.escapeSingleQuotes(objectName);
                                                        System.debug('the strQuery is ' + strQuery);
        if (preSelectedIds != null && preSelectedIds.size() > 0) {
            strQuery += ' WHERE Id IN :preSelectedIds';    
        } else {
            strQuery +=  ' WHERE ' + filterFieldAPIName + '  LIKE \'' + str + '%\'';
        }
        
        if(strInput == '') {
            strQuery += ' ORDER BY LastModifiedDate DESC LIMIT 50';
        } else {
            strQuery += ' ORDER BY ' + filterFieldAPIName + ' LIMIT 50';
        }                          
System.debug('the strQuery is ' + strQuery);
        List<SObject> lstResult = database.query(strQuery);
                                                        System.debug('the result is ' + lstResult);
        //create list of records that can be easily be parsable at js controller.
        for(SObject sobj:lstResult){                
                SObjectQueryResult result = new SObjectQueryResult();
                result.recordId = (String) sobj.get('Id');
                result.recordName = (String) sobj.get('Name');
            System.debug('the list is ' + fieldList);
                if (fieldList.contains('Email')) {
                    result.recordEmail = (String) sobj.get('Email');
                }
                if (fieldList.contains('Account.Name')) {
                    result.recordAccountName = (String) sobj.getSObject('Account').get('Name');
                }
                lstReturnResult.add(result);
        }
        return lstReturnResult;
    }
    
    public class SObjectQueryResult {
        @AuraEnabled
        public String recordId;

        @AuraEnabled
        public String recordName;

        @AuraEnabled
        public String recordAccountName;

        @AuraEnabled
        public String recordEmail;
    }
}