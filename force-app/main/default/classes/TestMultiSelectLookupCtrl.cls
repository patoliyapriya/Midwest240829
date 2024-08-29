/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 11-30-2023
 * @last modified by  : Nilesh Badrakiya
**/
@isTest
private class TestMultiSelectLookupCtrl {

    @TestSetup static void setup() {
        Account acc = new Account();
        acc.Name = 'Test Account 01';
        
        insert acc;

        Contact con = new Contact();
        con.LastName = 'Test con';
        con.AccountId = acc.Id;
        con.Title = 'Test';
        con.Job_Level_1__c = 'Internal Contact';
        insert con;

}


@isTest static void testretrieveRecords(){
    List<Account> acc = [Select Id ,Name from Account WHERE Name = 'Test Account 01'];
    List<Id> contactIds = new List<Id>();
    List<Id> ids = new List<Id>();
    for(Account account : acc){
        ids.add(account.Id);
    }
    // MultiSelectLookupController.retrieveRecords('Account', 'Name', 'Name', '*');
    MultiSelectLookupController.retrieveRecords('Account', 'Id,Name', 'Name', 'Test' , ids);
    MultiSelectLookupController.retrieveRecords('Contact', 'Name,Email,Account.Name', 'Name', '' , contactIds);
}

}