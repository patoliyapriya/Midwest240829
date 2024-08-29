@isTest
private class STLDashboardTest{
    
    static testMethod void testSTLDashboard() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
         User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, Office_Location__c = 'Saint Louis',
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduserSTLDB@testorg.com');
        
        //insert u; 
        
        Test.StartTest();
         Id equipmentRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Equipment').getRecordTypeId();
        // create opportunity
        Opportunity objOpportunity = new Opportunity(closeDate = Date.today(),
                                                    Name = 'Test Opportunity',
                                                    stageName = 'TARGET/NEGOTIATING',
                                                    recordTypeId = equipmentRecordTypeId);
        
        insert objOpportunity;
        
        
        // create sales rep
        Sales_Representative__c rep = new Sales_Representative__c();
        rep.Opportunity__c = objOpportunity.Id;
        rep.Sales_Rep__c = UserInfo.getUserId();
        insert rep;   
        
        
        STLDashboard objSTLDashboard = new STLDashboard();
        Test.StopTest();
    }

}