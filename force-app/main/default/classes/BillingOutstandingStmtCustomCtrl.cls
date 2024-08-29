public with sharing class BillingOutstandingStmtCustomCtrl {
public Boolean isEP {get;set;}  // Enginnering product
public String AddressLine1 {get;set;}
public String AddressLine2 {get;set;}
public String AddressLine3 {get;set;}
public AcctSeed__Ledger__c ledgerlst = new AcctSeed__Ledger__c ();

  //No need to use this controller beacuse directly we current added new Billing Outstanding Statement - EP 
  // in PDF Format in production for Log and Address
    public BillingOutstandingStmtCustomCtrl(){
        
    }

    public BillingOutstandingStmtCustomCtrl(Apexpages.standardController stdCon) {
        Id ledgerId  = apexpages.currentpage().getparameters().get('ledgerId');
        system.debug('ledger id: '+ledgerId);
        if(ledgerId != null){
            system.debug('Inside if');
            try {
                ledgerlst = [SELECT Id, Name FROM AcctSeed__Ledger__c WHERE Id = :ledgerId]; 
                system.debug('After query: '+ledgerlst);
                if(ledgerlst.Name == 'Engineered Products LLC') {
                    system.debug('Inside Engineered Products: '+ledgerlst.Name);
                    isEP = true;
                    AddressLine1 = 'Engineered Products';
                    AddressLine2 = '301 Commercial Rd, ';   
                    AddressLine3 = 'Suite D  Golden,CO 80401';
                }else{
                    system.debug('Inside else');
                    isEP = false;
                }
            } catch (Exception e) {
                system.debug('Inside catch exception: '+e);
            }
        }
    }
}