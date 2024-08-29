public with sharing class PostUnPostTransactionCtrl {
    public Boolean showActionButton {get;set;}
    public Boolean showForecastSection {get;set;}
    public Boolean isPost {get;set;}
    public Boolean isUnPostEnabled {get;set;}
    public AcctSeed__Billing__c billingSO;
    public List<AcctSeed__Transaction__c> forecastedTransactions{get;set;}
    public List<AcctSeed__Transaction__c> forecastedTransactionsToPost = new  List<AcctSeed__Transaction__c>();
    public AcctSeed__Billing_Line__c taxBillingLine1;

    public PostUnPostTransactionCtrl(Apexpages.standardController controller) {
        isPost = Boolean.valueOf(ApexPages.currentPage().getParameters().get('isPost'));
        forecastedTransactions = new List<AcctSeed__Transaction__c>();
        billingSO = [SELECT Id,
                            Name,
                            AcctSeed__Shipping_City__c,
                            AcctSeed__Shipping_Country__c,
                            AcctSeed__Shipping_PostalCode__c,
                            AcctSeed__Shipping_State__c,
                            AcctSeed__Shipping_Street__c,
                            AcctSeed__Total__c,
                            AcctSeed__Accounting_Period__c,
                            AcctSeed__Customer__c,
                            AcctSeed__Ledger__c,
                            AcctSeed__Status__c,
                            AcctSeed__Date__c,
                            AcctSeed__Opportunity__r.Office__c,
                            Posting_Status__c
                    FROM AcctSeed__Billing__c
                    WHERE Id = :controller.getId()
                    LIMIT 1];

    }


    public Pagereference post() {
        AvalaraTaxServiceCustom.createTransactionRequest request = new AvalaraTaxServiceCustom.createTransactionRequest();

        // create list of lines

        for(AcctSeed__Transaction__c transactionSO : forecastedTransactions) {

        }
        List<AvalaraTaxServiceCustom.TransactionalLine> transactionLines = new List<AvalaraTaxServiceCustom.TransactionalLine> ();
        try {
            AvalaraTaxServiceCustom.createTransaction(billingSO, forecastedTransactionsToPost);
        } catch(Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,e.getMessage()));
            return null;
        }

        insert taxBillingLine1;
        //insert forecastedTransactions;

        //billingSO.Is_Posted__c = true;
        billingSO.Posting_Status__c = 'Posted';
        update billingSO;
        Pagereference billingPage = new Pagereference('/'+billingSO.Id);
        billingPage.setRedirect(true);
        return billingPage;
        
    }

    public Pagereference unPost () {

        try {
            AvalaraTaxServiceCustom intialize = new AvalaraTaxServiceCustom();
            AvalaraTaxServiceCustom.unPostTransaction(billingSO);
        } catch(Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,e.getMessage()));
            return null;
        }
        List<AcctSeed__Billing_Line__c> taxBillingLines = new List<AcctSeed__Billing_Line__c>();
        taxBillingLines = [SELECT Id FROM AcctSeed__Billing_Line__c
                            WHERE AcctSeed__Billing__c = :billingSO.Id
                            AND AcctSeed__Tax_Line__c = true];
        
        if (!taxBillingLines.isEmpty()) {
            delete taxBillingLines;
        }
        billingSO.Posting_Status__c = 'UnPosted';
        update billingSO;
        showForecastSection = false;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Transactions successfully unposted'));
        Pagereference billingPage = new Pagereference('/'+billingSO.Id);
        billingPage.setRedirect(true);
        //return billingPage;
        return null;
    }

    public Pagereference cancel() {

        Pagereference billingPage = new Pagereference('/'+billingSO.Id);
        billingPage.setRedirect(true);
        return billingPage;
    }

    public Pagereference validateBeforePost() {
        Integer bilingLineCount = [SELECT Count() 
                                    FROM AcctSeed__Billing_Line__c 
                                    WHERE AcctSeed__Billing__c = :billingSO.Id];
        if (bilingLineCount == 0) {
            showForecastSection = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'There are no line items to post / unpost'));
            return null;                 
        }
        if (isPost) {
            
            if (billingSO.Posting_Status__c == 'Posted') {
                showForecastSection = false;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'The record has already been posted.'));
                return null;            
            }

            if (billingSO.AcctSeed__Opportunity__r.Office__c == null || billingSO.AcctSeed__Opportunity__r.Office__c == '') {
                showForecastSection = false;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please provide office location in opportunity'));
                return null;            
            }
            // estimate the tax
            AvalaraTaxServiceCustom av = new AvalaraTaxServiceCustom();
            AvalaraTaxServiceCustom.addressStruct addressDetail = new AvalaraTaxServiceCustom.addressStruct();
            addressDetail.city = billingSO.AcctSeed__Shipping_City__c;
            addressDetail.line1 = billingSO.AcctSeed__Shipping_Street__c;
            addressDetail.region = billingSO.AcctSeed__Shipping_State__c;
            addressDetail.country = billingSO.AcctSeed__Shipping_Country__c;
            addressDetail.postalCode = billingSO.AcctSeed__Shipping_PostalCode__c;

            decimal taxAmount = null;
            try {
                taxAmount = AvalaraTaxServiceCustom.estimateTax(billingSO.AcctSeed__Total__c,addressDetail);
            } catch(Exception e) {
                showForecastSection = false;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,e.getMessage()));
                return null;
                
            }
            List<AcctSeed__Billing_Line__c> billingLines = [SELECT Id,
                                                                    Name,
                                                                AcctSeed__Hours_Units__c,
                                                                AcctSeed__Total__c,
                                                                AcctSeed__Billing__r.Name,
                                                                AcctSeed__Product__r.Description,
                                                                AcctSeed__Product__c,
                                                                AcctSeed__Product__r.ProductCode,
                                                                AcctSeed__Product__r.AcctSeed__Tax_Code__c,
                                                                AcctSeed__Revenue_GL_Account__c,
                                                                AcctSeed__Date__c,
                                                                AcctSeed__Tax_Line__c
                                                            FROM AcctSeed__Billing_Line__c
                                                            WHERE AcctSeed__Billing__c = :billingSO.Id];

            List<AcctSeed__GL_Account__c> GLAccounts = [SELECT Id 
                                                        FROM AcctSeed__GL_Account__c
                                                        WHERE Name IN ('105-01 Accounts Receivable - Trade',
                                                                        '225-00 Sales Tax Payable')];   
            Map<String,Id> GLAccountMaps = new Map<String,Id>();
            for (AcctSeed__GL_Account__c glAccount :GLAccounts) {
                GLAccountMaps.put(glAccount.Name, glAccount.Id);
            }

            for(AcctSeed__Billing_Line__c billingLineSO : billingLines) {

                //create transaction for rev
                AcctSeed__Transaction__c rev_Transaction = new AcctSeed__Transaction__c();
                rev_Transaction.AcctSeed__GL_Account__c = billingLineSO.AcctSeed__Revenue_GL_Account__c;
                rev_Transaction.AcctSeed__Billing_Line__c = billingLineSO.Id;
                rev_Transaction.AcctSeed__Billing_Line__r = billingLineSO;
                rev_Transaction.AcctSeed__Product__c = billingLineSO.AcctSeed__Product__c;
                rev_Transaction.AcctSeed__Account__c = billingSO.AcctSeed__Customer__c;
                rev_Transaction.AcctSeed__Accounting_Period__c = billingSO.AcctSeed__Accounting_Period__c;
                rev_Transaction.AcctSeed__Amount__c =  billingLineSO.AcctSeed__Total__c * (-1);
                rev_Transaction.AcctSeed__Units__c =  billingLineSO.AcctSeed__Hours_Units__c * (-1);
                rev_Transaction.AcctSeed__Note__c = billingSO.Name;
                rev_Transaction.AcctSeed__Ledger__c = billingSO.AcctSeed__Ledger__c;
                rev_Transaction.AcctSeed__Date__c = billingLineSO.AcctSeed__Date__c;
                

                AcctSeed__Transaction__c BalanceSheet_Transaction = new AcctSeed__Transaction__c();
                BalanceSheet_Transaction = rev_Transaction.clone(false,false,false,false);
                BalanceSheet_Transaction.AcctSeed__Amount__c = BalanceSheet_Transaction.AcctSeed__Amount__c * (-1);
                BalanceSheet_Transaction.AcctSeed__Units__c = BalanceSheet_Transaction.AcctSeed__Units__c * (-1);
                BalanceSheet_Transaction.AcctSeed__GL_Account__c = 'a1N3J0000006mTt';
                
                forecastedTransactions.add(BalanceSheet_Transaction);
                forecastedTransactions.add(rev_Transaction);

                if (billingLineSO.AcctSeed__Tax_Line__c == false) {
                    forecastedTransactionsToPost.add(BalanceSheet_Transaction);
                }
                
                showForecastSection = true;
                showActionButton= true;
            }       
            if(taxAmount != null) {
                Product2 AvalaraTax = [SELECT Id,
                                            AcctSeed__Expense_GL_Account__c,
                                            AcctSeed__Revenue_GL_Account__c,
                                            Description,
                                            Product_Description__c
                                        FROM Product2
                                        WHERE Name = 'Avalara Tax'
                                        AND ProductCode = 'AVATAX'
                                        LIMIT 1];
                
                taxBillingLine1 = new AcctSeed__Billing_Line__c();
                taxBillingLine1.AcctSeed__Tax_Line__c = true;
                taxBillingLine1.AcctSeed__Hours_Units__c = 1;
                taxBillingLine1.AcctSeed__Rate__c = taxAmount;
                taxBillingLine1.AcctSeed__Date__c = billingSO.AcctSeed__Date__c;
                taxBillingLine1.AcctSeed__Expense_GL_Account__c = AvalaraTax.AcctSeed__Expense_GL_Account__c;
                taxBillingLine1.AcctSeed__Revenue_GL_Account__c = AvalaraTax.AcctSeed__Revenue_GL_Account__c;
                taxBillingLine1.AcctSeed__Billing__c = billingSO.Id;
                taxBillingLine1.AcctSeed__Product__c = AvalaraTax.Id;

                // create transactions
                AcctSeed__Transaction__c tax_rev_Transaction = new AcctSeed__Transaction__c();
                if(billingSO.AcctSeed__Opportunity__r.Office__c == 'Midwest Machinery KC') {
                    tax_rev_Transaction.AcctSeed__GL_Account__c = GLAccountMaps.get('105-01 Accounts Receivable - Trade');
                } else {
                    tax_rev_Transaction.AcctSeed__GL_Account__c = taxBillingLine1.AcctSeed__Revenue_GL_Account__c;
                }
                
                //tax_rev_Transaction.AcctSeed__Billing_Line__c = billingLineSO.Id;
                //tax_rev_Transaction.AcctSeed__Billing_Line__r = billingLineSO;
                tax_rev_Transaction.AcctSeed__Product__c = taxBillingLine1.AcctSeed__Product__c;
                tax_rev_Transaction.AcctSeed__Account__c = billingSO.AcctSeed__Customer__c;
                tax_rev_Transaction.AcctSeed__Accounting_Period__c = billingSO.AcctSeed__Accounting_Period__c;
                tax_rev_Transaction.AcctSeed__Amount__c =  taxAmount * (-1);
                tax_rev_Transaction.AcctSeed__Units__c =  taxAmount * (-1);
                tax_rev_Transaction.AcctSeed__Note__c = billingSO.Name;
                tax_rev_Transaction.AcctSeed__Ledger__c = billingSO.AcctSeed__Ledger__c;
                tax_rev_Transaction.AcctSeed__Date__c = taxBillingLine1.AcctSeed__Date__c;

                AcctSeed__Transaction__c tax_BalanceSheet_Transaction = new AcctSeed__Transaction__c();
                tax_BalanceSheet_Transaction = tax_rev_Transaction.clone(false,false,false,false);
                tax_BalanceSheet_Transaction.AcctSeed__Amount__c = tax_rev_Transaction.AcctSeed__Amount__c * (-1);
                tax_BalanceSheet_Transaction.AcctSeed__Units__c = tax_rev_Transaction.AcctSeed__Units__c * (-1);
                if(billingSO.AcctSeed__Opportunity__r.Office__c == 'Midwest Machinery KC') {
                    tax_BalanceSheet_Transaction.AcctSeed__GL_Account__c = GLAccountMaps.get('225-00 Sales Tax Payable');
                } else {
                    tax_BalanceSheet_Transaction.AcctSeed__GL_Account__c = 'a1N3J0000006mTt';
                }
                
                forecastedTransactions.add(tax_BalanceSheet_Transaction);
                forecastedTransactions.add(tax_rev_Transaction);
            }
        } else {
            if(billingSO.Posting_Status__c == 'UnPosted') {
                showForecastSection = false;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'No transactions found to unPost'));
                return null;                 
            }
            if(billingSO.Posting_Status__c != 'Posted') {
                showForecastSection = false;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'The billing is not posted yet'));
                return null;                 
            }
            forecastedTransactions = [SELECT Id,
                                            Name,
                                            AcctSeed__Ledger__c,
                                            AcctSeed__GL_Account__c,
                                            AcctSeed__Amount__c,
                                            AcctSeed__Project__c,
                                            AcctSeed__Project_Task__c,
                                            AcctSeed__GL_Account_Variable_1__c,
                                            AcctSeed__GL_Account_Variable_2__c,
                                            AcctSeed__GL_Account_Variable_3__c,
                                            AcctSeed__GL_Account_Variable_4__c,
                                            AcctSeed__Product__c
                                        FROM AcctSeed__Transaction__c
                                        WHERE AcctSeed__Billing_Line__r.AcctSeed__Billing__c = :billingSO.Id];


            showForecastSection = true;          
        }
        
        return null;
    }


}