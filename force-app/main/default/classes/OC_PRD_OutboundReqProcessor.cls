/*@File Name 		  : OC_PRD_OutboundReqProcessor
* @Description 		  : class to handle the sf-->EBIP outbound requests to fetch the product data
to trigger Ibase outbound api requests to EBIP.
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2107
* @Created Date       : 10th May 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-05-10                 IBM                   Initial Version
*/
public class OC_PRD_OutboundReqProcessor{
    public Static List<EventLog.integrationEventLog> integEventLogInsertList = new List<EventLog.integrationEventLog> ();
    @future(callout=true)
    public static void OC_PRD_Outbound_Authentication(String integrationIdentifier){
        try{
            OC_IB_IntegrationBaseClass.Authentication(integrationIdentifier,null,null);
            if(Test.isRunningTest())
            {
                Exception excp;
                throw excp;
            }
        }
        catch(exception excep){
            integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,'OC_PRD_OutboundReqProcessor','OC_PRD_Outbound_Authentication',null,false,excep,
                                                                    integrationIdentifier,null,true,false,false,false,false,null,null,true,OC_IB_Constants.attachTextContentType,null));
            EventLog.createIntegrationLog(integEventLogInsertList);
        }
        
    }
}