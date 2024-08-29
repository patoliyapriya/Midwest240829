global class CreateAttachmentInSharePoint {
     @future(callout=true)
     Public static void createFile(String folder,String file, Blob body,String docType, Id quoteId)
     {    
          HttpResponse response = new HttpResponse ();
          if (!Test.isRunningTest()) {
              SharePointRestServiceCallOut.authenticateSharePoint();
              response = SharePointRestServiceCallOut.createFile(folder,file,body);
              system.debug('CreateAttachmentInSharePoint response'+response);
              
          } else { 
              response.setBody('test message');
              response.setStatus('not found');
              response.setStatusCode(400);
          
          }    
          
        if (Test.isrunningtest() || response.getStatusCode() != 200) {
            Quote quoteSO = [SELECT Id, Name FROM Quote WHERE Id = :quoteId];
            String errorType;
            if (docType == 'Quote') {
                system.debug('create Quote failed');
                errorType = 'Quote File';
                Quote quoteToUpdate = [SELECT Id,QuoteDocumentVersion__c FROM Quote WHERE Id =: quoteId];
                Integer versionNumber = quoteToUpdate.QuoteDocumentVersion__c != null ? Integer.valueOf(quoteToUpdate.QuoteDocumentVersion__c) : 0;
                
                if (versionNumber > 0) {
                    versionNumber--;
                    quoteToUpdate.QuoteDocumentVersion__c = versionNumber;
                    update quoteToUpdate;
                }
            }
            
            if (docType == 'Scope') {
                system.debug('create Scope failed');
                errorType = 'Scope File';
                Quote quoteToUpdate = [SELECT Id,ScopeDocumentVersion__c FROM Quote WHERE Id =: quoteId];
                Integer versionNumber = quoteToUpdate.ScopeDocumentVersion__c != null ? Integer.valueOf(quoteToUpdate.ScopeDocumentVersion__c) : 0;
                
                if (versionNumber > 0) {
                    versionNumber--;
                    quoteToUpdate.ScopeDocumentVersion__c = versionNumber;
                    update quoteToUpdate;
                }
            }
            
            if (docType == 'Submittal') {
                system.debug('create Quote failed');
                errorType = 'Submittal File';

                Quote quoteToUpdate = [SELECT Id,SubmittalDocumentVersion__c FROM Quote WHERE Id =: quoteId];
                Integer versionNumber = quoteToUpdate.SubmittalDocumentVersion__c != null ? Integer.valueOf(quoteToUpdate.SubmittalDocumentVersion__c) : 0;
                
                if (versionNumber > 0 && quoteToUpdate != null) {
                    versionNumber--;
                    quoteToUpdate.SubmittalDocumentVersion__c = versionNumber;
                    update quoteToUpdate;
                }
            }

            // create error object
            SharePointError__c error = new SharePointError__c(
                Quote__c = quoteId,
                Error__c = 'File creation for quote is failed for '+ quoteSO.Name + 'reason is:'+ response.getBody() + '  path:'+folder,
                Status_Code__c = response.getStatusCode() +' Status:' + response.getStatus(),
                Type__c = errorType
            );
            insert error;
        }
     }
}