/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class NewQuoteTest {

    static testMethod void testMethod1() { 

        Opportunity objOpportunity = new Opportunity();
        objOpportunity.closeDate = Date.today();
        objOpportunity.Name = 'Test Opportunity';
        objOpportunity.stageName = 'Draft';
        objOpportunity.Application_Engineer__c = UserInfo.getUserId();
        insert objOpportunity;

        Quote objQuote = new Quote();
        objQuote.Name = 'Test Quote';
        objQuote.opportunityId = objOpportunity.Id;
        objQuote.Scope_Revision_Number__c = '01';
        objQuote.Submittal_Revision_Number__c = '01';
        insert objQuote;
        
        String updatedQuoteName = 'Update Name';
        
        Boolean splitEngineer = NewQuote.getSplitEngineer(objOpportunity.Id);
        NewQuote.getOpportunity(objOpportunity.Id);
        NewQuote.updateQuote(objQuote.Name,updatedQuoteName,objQuote.Id);
        NewQuote.deleteQuote(objQuote.Id);
        
        String jsonWrap = '{"quoteDate": "2024-06-12","quoteSubmittedByC": "005O1000005pdndIAA","quotePreparedByUser": "005O1000005pdndIAA","quoteBiddingToC": "003O100000CnIszIAF","quoteName": "24-1357 - test345 - 6/3/2024, 2:41:05 PM","qutRecordTypeName": "Parts Quote","qutaAttentionToAccount": "001O1000009OGRjIAO","oppId": "006O1000007aFSjIAM"}';
        NewQuote.insertQuote(jsonWrap);
    }

    static testMethod void testMethod2() { 

        Opportunity objOpportunity = new Opportunity();
        objOpportunity.closeDate = Date.today();
        objOpportunity.Name = 'Test Opportunity Marrs';
        objOpportunity.stageName = 'Draft';
        objOpportunity.Application_Engineer__c = UserInfo.getUserId();
        insert objOpportunity;

        Quote objQuote = new Quote();
        objQuote.Name = 'Test Quote 2';
        objQuote.opportunityId = objOpportunity.Id;
        objQuote.Scope_Revision_Number__c = '01';
        objQuote.Submittal_Revision_Number__c = '01';
        insert objQuote;
        
        String updatedQuoteName = 'Update Name';
        
        Boolean splitEngineer = NewQuote.getSplitEngineer(objOpportunity.Id);
        NewQuote.getOpportunity(objOpportunity.Id);
        NewQuote.updateQuote(objQuote.Name,updatedQuoteName,objQuote.Id);
        NewQuote.deleteQuote(objQuote.Id);
        
        String jsonWrap = '{"quoteDate": "2024-06-12","quoteSubmittedByC": "005O1000005pdndIAA","quotePreparedByUser": "005O1000005pdndIAA","quoteBiddingToC": "003O100000CnIszIAF","quoteName": "24-1357 - test345 - 6/3/2024, 2:41:05 PM","qutRecordTypeName": "MaRRS Quote","qutaAttentionToAccount": "001O1000009OGRjIAO","oppId": "006O1000007aFSjIAM"}';
        NewQuote.insertQuote(jsonWrap);
    }
}