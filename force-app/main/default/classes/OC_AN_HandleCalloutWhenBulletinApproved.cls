/**
 * @File Name          : OC_AN_HandleCalloutWhenBulletinApproved
 * @Description        : Below class OC_AN_HandleCalloutWhenBulletinApproved is called from Process Builder 'BulletinProcessMain'
 * @Author             : IBM
 * @Group              : OmniChannel - Service
 * @Release            : U-2763, U-2782
 * @Created Date       : 07th May 2021
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0        2021-05-07                 IBM                   Initial Version
 **/
public class OC_AN_HandleCalloutWhenBulletinApproved{
	public static final String BULLETIN_ID = OC_AN_Constants.BULLETIN_ID;
	public static final String DE_CATEGORY_ID = OC_AN_Constants.DE_CATEGORY_ID;
	public static final String ACCESS_TOKEN = OC_AN_Constants.ACCESS_TOKEN;
	public static final String EMAIL_ID = OC_AN_Constants.EMAIL_ID;
	public static final String BULLETIN_DATA_EXTENSION_ID = OC_AN_Constants.BULLETIN_DATA_EXTENSION_ID;
	public static final String BULLETIN_JOURNEY_ID = OC_AN_Constants.BULLETIN_JOURNEY_ID;
	public static final String BULLETIN_AUTOMATION_ID = OC_AN_Constants.BULLETIN_AUTOMATION_ID;
	public static final String BULLETIN_NAME = OC_AN_Constants.BULLETIN_NAME;
    public static final String BULLETIN_Type = 'BulletinType';
	public static final String BULLETIN_Status = 'BulletinStatus';
	private static Set<String> mdt_const = new Set<String>{OC_AN_Constants.OC_AN_Auth_Url, OC_AN_Constants.OC_AN_Create_Email, 
		OC_AN_Constants.OC_AN_Create_Internal_User_DE, OC_AN_Constants.OC_AN_Insert_Internal_User, OC_AN_Constants.OC_AN_Create_Journey, 
		OC_AN_Constants.OC_AN_Execute_Journey, OC_AN_Constants.OC_AN_Ex_SQL_Activity, OC_AN_Constants.OC_AN_Ex_Automation, 
		OC_AN_Constants.OC_AN_Insert_Event_Definition,OC_AN_Constants.DE_CATEGORY_ID, OC_AN_Constants.ericcsonLogo };
	private static Map<String, OC_IB_OutboundIntegrationIdentifier__mdt> mdtMap = new Map<String, OC_IB_OutboundIntegrationIdentifier__mdt>();
	private static Map<String, String> sfmc_Config = new Map<String, String>();
	@InvocableMethod
	public static void callOutWhenBulletinApproved(List<Id> bulletinId){
		mcRestCallouts(bulletinId);
	}

	@future(callout = true)
	public static void mcRestCallouts(List<Id> bulletinId){
		mdtMap = OC_IB_Utility.getIntegrationIdentifierMdtRecordvalues(mdt_const);

		for (OC_AN_AlertsAndNotification__mdt config : [Select Id, Label, Values__c
		                                                from OC_AN_AlertsAndNotification__mdt]){
			sfmc_Config.put(config.Label, config.Values__c);
		}
		String accessToken = null;
        try{
			accessToken = createAccessToken(); //Create Access Token
		}catch( Exception e ){
			EventLog.createLog(new EventLog.Error(OC_AN_Constants.OC_AN_HandleCalloutWhenBulletinApproved,OC_AN_Constants.mcRestCallouts,null, false, e));
		}
		if( String.isEmpty( accessToken ) ){
			return;
		}
		
		for (OC_AN_Bulletin__c bulletinSObj : [
			SELECT 
				Id, Name, OC_AN_MC_Email_Id__c, OC_AN_Body_Of_Bulletin__c,
				OC_AN_MC_Internal_DE_Id__c, OC_AN_Current_Status__c, OC_AN_MC_Journey_Id__c, OC_AN_Internal_Body_Of_Bulletin__c,
				OC_AN_Type__c
	  		FROM OC_AN_Bulletin__c
	  		WHERE Id IN: bulletinId] 
		) {
		// for (Id sbulletinId : bulletinId ) {
			try{
				// OC_AN_Bulletin__c bulletinSObj = [SELECT Id, Name, OC_AN_MC_Email_Id__c, OC_AN_Body_Of_Bulletin__c,
                //                                   OC_AN_MC_Internal_DE_Id__c, OC_AN_MC_Journey_Id__c, OC_AN_Internal_Body_Of_Bulletin__c,
                //                                   OC_AN_Type__c
				// 								FROM OC_AN_Bulletin__c
				// 								WHERE Id = :bulletinId
				// 								LIMIT 1];
				Map<String, String> emailContentAndAccessToken = new Map<String, String>();
				emailContentAndAccessToken.put(BULLETIN_ID, bulletinSObj.Id);
				emailContentAndAccessToken.put(DE_CATEGORY_ID, sfmc_Config.get(DE_CATEGORY_ID));
				emailContentAndAccessToken.put(ACCESS_TOKEN, accessToken);
				emailContentAndAccessToken.put(BULLETIN_NAME, bulletinSObj.Name);
                emailContentAndAccessToken.put(BULLETIN_Type, bulletinSObj.OC_AN_Type__c);
				emailContentAndAccessToken.put(BULLETIN_Status, bulletinSObj.OC_AN_Current_Status__c);
				emailContentAndAccessToken.put(EMAIL_ID, sfmc_Config.get(EMAIL_ID));

				String emailId = createEmail(emailContentAndAccessToken); //Create Email

				System.debug(emailId);

				String bulletinDataExtensionId = createInternalUserDataExtension(emailContentAndAccessToken); //Create InternalUser Data Extension
				emailContentAndAccessToken.put(BULLETIN_DATA_EXTENSION_ID, bulletinDataExtensionId);

				insertInternalUser(emailContentAndAccessToken); //Insert Internal Users

				List<String> newObjIds = createSQLActivity(emailContentAndAccessToken); //Create SQL Activity
				if (!newObjIds.isEmpty()){
					emailContentAndAccessToken.put(OC_AN_Constants.NewObjId_Step1, newObjIds[0]);
				}

				String automationId = createAutomationProcess(emailContentAndAccessToken); //Create Automation Process
				emailContentAndAccessToken.put(BULLETIN_AUTOMATION_ID, automationId);

				String result = createEventDefinition(emailContentAndAccessToken); // Create the event definition to be used in the Journey Creation as the source and triggering event.

				String journeyId = createInternalJourney(emailContentAndAccessToken); //Create Internal Journey
				
				emailContentAndAccessToken.put(BULLETIN_JOURNEY_ID, journeyId);

				String journeyIdPublished = publishInternalJourney(emailContentAndAccessToken);  // Journey to active state

				// This needs to be executed after 20 minutes after the journey is published (a journey needs to be validated and etc and that takes 1-2 minutes)
				OC_AN_AutomationScheduler scheduledAutomation = new OC_AN_AutomationScheduler(emailContentAndAccessToken,OC_AN_Constants.FLOWTYPE_INTERNAL,OC_AN_Constants.JOB_NAME_INTERNAL);
                // Triggering external flow
                OC_AN_ExternalAutomationScheduler scheduleExternal = new OC_AN_ExternalAutomationScheduler(emailContentAndAccessToken);

			}catch(Exception e){
				EventLog.createLog(new EventLog.Error(OC_AN_Constants.OC_AN_HandleCalloutWhenBulletinApproved,OC_AN_Constants.mcRestCallouts,null, false, e));
			}
        } 
 	}

	/**************************************************************************************************
	 * @Method Name : createAccessToken
	 * @Description : Generates Access Token
	 * @Param       : null
	 * @Return      : String
	 ****************************************************************************************************/
	public static String createAccessToken(){
		OC_IB_OutboundIntegrationIdentifier__mdt mdt = mdtMap.get(OC_AN_Constants.OC_AN_Auth_Url);
		Map<String, String> headerMap = new Map<String, String>();
		headerMap.put(OC_AN_Constants.CONTENT_TYPE, OC_AN_Constants.APPLICATION_JSON);
        string username = OC_AN_Constants.userName;
        string password = OC_AN_Constants.password;
        if(sfmc_Config.get('AccountId') == null){
            for (OC_AN_AlertsAndNotification__mdt config : [SELECT Id, Label, Values__c
		                                                FROM OC_AN_AlertsAndNotification__mdt
														WHERE DeveloperName = 'AccountId']){
			sfmc_Config.put(config.Label, config.Values__c);
		}}
		String requestBody = '{"'+OC_AN_Constants.grantType+'":"'+OC_AN_Constants.clientCreds+'", "'+OC_AN_Constants.clientId+'":"'+username+'", "'+OC_AN_Constants.clientSecret+'":"'+password+'", "'+OC_AN_Constants.accountId+'":"'+sfmc_Config.get('AccountId')+'"}';
        System.debug(requestBody);
		HttpResponse response = OC_IB_IntegrationBaseClass.RequestGenerationcallout(requestBody, headerMap, OC_AN_Constants.accessTokenEndPoint, mdt.OC_IB_RequestType__c);
		String responseValue = OC_IB_ResponseHandler.handleResponseCallouts(response, OC_AN_Constants.OC_AN_Auth_Url);
        return responseValue; 
	}

	/**************************************************************************************************
	 * @Method Name : createEmail
	 * @Description : Generates Email in Marketing Cloud
	 * @Param       : Map<String, String> emailContentAndAccessToken
	 * @Return      : String
	 ****************************************************************************************************/
	public static String createEmail(Map<String, String> emailContentAndAccessToken){
		OC_IB_OutboundIntegrationIdentifier__mdt mdt = mdtMap.get(OC_AN_Constants.OC_AN_Create_Email);
		Map<String, String> headerMap = new Map<String, String>();
		headerMap.put(OC_AN_Constants.CONTENT_TYPE, OC_AN_Constants.APPLICATION_JSON);
		headerMap.put(OC_AN_Constants.AUTHORIZATION, OC_AN_Constants.BEARER + emailContentAndAccessToken.get(ACCESS_TOKEN));
		String requestBody = OC_AN_MC_Callout_EmailBody.emailJson(emailContentAndAccessToken.get(BULLETIN_ID), sfmc_Config);

		HttpResponse response = OC_IB_IntegrationBaseClass.RequestGenerationcallout(requestBody, headerMap, mdt.OC_IB_EndPointUrl__c, mdt.OC_IB_RequestType__c);
		Map<String, object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
		String res = '' + resultMap.get(OC_AN_Constants.DATA);
		res = res.substringAfter(OC_AN_Constants.LEGACYID);
		res = res.substringBefore(OC_AN_Constants.LEGACYKEY);
		res = res.remove(',').trim();
		return res;
	}

	/**************************************************************************************************
	 * @Method Name : createInternalUserDataExtension
	 * @Description : Generate data Extension Id for users
	 * @Param       : Map<String, String> emailContentAndAccessToken
	 * @Return      : String
	 ****************************************************************************************************/
	public static String createInternalUserDataExtension(Map<String, String> emailContentAndAccessToken){
		OC_IB_OutboundIntegrationIdentifier__mdt mdt = mdtMap.get(OC_AN_Constants.OC_AN_Create_Internal_User_DE);
		Map<String, String> headerMap = new Map<String, String>();
		headerMap.put(OC_AN_Constants.CONTENT_TYPE, OC_AN_Constants.APPLICATION_SOAP);
		String requestBody = OC_AN_MC_DataExtensionUtils.getSoapBodyEnvelope(emailContentAndAccessToken.get(BULLETIN_ID),
		 emailContentAndAccessToken.get(ACCESS_TOKEN), mdt.OC_IB_EndPointUrl__c, emailContentAndAccessToken.get(DE_CATEGORY_ID));
         system.debug('InternalDE RequestBody'+requestBody);
		String responseValue = OC_AN_MC_DataExtensionUtils.getResponseDataExtensionId(OC_IB_IntegrationBaseClass.RequestGenerationcallout(requestBody, headerMap, mdt.OC_IB_EndPointUrl__c, mdt.OC_IB_RequestType__c));
        system.debug('InternalDE ResponseBody'+responseValue);
		return responseValue;
	}

	/**************************************************************************************************
	 * @Method Name : createEventDefinition
	 * @Description : To reference the right DataExtension when creating the Journey a EventDefinition is needed.
	 * @Param       : Map<String, String> emailContentAndAccessToken
	 * @Return      : String
	 ****************************************************************************************************/
	public static String createEventDefinition(Map<String, String> emailContentAndAccessToken){
		OC_IB_OutboundIntegrationIdentifier__mdt mdt = mdtMap.get(OC_AN_Constants.OC_AN_Insert_Event_Definition);

		Map<String, String> headerMap = new Map<String, String>();
		headerMap.put(OC_AN_Constants.CONTENT_TYPE, OC_AN_Constants.APPLICATION_JSON);
		headerMap.put(OC_AN_Constants.AUTHORIZATION, OC_AN_Constants.BEARER + emailContentAndAccessToken.get(ACCESS_TOKEN));
        
		String requestBody = MC_AN_EventDefinitionVo.populate(emailContentAndAccessToken, OC_AN_Constants.INTERNAL_DISTRIBUTION_NAME_PRESET);
		HttpResponse response = OC_IB_IntegrationBaseClass.RequestGenerationcallout(requestBody, headerMap, mdt.OC_IB_EndPointUrl__c, mdt.OC_IB_RequestType__c);
		return response.getStatus();
	}

	/**************************************************************************************************
	 * @Method Name : insertInternalUser
	 * @Description : Creates Internal Users in Marketing Cloud
	 * @Param       : Map<String, String> emailContentAndAccessToken
	 * @Return      : String
	 ****************************************************************************************************/
	public static String insertInternalUser(Map<String, String> emailContentAndAccessToken){
        
		OC_IB_OutboundIntegrationIdentifier__mdt mdt = mdtMap.get(OC_AN_Constants.OC_AN_Insert_Internal_User);
		Map<String, String> headerMap = new Map<String, String>();
		headerMap.put(OC_AN_Constants.CONTENT_TYPE, OC_AN_Constants.APPLICATION_JSON);
		headerMap.put(OC_AN_Constants.AUTHORIZATION, OC_AN_Constants.BEARER + emailContentAndAccessToken.get(ACCESS_TOKEN));
		System.debug('BULLETIN_Type'+emailContentAndAccessToken.get(BULLETIN_Type));
        String requestBody = OC_AN_MC_Callout_DataExt_Body.dataExtensionJson(emailContentAndAccessToken.get(BULLETIN_ID),
                                                                            emailContentAndAccessToken.get(BULLETIN_Type),
																			emailContentAndAccessToken.get(BULLETIN_Status));
             system.debug('requestBodyInternal====>'+requestBody);
		String endPoint = mdt.OC_IB_EndPointUrl__c + sfmc_Config.get(OC_AN_Constants.ID_Step_1_DE_Target_CustomerKey)+OC_AN_MC_Utils.MC_ID_END_POINT;
		HttpResponse response = OC_IB_IntegrationBaseClass.RequestGenerationcallout(requestBody, headerMap, endPoint, mdt.OC_IB_RequestType__c);
		String responseValue = OC_IB_ResponseHandler.handleResponseCallouts(response, OC_AN_Constants.OC_AN_Insert_Internal_User);
        system.debug('responseValueInternal====>'+responseValue);
		return responseValue;
	}

	/**************************************************************************************************
	 * @Method Name : createSQLActivity
	 * @Description : Creates SQL Activity in Marketing Cloud
	 * @Param       : Map<String, String> emailContentAndAccessToken
	 * @Return      : String
	 ****************************************************************************************************/
	public static List<String> createSQLActivity(Map<String, String> emailContentAndAccessToken){
		OC_IB_OutboundIntegrationIdentifier__mdt mdt = mdtMap.get(OC_AN_Constants.OC_AN_Create_Internal_User_DE);
		Map<String, String> headerMap = new Map<String, String>();
        String requestBody='';
		headerMap.put(OC_AN_Constants.CONTENT_TYPE, OC_AN_Constants.APPLICATION_SOAP);
		String targetName = OC_AN_Constants.INTERNALUSER  + emailContentAndAccessToken.get(BULLETIN_ID);
		List<OC_AN_Bulletin_Account_Product__c> recProdcuctRecord =  [SELECT Id FROM OC_AN_Bulletin_Account_Product__c 
                                                                      WHERE OC_AN_Bulletin__c =:emailContentAndAccessToken.get(BULLETIN_ID)
                                                                      AND RecordTypeId =: OC_AN_Constants.recTypeId_AccPrdForBulletin_Product];
        //String requestBody = OC_AN_MC_Automation_Helper.createSQLQuery_ID(emailContentAndAccessToken.get(ACCESS_TOKEN), emailContentAndAccessToken.get(BULLETIN_ID), 'ID', sfmc_Config, targetName, targetName);
		requestBody =OC_AN_MC_Automation_Helper.createSQLQuery_ID(emailContentAndAccessToken.get(ACCESS_TOKEN), emailContentAndAccessToken.get(BULLETIN_ID), 'ID', sfmc_Config, targetName, targetName,recProdcuctRecord);
        HttpResponse response = OC_IB_IntegrationBaseClass.RequestGenerationcallout(requestBody, headerMap, mdt.OC_IB_EndPointUrl__c, OC_AN_Constants.httpMethodPOST);

		XmlStreamReader reader = new XmlStreamReader(response.getBody());
		OC_AN_XMLParser xmlParser = new OC_AN_XMLParser();
		List<String> newObjectIds = xmlParser.parseBooks(reader);

		return newObjectIds;
	}

	/**************************************************************************************************
	 * @Method Name : createAutomationProcess
	 * @Description : Creates Automation Process in Marketing Cloud
	 * @Param       : Map<String, String> emailContentAndAccessToken
	 * @Return      : String
	 ****************************************************************************************************/
	public static String createAutomationProcess(Map<String, String> emailContentAndAccessToken){
        String objectIdToReturn;
		OC_IB_OutboundIntegrationIdentifier__mdt mdt = mdtMap.get(OC_AN_Constants.OC_AN_Create_Internal_User_DE);
		Map<String, String> headerMap = new Map<String, String>();
		headerMap.put(OC_AN_Constants.CONTENT_TYPE, OC_AN_Constants.APPLICATION_SOAP);
		String targetName = OC_AN_Constants.INTERNALUSER + emailContentAndAccessToken.get(BULLETIN_ID);
		String requestBody = OC_AN_MC_Automation_Helper.createAutomationProcess_ID(emailContentAndAccessToken.get(ACCESS_TOKEN), emailContentAndAccessToken.get(BULLETIN_ID), 'ID', emailContentAndAccessToken.get('NewObjId_Step1'), targetName);
		HttpResponse response = OC_IB_IntegrationBaseClass.RequestGenerationcallout(requestBody, headerMap, mdt.OC_IB_EndPointUrl__c, OC_AN_Constants.httpMethodPOST);
		XmlStreamReader reader = new XmlStreamReader(response.getBody());
		OC_AN_XMLParser xmlParser = new OC_AN_XMLParser();
		List<String> newObjectIds = xmlParser.parseBooks(reader);
        if(!newObjectIds.isEmpty()){
            objectIdToReturn = newObjectIds.get(0);
        }
		return objectIdToReturn;
	}

	/**************************************************************************************************
	 * @Method Name : createInternalJourney
	 * @Description : Creates Journey Id
	 * @Param       : Map<String, String> emailContentAndAccessToken
	 * @Return      : String
	 ****************************************************************************************************/
	public static String createInternalJourney(Map<String, String> emailContentAndAccessToken){
		OC_IB_OutboundIntegrationIdentifier__mdt mdt = mdtMap.get(OC_AN_Constants.OC_AN_Create_Journey);
		Map<String, String> headerMap = new Map<String, String>();
		headerMap.put(OC_AN_Constants.CONTENT_TYPE, OC_AN_Constants.APPLICATION_JSON);
		headerMap.put(OC_AN_Constants.AUTHORIZATION, OC_AN_Constants.BEARER + emailContentAndAccessToken.get(ACCESS_TOKEN));
        Integer emailId;
        // Integer hardCodedEmail = 3057;
       
		String requestBody = OC_AN_MC_ID_Journey_Util.getInternalJourneyRestBody(emailContentAndAccessToken.get(BULLETIN_ID), emailContentAndAccessToken.get(BULLETIN_NAME),Integer.valueOf(emailContentAndAccessToken.get(EMAIL_ID)), emailContentAndAccessToken.get(BULLETIN_DATA_EXTENSION_ID), sfmc_Config , 'ID');
        system.debug('Journey Request'+requestBody);
		HttpResponse response = OC_IB_IntegrationBaseClass.RequestGenerationcallout(requestBody, headerMap, mdt.OC_IB_EndPointUrl__c, mdt.OC_IB_RequestType__c);
		String responseValue = OC_IB_ResponseHandler.handleResponseCallouts(response, OC_AN_Constants.OC_AN_Create_Journey);
		return responseValue; 
	}

	/**************************************************************************************************
	 * @Method Name : executeInternalJourney
	 * @Description : Executes Journey Request
	 * @Param       : Map<String, String> emailContentAndAccessToken
	 * @Return      : String
	 ****************************************************************************************************/
	public static String publishInternalJourney(Map<String, String> emailContentAndAccessToken){
		OC_IB_OutboundIntegrationIdentifier__mdt mdt = mdtMap.get(OC_AN_Constants.OC_AN_Execute_Journey);
		Map<String, String> headerMap = new Map<String, String>();
		headerMap.put(OC_AN_Constants.CONTENT_TYPE, OC_AN_Constants.APPLICATION_JSON);
		headerMap.put(OC_AN_Constants.AUTHORIZATION, OC_AN_Constants.BEARER + emailContentAndAccessToken.get(ACCESS_TOKEN));
		String endPoint = mdt.OC_IB_EndPointUrl__c + emailContentAndAccessToken.get(BULLETIN_JOURNEY_ID)+OC_AN_Constants.JOURNEY_PUBLISH_URL_VERSION;
		HttpResponse response = OC_IB_IntegrationBaseClass.RequestGenerationcallout(null, headerMap, endPoint, mdt.OC_IB_RequestType__c);
		String responseValue = OC_IB_ResponseHandler.handleResponseCallouts(response, OC_AN_Constants.OC_AN_Create_Journey);
		return responseValue;
	}


	/**************************************************************************************************
	 * @Method Name : startAutomationAndRunJourney
	 * @Description : Starts the automation and with that the second step in the automation is to execute the Journey.
	 * @Param       : Map<String, String> emailContentAndAccessToken
	 * @Return      : String
	 ****************************************************************************************************/
	@future(callout = true)
	public static void startAutomationAndRunJourney(Map<String, String> emailContentAndAccessToken){
		System.debug(JSON.serializePretty(emailContentAndAccessToken));
		if (mdtMap == null || mdtMap.size() == 0){
			mdtMap = OC_IB_Utility.getIntegrationIdentifierMdtRecordvalues(mdt_const);
		}
		String accessToken = OC_AN_HandleCalloutWhenBulletinApproved.createAccessToken();
		emailContentAndAccessToken.put(ACCESS_TOKEN, accessToken);
		OC_IB_OutboundIntegrationIdentifier__mdt mdt = mdtMap.get(OC_AN_Constants.OC_AN_Create_Internal_User_DE);
		Map<String, String> headerMap = new Map<String, String>();
		headerMap.put(OC_AN_Constants.CONTENT_TYPE, OC_AN_Constants.APPLICATION_SOAP);
		String requestBody = OC_AN_MC_AutomationActivityUtils.startAutomation(emailContentAndAccessToken.get(BULLETIN_AUTOMATION_ID), emailContentAndAccessToken.get(ACCESS_TOKEN));
		HttpResponse response = OC_IB_IntegrationBaseClass.RequestGenerationcallout(requestBody, headerMap, mdt.OC_IB_EndPointUrl__c, mdt.OC_IB_RequestType__c);
	}

	/**************************************************************************************************
	 * @Method Name : updateBulletin
	 * @Description : Save the different Id's to the bulletin
	 * @Param       : Map<String, String> emailContentAndAccessToken
	 * @Return      : 
	 ****************************************************************************************************/
	public static void updateBulletin(Map<String, String> emailContentAndAccessToken){
		try{
			OC_AN_Bulletin__c bulletinSObj = [SELECT Id, Name, OC_AN_MC_Email_Id__c, OC_AN_Body_Of_Bulletin__c, OC_AN_MC_Internal_DE_Id__c, OC_AN_MC_Journey_Id__c, OC_AN_Internal_Body_Of_Bulletin__c
			                                  FROM OC_AN_Bulletin__c
			                                  WHERE Id = :emailContentAndAccessToken.get(BULLETIN_ID)
			                                  LIMIT 1];
			bulletinSObj.OC_AN_MC_Email_Id__c = emailContentAndAccessToken.get(EMAIL_ID);
			bulletinSObj.OC_AN_MC_Internal_DE_Id__c = emailContentAndAccessToken.get(BULLETIN_DATA_EXTENSION_ID);
			bulletinSObj.OC_AN_MC_Journey_Id__c = emailContentAndAccessToken.get(BULLETIN_JOURNEY_ID);
			update bulletinSObj;
		} catch (Exception e){
			EventLog.createLog(new EventLog.Error(OC_AN_Constants.OC_AN_HandleCalloutWhenBulletinApproved,OC_AN_Constants.updateBulletin,null, false, e));
		}
	}
 
}