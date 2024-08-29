@isTest
private class BiddersNameTriggerTest {
    static testMethod void testBiddersName() {
        
        Account newAcc = new Account();
        newAcc.Name = 'Test Account';
        insert newAcc;

        Contact con = new Contact();
        con.FirstName ='TestFname';
        con.LastName = 'LastNm';
        con.Email = 'SA@test.com';
        insert con; 
        
        Opportunity newOpp = new Opportunity();
        newOpp.Name = 'Test Opportunity';
        newOpp.StageName = 'Open';
        newOpp.CloseDate = Date.Today();
        newOpp.Mechanical_Contractor_1__c = newAcc.Id;
        newOpp.Mechanical_Contractor_2__c = newAcc.Id;
        newOpp.Mechanical_Contractor_3__c = newAcc.Id;
        newOpp.Mechanical_Contractor_4__c = newAcc.Id;
        newOpp.Mechanical_Contractor_5__c = newAcc.Id;
        newOpp.Mechanical_Contractor_6__c = newAcc.Id;
        newOpp.Mechanical_Contractor_7__c = newAcc.Id;
        newOpp.Mechanical_Contractor_8__c = newAcc.Id;
        newOpp.Mechanical_Contractor_9__c = newAcc.Id;
        newOpp.Mechanical_Contractor_10__c = newAcc.Id;
        newOpp.Consulting_Engineer_Contact_Person__c = con.Id;
        newOpp.Opportunity_Owner__c = UserInfo.getUserId();
        insert newOpp;
    }
}