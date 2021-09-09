/**
 * @File Name          : MockHttpResponseGenerator.cls
 * @Description        :
 * @Author             : Ankit Jain
 * @Group              :
 * @Last Modified By   : Ankit Jain
 * @Last Modified On   :
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0    2019-9-18  		 Ankit Jain   			  Initial Version
 **/

@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
   /**
 * @File Name          : MockHttpResponseGenerator.cls
 * @Description        :
 * @Author             : Ankit Jain
 * @Group              :
 * @Last Modified By   : Ankit Jain
 * @Last Modified On   :
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0    2019-9-18  		 Ankit Jain   			  Initial Version
 **/
  
    global HTTPResponse respond(HTTPRequest req) {
       
        //System.assertEquals('GET', req.getMethod());
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"foo":"bar"}');
        res.setStatusCode(200);
        return res;
    }
}