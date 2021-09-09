/**
* @File Name          : OC_IB_IbaseInboundAssetRequestProcessor
* @Description        : Rest webservice class for Ibase inbound request data processing from EBIP-->SF.
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2010
* @Created Date       : 1Oth September 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-09-10                 IBM                   Initial Version
**/
@RestResource(urlMapping='/IbaseAsset/*')
global class OC_IB_IbaseInboundAssetRequestProcessor {
    
    
    /**************************************************************************************************
    * @Method Name : handleInboundRequest
    * @Description : Processing Ibase data by passing requestBody to the OC_IB_DeserializeInboundRequest Queueable class
    * @Param       : None
    * @Method      : HttpPost
    * @Return      : Void  
    ****************************************************************************************************/    
    @HttpPost
    global static void handleInboundRequest(){
        RestRequest request = RestContext.request;
        System.enqueueJob(new OC_IB_DeserializeInboundRequest(request,OC_IB_constants.Sfdc_Ebip_Ibase_InApi));
    }
    
}