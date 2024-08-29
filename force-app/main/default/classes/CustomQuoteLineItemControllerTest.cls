/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData=true)
private class CustomQuoteLineItemControllerTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        Pricebook2 standardPB = [select name, isactive from Pricebook2 where IsStandard = true limit 1];

        Pricebook2 prb= new Pricebook2(Name='Standard Price Book 2009',Description ='Price Book 2009 Products',IsActive = true);
        insert prb;
        
        Product2 pr = new Product2(Name='Connect Pro - Annual Fee',IsActive=true);
        insert pr;
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = pr.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        insert standardPrice;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = prb.Id, Product2Id = pr.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        insert pbe;
        
        Opportunity opp = new Opportunity(Name = 'Test Syndicated 2010', Type = 'Syndicated - New', StageName = 'Planning', CloseDate = system.today());
        insert opp;
        
        Quote quttest = new Quote (Name = 'qoutetest' , Pricebook2Id = prb.id, OpportunityId = opp.id,Scope_Revision_Number__c = '01',Submittal_Revision_Number__c = '01');
        insert quttest ;
        
        QuoteLineItem qutlineitemtest = new QuoteLineItem ();
        qutlineitemtest = new QuoteLineItem(QuoteId = quttest .id , Quantity = 3.00 ,UnitPrice = 12 ,Freight__c = 34, Margin_Percentage__c =1, PricebookEntryId = pbe.id,Multiplier__c = 2);
        insert qutlineitemtest;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(qutlineitemtest);
        //apexpages.currentpage().getparameters().put('quoteId') = quttest.Id;
        CustomQuoteLineItemCotroller objCustomQuoteLineItemCotroller = new CustomQuoteLineItemCotroller(sc);
        objCustomQuoteLineItemCotroller.CalculateSalesPrice();
        
        
        
    }
    
    static testMethod void myUnitTest1() {
        Pricebook2 standardPB = [select name, isactive from Pricebook2 where IsStandard = true limit 1];

        Pricebook2 prb= new Pricebook2(Name='Standard Price Book 2009',Description ='Price Book 2009 Products',IsActive = true);
        insert prb;
        
        Product2 pr = new Product2(Name='Connect Pro - Annual Fee',IsActive=true);
        insert pr;
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = pr.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        insert standardPrice;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = prb.Id, Product2Id = pr.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        insert pbe;
        
        Opportunity opp = new Opportunity(Name = 'Test Syndicated 2010', Type = 'Syndicated - New', StageName = 'Planning', CloseDate = system.today());
        insert opp;
        
        Quote quttest = new Quote (Name = 'qoutetest' , Pricebook2Id = prb.id, OpportunityId = opp.id,Scope_Revision_Number__c = '01',Submittal_Revision_Number__c = '01');
        insert quttest ;
        
        QuoteLineItem qutlineitemtest = new QuoteLineItem ();
        qutlineitemtest = new QuoteLineItem(QuoteId = quttest .id , Quantity = 3.00 ,UnitPrice = 12 ,Freight__c = 34, Margin_Percentage__c =1, PricebookEntryId = pbe.id,Multiplier__c = 2);
        insert qutlineitemtest;
        
        QuoteLineItem qutlineitemtest2 = new QuoteLineItem(QuoteId = quttest .id , Quantity = 3.00 ,UnitPrice = 12 ,Freight__c = 34, Margin_Percentage__c =1, PricebookEntryId = pbe.id,Multiplier__c = 2);
        insert qutlineitemtest2;
        
        apexpages.currentpage().getparameters().put('quoteId',quttest.Id);
        ApexPages.StandardController sc1 = new ApexPages.StandardController(quttest);
        
        CustomQuoteLineItemCotroller objCustomQuoteLineItemCotroller1 = new CustomQuoteLineItemCotroller(sc1);
        apexpages.currentpage().getparameters().put('quoteId',quttest.Id);
        objCustomQuoteLineItemCotroller1.CalculateSalesPrice();
        objCustomQuoteLineItemCotroller1.UpdateLineItems();
    }
    
}