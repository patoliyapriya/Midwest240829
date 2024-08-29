@isTest
global class MockHttpSharePointResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('Set-Cookie', 'RpsContextCookie=; path=/;FedAuth=77u/PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz48U1A+VjQsMGguZnxtZW1iZXJzaGlwfDEwMDM3ZmZlYTkwNzFhNzVAbGl2ZS5jb20sMCMuZnxt');
        res.setHeader('Location', 'NameOfLocation');
        res.setBody('{"example":"test"}');
        res.setStatusCode(200);
        return res;
    }
}