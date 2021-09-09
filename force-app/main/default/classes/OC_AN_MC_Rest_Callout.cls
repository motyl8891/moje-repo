/**
* @File Name          : OC_AN_MC_Rest_Callout
* @Description        : Added for Access Token Value and Generic Callout methods
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : U-2763, U-2782
* @Created Date       : 07th May 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-05-07                 IBM                   Initial Version
**/
public class OC_AN_MC_Rest_Callout {
    
   private Static String access_Token;    
    
    public static String accessToken(){
        OC_AN_MC_CalloutUtils callout = new OC_AN_MC_CalloutUtils();    
        if(String.isBlank(access_Token)){
            callout.endPoint(OC_AN_MC_Utils.MARKETING_CLOUD_INSTANCE_BASE_URL+OC_AN_MC_Utils.MARKETING_CLOUD_INSTANCE_ACCESS_URL)
                .method(OC_AN_MC_Utils.POST_METHOD_TYPE)            
                .addHeader('Content-Type','application/json')
                .body('{"grant_type":"client_credentials", "client_id":"jbuia3x9phyi7ygko2ydfct3", "client_secret":"iBpmSICLrYlmOz4q13csLi1h", "account_id":"510003459"}');
            callout.send();
            callout.access_token();
            access_Token = ''+callout.access_token;
        }
        System.debug(access_Token);
        return access_Token;
    }

    public static String accessToken(String clientId, String clientSecret, String accountId){
        OC_AN_MC_CalloutUtils callout = new OC_AN_MC_CalloutUtils();    
        if(String.isBlank(access_Token)){
            callout.endPoint(OC_AN_MC_Utils.MARKETING_CLOUD_INSTANCE_BASE_URL+OC_AN_MC_Utils.MARKETING_CLOUD_INSTANCE_ACCESS_URL)
                .method(OC_AN_MC_Utils.POST_METHOD_TYPE)            
                .addHeader('Content-Type','application/json')
                .body('{"grant_type":"client_credentials", "client_id":"' + clientId + '", "client_secret":"' + clientSecret + '", "account_id":"' + accountId + '"}');
            callout.send();
            callout.access_token();
            access_Token = ''+callout.access_token;
        }
        System.debug(access_Token);
        return access_Token;
    }

    public static HTTPResponse genericHTTPGeneratemethod(string reqBody,Map<String,String> Headermap,String endPoint,String method){
        HTTPResponse res= genericCallout(endPoint,
                                         Headermap,
                                         method,
                                         reqBody
                                        );
        return res;
    }

    public static HTTPResponse genericCallout(String endPoint, Map<String,String> header, String methodType, String Body){
        OC_AN_MC_CalloutUtils callout = new OC_AN_MC_CalloutUtils();    
            callout.endPoint(endPoint)
                .method(methodType)
                .addHeader(header)
                .body(body);
            callout.send();
        return callout.response;
    }
}