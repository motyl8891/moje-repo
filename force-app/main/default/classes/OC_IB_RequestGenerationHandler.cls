/* Class Name :  OC_IB_RequestGenerationHandler
* Description : Based on the integrationIdentifier value,retrieves the sfdc->external system field mappings 
*               from respective metadata records automatically and generates the request payload in JSON structure.
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-05-10                 IBM                   U-2816 Product MR change             
*/
public class OC_IB_RequestGenerationHandler {
    
    @AuraEnabled public String toastMsg {public get;public set;}
    @AuraEnabled public String toastType {public get;public set;}
    public Static  String statusMsg {get;set;}
    public Static  String statusType {get;set;}
    public  Static OC_IB_RequestGenerationHandler controllerObj =  new OC_IB_RequestGenerationHandler ();
    @AuraEnabled public List<OC_IB_OutboundIntegration_ObjectPicklist__mdt> objectPickListValues  {public get;public set;}
    public Static List<EventLog.integrationEventLog> integEventLogInsertList = new List<EventLog.integrationEventLog> ();
    Public Static integer NoOfTimesJobTriggered;
    public static string inteIdentifier;
    /**************************************************************************************************
* @Method Name : GenerateRequest
* @Description : Generates the request payload in JSON structure
* @Param       : integrationIdentifier - unique string to identify the integration context
* @Param       : sobjectRecordsList - List of sobject records
* @Return      : String - request JSON payload 
****************************************************************************************************/
    
    Public static String GenerateRequest(String integrationIdentifier,List<Sobject> sobjectRecordsList,List<OC_IB_OutboundIntegrationIdentifier__mdt> integrationIdentifierMdtRecordsList,Map<String,String> mapFieldNameToUISelValue){
        inteIdentifier=integrationIdentifier;
        List<OC_IB_OutboundIntegrationFieldMapping__mdt> fieldMappingMdtRecordList = OC_IB_Utility.getIntegrationFieldMappingMdtRecords(integrationIdentifier);
        String requestBody = '';
        try{
            if(integrationIdentifier.equalsIgnoreCase(OC_IB_Constants.Sfdc_Ebip_Ibase_OutApi)){
                NoOfTimesJobTriggered= OC_IB_Utility.getNoOfTimesJobTriggered(label.OC_IB_OutboundSchedulerJobName);
            }
            else if(integrationIdentifier.equalsIgnoreCase(OC_IB_Constants.Sfdc_Ebip_CSM_OutApi)){ // Added for Contract - To capture Contract Scheduler job details 
                NoOfTimesJobTriggered = OC_IB_Utility.getNoOfTimesJobTriggered(label.OC_CSM_OutboundSchedulerJobName);
            }
            else if(integrationIdentifier.equalsIgnoreCase(OC_IB_Constants.Sfdc_Ebip_PRD_OutApi)){ //Added as part of U-2816 Product MR to capture Product Scheduler job details 
                NoOfTimesJobTriggered = OC_IB_Utility.getNoOfTimesJobTriggered(label.OC_PRD_OutboundSchedulerJobName);
            }
            requestBody = OC_IB_Utility.GenerateOutboundReqBody(integrationIdentifier,sobjectRecordsList,integrationIdentifierMdtRecordsList,mapFieldNameToUISelValue);
            
        }
        catch(exception excep){
            
            statusType = OC_IB_Constants.toastMsgTypeError;
            statusMsg =  OC_IB_Constants.errorMsgPrefix + ' '+ excep.getMessage() + '.'+ OC_IB_Constants.errorMsgSuffix;
            integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classRequestGenerationHandler,OC_IB_Constants.methodGenerateRequest,null,false,excep,
                                                                    inteIdentifier,null,true,false,false,false,false,null,null,true,OC_IB_Constants.attachTextContentType,null));
            EventLog.createIntegrationLog(integEventLogInsertList);
        }
        return requestBody;
    }
 /**************************************************************************************************
* @Method Name : getObjectPicklistValues
* @Description : Get the Integration object picklist
* @Return      : OC_IB_RequestGenerationHandler object
****************************************************************************************************/
    @AuraEnabled
    public static OC_IB_RequestGenerationHandler getObjectPicklistValues() {
        
        Try {
        	controllerObj.objectPickListValues = OC_IB_Utility.fetchIntegrationOutBoundObjectPicklist();
       	   	controllerObj.toastType = OC_IB_Constants.toastMsgTypeSuccess;
        }catch (Exception ex) {
             controllerObj.objectPickListValues = new List<OC_IB_OutboundIntegration_ObjectPicklist__mdt>();
             controllerObj.toastMsg = ex.getMessage();
             controllerObj.toastType = OC_IB_Constants.toastMsgTypeError;
             integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classRequestGenerationHandler,OC_IB_Constants.methodSendRequestUI,null,false,null,
                                                                    OC_IB_Constants.Sfdc_Ebip_PRD_OutApi,null,true,false,false,false,false,null,ex.getMessage(),false,null,''));            
             EventLog.createIntegrationLog(integEventLogInsertList);            
        }
        return controllerObj;
    }
    
    /**************************************************************************************************
* @Method Name : sendRequest
* @Description : Sends the outbound request to external system
* @Param       : List<integrationIdentifierMdtRecordList> - Metadata record containing the details info
End point url,named credential,request type and ClientCertificateName
* @Return      : HTTPResponse - Response of external system for the sent request
****************************************************************************************************/
    
    Public Static HTTPResponse sendRequest(List<OC_IB_OutboundIntegrationIdentifier__mdt> integrationIdentifierMdtRecordList,string reqBody){
        HTTPRequest request;
        HTTPResponse tempHttpResponse;
        List<EventLog.integrationEventLog> integEventLogInsertList = new List<EventLog.integrationEventLog> ();
        String evtLogRecId;
        String requestBody;
        
        try{
            request = OC_IB_Utility.prepareHTTPRequest(integrationIdentifierMdtRecordList,reqBody);
            if(request!=null){
                
                requestBody = String.valueOf(request.getBody());
                
                if( !System.isFuture() && !System.isBatch()){//Modified as part of U-2816 Product MR
                    sendRequestFromUI(requestBody);
                }else{
                    HTTP http = new HTTP();
                    tempHttpResponse = http.send(request);
                    
                    if(tempHttpResponse.getStatusCode() == 200){
                        integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeSuccess,OC_IB_Constants.classRequestGenerationHandler,OC_IB_Constants.methodSendRequest,null,false,null,
                                                                                inteIdentifier,requestBody,true,false,false,false,false,null,OC_IB_Constants.IBOutboundSuccessMsg,true,OC_IB_Constants.attachTextContentType,String.ValueOf(tempHttpResponse)));
                        EventLog.createIntegrationLog(integEventLogInsertList);
                    }
                    else{
                        statusType = OC_IB_Constants.toastMsgTypeError;
                        StatusMsg =  OC_IB_Constants.connectivityIssue;
                        integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classRequestGenerationHandler,OC_IB_Constants.methodSendRequest,null,false,null,
                                                                                inteIdentifier,requestBody,true,false,false,false,false,null,OC_IB_Constants.IBOutboundErrorMsg,true,OC_IB_Constants.attachTextContentType,String.ValueOf(tempHttpResponse)));
                        EventLog.createIntegrationLog(integEventLogInsertList);
                    }
                    
                }
            }   
        }    
        catch(exception excep){
            statusType = OC_IB_Constants.toastMsgTypeError;
            StatusMsg =   OC_IB_Constants.errorMsgPrefix + ' '+excep.getMessage()  +  '.'+OC_IB_Constants.errorMsgSuffix;
            integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classRequestGenerationHandler,OC_IB_Constants.methodSendRequest,null,false,excep,
                                                                    inteIdentifier,requestBody,true,false,false,false,false,null,null,true,OC_IB_Constants.attachTextContentType,String.ValueOf(tempHttpResponse)));
            EventLog.createIntegrationLog(integEventLogInsertList);
            
        }
        return tempHttpResponse;
    }
    @AuraEnabled
    Public static OC_IB_RequestGenerationHandler getOutboundRequestParam(Map<string,string> outboundParams){
        List<Account> accountrecordsList; //U-2815 Added for Product Mr Change
        
        string objectName= string.valueof(outboundParams.get(OC_IB_Constants.objectName));  // Added for Contract - To differentiate Objects
        
        If (!objectName.equalsIgnoreCase(OC_IB_Constants.objectProduct)) { // U-2815 Added for Product Mr Change
            
            string soldToId =string.valueof(outboundParams.get(OC_IB_Constants.SoldToId));
            integer serviceToId =integer.valueof(outboundParams.get(OC_IB_Constants.serviceToId)); //line change for sap_s2p_id__c 
            accountrecordsList=[SELECT SAP_S2P_ID_Number__c,Parent.SAP_S2P_ID_Number__c FROM Account WHERE SAP_S2P_ID_Number__c=:serviceToId and Parent.SAP_S2P_ID_Number__c!=null];
            
        }
        
        if(accountrecordsList!=null && !accountrecordsList.isEmpty() && objectName.equalsIgnoreCase(OC_IB_Constants.objectAsset)){
            OC_IB_IntegrationBaseClass.Authentication(OC_IB_Constants.Sfdc_Ebip_Ibase_OutApi,accountrecordsList,outboundParams);
        }
        else if(accountrecordsList!=null && !accountrecordsList.isEmpty() && objectName.equalsIgnoreCase(OC_IB_Constants.objectContract)){
            OC_IB_IntegrationBaseClass.Authentication(OC_IB_Constants.Sfdc_Ebip_CSM_OutApi,accountrecordsList,outboundParams);
        }//U-2815 Added for product MR change Start
        else if(objectName.equalsIgnoreCase(OC_IB_Constants.objectProduct)) {
            OC_IB_IntegrationBaseClass.Authentication(OC_IB_Constants.Sfdc_Ebip_PRD_OutApi,accountrecordsList,outboundParams);
        }
        //U-2815 Added for Product MR change End
        controllerObj.toastType = (String.isNotBlank(statusType)) ? statusType : OC_IB_Constants.toastMsgTypeSuccess;
        controllerObj.toastMsg = (String.isNotBlank(StatusMsg)) ? StatusMsg : OC_IB_Constants.IBOutboundSuccessMsg;
        return controllerObj;
    }
    @future(callout=true)
    Public Static void sendRequestFromUI(string requestBody){
        HTTPResponse tempHttpResponse;
        String identifier;
        try{
            List<EventLog.integrationEventLog> integEventLogInsertList = new List<EventLog.integrationEventLog> ();
            
            HTTPRequest request=new HTTPRequest();
            string endpoint;
            string method;
            string certificateName;
            Boolean isAsset = requestBody.contains(OC_IB_Constants.objectAsset); // Added for Contract 
            Boolean isContract=requestBody.contains(OC_IB_Constants.objectContract);
            Boolean isProduct = requestBody.contains(OC_IB_Constants.objectProduct);//U-2815  Added for Product MR Change
            identifier = isAsset ? OC_IB_Constants.Sfdc_Ebip_Ibase_OutApi : OC_IB_Constants.Sfdc_Ebip_CSM_OutApi;
            if(isAsset){
                List<OC_IB_OutboundIntegrationIdentifier__mdt> integrationIdentifierMdtRecordList= OC_IB_Utility.getIntegrationIdentifierMdtRecords(OC_IB_Constants.Sfdc_Ebip_Ibase_OutApi);
                endpoint= (String.isNotBlank(integrationIdentifierMdtRecordList[0].OC_IB_EndPointUrl__c)) ?
                    integrationIdentifierMdtRecordList[0].OC_IB_EndPointUrl__c :
                integrationIdentifierMdtRecordList[0].OC_IB_NamedCredentialApiName__c;
                method = integrationIdentifierMdtRecordList[0].OC_IB_RequestType__c;
                certificateName = integrationIdentifierMdtRecordList[0].OC_IB_ClientCertificateName__c;
            }
            else if(isContract){
                List<OC_IB_OutboundIntegrationIdentifier__mdt> integrationIdentifierMdtRecordList= OC_IB_Utility.getIntegrationIdentifierMdtRecords(OC_IB_Constants.Sfdc_Ebip_CSM_OutApi);
                endpoint= (String.isNotBlank(integrationIdentifierMdtRecordList[0].OC_IB_EndPointUrl__c)) ?
                    integrationIdentifierMdtRecordList[0].OC_IB_EndPointUrl__c :
                integrationIdentifierMdtRecordList[0].OC_IB_NamedCredentialApiName__c;
                method = integrationIdentifierMdtRecordList[0].OC_IB_RequestType__c;
                certificateName = integrationIdentifierMdtRecordList[0].OC_IB_ClientCertificateName__c;  
            }// U-2815 Added for Product MR Change start 
            else if (isProduct) {
                
                identifier = OC_IB_Constants.Sfdc_Ebip_PRD_OutApi;
                List<OC_IB_OutboundIntegrationIdentifier__mdt> integrationIdentifierMdtRecordList= OC_IB_Utility.getIntegrationIdentifierMdtRecords(OC_IB_Constants.Sfdc_Ebip_PRD_OutApi);
                endpoint= (String.isNotBlank(integrationIdentifierMdtRecordList[0].OC_IB_EndPointUrl__c)) ?
                    integrationIdentifierMdtRecordList[0].OC_IB_EndPointUrl__c :
                integrationIdentifierMdtRecordList[0].OC_IB_NamedCredentialApiName__c;
                method = integrationIdentifierMdtRecordList[0].OC_IB_RequestType__c;
                certificateName = integrationIdentifierMdtRecordList[0].OC_IB_ClientCertificateName__c; 
                
            }
            
            // U-2815 Added for Product MR Change end 
            
            
            
            
            request.setBody(requestBody);
            request.setMethod(method);
            request.setEndpoint(endpoint);
            request.setClientCertificateName(certificateName);
            request.setHeader(OC_IB_Constants.contentType,OC_IB_Constants.jsonApplication);
            request.setTimeOut(120000);
            HTTP http = new HTTP();
            tempHttpResponse = http.send(request);
            if(tempHttpResponse.getStatusCode() == 200){
                integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeSuccess,OC_IB_Constants.classRequestGenerationHandler,OC_IB_Constants.methodSendRequestUI,null,false,null,
                                                                        identifier,requestBody,true,false,false,false,false,null,OC_IB_Constants.IBOutboundSuccessMsg,true,OC_IB_Constants.attachTextContentType,String.ValueOf(tempHttpResponse)));
                EventLog.createIntegrationLog(integEventLogInsertList);
            }
            else{
                statusType = OC_IB_Constants.toastMsgTypeError;
                StatusMsg =  OC_IB_Constants.connectivityIssue;
                integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classRequestGenerationHandler,OC_IB_Constants.methodSendRequestUI,null,false,null,
                                                                        identifier,requestBody,true,false,false,false,false,null,OC_IB_Constants.IBOutboundErrorMsg,true,OC_IB_Constants.attachTextContentType,String.ValueOf(tempHttpResponse)));
                EventLog.createIntegrationLog(integEventLogInsertList);
            }
        }catch(Exception ex){
            integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classRequestGenerationHandler,OC_IB_Constants.methodSendRequestUI,null,false,null,
                                                                    identifier,requestBody,true,false,false,false,false,null,OC_IB_Constants.IBOutboundErrorMsg,true,OC_IB_Constants.attachTextContentType,String.ValueOf(tempHttpResponse)));
            EventLog.createIntegrationLog(integEventLogInsertList);
        }   
    }
    
}