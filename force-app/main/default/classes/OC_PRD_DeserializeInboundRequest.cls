/**
* @File Name          : OC_PRD_DeserializeInboundRequest
* @Description        : Queueable class for Product inbound data processing which calls OC_PRD_InboundRequestHandler and OC_PRD_BatchProductInboundProcessor.
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2107
* @Created Date       : 26th May 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-05-26                 IBM                  U-2817 Initial Version
* 1.1        2021-07-09                 IBM                  U-3066 
**/
public class OC_PRD_DeserializeInboundRequest implements Queueable {
    RestRequest request;
    String integrationIdentifier;
    
    public OC_PRD_DeserializeInboundRequest (RestRequest req,String identifier){
        request = req;
        integrationIdentifier = identifier;
    }
    
    public Void execute(QueueableContext qc){
        Map<String,Object> sobjJsonDataMap = new Map<String,Object>();
        List<EventLog.integrationEventLog> integEventLogInsertList = new List<EventLog.integrationEventLog> ();
        OC_Org_Defaults__c mc = OC_Org_Defaults__c.getOrgDefaults();
        integer batchJobSize=Integer.valueof(mc.OC_PRD_CsdpToStagingObjBatchSize__c);
        try{
            if(String.isNotBlank(integrationIdentifier) && integrationIdentifier.equalsIgnoreCase(OC_IB_constants.Sfdc_Ebip_PRD_inApi)){
                sobjJsonDataMap = OC_PRD_InboundRequestHandler.fetchMdtRecordsAndDeserializereq(request,integrationIdentifier,true);
                
            }
               if(sobjJsonDataMap!=null && !sobjJsonDataMap.isEmpty()){
                   //U-3066 modified
                   Database.executeBatch(new OC_PRD_BatchProductInboundProcessor(OC_IB_constants.Sfdc_Ebip_PRD_inApi,sobjJsonDataMap,OC_IB_Constants.productNodeType,OC_IB_Constants.productSolutionType),batchJobSize);
                }
                else{ 
                    integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classPrdDeserializeInboundRequest, OC_IB_Constants.methodDeserializeInboundRequestexecute,null, true, null,integrationIdentifier,request.requestBody.tostring(),false,true,true,false,false,null,OC_IB_Constants.noRecordsErrorMessage,true,OC_IB_Constants.attachTextContentType,null));
					if(!integEventLogInsertList.isEmpty()){
                        EventLog.createIntegrationLog(integEventLogInsertList);
                    } 
                }
             
        }Catch(Exception e){
            integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classPrdDeserializeInboundRequest, OC_IB_Constants.methodDeserializeInboundRequestexecute,null, true, e,integrationIdentifier,request.requestBody.tostring(),false,true,true,false,false,null,null,true,OC_IB_Constants.attachTextContentType,null));
            if(!integEventLogInsertList.isEmpty()){
                EventLog.createIntegrationLog(integEventLogInsertList);
            }
        }
    }
}