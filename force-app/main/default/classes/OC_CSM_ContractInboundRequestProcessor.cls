/* Class Name :  OC_CSM_contractInboundRequestProcessor
 * Description : Rest webservice class for contract inbound request data processing from EBIP-->SF.            
*/
@RestResource(urlMapping='/ServiceContract/*')
global class OC_CSM_ContractInboundRequestProcessor {
    @HttpPost
    global static void handleInboundRequest(){
         RestRequest request = RestContext.request;

      System.enqueueJob(new OC_IB_DeserializeInboundRequest(request,OC_IB_Constants.Sfdc_Ebip_CSM_inApi));
    }

}