@isTest
private class assignPermissionInSharepointFolderTest {



    @isTest static void testPermissionAssignment() {
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.closeDate = Date.today();
        objOpportunity.Name = 'Test Opportunity';
        //objOpportunity.OriginalName__c = 'Test Opportunity';
        objOpportunity.stageName = 'Draft';
        insert objOpportunity;
        
        objOpportunity = [SELECT  Id,CreatedById, CreatedDate,RecordType.Name,Office__c,Opportunity_Number__c,OriginalName__c FROM Opportunity];
        
        /*Test.StartTest();
            //Database.executeBatch(obj,25);
            Test.setMock(HttpCalloutMock.class, new MockHttpSharePointResponseGenerator());  
            
            assignPermissionInSharepointFolder bclass = new assignPermissionInSharepointFolder();  
            Database.executeBatch(bclass ,25);  
            Database.BatchableContext bc;
            
              MyIterable  itrbl = (MyIterable)bclass.start();  //start() returns an iterable, in my case, a custom iterable. Note the casting
              MyIterator  itrator = (MyIterator) itrbl.iterator();  // continue simulation of start() by constructing the iterator
              List<Opportunity> aScopeList = new List<Opportunity> ();      // create scope for execute() by iterating against the result of the mocked callout
              while (itrator.hasNext()) {
                 aScopeList.add(itrator.next());
              }   
            
            bClass.execute(bc,aScopeList);
            bClass.finish(bc);
            
            
         Test.stopTest();*/
         
        Test.startTest();
        Database.BatchableContext bc;
            Test.setMock(HttpCalloutMock.class, new MockHttpSharePointResponseGenerator());
            new assignPermissionInSharepointFolder().start(bc);
            new assignPermissionInSharepointFolder().execute(bc,new List<Opportunity>{objOpportunity});
            new assignPermissionInSharepointFolder().finish(bc);
        Test.stopTest();
    
    }
}