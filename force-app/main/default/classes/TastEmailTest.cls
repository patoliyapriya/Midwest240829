@isTest
private class TastEmailTest {
    static testMethod void TastEmailMethod() {
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.closedate = System.today();
        opp.StageName = 'Non Qualified';
        insert opp;
        
        TaskEmail objTaskEmail = new TaskEmail();
        objTaskEmail.strWhatId = opp.Id;
        objTaskEmail.getopportunityNumber();
    }
}