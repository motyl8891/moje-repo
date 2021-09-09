/**
* @File Name          : OC_AN_MC_CalloutUtils
* @Description        : Added for Callout to External System
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
public class OC_AN_MC_CalloutUtils {
    public HttpRequest request;
    public Http http;
    public HttpResponse response;  
    public String access_token;
    
    private String endPoint;
    private String method;
    private Map<String,String> headers;
    private String body;
    
    public OC_AN_MC_CalloutUtils(){
        response = new HttpResponse();
        http = new Http(); 
        headers = new Map<String,String>();
    }
    
    /**************************************************************************************************
* @Method Name : endPoint
* @Description : Set EndPoint
* @Param       : endpoint
* @Return      : NA
****************************************************************************************************/
    public virtual OC_AN_MC_CalloutUtils endPoint(String endpoint){
        this.endPoint = endpoint;
        return this;
    }
    /**************************************************************************************************
* @Method Name : method
* @Description : Set Method
* @Param       : method
* @Return      : NA
****************************************************************************************************/
    public virtual OC_AN_MC_CalloutUtils method(String method){
        this.method = method;
        return this;
    }
    /**************************************************************************************************
* @Method Name : addHeader
* @Description : Set Header
* @Param       : Key
* @Param       : body
* @Return      : NA
****************************************************************************************************/    
    public virtual OC_AN_MC_CalloutUtils addHeader(String key, String body){
        this.headers.put(key,body);
        return this;
    }
    /**************************************************************************************************
* @Method Name : addHeader
* @Description : Set Header
* @Param       : collectionHeaders - Map of headers
* @Return      : NA
****************************************************************************************************/
    public virtual OC_AN_MC_CalloutUtils addHeader(Map<String,String> collectionHeaders){
        for( String header : collectionHeaders.keySet() ) {                        
            this.headers.put(header,collectionHeaders.get(header));
        }               
        return this;
    }
    /**************************************************************************************************
* @Method Name : body
* @Description : Set Body
* @Param       : body
* @Return      : NA
****************************************************************************************************/
    public virtual OC_AN_MC_CalloutUtils body(String body){
        this.body = body;
        return this;
    }
    /**************************************************************************************************
* @Method Name : access_token
* @Description : Set Access Token
* @Param       : access_token
* @Return      : NA
****************************************************************************************************/
    public virtual OC_AN_MC_CalloutUtils access_token(){
        Map<String,object>  resultMap = (Map<String,Object>)JSON.deserializeUntyped(this.response.getBody());
        this.access_token = ''+resultMap.get(OC_AN_Constants.resAccessToken);
        return this;
    }
    /**************************************************************************************************
* @Method Name : builder
* @Description : To create HTTP request
* @Param       : NA
* @Return      : NA
****************************************************************************************************/    
    public virtual OC_AN_MC_CalloutUtils builder(){
        this.request = new HttpRequest();              
        this.request.setEndpoint(this.endpoint);      
        this.request.setMethod(this.method);      
        
        if(this.body!=null){
            this.request.setBody(this.body);
        }
        
        /*if(this.timeout!=null){
		this.request.setTimeout(this.timeout);
		}*/  
        
        if(!headers.isEmpty())        {
            for(String header : headers.keySet() ) {                        
                request.setHeader( header , headers.get( header ) );
            }
        }  
        return this;
    }    
    /**************************************************************************************************
* @Method Name : send
* @Description : To send request to the External System
* @Param       : NA
* @Return      : NA
****************************************************************************************************/     
    public virtual HttpResponse send() {               
        try {       
            this.builder();
            response = http.send(this.request);
        } catch(Exception e) {
            EventLog.createLog(new EventLog.Error(OC_AN_Constants.OC_AN_MC_CalloutUtils,OC_AN_Constants.SEND,OC_AN_Constants.OC_AN_MC_CalloutUtils, false, e));
        }
        return response;
    } 
    
}