public with sharing class GeneratePdfOnQuoteController {
public Boolean displayPopup {get; set;}     
public String fileName {get; set;}
public Id quoteId;   
public Quote quoteRecord {get;set;}
public String type; 
public String isfrom;
    public GeneratePdfOnQuoteController(Apexpages.StandardController stdCont){
        quoteId = stdCont.getId();
        quoteRecord = [Select 
                       Id, 
                       Name,
                       Opportunity_Number__c,
                       Opportunity_Name__c,
                       QuoteNumber,
                       Revision__c,
                       Bid_Date__c
                       From Quote Where Id =: quoteId];
        type = apexpages.currentpage().getparameters().get('type');
        isfrom = apexpages.currentpage().getparameters().get('isfrom');
        showPopup();
    }
         
    public PageReference createFile() {
        String redirectPageName;
        
        Switch on type {
            When 'quote' {
                redirectPageName = '/apex/GenerateQuotes?quoteType=quote';
            }
            When 'scope' {
                redirectPageName = '/apex/GenerateScopePDF';
            }
            When 'marrs' {
                redirectPageName = '/apex/GenerateQuotes?quoteType=marrs';
            }
        }
        
        PageReference createPdf = new PageReference(redirectPageName);
        createPdf.getParameters().put('id',quoteId);
        createPdf.getParameters().put('type','pdf');
        createPdf.getParameters().put('biddate',String.valueOf(quoteRecord.Bid_Date__c.format()));
        createPdf.getParameters().put('fileName',fileName+'.pdf');
        createPdf.setRedirect(true);
        return createPdf;        
    }
    public PageReference closePopup() {        
        displayPopup = false;
        PageReference pr;
        if(isfrom == 'designQuoteHeaderController') {
            pr = new PageReference('/lightning/cmp/c__RedirectToQuoteTool?c__quoteId='+quoteId);
        }
        else {
            pr = new PageReference('/'+quoteId);
        }
        
        pr.setRedirect(true);
        return pr;    
    }     
    public void showPopup() {
         Switch on type
        {
            When 'quote'
            {
                fileName = quoteRecord.Name +
                ' Quote';
                if (quoteRecord.Revision__c != null && quoteRecord.Revision__c.trim() != ''){
                    fileName += '-'+quoteRecord.Revision__c; 
                }
            }
            When 'scope'
            {
                fileName = quoteRecord.Name +
                ' Scope';
                if (quoteRecord.Revision__c != null && quoteRecord.Revision__c.trim() != ''){
                    fileName += '-'+quoteRecord.Revision__c; 
                }
            }
            When 'marrs'
            {
                fileName = quoteRecord.Name +
                ' Quote';
            }
        /*    When 'submittal'
            {
                fileName = quoteRecord.Opportunity_Number__c+'.'+
                quoteRecord.QuoteNumber+'-'+
                quoteRecord.Opportunity_Name__c+
                ' Submittal';
            }*/
        }
                
        displayPopup = true;    
    }

}