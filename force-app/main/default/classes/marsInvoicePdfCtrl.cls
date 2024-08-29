public class marsInvoicePdfCtrl {
	Id billingId;
    public AcctSeed__Billing__c Billing;

    public marsInvoicePdfCtrl() {
        billingId = apexpages.currentpage().getparameters().get('id');
        Billing = [SELECT Id, Name From AcctSeed__Billing__c WHERE Id = :billingId];
    }
    
      public PageReference generateAttachment() {
            PageReference pdf = new PageReference('/apex/MarrsInvoicePdf2?Id='+billingId);
            
            Attachment billingPdf = new Attachment();
            billingPdf.Name = Billing.Name + ' | Accounting Seed.pdf';
            billingPdf.IsPrivate = false;
            billingPdf.ParentId = billingId;
            if(!Test.isRunningTest()){
                billingPdf.body = pdf.getContentAsPDF();
            }
            else{
                Blob content = Blob.valueOf('UNIT.TEST');
                billingPdf.body = content;
            }
            
            insert billingPdf;
            
            PageReference pr = new PageReference('/'+billingId);
            pr.setRedirect(true);
            return pr;
        
    }
}