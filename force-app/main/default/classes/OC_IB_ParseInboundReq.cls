/**
* @File Name          : OC_IB_ParseInboundReq
* @Description        : Queueable class for Ibase inbound data processing which calls OC_IB_InboundRequestHandler.
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
public class OC_IB_ParseInboundReq implements Queueable{
    String requestBody;
    List<Object> sobjRecJsonDataList = new List<Object> ();
    String integrationIdentifier;
    List<EventLog.integrationEventLog> integEventLogInsertList = new List<EventLog.integrationEventLog> ();
    
    
    public OC_IB_ParseInboundReq (String identifier,List<Object> sobjJsonData){
        try{
            integrationIdentifier = identifier;
            sobjRecJsonDataList.addAll(sobjJsonData);
        }
        catch(Exception e){
            integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classParseInboundReq, OC_IB_Constants.methodParseInboundReq,null, true, e,integrationIdentifier,null,false,true,true,false,false,null,null,false,null,null));
            EventLog.createIntegrationLog(integEventLogInsertList);
        }
    }
    
    public Void execute(QueueableContext qc){
        try{
           if(String.isNotBlank(integrationIdentifier) && integrationIdentifier.equalsIgnoreCase(OC_IB_Constants.Sfdc_Ebip_Ibase_InApi)){
            new OC_IB_InboundRequestHandler(requestBody,integrationIdentifier,sobjRecJsonDataList); 
            }
           else if(String.isNotBlank(integrationIdentifier) && integrationIdentifier.equalsIgnoreCase(OC_IB_Constants.Sfdc_Ebip_CSM_inApi)){
               new OC_CSM_InboundRequestHandler(requestBody,integrationIdentifier,sobjRecJsonDataList); 
           }
        }catch(Exception e){
            integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classParseInboundReq, OC_IB_Constants.methodParseInboundReqexecute,null, true, e,integrationIdentifier,null,false,true,true,false,false,null,null,false,null,null));
            EventLog.createIntegrationLog(integEventLogInsertList);
            
        }
    }
}