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
 **/
public class OC_AN_HandleExtCalloutBulletin_Demo {
    public static final String BULLETIN_ID = OC_AN_Constants.BULLETIN_ID;
	public static final String ACCESS_TOKEN = OC_AN_Constants.ACCESS_TOKEN;
    public static final String EMAIL_ID = OC_AN_Constants.EMAIL_ID;
	public static final String BULLETIN_DATA_EXTENSION_ID = OC_AN_Constants.BULLETIN_DATA_EXTENSION_ID;
	public static final String BULLETIN_JOURNEY_ID = OC_AN_Constants.BULLETIN_JOURNEY_ID;
    public static final String BULLETIN_AUTOMATION_ID = OC_AN_Constants.BULLETIN_AUTOMATION_ID;
    public static final String BULLETIN_NAME = OC_AN_Constants.BULLETIN_NAME;

    private static Set<String> mdt_const = new Set<String>{OC_AN_Constants.OC_AN_Auth_Url, OC_AN_Constants.OC_AN_Create_Email, OC_AN_Constants.OC_AN_Create_Internal_User_DE, OC_AN_Constants.OC_AN_Insert_Internal_User, OC_AN_Constants.OC_AN_Create_Journey, OC_AN_Constants.OC_AN_Execute_Journey, OC_AN_Constants.OC_AN_Ex_SQL_Activity, OC_AN_Constants.OC_AN_Ex_Automation};
	private static Map<String, OC_IB_OutboundIntegrationIdentifier__mdt> mdtMap = new Map<String, OC_IB_OutboundIntegrationIdentifier__mdt>();
	private static String emailId = '';
	private static String bulletinDataExtensionId = '';
	private static String journeyId = '';
	private static Map<String,String> sfmc_Config= new Map<String,String> ();//OC_AN_AlertsAndNotification__mdt
    
    @future(callout = true)
	public static void mcRestCallouts(Id bulletinId){//  pass single Id
		for(OC_AN_AlertsAndNotification__mdt config:[Select Id,Label,Values__c from OC_AN_AlertsAndNotification__mdt]){
			sfmc_Config.put(config.Label,config.Values__c);
		}

		mdtMap = OC_IB_Utility.getIntegrationIdentifierMdtRecordvalues(mdt_const);
		String accessToken = createAccessToken();

			Map<String, String> emailContentAndAccessToken = new Map<String, String>();		
			emailContentAndAccessToken.put(BULLETIN_ID, bulletinId);
			emailContentAndAccessToken.put(ACCESS_TOKEN, accessToken);
        
        	OC_AN_Bulletin__c bullitenEmail = [Select id, Name, OC_AN_MC_Email_Id__c
		                                        from OC_AN_Bulletin__c
		                                        where Id = :bulletinId];
			
        	
			emailContentAndAccessToken.put(EMAIL_ID, '1148'); 
        	emailContentAndAccessToken.put(BULLETIN_NAME, bullitenEmail.Name);
        
        	List<String> newObjIds = createExternalUserDataExtension(emailContentAndAccessToken); //Create Data Extension
			emailContentAndAccessToken.put(BULLETIN_DATA_EXTENSION_ID, newObjIds[0]);
                  		        	
        	List<String> newSqlObjIds = createSQLActivity(emailContentAndAccessToken);//Create SQL Activity
			emailContentAndAccessToken.put('NewSqlObjId_Step1', newSqlObjIds[0]);
        	
        	String automationId = createAutomationProcess(emailContentAndAccessToken);//Create Automation Process
			emailContentAndAccessToken.put(BULLETIN_AUTOMATION_ID, automationId);
        	
        	String eventDefinition = createEventDefinition(emailContentAndAccessToken); // Create the event definition to be used in the Journey Creation as the source and triggering event.
        
        	String jounreyId = createExternalJourney(emailContentAndAccessToken);//Create Journey
            system.debug('jounreyId===>'+jounreyId);
			emailContentAndAccessToken.put(BULLETIN_JOURNEY_ID, jounreyId);
			System.debug('Create Journey: ' + newObjIds);
        
        	String journeyIdPublished = publishExternalJourney(emailContentAndAccessToken);// Journey to active state
        	
        	// This needs to be executed 20 minutes after the journey is published (a journey needs to be validated and etc and that takes 15 minutes)
        	//OC_AN_AutomationScheduler scheduledAutomation = new OC_AN_AutomationScheduler(emailContentAndAccessToken,'External','OC_AN_EX');
        	
      
		
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
		headerMap.put('Content-Type', 'application/json');
		String requestBody = '{"grant_type":"client_credentials", "client_id":"jbuia3x9phyi7ygko2ydfct3", "client_secret":"iBpmSICLrYlmOz4q13csLi1h", "account_id":"510003459"}';

		HttpResponse response = OC_IB_IntegrationBaseClass.RequestGenerationcallout(requestBody, headerMap, mdt.OC_IB_EndPointUrl__c, mdt.OC_IB_RequestType__c);
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
		Map<String, String> headerMap = new Map<String, String>();
		headerMap.put('Content-Type', 'application/soap+xml; charset=utf-8');
		String requestBody = OC_AN_MC_ExtDataExtensionUtils.createExtDataExtension_ID(emailContentAndAccessToken.get(ACCESS_TOKEN), emailContentAndAccessToken.get(BULLETIN_ID),'ED');

		HttpResponse responseValue = OC_IB_IntegrationBaseClass.RequestGenerationcallout(requestBody,headerMap,mdt.OC_IB_EndPointUrl__c,'POST');
        XmlStreamReader reader = new XmlStreamReader(responseValue.getBody());
		OC_AN_XMLParser xmlParser = new OC_AN_XMLParser();
		List<String>newObjectIds =  xmlParser.parseBooks(reader);
        System.debug('newObjectIds==>'+newObjectIds);
		return newObjectIds;
	}
    
    	/**************************************************************************************************
	 * @Method Name : createEventDefinition
	 * @Description : To reference the right DataExtension when creating the Journey a EventDefinition is needed.
	 * @Param       : Map<String, String> emailContentAndAccessToken
	 * @Return      : String
	 ****************************************************************************************************/
    
    public static String createEventDefinition(Map<String, String> emailContentAndAccessToken){

		Map<String, String> headerMap = new Map<String, String>();
		headerMap.put('Content-Type', 'application/json');
		headerMap.put('Authorization', 'Bearer ' + emailContentAndAccessToken.get(ACCESS_TOKEN));
        
        String externalEventDEfination = 'ED';
        
		String requestBody = MC_AN_EventDefinitionVo.populate(emailContentAndAccessToken,'ED');
        /* = '{' + 
							 '    "type": "AutomationAudience",' + 
							 '    "name": "' + emailContentAndAccessToken.get(BULLETIN_ID)+'",' + 
							 '    "mode": "Production",' + 
							 '    "eventDefinitionKey": "' + OC_AN_MC_ID_Journey_Util.EVENT_SOURCE_TYPE_NAME + emailContentAndAccessToken.get(BULLETIN_ID)+externalEventDEfination+'",' + 
							 '    "dataExtensionId": "' + emailContentAndAccessToken.get(BULLETIN_DATA_EXTENSION_ID)+'",' + 
							 '    "iconUrl": "/images/icon-data-extension.svg",' + 
							 '    "isVisibleInPicker": false,' + 
							 '    "automationId": "' + emailContentAndAccessToken.get(BULLETIN_AUTOMATION_ID)+'",' + 
							 '    "category": "Audience",' + 
							 '    "arguments": {' + 
							 '       "automationId": "' + emailContentAndAccessToken.get(BULLETIN_AUTOMATION_ID)+'",' + 
							 '       "eventDefinitionKey": "' + OC_AN_MC_ID_Journey_Util.EVENT_SOURCE_TYPE_NAME + emailContentAndAccessToken.get(BULLETIN_ID)+externalEventDEfination+'",' + 
							 '       "dataExtensionId": "' + emailContentAndAccessToken.get(BULLETIN_DATA_EXTENSION_ID)+'"' + 
							 '    }' + 
							 '}';
        */
        
        
		System.debug('createEventDefinition: '+requestBody);
		
		String endPoint = 'https://mcs82tyyyzfmk1mrbbjnd1m9f5l4.rest.marketingcloudapis.com/interaction/v1/eventDefinitions';
		System.debug(endPoint);
		HttpResponse response = OC_IB_IntegrationBaseClass.RequestGenerationcallout(requestBody, headerMap, endPoint, 'POST');
		System.debug('Response from createEventDefinition: '+response.getBody());
		return 'SUCCESS';
	}
    
    	/**************************************************************************************************
	 * @Method Name : createSQLActivity
	 * @Description : Creates SQL Activity in Marketing Cloud
	 * @Param       : Map<String, String> emailContentAndAccessToken
	 * @Return      : String
	 ****************************************************************************************************/
    
    public static List<String> createSQLActivity(Map<String, String> emailContentAndAccessToken){
		OC_IB_OutboundIntegrationIdentifier__mdt mdt = mdtMap.get(OC_AN_Constants.OC_AN_Create_Internal_User_DE);
        String sqlActivityKey = sfmc_Config.get('ED_SQLActivity_TargetKey');
		Map<String, String> headerMap = new Map<String, String>();
		headerMap.put('Content-Type', 'application/soap+xml; charset=utf-8');		
		string dataExtCustomerkey = 'ED'+'_step3_'+emailContentAndAccessToken.get(BULLETIN_ID);
		String requestBody = OC_AN_MC_Automation_Helper.createSQLQuery_ED(
            						emailContentAndAccessToken.get(BULLETIN_DATA_EXTENSION_ID),
									emailContentAndAccessToken.get(ACCESS_TOKEN),	
									emailContentAndAccessToken.get(BULLETIN_ID),
									'ED',
									sfmc_Config,
            						dataExtCustomerkey,
									dataExtCustomerkey
							);
		System.debug('requestBody==>'+requestBody);
		HttpResponse response = OC_IB_IntegrationBaseClass.RequestGenerationcallout(requestBody,headerMap,mdt.OC_IB_EndPointUrl__c,'POST');

		System.debug(response);
		XmlStreamReader reader = new XmlStreamReader(response.getBody());
		OC_AN_XMLParser xmlParser = new OC_AN_XMLParser();
		List<String>newObjectIds =  xmlParser.parseBooks(reader);
        System.debug('newObjectIds==>'+newObjectIds);
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
        String sqlobjid = sfmc_Config.get('ED_Step3_ObjectID');
		Map<String, String> headerMap = new Map<String, String>();
		headerMap.put('Content-Type', 'application/soap+xml; charset=utf-8');		
		String targetName = 'ExternalUser_' +emailContentAndAccessToken.get(BULLETIN_ID);
		String requestBody = OC_AN_MC_Automation_Helper.createAutomationProcess_ED(
									emailContentAndAccessToken.get(ACCESS_TOKEN),	
									emailContentAndAccessToken.get(BULLETIN_ID),
									'ED',
            						sfmc_Config,
									emailContentAndAccessToken.get('NewSqlObjId_Step1'),
            						targetName,
									targetName
							);
        System.debug('Automation Body==>'+requestBody);
		HttpResponse response = OC_IB_IntegrationBaseClass.RequestGenerationcallout(requestBody,headerMap,mdt.OC_IB_EndPointUrl__c,'POST');
		XmlStreamReader reader = new XmlStreamReader(response.getBody());
		OC_AN_XMLParser xmlParser = new OC_AN_XMLParser();
		List<String>newObjectIds =  xmlParser.parseBooks(reader);
        System.debug('newObjectIds==>'+newObjectIds);
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
		Map<String, String> headerMap = new Map<String, String>();
		headerMap.put('Content-Type', 'application/json');
		headerMap.put('Authorization', 'Bearer ' + emailContentAndAccessToken.get(ACCESS_TOKEN));
        System.debug('emailContentAndAccessToken.get(BULLETIN_ID)'+emailContentAndAccessToken.get(BULLETIN_ID));
        System.debug('emailContentAndAccessToken.get(BULLETIN_NAME)'+emailContentAndAccessToken.get(BULLETIN_NAME));
        System.debug('emailContentAndAccessToken.get(EMAIL_ID)'+emailContentAndAccessToken.get(EMAIL_ID));
        System.debug('emailContentAndAccessToken.get(BULLETIN_DATA_EXTENSION_ID)'+emailContentAndAccessToken.get(BULLETIN_DATA_EXTENSION_ID));
		String requestBody = OC_AN_MC_ID_Journey_Util.getJourneyRestBody(emailContentAndAccessToken.get(BULLETIN_ID), emailContentAndAccessToken.get(BULLETIN_NAME), Integer.valueOf(emailContentAndAccessToken.get(EMAIL_ID)), emailContentAndAccessToken.get(BULLETIN_DATA_EXTENSION_ID), sfmc_Config, 'ED');
		System.debug('requestBody->'+requestBody);
		HttpResponse response = OC_IB_IntegrationBaseClass.RequestGenerationcallout(requestBody, headerMap, mdt.OC_IB_EndPointUrl__c, mdt.OC_IB_RequestType__c);
		String responseValue = OC_IB_ResponseHandler.handleResponseCallouts(response, OC_AN_Constants.OC_AN_Create_Journey);
        System.debug('responseValue-->'+responseValue);
        System.debug('responseValue-->'+response.getBody());
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
		Map<String, String> headerMap = new Map<String, String>();
		headerMap.put('Content-Type', 'application/json');
		headerMap.put('Authorization', 'Bearer ' + emailContentAndAccessToken.get(ACCESS_TOKEN));
		String endPoint = mdt.OC_IB_EndPointUrl__c + emailContentAndAccessToken.get(BULLETIN_JOURNEY_ID)+'?versionNumber=1';
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
    
    //@future(callout = true)
	 public static void startAutomationAndRunJourney(Map<String, String> emailContentAndAccessToken){
		if (mdtMap == null || mdtMap.size() == 0){
			mdtMap = OC_IB_Utility.getIntegrationIdentifierMdtRecordvalues(mdt_const);
		}
		String accessToken = OC_AN_HandleCalloutWhenBulletinApproved.createAccessToken();
		emailContentAndAccessToken.put(ACCESS_TOKEN, accessToken);
		OC_IB_OutboundIntegrationIdentifier__mdt mdt = mdtMap.get(OC_AN_Constants.OC_AN_Create_Internal_User_DE);
		Map<String, String> headerMap = new Map<String, String>();
		headerMap.put('Content-Type', 'application/soap+xml; charset=utf-8');
		String requestBody = OC_AN_MC_AutomationActivityUtils.startAutomation(emailContentAndAccessToken.get(BULLETIN_AUTOMATION_ID), emailContentAndAccessToken.get(ACCESS_TOKEN));
		HttpResponse response = OC_IB_IntegrationBaseClass.RequestGenerationcallout(requestBody, headerMap, mdt.OC_IB_EndPointUrl__c, mdt.OC_IB_RequestType__c);
	}

}