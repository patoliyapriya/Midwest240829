public class SharePointRestServiceCallOut {
public Static String username ='sharepoint@midwestmach.com';
//public Static String password ='Kraken#Cloud';
public Static String password ='Cloud123';
public Static String host = 'https://midwestmach.sharepoint.com';
public Static String cookie ='';
public Static string body = '';
public Static String requestDigestXml ='';
public Static String requestDigestXmlUI {get;set;}        
public Static String endPointUI {get;set;}   
public Static Blob fileBody {get;set;}   
public static string cookieUI {get;set;}

public Static String AccountTitle ='TestNilesh';

public SharePointRestServiceCallOut() {
requestDigestXml = '';
   // authenticateSharePoint();
   system.debug('insideconstructor');
}    
    
  
    public static void authenticateSharePoint() {
    string tokenRequestXml  = getSecurityToken();
        
        getCookie(tokenRequestXml);
        getrequestDigest();
    }
    
    public static HttpResponse createFile(String folderName,String fileName,Blob body) {
        system.debug(folderName+'   '+fileName   );    
        
        HttpRequest reqWrite = new HttpRequest();   
        HttpResponse resWrite = new HttpResponse();
        
        Http httpWrite = new Http();
        String docTitle = 'newFile';
        String url = 'https://midwestmach.sharepoint.com/_api/web/GetFolderByServerRelativeUrl(\'/'+folderName.replace(' ','%20')+'\')/Files/add(url=\''+fileName.replace(' ','%20')+'\',overwrite=true)';           
        system.debug('folderName ='+folderName);
        system.debug('fileName ='+fileName);
        system.debug('url for filecreate = '+url );
        reqWrite.setEndpoint(url);
        system.debug(reqWrite);
        reqWrite.setMethod('POST');
        //reqWrite.setTimeout(120);
        reqWrite.setCompressed(false);
        reqWrite.setHeader('Accept', 'application/json;odata=verbose');
        reqWrite.setHeader('Content-Type', 'application/json;odata=verbose');
        reqWrite.setHeader('X-RequestDigest',requestDigestXml);
        reqWrite.setHeader('Cookie', cookie);
        string writebody = '{ \'__metadata\': { \'type\': \'SP.Salesforce\' } }'; 
        if(body != null) {
            reqWrite.setBodyAsBlob(body);
            reqWrite.setHeader('Content-Length', String.ValueOf(body.size()));
        }

        fileBody = body;
        try
        {    
            if (body != null) {
            resWrite = httpWrite.send(reqWrite);
            system.debug('responseFromsharePoint'+resWrite.getBody());
            }
       
        }
        catch(System.CalloutException e) 
        {
        System.debug('Callout error: '+ e);
        }
        return resWrite;
     
    }
    
  
     
    public static SharePointError__c createFolder(String path) {
        
        SharePointError__c Integration_Error = new SharePointError__c();
        
        system.debug(path);    
        HttpRequest reqWrite = new HttpRequest();   
        HttpResponse resWrite = new HttpResponse();
        Http httpWrite = new Http();//add('LibraryName/FolderName')    
        String url = 'https://midwestmach.sharepoint.com/_api/web/Folders/'+path;           
        
        reqWrite.setEndpoint(url);
        system.debug(reqWrite);
        reqWrite.setMethod('POST');
        //reqWrite.setTimeout(120);
        reqWrite.setCompressed(false);
        reqWrite.setHeader('Accept', 'application/json;odata=verbose');
        reqWrite.setHeader('X-HTTP-Method', 'PUT');
        reqWrite.setHeader('Content-Type', 'application/json;odata=verbose');
        reqWrite.setHeader('X-RequestDigest',requestDigestXml);
        reqWrite.setHeader('Cookie', cookie);
        string writebody = '{ \'__metadata\': { \'type\': \'SP.Salesforce\' }'; 
        reqWrite.setBody(writebody);
        reqWrite.setHeader('Content-Length', string.ValueOf(writebody.length()));
        try
        {   
            resWrite = httpWrite.send(reqWrite);
       
             system.debug('responseFromsharePoint'+resWrite.getBody());
             system.debug(resWrite.getStatusCode());
             system.debug(resWrite.getStatus());
        }
        catch(System.CalloutException e) 
        {
        System.debug('Callout error: '+ e);
        }
        return Integration_Error;
    
    }

    public static integer assignFolderPermission(String path, String grpId, String permissionLevelId, Id opportunityId) {
        String baseurl = 'https://midwestmach.sharepoint.com/_api/web/GetFolderByServerRelativeUrl(';
        String endbaseUrl = ')/ListItemAllFields/roleassignments/addroleassignment(principalid=' + grpId + ',roleDefId=' + permissionLevelId + ')';
        String endPoint = baseurl + '\'' + path + '\''+endbaseUrl;
        
        HttpRequest request = new HttpRequest();   
        HttpResponse response = new HttpResponse();
        Http makeReq = new Http();
        
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        
        request.setHeader('Accept', 'application/json;odata=verbose');
        request.setHeader('content-Type', 'application/json;odata=verbose');
        request.setHeader('Content-Length', '0');
        request.setHeader('X-RequestDigest', requestDigestXml);
        request.setHeader('Cookie', cookie);
        
        try {
            response = makeReq.send(request);
            if(response.getStatusCode() != 200) {
                
                SharePointError__c error = new SharePointError__c(
                Opportunity__c = opportunityId,
                Status_Code__c = 'statusCode: ' +String.valueOf(response.getStatusCode())+ 'status:' +response.getStatus(),
                Error__c = ' path:' +path+ 'groupId:' +grpId+ 'permissionLevel:' +permissionLevelId,
                Type__c = 'Opportunity assign Permission');
                insert error;
            }
            
        } catch(exception ex) {
            SharePointError__c error = new SharePointError__c(
                Opportunity__c = opportunityId,
                Error__c = ex.getMessage() + '1.path:' +path+ ' 2.groupId:' +grpId+ ' 3.permissionLevlId:' +permissionLevelId,
                Type__c = 'Opportunity assign permission');
            insert error;    
            
        }
        
        system.debug('endpoint=>'+endpoint);
        system.debug('body stop inr'+response.getBody());
        system.debug('stop inr'+response.getStatusCode());
        system.debug('stop inr'+response.getStatus());
        return response.getStatusCode();
    
    }
    
    public static SharePointError__c breakInheritanceForFolder(String path, Id OpportunityId) {
    
        SharePointError__c errorRecord = null;
        String baseurl = 'https://midwestmach.sharepoint.com/_api/web/GetFolderByServerRelativeUrl(';
        String endbaseUrl =')/ListItemAllFields/breakroleinheritance(true)';
        String endPoint = baseurl + '\'' +path+ '\'' + endbaseUrl;
        //string endpoint = baseurl+'\''+'/Salesforce/Salesforce/2020/Saint%20Louis/20-4147%20Test%20NB%20Testinher'+'\''+endbaseUrl;
        
        HttpRequest request = new HttpRequest();   
        HttpResponse response = new HttpResponse();
        Http makeReq = new Http();
        
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Accept', 'application/json;odata=verbose');
        request.setHeader('content-Type', 'application/json;odata=verbose');
        request.setHeader('Content-Length', '0');
        request.setHeader('X-RequestDigest',SharePointRestServiceCallOut.requestDigestXml);
        request.setHeader('Cookie', SharePointRestServiceCallOut.cookie);
        
        try {
            response = makeReq.send(request);
            if(response.getStatusCode() != 200) {
                
                SharePointError__c error = new SharePointError__c(
                Opportunity__c = opportunityId,
                Status_Code__c = 'statusCode: ' +String.valueOf(response.getStatusCode())+ 'status:' +response.getStatus(),
                Error__c = 'path:'+path,
                Type__c = 'Opportunity BreakPermission');
                errorRecord = error;
            }
            
        } catch (exception ex) {
            SharePointError__c error = new SharePointError__c(
                Opportunity__c = opportunityId,
                Error__c = ex.getMessage() + '1.path:' +path,
                Type__c = 'Opportunity BreakPermission');
            errorRecord = error;
        }
        
        
        system.debug('endpoint=>'+endpoint);
        system.debug('body stop inr'+response.getBody());
        system.debug('stop inr'+response.getStatusCode());
        system.debug('stop inr'+response.getStatus());
        
        return errorRecord ;
    }
    
    /*
    * 
    */
    public static Void getrequestDigest() {
        system.debug('insidegetrequestDigest');
        HttpRequest requestDigest = new HttpRequest();
        requestDigest.setEndpoint('https://midwestmach.sharepoint.com/_api/contextinfo');
        requestDigest.setMethod('POST');
        requestDigest.setBody(body);
        requestDigest.setHeader('Content-Length',String.valueof(body.length()));
        requestDigest.setHeader('Accept','application/json;odata=verbose');
        requestDigest.setHeader('Content-Type','application/json;odata=verbose');
        requestDigest.setHeader('Cookie',cookie);
        Http httpRequestDigest = new Http();
        HttpResponse responseRequestDigest = new HttpResponse();
        responseRequestDigest = httpRequestDigest.send(requestDigest);
        system.debug('responseFor_xmlContentRequest'+responseRequestDigest);
        string requestDigestValue = responseRequestDigest.toString();
        string xmlContentRequestDigest = responseRequestDigest.getBody();
        Integer index1 = xmlContentRequestDigest.indexOf('"FormDigestValue":"');
        Integer index2 = '"FormDigestValue":"'.length();
        string contentRequestDigest = xmlContentRequestDigest.Substring(index1 + index2);
        requestDigestXml = contentRequestDigest.split('\"')[0];
        
        if (Test.isRunningTest())
        requestDigestXml='0x2502F2B152E3A4301DF21DA70C7E04C91BDABD18BCCDB99ADC9E65FE795F44C1D67A781228B37D17DEA05499D5E4D8E2D7EBA17C6BD2794A78477DD46390BE02,23 Jun 2018 09:40:17 -0000';
        
        system.debug(requestDigestXml);
    
    }
    public static Void getCookie(String token) {
        HttpRequest requestCookie = new HttpRequest();
        requestCookie.setEndpoint('https://midwestmach.sharepoint.com/_forms/default.aspx?wa=wsignin1.0');
        requestCookie.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        requestCookie.setHeader('User-Agent','Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)');
        requestCookie.setMethod('POST');
        requestCookie.setBody(token);
        requestCookie.setHeader('Content-Length',String.valueof(token.length()));
        HttpResponse responseCookie = new HttpResponse();
        Http httpCookie = new Http();
        responseCookie = httpCookie.send(requestCookie);
        
        system.debug('cooki 1st request'+responseCookie );
        system.debug('cooki 1st request'+responseCookie.getHeader('Set-Cookie') );
        string location = responseCookie.getHeader('Location');
        
        if(responseCookie.getStatus() == 'MovedPermanently' || Test.isRunningTest()){    
        HttpRequest reqMovedPermanently = new HttpRequest();
        reqMovedPermanently.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        reqMovedPermanently.setMethod('POST');
        reqMovedPermanently.setEndpoint('https://midwestmach.sharepoint.com/_forms/default.aspx?wa=wsignin1.0');
        reqMovedPermanently.setBody(token);
        reqMovedPermanently.setHeader('Content-Length',String.valueof(token.length()));
        reqMovedPermanently.setHeader('Location', location);
        reqMovedPermanently.setHeader('User-Agent','Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)');
        HttpResponse responseMovedPermanently = new HttpResponse();
        Http httpMovedPermanently = new Http();
        responseMovedPermanently = httpMovedPermanently.send(reqMovedPermanently);
        
        
        
        cookie = responseMovedPermanently.getHeader('Set-Cookie');
        }
        else
        {    
        
        cookie = responseCookie.getHeader('Set-Cookie');
        system.debug('===sadsa=='+cookie );
        system.debug(cookie );
        }
        if (Test.isRunningTest())
            cookie ='RpsContextCookie=; path=/;FedAuth=77u/PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz48U1A+VjQsMGguZnxtZW1iZXJzaGlwfDEwMDM3ZmZlYTkwNzFhNzVAbGl2ZS5jb20sMCMuZnxt';
    
    }
    
    /* 
     * get Security Token 
    */
    public static String getSecurityToken() {
        String token; 
        string tokenRequestXml ='<s:Envelope ' +
                        'xmlns:s=\'http://www.w3.org/2003/05/soap-envelope\' ' +
                        'xmlns:a=\'http://www.w3.org/2005/08/addressing\' ' +
                        'xmlns:u=\'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd\'> ' +
                        '<s:Header>' +
                            '<a:Action s:mustUnderstand=\'1\'>http://schemas.xmlsoap.org/ws/2005/02/trust/RST/Issue</a:Action>' +
                            '<a:ReplyTo> ' +
                                '<a:Address>http://www.w3.org/2005/08/addressing/anonymous</a:Address> ' +
                            '</a:ReplyTo>' +
                            '<a:To s:mustUnderstand=\'1\'>https://login.microsoftonline.com/extSTS.srf</a:To> ' +
                            '<o:Security ' +
                                's:mustUnderstand=\'1\' ' +
                                'xmlns:o=\'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd\'> ' +
                                '<o:UsernameToken> ' +
                                    '<o:Username>' + username + '</o:Username>' +
                                    '<o:Password>' + password + '</o:Password>' +
                                '</o:UsernameToken>' +
                            '</o:Security>' +
                        '</s:Header>' +
                        '<s:Body>' +
                            '<t:RequestSecurityToken xmlns:t=\'http://schemas.xmlsoap.org/ws/2005/02/trust\'> ' +
                                '<wsp:AppliesTo xmlns:wsp=\'http://schemas.xmlsoap.org/ws/2004/09/policy\'> ' +
                                    '<a:EndpointReference> ' +
                                       ' <a:Address>' + host + '</a:Address> ' +
                                    '</a:EndpointReference> ' +
                                '</wsp:AppliesTo> ' +
                               ' <t:KeyType>http://schemas.xmlsoap.org/ws/2005/05/identity/NoProofKey</t:KeyType> ' +
                                '<t:RequestType>http://schemas.xmlsoap.org/ws/2005/02/trust/Issue</t:RequestType> ' +
                               ' <t:TokenType>urn:oasis:names:tc:SAML:1.0:assertion</t:TokenType> ' +
                            '</t:RequestSecurityToken> ' +
                       ' </s:Body> ' +
                    '</s:Envelope>';
        
        HttpRequest reqBinaryToken = new HttpRequest();
        reqBinaryToken.setEndpoint('https://login.microsoftonline.com/extSTS.srf');
        reqBinaryToken.setMethod('POST');
        reqBinaryToken.setbody(tokenRequestXml);
        reqBinaryToken.setHeader('Content-Length',String.valueof(tokenRequestXml.length()));
        reqBinaryToken.setTimeout(60000);
        
        HttpResponse responseBinaryToken = new HttpResponse();
        
        Http httpBinaryToken = new Http();
        responseBinaryToken = httpBinaryToken.send(reqBinaryToken);
        
        system.debug('responseFor_Token'+responseBinaryToken.getBody());
        
        string xmlContent ;
        if(!Test.isRunningTest()) {
           xmlContent = responseBinaryToken.getBody();
            
            Dom.Document doc = responseBinaryToken.getBodyDocument();
            system.debug('document on 223'+doc);
            Dom.XMLNode address = doc.getRootElement();
            //XmlStreamReader reader = new XmlStreamReader(responseBinaryToken.getBody());
            string outxmlstring = String.valueof(doc.getRootElement().getName());//gives you root element Name
            XmlStreamReader reader = new XmlStreamReader(responseBinaryToken.getBody());
            while(reader.hasNext()) {
            if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName()== 'BinarySecurityToken') {
            reader.next();
                if(reader.hasNext()){
                if(reader.getEventType() == XmlTag.CHARACTERS){        
            token = reader.getText();
            token += '&p=';    
                }
                }
            }
            reader.next();
            } 
        
        
        
        } 
        
        
        
       
    if (Test.isRunningTest()) {
        token = 'EwAwA06hBwAUamW55wMmWmxpdUrikyyDcCuRBpIAAdG9+0MeHsu8QOTrpZdkU';
    }
    return token;    
    }
 }