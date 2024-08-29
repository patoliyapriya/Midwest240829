public with sharing class AvalaraTaxServiceCustom {
    public static AcctSeed__Accounting_Settings__c avalaraSetting;
    public static String endPoint;
    public static AcctSeed__Accounting_Settings__c getavalaraSetting() {
        if(avalaraSetting == null) {
            avalaraSetting = [SELECT Id,
                                    AcctSeed__Avalara_Account_Id__c,
                                    AcctSeed__Avalara_License_Key__c,
                                    AcctSeed__Avalara_Production_Endpoint__c 
                                FROM AcctSeed__Accounting_Settings__c
                                LIMIT 1];
            system.debug('Query fired');
        } 
        return  avalaraSetting;
    }

    public AvalaraTaxServiceCustom () {
        getavalaraSetting();
        if (endPoint == null) {
            if(avalaraSetting.AcctSeed__Avalara_Production_Endpoint__c) {

            } else {
                endPoint = 'https://sandbox-rest.avatax.com';
            }
        }   
    }


    public static String createTransaction(AcctSeed__Billing__c billingSO, List<AcctSeed__Transaction__c> transactionList) {
        if (endPoint == null) {
            if(getavalaraSetting().AcctSeed__Avalara_Production_Endpoint__c) {

            } else {
                endPoint = 'https://sandbox-rest.avatax.com';
            }
        }
        string responseString = '';
        createTransactionRequest request = new createTransactionRequest();
        List<TransactionalLine> transactions = new List<TransactionalLine>();

        for(AcctSeed__Transaction__c transactionSO : transactionList) {
            TransactionalLine lineItem = new TransactionalLine();
            lineItem.itemNumber = transactionSO.AcctSeed__Billing_Line__r.Name;
            lineItem.quantity = transactionSO.AcctSeed__Billing_Line__r.AcctSeed__Hours_Units__c;
            lineItem.amount = transactionSO.AcctSeed__Billing_Line__r.AcctSeed__Total__c;
            lineItem.taxCode = transactionSO.AcctSeed__Billing_Line__r.AcctSeed__Product__r.AcctSeed__Tax_Code__c;
            lineItem.itemCode = transactionSO.AcctSeed__Billing_Line__r.Name;
            lineItem.description = transactionSO.AcctSeed__Billing_Line__r.AcctSeed__Product__r.Description;
            transactions.add(lineItem);
        }
        // assign trnasaction lines
        request.lines = transactions;

        // address detail
        addressStruct addressDetail = new addressStruct();
        addressDetail.city = billingSO.AcctSeed__Shipping_City__c;
        addressDetail.line1 = billingSO.AcctSeed__Shipping_Street__c;
        addressDetail.region = billingSO.AcctSeed__Shipping_State__c;
        //addressDetail.country = billingSO.AcctSeed__Shipping_Country__c;
        addressDetail.postalCode = billingSO.AcctSeed__Shipping_PostalCode__c;

        addresses addressSO = new addresses();
        addressSO.singleLocation = addressDetail;
        request.addresses = addressSO;

        request.code = billingSO.Name;
        request.companyCode = fetchCompanyCode(billingSO.AcctSeed__Opportunity__r.Office__c);
        request.transactionDate = billingSO.AcctSeed__Date__c;
        request.customerCode = billingSO.AcctSeed__Customer__c;
        //request.purchaseOrderNo = '2020-10-12-001';
        //request.description = 'Yarn';

        String requestBody = JSON.serializePretty(request, true);
        requestBody = requestBody.replace('"transactionDate"', '"Date"');
        requestBody = requestBody.replace('"IsCommit"', '"commit"');

  
        /*Attachment att=new Attachment();
        att.Body=Blob.valueOf(requestBody);
        att.Name='Note_' + System.now().format('yyyy_MM_dd_hh_mm_ss') + '.txt';
        att.parentId='0013J000007aoL2';
        insert att; */

        HttpRequest httpRequest = new HttpRequest();  
        httpRequest.setMethod('POST');   
        httpRequest.setBody(requestBody);
        httpRequest.setHeader('Authorization', 'Basic  '+convertToBase64());        
        httpRequest.setHeader('Accept', 'application/json'); 
        httpRequest.setHeader('Content-Type', 'application/json'); 
        httpRequest.setEndpoint(endPoint + '/api/v2/transactions/create');  
        httpRequest.setHeader('Content-Length', String.valueOf(requestBody.length()));  
        Http http = new Http();   
        HttpResponse httpResponse = http.send(httpRequest); 
        responseString = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );  
            
        System.debug(' httpResponse ' + httpResponse.getBody() );  
        if (httpResponse.getStatusCode() == 201 ) {  
            responseString = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );  
            
            System.debug(' httpResponse sucess' + httpResponse.getBody() );  
        } else {  
            System.debug(' httpResponse failed' + httpResponse.getBody() );  
            CalloutException e = new CalloutException();
            e.setMessage('Error in posting transaction.');
            throw e;
        }

        return responseString;
        
    }

    public static Decimal estimateTax(Decimal inputAmout, addressStruct address) {
        
        Decimal taxAmout = null;
        String taxRateEndPoint =  endPoint + '/api/v2/taxrates/byaddress?';
        if (address.postalCode != null) {

            taxRateEndPoint += 'postalCode=' + address.postalCode;
        } else {

            taxRateEndPoint += 'line1=' + address.line1;
            taxRateEndPoint += '&city=' + address.city;
            taxRateEndPoint += '&region=' + address.region;
        }
        taxRateEndPoint += '&country=US';
        taxRateEndPoint = taxRateEndPoint.replace(' ', '%20');
        HttpRequest httpRequest = new HttpRequest();  
        httpRequest.setMethod('GET');   
        httpRequest.setHeader('Authorization', 'Basic '+convertToBase64());        
        httpRequest.setEndpoint(taxRateEndPoint);  
        
        system.debug('taxRateEndPoint='+taxRateEndPoint);
        Http http = new Http(); 
        HttpResponse httpResponse = http.send(httpRequest); 
        if (httpResponse.getStatusCode() != 200) {
            CalloutException e = new CalloutException();
            e.setMessage('The address value was incomplete. You must provide either a valid postal code, line1 + city + region, or line1 + postal code.');
            throw e;
        }
        String responseString = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) ); 

        Map<String,Object>  responseMap = ( Map<String,Object>)JSON.deserializeUntyped(httpResponse.getBody());
        Decimal taxRate = Decimal.valueOf(String.valueOf(responseMap.get('totalRate')));
        system.debug('taxRate=='+taxRate);
        taxAmout = inputAmout * taxRate;
        taxAmout = taxAmout.setScale(2);
        System.debug('taxAmout='+taxAmout);
        return taxAmout;
    }

    public static void unPostTransaction(AcctSeed__Billing__c billingSO) {

        String requestBody = '{"code": "DocVoided"}';
        String companyCode = fetchCompanyCode(billingSO.AcctSeed__Opportunity__r.Office__c);
        String requestEndPoint = endPoint + '/api/v2/companies/' + companyCode + '/transactions/' + billingSO.Name + '/void';

        HttpRequest httpRequest = new HttpRequest();  
        httpRequest.setMethod('POST');   
        httpRequest.setBody(requestBody);
        httpRequest.setHeader('Authorization', 'Basic  '+convertToBase64());        
        httpRequest.setHeader('Accept', 'application/json'); 
        httpRequest.setHeader('Content-Type', 'application/json'); 
        httpRequest.setEndpoint(requestEndPoint);  
        httpRequest.setHeader('Content-Length', String.valueOf(requestBody.length()));  
        Http http = new Http();   
        HttpResponse httpResponse = http.send(httpRequest); 
        
        System.debug(' httpResponse ' + httpResponse.getBody() );  
        if (httpResponse.getStatusCode() == 200 ) {  
            System.debug(' httpResponse sucess' + httpResponse.getBody() );  
        } else {  
            System.debug(' httpResponse failed' + httpResponse.getBody() );  
            CalloutException e = new CalloutException();
            e.setMessage('Error in unPosting transaction.');
            throw e;
        }
    }

    public static string fetchCompanyCode(String officeName) {

        if (officeName == 'Midwest Machinery STL') {
            return 'DEFAULT';
        } else if (officeName == 'Midwest Machinery KC') {
            return 'MIDWESTMACHINERYKC';
        } else if (officeName == 'Midwest Machinery OK') {
            return '4992515';
 
        } else if (officeName == 'Engineered Products') {
            return 'EPL';
        } else if (officeName == 'MaRRS') {
            return 'DEFAULT';
        }
        return 'DEFAULT';
    }
    public static string convertToBase64(){
        avalaraSetting = getavalaraSetting();
        return EncodingUtil.base64Encode(Blob.valueof(avalaraSetting.AcctSeed__Avalara_Account_Id__c+':'+avalaraSetting.AcctSeed__Avalara_License_Key__c));
    }

    public class createTransactionRequest {
        public List<TransactionalLine> lines;
        public addresses addresses;
        public String code;
        public String type;
        public String companyCode;
        public date transactionDate;
        public String customerCode;
        public String purchaseOrderNo;
        public Boolean IsCommit;
        public String currencyCode;
        public String description;

        public createTransactionRequest() {
            lines = new List<TransactionalLine>();
            currencyCode = 'USD';
            type = 'SalesInvoice';
            IsCommit = true;
            description = 'Create or adjust transaction';
        }

    } 

    public class TransactionalLine {
        public String itemNumber;
        public Decimal quantity;
        public Decimal amount; 
        public String taxCode;
        public String description;
        public String itemCode;

        public TransactionalLine() {
            itemNumber = null;
            quantity = null;
            amount = null;
            description = null;
            itemCode = null;

        }
    }

    public class addresses {
        public addressStruct singleLocation;
        public addresses(){

        }
    }

    public class addressStruct {
        public string line1;
        public string city;
        public string region;
        public string country;
        public string postalCode;

        public addressStruct() {
            country = 'US';

        }
    }


}