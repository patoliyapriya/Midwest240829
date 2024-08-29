@isTest
private class SearchProductsControllerTest {
    static testMethod void testSearchQuoteLine() {
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.closeDate = Date.today();
        objOpportunity.Name = 'Test Opportunity';
        objOpportunity.stageName = 'TARGET/NEGOTIATING';
        insert objOpportunity;
        
        Datetime dt = System.now();
        String todayDay = dt.format('EEEE');
        Project__c newProject = new Project__c();
        newProject.Name = 'Test Project';
        newProject.Receipt_of_Order_Date__c = System.Now().Date();
        newProject.Opportunity__c = objOpportunity.Id;
        newProject.Schedule_On__c = todayDay;
        newProject.Schedule_End_Date__c = system.today();
        insert newProject;

        Quote newQuote = new Quote();
        newQuote.Name = 'Test Quote';
        newQuote.opportunityId = objOpportunity.Id;
        newQuote.Scope_Revision_Number__c = '01';
        newQuote.Submittal_Revision_Number__c = '01';
        insert newQuote;
        
        Product_Group__c objParentProductGroup = new Product_Group__c();
        objParentProductGroup.Name = 'Parent Group';
        objParentProductGroup.Quote__c = newQuote.Id;
        insert objParentProductGroup;
        
        Product_Group__c objChildProductGroup = new Product_Group__c();
        objChildProductGroup.Name = 'Parent Group';
        objChildProductGroup.Quote__c = newQuote.Id;
        objChildProductGroup.Parent_Product_Group__c = objParentProductGroup.Id;
        insert objChildProductGroup;
        
        Product_Select__c objParentLineItem = new Product_Select__c();
        objParentLineItem.Product_Name__c = 'Parent Product Name';
        objParentLineItem.Release_pick__c = '1.1';
        objParentLineItem.Quote__c = newQuote.Id;
        objParentLineItem.Product_Group__c = objChildProductGroup.Id;
        objParentLineItem.Serial_Number__c = 'TestSerail12';
        objParentLineItem.Warranty_End_Date__c = Date.today();
        insert objParentLineItem;
        
        Product_Select__c objChildLineItem = new Product_Select__c();
        objChildLineItem.Product_Name__c = 'Child Product Name';
        objChildLineItem.Quote__c = newQuote.Id;
        objParentLineItem.Release_pick__c = '2.1';
        objChildLineItem.Product_Group__c = objChildProductGroup.Id;
        objChildLineItem .Warranty_End_Date__c = Date.today().addDays(1);
        insert objChildLineItem;
        
        
        
        List<Product_Select__c> qls = [select id,Warranty_End_Date__c  from Product_Select__c ];
        system.debug(qls[0].Warranty_End_Date__c );
        system.debug(qls[1].Warranty_End_Date__c );
        
        
        SearchProductsController obj = new SearchProductsController();
        system.assertEquals(0,obj.quoteLineItems.Size());
        system.debug('Csize'+obj.quoteLineItems.Size());
        
        obj.SerialNumber = 'TestSer';
        obj.searchProducts();
        //system.assertEquals(1,obj.quoteLineItems.Size());
        
        /*obj.SerialNumber = '';
        obj.searchProducts();
        system.assertEquals(2,obj.quoteLineItems.Size());*/
        
    }        
}