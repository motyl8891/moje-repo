/**
 * @File Name          : OC_AN_MockBulletinApproved
 * @Description        : Test class for OC_AN_HandleCalloutWhenBulletinApproved.
 * @Author             : IBM
 * @Group              : OmniChannel - Service
 * @Release            : R2106
 * @Created Date       : 20th May 2021
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0        2021-05-20                 IBM                   Initial Version
 **/

@isTest
global class OC_AN_MockBulletinApproved implements HttpCalloutMock{
  
    public static final String RETURN_FOR_ALL_URLS = '*';
    protected Map<String, Response> responses;

    public OC_AN_MockBulletinApproved(Map<String, Response> responses) {
        this.responses = responses;
    }

    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        Response response = responses.get(req.getEndpoint());
        if( response == null ){
            response = responses.get(RETURN_FOR_ALL_URLS);
        }

        if (response != null) {
            res.setBody(response.body);
            res.setStatusCode(response.code);
            if (response.except) {
                throw new CalloutException('ERROR');
            }
        }
        return res;
    }

    public class Response {
        Integer code;
        String status;
        String body;
        Boolean except;

        public Response(String body, Integer code, Boolean except) {
            this.body = body;
            this.code = code;
            this.except = except;
        }
    }
}