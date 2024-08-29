/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 04-24-2024
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class CartWrapper {
    
    @AuraEnabled public QuoteWrapper quoteDetails;
    @AuraEnabled public List<GrpWrapper> groupDetails;
    @AuraEnabled public Boolean isMarrs;

    /**
    * @description : Constructor
    * @author Nilesh Badrakiya | 04-24-2024 
    * @param quote 
    **/
    public CartWrapper(Quote quote) {
        if (quote.RecordType.Name == 'MaRRS Quote') {
            this.isMarrs = true;
        }
        this.quoteDetails = new QuoteWrapper(quote);
        this.groupDetails = new List<GrpWrapper>();
    }
}