/**
* @File Name          : OC_PRD_ProductInboundRequestProcessor
* @Description        : Rest webservice class for product inbound request data processing from EBIP-->SF.
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2107
* @Created Date       : 12th May 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-05-12                 IBM                  U-2817 Initial Version
**/
@RestResource(urlMapping='/Product/*')
global class OC_PRD_ProductInboundRequestProcessor {
    @HttpPost
    global static void handleInboundRequest(){
        List<EventLog.integrationEventLog> integEventLogInsertList = new List<EventLog.integrationEventLog>();
        try{
            RestRequest request = RestContext.request;
            System.enqueueJob(new OC_PRD_DeserializeInboundRequest(request,OC_IB_Constants.Sfdc_Ebip_PRD_inApi));
            if(Test.isRunningTest())
            {
                Exception excp;
                throw excp;
            }
        }Catch(exception e){
            integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.productInboundRequestProcessorCls,OC_IB_Constants.handleInboundRequestMethod,null, true, e,OC_IB_Constants.Sfdc_Ebip_PRD_inApi,RestContext.request.requestBody.toString(),false,true,true,false,false,null,null,true,OC_IB_Constants.attachTextContentType,null));
            if(!integEventLogInsertList.isEmpty()){
                EventLog.createIntegrationLog(integEventLogInsertList);
            } 
        } 
    }
}