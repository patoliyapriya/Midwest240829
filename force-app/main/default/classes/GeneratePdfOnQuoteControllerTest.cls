@isTest
Private class GeneratePdfOnQuoteControllerTest {
    
     static testMethod void Testmethod1(){
        RecordType oppType = [SELECT ID,Name From RecordType WHERE Name =: 'Equipment'];
         
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.closeDate = Date.today();
        objOpportunity.Name = 'Test Opportunity';
        objOpportunity.stageName = 'Draft';
        objOpportunity.RecordTypeId =oppType.Id;
        insert objOpportunity;
        
        Quote newQuote = new Quote();
        newQuote.Name = 'Test Quote';
        newQuote.opportunityId = objOpportunity.Id;
        newQuote.Scope_Revision_Number__c = '01';
        newQuote.Submittal_Revision_Number__c = '01';
        newQuote.Bid_Date__c = Date.Today();
        insert newQuote;
            
        Test.StartTest();
           
        PageReference pageRef = Page.GeneratePdfOnQuote;
         Test.setCurrentPage(pageRef);
         pageRef.getParameters().put('id',newQuote.id);
        pageRef.getParameters().put('type','quote');
        
        ApexPages.StandardController sc = new ApexPages.StandardController(newQuote);
        GeneratePdfOnQuoteController Testobj = New GeneratePdfOnQuoteController(sc);

        Testobj.createFile();
         
         PageReference pageRef1 = Page.GeneratePdfOnQuote;
         Test.setCurrentPage(pageRef1);
         pageRef1.getParameters().put('id',newQuote.id);
        pageRef1.getParameters().put('type','scope');
         
         ApexPages.StandardController sc1 = new ApexPages.StandardController(newQuote);
        GeneratePdfOnQuoteController Testobj1 = New GeneratePdfOnQuoteController(sc1);

         Testobj1.createFile();
        
        /*pageRef.getParameters().put('id',newQuote.id);
        pageRef.getParameters().put('type','scope');
         Test.setCurrentPage(pageRef);
        Testobj.createFile();*/

         Testobj.closepopup();
         
        Test.StopTest();
        
    }

}