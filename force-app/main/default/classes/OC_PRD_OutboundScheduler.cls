/*@File Name 		  : OC_PRD_OutboundScheduler
* @Description 		  : Scheduler class for scheduling the apex class "OC_PRD_OutboundReqProcessor" 
                 		to trigger  Product outbound api requests to EBIP.
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
global class OC_PRD_OutboundScheduler implements schedulable{   
    global void execute(SchedulableContext sc){
        OC_PRD_OutboundReqProcessor.OC_PRD_Outbound_Authentication(OC_IB_Constants.Sfdc_Ebip_PRD_OutApi);
    }
}