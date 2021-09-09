/**
* @File Name          : OC_IB_DeserializeInboundRequest
* @Description        : Queueable class for Ibase inbound data processing which calls OC_IB_InboundRequestHandler and OC_IB_ParseInboundReq.
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
public class OC_IB_DeserializeInboundRequest implements Queueable {
    
    RestRequest request;
    String integrationIdentifier;
    
    public OC_IB_DeserializeInboundRequest (RestRequest req,String identifier){
        request = req;
        integrationIdentifier = identifier;
    }
    
    public Void execute(QueueableContext qc){
        List<Object> sobjJsonDataList = new List<Object> ();
        List<EventLog.integrationEventLog> integEventLogInsertList = new List<EventLog.integrationEventLog> ();
        
        try{
        if(integrationIdentifier.equalsIgnoreCase(OC_IB_constants.Sfdc_Ebip_Ibase_InApi)){
            sobjJsonDataList = OC_IB_InboundRequestHandler.fetchMdtRecordsAndDeserializereq(request,integrationIdentifier,true);
         }
        else if(integrationIdentifier.equalsIgnoreCase(OC_IB_constants.Sfdc_Ebip_CSM_inApi)){

         sobjJsonDataList = OC_CSM_InboundRequestHandler.fetchMdtRecordsAndDeserializereq(request,integrationIdentifier,true);
            
        }
            //if(!Test.isRunningTest()) {
            if(sobjJsonDataList !=null && !sobjJsonDataList.isEmpty()){
                System.enqueueJob(new OC_IB_ParseInboundReq(integrationIdentifier,sobjJsonDataList));
                }
                else{
                    integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classDeserializeInboundRequest, OC_IB_Constants.methodDeserializeInboundRequestexecute,null, true, null,integrationIdentifier,request.requestBody.tostring(),false,true,true,false,false,null,OC_IB_Constants.noRecordsErrorMessage,true,OC_IB_Constants.attachTextContentType,null));
                    if(!integEventLogInsertList.isEmpty()){
                        EventLog.createIntegrationLog(integEventLogInsertList);
                    } 
                }
                
          //  }
        }Catch(Exception e){
            integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classDeserializeInboundRequest, OC_IB_Constants.methodDeserializeInboundRequestexecute,null, true, e,integrationIdentifier,request.requestBody.tostring(),false,true,true,false,false,null,null,true,OC_IB_Constants.attachTextContentType,null));
            if(!integEventLogInsertList.isEmpty()){
                EventLog.createIntegrationLog(integEventLogInsertList);
            }

        }
    }
}