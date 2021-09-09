/* Class Name :  OC_IB_IntegrationBaseClass
 * Description : Generic class which performs the following actions based on provided integrationIdentifier 
 *               and sobjectRecordsList.
 *              1. Authenticating an outbound api request
 *              2. Generation of outbound request JSON payload and sending outbound payload to the designated 
 *                 external system based on the provided integrationIdentifier and sobject records list
 *              3. Response handling for the triggered outbound api request
 *              4. Error handling for the errors occured during the sending of outbound payload/handling response.
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0        2021-05-12                 IBM                   U-2816 Product Mr change
*/

Public class OC_IB_IntegrationBaseClass {
    
   /**************************************************************************************************
   * @Method Name : Authentication
   * @Description : Authenticate with external system
   * @Param       : integrationIdentifier - unique string to identify the integration context
   * @Param       : sobjectRecordsList - List of sobject records
   * @Return      : NA.
   ****************************************************************************************************/
    Public static Void Authentication(String integrationIdentifier,List<Sobject> sobjectRecordsList,Map<String,String> mapFieldNameToUISelValue){
   
        List<OC_IB_OutboundIntegrationIdentifier__mdt> integrationIdentifierMdtRecordsList;
        
        if((String.isNotBlank(integrationIdentifier) &&   //modified as part of U-2815/U-2816 Product MR
        ((integrationIdentifier.equalsIgnoreCase(OC_IB_Constants.Sfdc_Ebip_PRD_OutApi) && sobjectRecordsList ==null )|| ((integrationIdentifier.equalsIgnoreCase(OC_IB_Constants.Sfdc_Ebip_Ibase_OutApi)|| integrationIdentifier.equalsIgnoreCase(OC_IB_Constants.Sfdc_Ebip_CSM_OutApi))&& sobjectRecordsList!=null && !sobjectRecordsList.isEmpty())))) { 
            
            integrationIdentifierMdtRecordsList = OC_IB_Utility.getIntegrationIdentifierMdtRecords(integrationIdentifier); 
            if(integrationIdentifierMdtRecordsList!=null && !integrationIdentifierMdtRecordsList.isEmpty()){
               
                if(integrationIdentifierMdtRecordsList[0].OC_IB_RequiresDynamicAccessToken__c){
                    //placeholder - Method call to retrive an access token from external system dynamically
                    OC_IB_Authenticationhandler.handleAuthentication(integrationIdentifierMdtRecordsList);
                }else{
                   RequestGeneration(integrationIdentifier,sobjectRecordsList,integrationIdentifierMdtRecordsList,mapFieldNameToUISelValue);
                }
                 
            }
        }
    } 
    
     /**************************************************************************************************
   * @Method Name : RequestGeneration
   * @Description : Generates outbound api request and sends it to external system
   * @Param       : integrationIdentifier - unique string to identify the integration context
   * @Param       : sobjectRecordsList - List of sobject records
   * @Return      : NA.
   ****************************************************************************************************/
    Public static Void RequestGeneration(String integrationIdentifier,List<Sobject> sobjectRecordsList,List<OC_IB_OutboundIntegrationIdentifier__mdt> integrationIdentifierMdtRecordsList,Map<String,String> mapFieldNameToUISelValue){
       string outboundRequest = OC_IB_RequestGenerationHandler.GenerateRequest(integrationIdentifier,sobjectRecordsList,integrationIdentifierMdtRecordsList,mapFieldNameToUISelValue);
        
        if(string.isNotBlank(outboundRequest)){
          ProcessReponse(OC_IB_RequestGenerationHandler.sendRequest(integrationIdentifierMdtRecordsList,outboundRequest));
        }
    }
    
     /**************************************************************************************************
   * @Method Name : ProcessReponse
   * @Description : Handles the received response from external system 
   * @Return      : NA.
   ****************************************************************************************************/
    Public static Void ProcessReponse(HTTPResponse response){
        
      //  OC_IB_ResponseHandler.handleResponse(response);
        
    }
    
     /**************************************************************************************************
 * @Method Name : RequestGenerationcallout
 * @Description : Generates outbound api request and sends it to Marketing Cloud
 * @Param       : requestBody - the body part of the request
 * @Param       : headerMap - Header of the request
 * @Param       : endPoint - Endpoint of the external system
 * @Param       : method - HTTP method
 * @Return      : HttpResponse
 ****************************************************************************************************/
     Public static HttpResponse RequestGenerationcallout(String requestBody,Map<String,String> headerMap,String endPoint,String method){
         System.debug('requestBody :'+requestBody+' endpoint: '+endPoint+' methpd: '+method+' headerMap:'+headerMap);
         OC_AN_MC_CalloutUtils callout = new OC_AN_MC_CalloutUtils();    
         callout.endPoint(endPoint)
             .method(method)
             .addHeader(headerMap)
             .body(requestBody);
         callout.send();
         return callout.response;
     } 
 }