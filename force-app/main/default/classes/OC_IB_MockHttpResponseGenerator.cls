@isTest
global class OC_IB_MockHttpResponseGenerator implements HttpCalloutMock{
    public integer statuscode;
    
    public OC_IB_MockHttpResponseGenerator(integer statuscode){
        this.statuscode=statuscode;
    }
    global HTTPResponse respond(HTTPRequest req) {        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"example":"test"}');
        res.setStatusCode(this.statuscode);
        
        if(statuscode==0){
        CalloutException e = (CalloutException)CalloutException.class.newInstance();
        e.setMessage('Read Timed out');
        throw e;
        }
        return res;
  }
   
}