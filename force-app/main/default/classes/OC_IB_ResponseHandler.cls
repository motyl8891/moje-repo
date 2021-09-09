/**
* @File Name          : OC_IB_ResponseHandler
* @Description        : Handler class to handle the response sent by external system
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 20th May
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-05-20                 IBM               Initial Version
**/
public class OC_IB_ResponseHandler{
    /**************************************************************************************************
* @Method Name : handleResponseCallouts
* @Description : Handles the response sent by external system
* @Param       : response - response from the external system
* @Param       : integrationIdentifier - unique string to identify the integration context
* @Return      : String
****************************************************************************************************/
    Public Static String handleResponseCallouts(HTTPResponse response, String integrationIdentifier){
        String accessToken;
        Map<String, object> resultMap = new Map<String, object>();
        try{
        if (response.getStatusCode() == 200 && integrationIdentifier == OC_AN_Constants.OC_AN_Auth_Url ){
            resultMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            if (resultMap.containsKey(OC_AN_Constants.resAccessToken)){
                accessToken = (String)resultMap.get(OC_AN_Constants.resAccessToken);
            }
            return accessToken;
        } else if (integrationIdentifier == OC_AN_Constants.OC_AN_Create_Email || integrationIdentifier == OC_AN_Constants.OC_AN_Create_Journey){
            resultMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            String returnId = String.valueOf(resultMap.get('id'));
            return returnId;
        }
        } catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_AN_Constants.OC_IB_ResponseHandler,OC_AN_Constants.handleResponseCallouts,null, false, e));
        }
        return response.getBody();
    }
}