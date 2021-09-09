/**
 * @File Name          : OC_AN_MC_AutomationActivityUtils
 * @Description        : This class will be used to create SOAP request to start the
 * 						 automation activities in MC.
 * @Author             : IBM
 * @Group              : OmniChannel - Service
 * @Release            : R2106
 * @Created Date       : 20th May 2021
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0        2021-05-20                 IBM                   Initial Version
 **/


public class OC_AN_MC_AutomationActivityUtils{
	public static String accessToken;
	private static final String endPoint = 'https://mcs82tyyyzfmk1mrbbjnd1m9f5l4.soap.marketingcloudapis.com/Service.asmx';
	private static final String envelopeInit = '<?xml version="1.0" encoding="UTF-8"?>' + 
										  '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">';
	private static final String envelopeBody = '<s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
	private static final String createRequest = '<CreateRequest xmlns="http://exacttarget.com/wsdl/partnerAPI">';
	private static final String envelopeBodyClose = '</s:Body>';
	private static final String envelopeEnd = '</s:Envelope>';
	private static final String createRequestEnd = '</CreateRequest>';
    
      /**************************************************************************************************
	 * @Method Name : getSoapQueryBodyEnvelope
	 * @Description : Creates SOAP body based on the given parameters
	 * @Param       : CustomerKey 
	 * @Param       : sqlActivityName 
	 * @Param       : sqlQueryText 
	 * @Param       : dataExtTargetCustKey 
	 * @Param       : dataExtTargetName 
	 * @Param       : TargetUpdateType 
	 * @Return      : String
	 ****************************************************************************************************/
    
	public static String getSoapQueryBodyEnvelope(String CustomerKey, String sqlActivityName, String sqlQueryText, String dataExtTargetCustKey, String dataExtTargetName, String TargetUpdateType){

		String QUERY_DEFINITION_ENVELOPE = '<Objects xsi:type="QueryDefinition">' + 
											'            <CustomerKey>' + CustomerKey + '</CustomerKey>' + 
											'            <Name>' + sqlActivityName + '</Name>' + 
											'            <QueryText>' + sqlQueryText + '</QueryText>' + 
											'            <TargetType>DE</TargetType>' + 
											'            <DataExtensionTarget>' + 
											'                <CustomerKey>' + dataExtTargetCustKey + '</CustomerKey>' + 
											'                <Name>' + dataExtTargetName + '</Name>' + 
											'            </DataExtensionTarget>' + 
											'            <TargetUpdateType>' + TargetUpdateType + '</TargetUpdateType>' + 
											'        </Objects>';


		return QUERY_DEFINITION_ENVELOPE;
	}
    
    /**************************************************************************************************
	 * @Method Name : getSoapAutomationTaskBodyEnvelope
	 * @Description : Creates SOAP body Enevelope based on the given parameters
	 * @Param       : automationTaskName 
	 * @Param       : activityObjID 
	 * @Param       : activityObjObjID 
	 * @Param       : customerKey 
	 * @Param       : activityObjName 
	 * @Return      : String
	 ****************************************************************************************************/

	public static String getSoapAutomationTaskBodyEnvelope(String automationTaskName, String activityObjID, String activityObjObjID, String customerKey, String activityObjName){

		String AUTOMATION_TASK_ENVELOPE = 
			'<AutomationTask>' + 
			'   <Name>' + automationTaskName + '</Name>' + 
			'   <Activities>' + 
			'       <Activity>' + 
			'           <ObjectID>' + activityObjID + '</ObjectID>' + 
			'           <ActivityObject xsi:type="QueryDefinition">' + 
			'               <ObjectID>' + activityObjObjID + '</ObjectID>' + 
			'               <CustomerKey>' + customerKey + '</CustomerKey>' + 
			'               <Name>' + activityObjName + '</Name>' + 
			'           </ActivityObject>' + 
			'       </Activity>' + 
			'   </Activities>' + 
			'</AutomationTask>';


		return AUTOMATION_TASK_ENVELOPE;
	}
    
    /**************************************************************************************************
	 * @Method Name : getSoapHeader
	 * @Description : Creates SOAP header based on the given parameters
	 * @Param       : action 
	 * @Return      : String
	 ****************************************************************************************************/

	public static string getSoapHeader(String action){
		String SOAP_HEADER = '<s:Header>' + 
							'<a:Action s:mustUnderstand="1">' + action + '</a:Action>' + 
							'<a:To s:mustUnderstand="1">' + endPoint + '</a:To>' + 
							'<fueloauth xmlns="http://exacttarget.com">'+accessToken+'</fueloauth>'+
		'</s:Header>';
		return SOAP_HEADER;
	}
    
      /**************************************************************************************************
	 * @Method Name : createSQLActivity
	 * @Description : Creates SQL based on the query list
	 * @Param       : queryList 
	 * @Return      : String
	 ****************************************************************************************************/

	public static string createSQLActivity(List<String> queryList){
		String queries = String.join(queryList, '');
		String sqlActivity = envelopeInit + OC_AN_MC_AutomationActivityUtils.getSoapHeader('Create')+envelopeBody + createRequest + queries + createRequestEnd + envelopeBodyClose + envelopeEnd;
		return sqlActivity;
	}
    
   /**************************************************************************************************
	 * @Method Name : createAutomationActivity
	 * @Description : Creates Automation Activity based on the supplied params
	 * @Param       : BulletinId
	 * @Param		: flowType
	 * @Param		: activityList
	 * @Return      : String
	 ****************************************************************************************************/
	public static string createAutomationActivity(String BulletinId, string flowType, String activityList){
		String automationName = flowType + '_Automation_' + BulletinId;
		String autoKey = flowType + 'Automation_' + BulletinId;
		String activities = '<AutomationTasks>' + activityList + '</AutomationTasks>';

		String automationActivity = envelopeInit + OC_AN_MC_AutomationActivityUtils.getSoapHeader('Create')+envelopeBody + createRequest + '<Objects xsi:type="Automation">' + 
																																			 '<Name>' + automationName + '</Name>' + 
																																			 '<CustomerKey>' + autoKey + '</CustomerKey>' + 
																																			 activities + '<AutomationType>scheduled</AutomationType>' + 
																																			 '</Objects>' + 
																																			 createRequestEnd + envelopeBodyClose + envelopeEnd;

		return automationActivity;
	}

 /**************************************************************************************************
	 * @Method Name : startAutomation
	 * @Description : Starts Automation Activity based on the supplied params
	 * @Param       : objectId
	 * @Param		: accessTokenAsParameter
	 * @Return      : String
	 ****************************************************************************************************/
	public static String startAutomation(String objectId, String accessTokenAsParameter){
		// Make adaptions
		String soapMessage = '<?xml version="1.0" encoding="UTF-8"?>' + 
							 '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'+
		'    <s:Header>' + 
							 '        <a:Action s:mustUnderstand="1">Perform</a:Action>' + 
							 '        <a:To s:mustUnderstand="1">' + endPoint + '</a:To>' + 
							 '        <fueloauth xmlns="http://exacttarget.com">'+accessTokenAsParameter+'</fueloauth>'+
		'    </s:Header>' + 
							 '    <s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'+
		'        <PerformRequestMsg xmlns="http://exacttarget.com/wsdl/partnerAPI" xmlns:ns2="urn:fault.partner.exacttarget.com">'+
		'            <Action>start</Action>' + 
							 '            <Definitions>' + 
							 '                <Definition xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="Automation">'+
		'                    <ObjectID>' + objectId + '</ObjectID>' + 
							 '                </Definition>' + 
							 '            </Definitions>' + 
							 '        </PerformRequestMsg>' + 
							 '    </s:Body>' + 
							 '</s:Envelope>';
		multiLineDebug(soapMessage);
		return soapMessage;
	}

	public static void multiLineDebug(Object debugContents){
		String debugText = JSON.serialize(debugContents);
		Pattern lengthLimit = Pattern.compile('(.{299})');
		debugText = lengthLimit.matcher(debugText).replaceAll('$1\n');
		system.debug(debugText);
	}
}