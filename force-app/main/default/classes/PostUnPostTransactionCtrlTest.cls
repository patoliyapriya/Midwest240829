@isTest
global class PostUnPostTransactionCtrlTest implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type','application/json');
        res.setBody('{"totalRate":"120"}');
        res.setStatusCode(200);
        return res;
    }
   
}