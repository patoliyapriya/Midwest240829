public with sharing class BillingPdfPreviewCtrl {
    public String selectedOrgWideEmailAddress {get; set;}
    //public AcctSeed__Billing__c billing {get;set;}
    public AcctSeed__Billing__c billingSO {get;set;}
    public Boolean sendccUser {get; set;}
    public String ccAddresses {get;set;}
    public String pdfName{get;set;}
    public String emailBody{get;set;}
    public String emailsubject{get;set;}
    public Id billingId;
    public String EmailSelectorLink {get;set;}
    public Boolean showSendEmail{get;set;}
    public Boolean showSendContactError{get;set;}
    public Contact ContactSO{get;set;}
    public EmailTemplate emailTemplateSO;
    public EmailTemplate emailTemplateEP;
    public String emailDeveloperName = 'Engineered_Product_Billing_Email_Template';
    public Boolean displayPopUp{get;set;}
    public Blob fileData{get;set;}
    public String fileName{get;set;}
    public Integer fileSize{get;set;}
    public Boolean isFileSizeLimitExceeded{get;set;}
    public String fileSizeLimitErrorMessage{get;set;}
    public List<CustomFileStruct> attachmetsWrapperList{get;set;}
    //private List<Attachment> emialAttachments = new List<Attachment>();
    public Boolean ShowAttachments{get;set;}
    public List<Id> attachmentIds = new List<Id>();

    public Attachment uploadFile {
        get {
        if (uploadFile == null)
        uploadFile = new Attachment();
        return uploadFile;
        }
        set;
        }

    public BillingPdfPreviewCtrl() {

    }

    public BillingPdfPreviewCtrl(Apexpages.standardController stdCon){
        attachmetsWrapperList = new List<CustomFileStruct>();
        emailTemplateSO = new EmailTemplate();
        emailTemplateEP = new EmailTemplate();
        EmailSelectorLink = 'https://midwest--quoting--c.cs124.visual.force.com/apex/AcctSeed__EmailFileSelector?entityId=a153J0000006XhVQAU&stmMode=billing';
        pdfName = System.URL.getSalesforceBaseUrl().toExternalForm() + '/apex/MarrsInvoicePdf2';
        //billing = new AcctSeed__Billing__c();
        billingId = apexpages.currentpage().getparameters().get('id');
        billingSO =[SELECT Id,Name, Invoice_Number__c, // Added Invoice_Number__c to get invoice in query
                        AcctSeed__Billing_Contact__c,
                        AcctSeed__Billing_Format__c,
                        AcctSeed__Opportunity__r.Office__c
                    From AcctSeed__Billing__c WHERE Id = :billingId];
        //billing.AcctSeed__Billing_Contact__c = billingSO.AcctSeed__Billing_Contact__c;
        //billing.Id = billingId;
        if(billingSO.AcctSeed__Billing_Contact__c != null) {
            
            ContactSO = [SELECT Id,Email FROM Contact WHERE Id = :billingSO.AcctSeed__Billing_Contact__c Limit 1];
            if(ContactSO.Email != null && ContactSO.Email != '') {
                showSendEmail = true;
                showSendContactError = false;  
            } else {
                showSendEmail = false;
                showSendContactError = true;               
            }
        } else {
            showSendEmail = false;
        }
        AcctSeed__Billing_Format__c pdfFormateSO = [SELECT Id,
                                                        AcctSeed__Default_Email_Template__c
                                                    FROM AcctSeed__Billing_Format__c
                                                    WHERE Id = :billingSO.AcctSeed__Billing_Format__c];
        emailTemplateSO = [SELECT Id,
                                Subject,
                                Description,
                                HtmlValue,
                                DeveloperName,
                                Body 
                            FROM EmailTemplate 
                            WHERE DeveloperName = :pdfFormateSO.AcctSeed__Default_Email_Template__c];

        // fetch preview email subject
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTemplateSO.Id, billingSO.AcctSeed__Billing_Contact__c, billingSO.Id);
        // Only for Engineered Products 
        if (billingSO.AcctSeed__Opportunity__r.Office__c == 'Engineered Products') {
            emailTemplateEP = [SELECT Id,
                                Subject,
                                Description,
                                HtmlValue,
                                DeveloperName,
                                Body 
                            FROM EmailTemplate 
                            WHERE DeveloperName = :emailDeveloperName];
            Messaging.SingleEmailMessage emailEngineeredProducts = Messaging.renderStoredEmailTemplate(emailTemplateEP.Id, billingSO.AcctSeed__Billing_Contact__c, billingSO.Id);
            emailsubject = emailEngineeredProducts.getSubject();
        } 
         else {
            emailsubject = email.getSubject();
        }

        // Fetch preview email body
        List<String> emailRawbodies;
        if(billingSO.AcctSeed__Opportunity__r.Office__c == 'Engineered Products'){
            emailRawbodies = new List<String>{emailTemplateEP.Body};
        }else{
            emailRawbodies = new List<String>{emailTemplateSO.Body};
        }
        List<Messaging.RenderEmailTemplateBodyResult> result = Messaging.renderEmailTemplate(billingSO.AcctSeed__Billing_Contact__c, billingSO.Id, emailRawbodies);
        if (result != null && !result.isEmpty()) {
            emailBody = result[0].getMergedBody();
        }


        // ORGIGINAL
        // List<String> emailRawbodies = new List<String>{emailTemplateSO.Body};
        // List<Messaging.RenderEmailTemplateBodyResult> result = Messaging.renderEmailTemplate(billingSO.AcctSeed__Billing_Contact__c, billingSO.Id, emailRawbodies);
        // if (result != null && !result.isEmpty()) {
        //     emailBody = result[0].getMergedBody();
        // }

    }

    public List<SelectOption> getOrgWideEmailSelectOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(UserInfo.getUserEmail(),UserInfo.getUserEmail()));
        for(OrgWideEmailAddress orgWideAddressSO : [SELECT Id, 
                                                            Address,
                                                            DisplayName 
                                                    FROM OrgWideEmailAddress]) {
            system.debug('before error');
            String addressWithName = orgWideAddressSO.DisplayName + ' '+orgWideAddressSO.Address; 
            options.add(new SelectOption(orgWideAddressSO.Address,addressWithName));
                                                        
        }
       
        if (billingSO!= null 
            && billingSO.AcctSeed__Opportunity__c != null 
            && billingSO.AcctSeed__Opportunity__r.Office__c == 'Engineered Products') {
            // show  this email only when billingSO.AcctSeed__Opportunity__r.Office__c == 'Engineered Products'

            options.add(new SelectOption('jgerlemann@engineeredproducts.com',' jgerlemann@engineeredproducts.com'));
        }
        return options;
    }

    public Pagereference saveAttach() {
        System.debug('saveAttach execution starts');
        PageReference pdf = new PageReference('/apex/MarrsInvoicePdf2?Id='+billingId);
            
        Attachment billingPdf = new Attachment();
        billingPdf.Name = billingSO.Name + ' | Accounting Seed.pdf';
        billingPdf.IsPrivate = false;
        billingPdf.ParentId = billingId;
        if(!Test.isRunningTest()){
            billingPdf.body = pdf.getContentAsPDF();
        }
        else{
            Blob content = Blob.valueOf('UNIT.TEST');
            billingPdf.body = content;
        }
        System.debug('saveAttach execution ends'+billingPdf);
        insert billingPdf;
        return null;
    }

    public Void saveAndEmail() {
        List<String> ccAddress = new List<String>();
        if(ccAddresses != null && ccAddresses != '') {
            ccAddress = ccAddresses.split(',');
        }

        // construct Email
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(billingSO.AcctSeed__Billing_Contact__c); 
        //message.setSenderDisplayName(‘Company Support’); 
        //message.setReplyTo(‘no-reply@company.com’);
        //message.setUseSignature(false); 
        //message.setBccSender(false); 
        //message.setSaveAsActivity(false); 
        message.setToAddresses(new List<String>{ContactSO.Email});
        if (Test.isRunningTest() || sendccUser) {
            ccAddress.add(UserInfo.getUserEmail());
            
        }
        system.debug('ccAddress==>'+ccAddress);
        if (!ccAddress.isEmpty() && ccAddress.size()>0) {
            system.debug('in side if ccAddress==>'+ccAddress);
            message.setCcAddresses(ccAddress);
        }

        //message.setTemplateID(emailTemplateSO.Id); 
        //message.setWhatId(billingId);
        message.setPlainTextBody(emailBody);
        message.setSubject(emailsubject);
        // insert attachment
        PageReference pdf = new PageReference('/apex/MarrsInvoicePdf2?Id='+billingId);
        Attachment billingPdf = new Attachment();
        billingPdf.Name = billingSO.Name + ' | Accounting Seed.pdf';
        billingPdf.IsPrivate = false;
        billingPdf.ParentId = billingId;
        if(!Test.isRunningTest()){
            billingPdf.body = pdf.getContentAsPDF();
        }
        else{
            Blob content = Blob.valueOf('UNIT.TEST');
            billingPdf.body = content;
        }
        System.debug('saveAttach execution ends'+billingPdf);
        insert billingPdf;

        // add attachment  to email
        List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
        Messaging.EmailFileAttachment attachemtsForEmail = new Messaging.EmailFileAttachment();
        attachemtsForEmail.setFileName(billingPdf.Name);
        attachemtsForEmail.setBody(billingPdf.Body);
        emailAttachments.add(attachemtsForEmail);

        List<Attachment> fileToAttachWithEmail = new List<Attachment>();
        if (attachmentIds != null && attachmentIds.size() > 0) {
            fileToAttachWithEmail =  [SELECT Id, Name, Body 
                                                        FROM Attachment
                                                        WHERE Id IN: attachmentIds];
            for (Attachment att : fileToAttachWithEmail) {
                Messaging.EmailFileAttachment customAttachemtsForEmail = new Messaging.EmailFileAttachment();
                customAttachemtsForEmail.setFileName(att.Name);
                customAttachemtsForEmail.setBody(att.Body);  
                emailAttachments.add(customAttachemtsForEmail);  
            }
        }

        message.setFileAttachments(emailAttachments);

        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if (results[0].success) {
          
        } else {
        
        }
        if(fileToAttachWithEmail!= null && fileToAttachWithEmail.size() > 0 ) {
            System.debug('deleting the attachments');
            delete fileToAttachWithEmail;
        }
        
        // send email
    }

    public PageReference cancel() {
        PageReference pr = new PageReference('/'+billingId);
            pr.setRedirect(true);
            return pr;
    }

    public PageReference setContact() {
        if(billingSO.AcctSeed__Billing_Contact__c == null) {
            showSendEmail = false;
        } else {
            ContactSO = [SELECT Email FROM Contact WHERE Id = :billingSO.AcctSeed__Billing_Contact__c];
            if(ContactSO.Email != null) {
                showSendEmail = true;
                showSendContactError = false;
            } else {
                showSendEmail = false;
                showSendContactError = true;
            }
            
        }
        return null;
    }

    public Pagereference attachCustomFile() {
        /*Messaging.EmailFileAttachment attachemtsForEmail = new Messaging.EmailFileAttachment();
        attachemtsForEmail.setFileName(fileName);
        attachemtsForEmail.setBody(fileData);
        emailAttachments.add(attachemtsForEmail);*/
        Attachment att = new Attachment();
        att.Name = fileName;
        att.Body = fileData;
        att.ParentId = billingSO.Id;
        insert att;
        attachmentIds.add(att.Id);

        CustomFileStruct attachment = new CustomFileStruct();
        attachment.fileName = fileName;
        //attachment.body = fileData;
        attachment.size = FileSizeToString(fileSize);
        attachmetsWrapperList.add(attachment);
        if(attachmetsWrapperList != null && attachmetsWrapperList.size() > 0) {
            ShowAttachments = true;
        } else {
            ShowAttachments = false;
        }
        fileData = null;
        return null;
    }

    public class CustomFileStruct {
        public string fileName{get;set;}
        //public Blob body;
        public String size{get;set;}
        public CustomFileStruct () {

        }
    }

    public static String FileSizeToString(Long Value) {
        /* string representation if a file's size, such as 2 KB, 4.1 MB, etc */
        if (Value < 1024)
            return ToString(Value) + ' Bytes';
        else
        if (Value >= 1024 && Value < (1024*1024))
        {
            //KB
            Decimal kb = Decimal.valueOf(Value);
            kb = kb.divide(1024,2);
            return ToString(kb) + ' KB';
        }
        else
        if (Value >= (1024*1024) && Value < (1024*1024*1024))
        {
            //MB
            Decimal mb = Decimal.valueOf(Value);
            mb = mb.divide((1024*1024),2);
            return ToString(mb) + ' MB';
        }
        else
        {
            //GB
            Decimal gb = Decimal.valueOf(Value);
            gb = gb.divide((1024*1024*1024),2);

            return ToString(gb) + ' GB';
        }

    }

    public static String ToString(Long Value)
    {
      /* string representation if a Long value */
      return Value.format();
    }

    public static String ToString(Decimal Value) {
        /* string representation if a Decimal value */
        return Value.format();
    }
    
    public static void sharepointUpdate () {
        Map<Integer,String> folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };
                
        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };
                
        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };
                
        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };
                
        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };
                
        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };
                
        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };
                
        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };
                
        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };
                
        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };
                
        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };
                
        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };
                
        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };
                
        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };
                
        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };

            folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };        folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            	17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports'
            };
    }
}