/**
 * @File Name          : OC_AN_HandleExtCalloutBulletin
 * @Description        : Below class OC_AN_HandleExtCalloutBulletin is called from OC_AN_HandleCalloutWhenBulletinApproved based on delay hours
 * @Author             : IBM
 * @Group              : OmniChannel - Service
 * @Release            : U-2763, U-2782
 * @Created Date       : 07th May 2021
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0        2021-05-07                 IBM                   Initial Version
 * 2.0        2021-07-05                 IBM                   Modified as a part of D-4138
 **/
public class OC_AN_HandleExtCalloutBulletin{
	public static final String BULLETIN_ID = OC_AN_Constants.BULLETIN_ID;
	public static final String DE_CATEGORY_ID = OC_AN_Constants.DE_CATEGORY_ID;
	public static final String DE_ENDPOINT = OC_AN_Constants.DE_ENDPOINT;
	public static final String ACCESS_TOKEN = OC_AN_Constants.ACCESS_TOKEN;
	public static final String EMAIL_ID = OC_AN_Constants.EMAIL_ID;
	public static final String BULLETIN_DATA_EXTENSION_ID = OC_AN_Constants.BULLETIN_DATA_EXTENSION_ID;
	public static final String BULLETIN_JOURNEY_ID = OC_AN_Constants.BULLETIN_JOURNEY_ID;
	public static final String BULLETIN_AUTOMATION_ID = OC_AN_Constants.BULLETIN_AUTOMATION_ID;
    public static final String BULLETIN_ExternalAUTOMATION_ID = 'ExternalAutomationId';
	public static final String BULLETIN_NAME = OC_AN_Constants.BULLETIN_NAME;

	private static Set<String> mdt_const = new Set<String>{OC_AN_Constants.OC_AN_Auth_Url, OC_AN_Constants.OC_AN_Create_Email, OC_AN_Constants.OC_AN_Create_Internal_User_DE, 
		OC_AN_Constants.OC_AN_Insert_Internal_User, OC_AN_Constants.OC_AN_Create_Journey, OC_AN_Constants.OC_AN_Execute_Journey, OC_AN_Constants.OC_AN_Ex_SQL_Activity,
		 OC_AN_Constants.OC_AN_Ex_Automation, OC_AN_Constants.OC_AN_Insert_Event_Definition, OC_AN_Constants.DE_CATEGORY_ID,OC_AN_Constants.DE_ENDPOINT  };
	private static Map<String, OC_IB_OutboundIntegrationIdentifier__mdt> mdtMap = new Map<String, OC_IB_OutboundIntegrationIdentifier__mdt>();	
	private static Map<String, String> sfmc_Config = new Map<String, String>();
	
	@future(callout = true)
	public static void mcRestCallouts(Id bulletinId){
		//  pass single Id
		for (OC_AN_AlertsAndNotification__mdt config : [SELECT Id, Label, Values__c
			                                                FROM OC_AN_AlertsAndNotification__mdt]){
				sfmc_Config.put(config.Label, config.Values__c);
		}

		String accessToken = null;
		try{
            mdtMap = OC_IB_Utility.getIntegrationIdentifierMdtRecordvalues(mdt_const);
			accessToken = createAccessToken(); //Create Access Token

			
			Map<String, String> emailContentAndAccessToken = new Map<String, String>();
			emailContentAndAccessToken.put(BULLETIN_ID, bulletinId);
			emailContentAndAccessToken.put(ACCESS_TOKEN, accessToken);

			OC_AN_Bulletin__c bullitenEmail = [Select id, Name, OC_AN_MC_Email_Id__c
			                                   from OC_AN_Bulletin__c
			                                   where Id = :bulletinId];


			emailContentAndAccessToken.put(EMAIL_ID, sfmc_Config.get(EMAIL_ID));
			emailContentAndAccessToken.put(BULLETIN_NAME, bullitenEmail.Name);
			emailContentAndAccessToken.put(DE_CATEGORY_ID, sfmc_Config.get(DE_CATEGORY_ID));
			emailContentAndAccessToken.put(DE_ENDPOINT, sfmc_Config.get(DE_ENDPOINT));
			

			List<String> newObjIds = createExternalUserDataExtension(emailContentAndAccessToken); //Create Data Extension
			emailContentAndAccessToken.put(BULLETIN_DATA_EXTENSION_ID, newObjIds[0]);

			List<String> newSqlObjIds = createSQLActivity(emailContentAndAccessToken);//Create SQL Activity
			emailContentAndAccessToken.put(OC_AN_Constants.AUTOMATION_EXTRA_SQL, newSqlObjIds[0]);
            
            List<String> newSqlObjIdsForArchive = createArchiveSQLActivity(emailContentAndAccessToken);//Create SQL Activity
			emailContentAndAccessToken.put('ArchiveSQLID', newSqlObjIdsForArchive[0]);
            system.debug('ArchiveObjectId'+emailContentAndAccessToken.get('ArchiveSQLID'));

			String automationId = createAutomationProcess(emailContentAndAccessToken);//Create Automation Process
			emailContentAndAccessToken.put(BULLETIN_AUTOMATION_ID, automationId);
            emailContentAndAccessToken.put(BULLETIN_ExternalAUTOMATION_ID, automationId);
            system.debug('External AutomationId===>'+emailContentAndAccessToken.get(BULLETIN_ExternalAUTOMATION_ID));
			// OC_AN_HandleExtCalloutBulletin.updateBulletin(emailContentAndAccessToken);
			String eventDefinition = createEventDefinition(emailContentAndAccessToken); // Create the event definition to be used in the Journey Creation as the source and triggering event.
			
			
			String jounreyId = createExternalJourney(emailContentAndAccessToken);//Create Journey
			emailContentAndAccessToken.put(BULLETIN_JOURNEY_ID, jounreyId);
			
			String journeyIdPublished = publishExternalJourney(emailContentAndAccessToken);// Journey to active state
			OC_AN_HandleExtCalloutBulletin.updateBulletin(emailContentAndAccessToken);
			
			// This needs to be executed 20 minutes after the journey is published (a journey needs to be validated and etc and that takes 15 minutes)
			OC_AN_AutomationScheduler scheduledAutomation = new OC_AN_AutomationScheduler(emailContentAndAccessToken, OC_AN_Constants.FLOWTYPE_EXTERNAL, OC_AN_Constants.JOB_NAME_EXTERNAL);
		} catch (Exception e){
			EventLog.createLog(new EventLog.Error(OC_AN_Constants.OC_AN_HandleCalloutWhenBulletinApproved, OC_AN_Constants.mcRestCallouts, null, false, e));
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
            for (OC_AN_AlertsAndNotification__mdt config : [Select Id, Label, Values__c
		                                                from OC_AN_AlertsAndNotification__mdt where DeveloperName = 'AccountId']){
			sfmc_Config.put(config.Label, config.Values__c);
			}
        }
		String requestBody = '{"'+OC_AN_Constants.grantType+'":"'+OC_AN_Constants.clientCreds+'", "'+OC_AN_Constants.clientId+'":"'+username+'", "'+OC_AN_Constants.clientSecret+'":"'+password+'", "'+OC_AN_Constants.accountId+'":"'+sfmc_Config.get('AccountId')+'"}';
        HttpResponse response = OC_IB_IntegrationBaseClass.RequestGenerationcallout(requestBody, headerMap, OC_AN_Constants.accessTokenEndPoint, mdt.OC_IB_RequestType__c);
		String responseValue = OC_IB_ResponseHandler.handleResponseCallouts(response, OC_AN_Constants.OC_AN_Auth_Url);
        return responseValue; 
	}

	/**************************************************************************************************
	 * @Method Name : createExternalUserDataExtension
	 * @Description : Generate data Extension Id for users
	 * @Param       : Map<String, String> emailContentAndAccessToken
	 * @Return      : String
	 ****************************************************************************************************/
	public static List<String> createExternalUserDataExtension(Map<String, String> emailContentAndAccessToken){
		OC_IB_OutboundIntegrationIdentifier__mdt mdt = mdtMap.get(OC_AN_Constants.OC_AN_Create_Internal_User_DE);
		String requestBody = OC_AN_MC_ExtDataExtensionUtils.createExtDataExtension_ID(
			emailContentAndAccessToken.get(ACCESS_TOKEN), 
			emailContentAndAccessToken.get(BULLETIN_ID),
			OC_AN_Constants.EXTERNALDISTRIBUTION,
			emailContentAndAccessToken.get(DE_CATEGORY_ID),
			emailContentAndAccessToken.get(DE_ENDPOINT)
			 );

		HttpResponse responseValue = OC_IB_IntegrationBaseClass.RequestGenerationcallout(requestBody, getSoapHTTPHeaders(), mdt.OC_IB_EndPointUrl__c, mdt.OC_IB_RequestType__c);
		XmlStreamReader reader = new XmlStreamReader(responseValue.getBody());
		OC_AN_XMLParser xmlParser = new OC_AN_XMLParser();
		List<String> newObjectIds = xmlParser.parseBooks(reader);

		return newObjectIds;
	}

	/**************************************************************************************************
	 * @Method Name : createEventDefinition
	 * @Description : To reference the right DataExtension when creating the Journey a EventDefinition is needed.
	 * @Param       : Map<String, String> emailContentAndAccessToken
	 * @Return      : String
	 ****************************************************************************************************/
	public static String createEventDefinition(Map<String, String> emailContentAndAccessToken){

		OC_IB_OutboundIntegrationIdentifier__mdt mdt = mdtMap.get(OC_AN_Constants.OC_AN_Insert_Event_Definition);

		String requestBody = MC_AN_EventDefinitionVo.populate(emailContentAndAccessToken, OC_AN_Constants.EXTERNAL_DISTRIBUTION_NAME_PRESET);
		HttpResponse response = OC_IB_IntegrationBaseClass.RequestGenerationcallout(requestBody, getRESTHttpHeaders(emailContentAndAccessToken.get(ACCESS_TOKEN)), mdt.OC_IB_EndPointUrl__c, mdt.OC_IB_RequestType__c);
		return response.getStatus();
	}

	/**************************************************************************************************
	 * @Method Name : createSQLActivity
	 * @Description : Creates SQL Activity in Marketing Cloud
	 * @Param       : Map<String, String> emailContentAndAccessToken
	 * @Return      : String
	 ****************************************************************************************************/
	public static List<String> createSQLActivity(Map<String, String> emailContentAndAccessToken){
		OC_IB_OutboundIntegrationIdentifier__mdt mdt = mdtMap.get(OC_AN_Constants.OC_AN_Create_Internal_User_DE);
        String requestBody;
		string dataExtCustomerkey = OC_AN_Constants.EXTERNALDISTRIBUTION + OC_AN_Constants.AUTOMATION_THIRD_STEP + emailContentAndAccessToken.get(BULLETIN_ID);
        List<OC_AN_Bulletin_Account_Product__c> recProdcuctRecord =  [SELECT Id FROM OC_AN_Bulletin_Account_Product__c 
                                                                      WHERE OC_AN_Bulletin__c =:emailContentAndAccessToken.get(BULLETIN_ID)
                                                                      AND RecordTypeId =: OC_AN_Constants.recTypeId_AccPrdForBulletin_Product];
        
        if(!recProdcuctRecord.isEmpty()){
            requestBody = OC_AN_MC_Automation_Helper.createSQLQuery_ED(emailContentAndAccessToken.get(BULLETIN_DATA_EXTENSION_ID), emailContentAndAccessToken.get(ACCESS_TOKEN), emailContentAndAccessToken.get(BULLETIN_ID), OC_AN_Constants.EXTERNALDISTRIBUTION, sfmc_Config, dataExtCustomerkey, dataExtCustomerkey,recProdcuctRecord);
        }else{
            requestBody = OC_AN_MC_Automation_Helper.createSQLQuery_ED(emailContentAndAccessToken.get(BULLETIN_DATA_EXTENSION_ID), emailContentAndAccessToken.get(ACCESS_TOKEN), emailContentAndAccessToken.get(BULLETIN_ID), OC_AN_Constants.EXTERNALDISTRIBUTION, sfmc_Config, dataExtCustomerkey, dataExtCustomerkey,recProdcuctRecord);
        }
        
		HttpResponse response = OC_IB_IntegrationBaseClass.RequestGenerationcallout(requestBody, getSoapHTTPHeaders(), mdt.OC_IB_EndPointUrl__c, mdt.OC_IB_RequestType__c);

		XmlStreamReader reader = new XmlStreamReader(response.getBody());
		OC_AN_XMLParser xmlParser = new OC_AN_XMLParser();
		List<String> newObjectIds = xmlParser.parseBooks(reader);
        
        system.debug('newObjectIds ===>'+newObjectIds);
		return newObjectIds;
	}
    
    /**************************************************************************************************
	 * @Method Name : createSQLActivity
	 * @Description : Creates SQL Activity in Marketing Cloud
	 * @Param       : Map<String, String> emailContentAndAccessToken
	 * @Return      : String
	 ****************************************************************************************************/
	public static List<String> createArchiveSQLActivity(Map<String, String> emailContentAndAccessToken){
		OC_IB_OutboundIntegrationIdentifier__mdt mdt = mdtMap.get(OC_AN_Constants.OC_AN_Create_Internal_User_DE);
        String requestBody;
		string dataExtCustomerkey = OC_AN_Constants.EXTERNALDISTRIBUTION  + emailContentAndAccessToken.get(BULLETIN_ID);
       
        requestBody = OC_AN_MC_Automation_Helper.createSQLQuery_EDArchive(emailContentAndAccessToken.get(BULLETIN_DATA_EXTENSION_ID), emailContentAndAccessToken.get(ACCESS_TOKEN), emailContentAndAccessToken.get(BULLETIN_ID), OC_AN_Constants.EXTERNALDISTRIBUTION, sfmc_Config, dataExtCustomerkey, dataExtCustomerkey);
        system.debug('requestBody Archive SQL===>'+requestBody);
		HttpResponse response = OC_IB_IntegrationBaseClass.RequestGenerationcallout(requestBody, getSoapHTTPHeaders(), mdt.OC_IB_EndPointUrl__c, mdt.OC_IB_RequestType__c);
        system.debug('response archive ====>'+response.getBody());
		XmlStreamReader reader = new XmlStreamReader(response.getBody());
		OC_AN_XMLParser xmlParser = new OC_AN_XMLParser();
		List<String> newObjectIds = xmlParser.parseBooks(reader);
        system.debug('newObjectIds Archive===>'+newObjectIds);
		return newObjectIds;
	}

	/**************************************************************************************************
	 * @Method Name : createAutomationProcess
	 * @Description : Creates Automation Process in Marketing Cloud
	 * @Param       : Map<String, String> emailContentAndAccessToken
	 * @Return      : String
	 ****************************************************************************************************/
	public static String createAutomationProcess(Map<String, String> emailContentAndAccessToken){
		OC_IB_OutboundIntegrationIdentifier__mdt mdt = mdtMap.get(OC_AN_Constants.OC_AN_Create_Internal_User_DE);

		String targetName = OC_AN_Constants.AUTOMATION_CREATION_EXTERNAL_NAME + emailContentAndAccessToken.get(BULLETIN_ID);
		String requestBody = OC_AN_MC_Automation_Helper.createAutomationProcess_EDFinal(emailContentAndAccessToken.get(ACCESS_TOKEN), emailContentAndAccessToken.get(BULLETIN_ID), OC_AN_Constants.EXTERNAL_DISTRIBUTION_NAME_PRESET, sfmc_Config, emailContentAndAccessToken.get(OC_AN_Constants.AUTOMATION_EXTRA_SQL), targetName, targetName,emailContentAndAccessToken.get('ArchiveSQLID') );
		HttpResponse response = OC_IB_IntegrationBaseClass.RequestGenerationcallout(requestBody, getSoapHTTPHeaders(), mdt.OC_IB_EndPointUrl__c, mdt.OC_IB_RequestType__c);
		XmlStreamReader reader = new XmlStreamReader(response.getBody());
		OC_AN_XMLParser xmlParser = new OC_AN_XMLParser();
		List<String> newObjectIds = xmlParser.parseBooks(reader);
		return newObjectIds.get(0);
	}

	/**************************************************************************************************
	 * @Method Name : createExternalJourney
	 * @Description : Creates Journey Id
	 * @Param       : Map<String, String> emailContentAndAccessToken
	 * @Return      : String
	 ****************************************************************************************************/
	public static String createExternalJourney(Map<String, String> emailContentAndAccessToken){
		OC_IB_OutboundIntegrationIdentifier__mdt mdt = mdtMap.get(OC_AN_Constants.OC_AN_Create_Journey);
		
		// String requestBody = OC_AN_MC_ID_Journey_Util.getExternalJourneyRestBody(emailContentAndAccessToken.get(BULLETIN_ID), emailContentAndAccessToken.get(BULLETIN_NAME), Integer.valueOf(emailContentAndAccessToken.get(EMAIL_ID)), emailContentAndAccessToken.get(BULLETIN_DATA_EXTENSION_ID), sfmc_Config, OC_AN_Constants.EXTERNAL_DISTRIBUTION_NAME_PRESET);
		String requestBody = OC_AN_MC_ID_Journey_Util.getExternalJourneyRestBodyU2984U2990(emailContentAndAccessToken.get(BULLETIN_ID), emailContentAndAccessToken.get(BULLETIN_NAME), Integer.valueOf(emailContentAndAccessToken.get(EMAIL_ID)), emailContentAndAccessToken.get(BULLETIN_DATA_EXTENSION_ID), sfmc_Config, OC_AN_Constants.EXTERNAL_DISTRIBUTION_NAME_PRESET);
		HttpResponse response = OC_IB_IntegrationBaseClass.RequestGenerationcallout(requestBody, getRESTHttpHeaders(emailContentAndAccessToken.get(ACCESS_TOKEN)), mdt.OC_IB_EndPointUrl__c, mdt.OC_IB_RequestType__c);
		String responseValue = OC_IB_ResponseHandler.handleResponseCallouts(response, OC_AN_Constants.OC_AN_Create_Journey);
		return responseValue;
	}

	/**************************************************************************************************
	 * @Method Name : publishExternalJourney
	 * @Description : Executes Journey Request
	 * @Param       : Map<String, String> emailContentAndAccessToken
	 * @Return      : String
	 ****************************************************************************************************/
	public static String publishExternalJourney(Map<String, String> emailContentAndAccessToken){
		OC_IB_OutboundIntegrationIdentifier__mdt mdt = mdtMap.get(OC_AN_Constants.OC_AN_Execute_Journey);
		
		String endPoint = mdt.OC_IB_EndPointUrl__c + emailContentAndAccessToken.get(BULLETIN_JOURNEY_ID)+OC_AN_Constants.JOURNEY_PUBLISH_URL_VERSION;
		HttpResponse response = OC_IB_IntegrationBaseClass.RequestGenerationcallout(null, getRESTHttpHeaders(emailContentAndAccessToken.get(ACCESS_TOKEN)), endPoint, mdt.OC_IB_RequestType__c);
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
		if (mdtMap == null || mdtMap.size() == 0){
			mdtMap = OC_IB_Utility.getIntegrationIdentifierMdtRecordvalues(mdt_const);
		}
		String accessToken = OC_AN_HandleExtCalloutBulletin.createAccessToken();
		emailContentAndAccessToken.put(ACCESS_TOKEN, accessToken);
		OC_IB_OutboundIntegrationIdentifier__mdt mdt = mdtMap.get(OC_AN_Constants.OC_AN_Create_Internal_User_DE);
		
		String requestBody = OC_AN_MC_AutomationActivityUtils.startAutomation(emailContentAndAccessToken.get(BULLETIN_AUTOMATION_ID), emailContentAndAccessToken.get(ACCESS_TOKEN));
		HttpResponse response = OC_IB_IntegrationBaseClass.RequestGenerationcallout(requestBody, getSoapHTTPHeaders(), mdt.OC_IB_EndPointUrl__c, mdt.OC_IB_RequestType__c);
	}

	/**************************************************************************************************
	 * @Method Name : getSoapHeaders
	 * @Description : Returns the SOAP HTTP headers for a call to Marketing Cloud
	 * @Param       : 
	 * @Return      : Map<String, String> HTTP Header values.
	 ****************************************************************************************************/
	private static Map<String,String> getSoapHTTPHeaders(){
		Map<String, String> headerMap = new Map<String, String>();
		headerMap.put(OC_AN_Constants.CONTENT_TYPE, OC_AN_Constants.APPLICATION_SOAP);
		return headerMap;
	}

	/**************************************************************************************************
	 * @Method Name : getRESTHttpHeaders
	 * @Description : Returns the REST HTTP headers for a call to Marketing Cloud
	 * @Param       : 
	 * @Return      : Map<String, String> HTTP Header values.
	 ****************************************************************************************************/
	private static Map<String,String> getRESTHttpHeaders(String accessToken){
		Map<String, String> headerMap = new Map<String, String>();
		headerMap.put(OC_AN_Constants.CONTENT_TYPE, OC_AN_Constants.APPLICATION_JSON);
		headerMap.put(OC_AN_Constants.AUTHORIZATION, OC_AN_Constants.BEARER + accessToken);
		return headerMap;
	}
    
    public static void updateBulletin(Map<String, String> emailContentAndAccessToken){
		try{
			OC_AN_Bulletin__c bulletinSObj = [SELECT Id, Name, OC_AN_MC_Email_Id__c, OC_AN_Body_Of_Bulletin__c,OC_AN_ExternalAutomationId__c, OC_AN_MC_Internal_DE_Id__c, OC_AN_MC_Journey_Id__c, OC_AN_Internal_Body_Of_Bulletin__c
			                                  FROM OC_AN_Bulletin__c
			                                  WHERE Id = :emailContentAndAccessToken.get(BULLETIN_ID)
			                                  LIMIT 1];
            system.debug('External AutomationId===>'+emailContentAndAccessToken.get(BULLETIN_ExternalAUTOMATION_ID));
			bulletinSObj.OC_AN_ExternalAutomationId__c = emailContentAndAccessToken.get(BULLETIN_ExternalAUTOMATION_ID);
            system.debug('External JourneyId===>'+emailContentAndAccessToken.get(BULLETIN_JOURNEY_ID));
			bulletinSObj.OC_AN_ExternalJourneyId__c = emailContentAndAccessToken.get(BULLETIN_JOURNEY_ID);
			bulletinSObj.OC_AN_MC_Email_Id__c = emailContentAndAccessToken.get(EMAIL_ID);
			update bulletinSObj;
		} catch (Exception e){
			EventLog.createLog(new EventLog.Error(OC_AN_Constants.OC_AN_HandleCalloutWhenBulletinApproved,OC_AN_Constants.updateBulletin,null, false, e));
		}
	}
}