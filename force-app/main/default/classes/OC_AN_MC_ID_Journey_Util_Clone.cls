/**
* @File Name          : OC_AN_MC_ID_Journey_Util
* @Description        : This class will create the journey with the supplied parameters
						Common class for both internal and external journey creation.
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 20th May 2021
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-05-20                IBM                   Initial Version
**/


public with sharing class OC_AN_MC_ID_Journey_Util_Clone {
    
    private static final String SEND_CLASSIFICATION = 'OC_AN_SendClassificationId';
    private static final String DELIVERY_PROFILE_ACCOUNT = 'OC_AN_DeliveryProfileId';
	private static final String JOURNEY_NAME_SEPERATOR = '_';
	private static final String SALES_CLOUD_ACTIVITY_NAME = 'SALESCLOUDACTIVITY-1';
	private static final String SALES_CLOUD_ACTIVITY_NAME_2 = 'SALESCLOUDACTIVITY-2';
	private static final String SALES_CLOUD_ACTIVITY = 'SALESCLOUDACTIVITY'; 
	private static final String BULLETIN_ID_NAME = 'OC_AN_Bulletin__c';
	private static final String SALES_CLOUD_ACTION = 'Update';
	private static final String DATA_EXTENSION_BULLETIN_ID = 'Bulletin_Id';
	private static final String BULLETIN_FIELD_TO_UPDATE = 'OC_AN_Email_Sent_to_Internal_Users__c';
	private static final String BULLETIN_FIELD_TO_UPDATE_LABEL = 'Email Sent to Internal Users?';
	private static final String BULLETIN_EX_FIELD_TO_UPDATE = 'OC_AN_Email_Sent_to_External_Users__c';
	private static final String BULLETIN_EX_FIELD_TO_UPDATE_LABEL = 'Email sent to External Contacts?';		
	private static final String SALES_CLOUD_LOOKUP_TYPE = 'salesforceLookup';
	private static final String SALES_CLOUD_UPDATE_MULTIPLE = 'UpdateLastModified';
	private static final String SALES_CLOUD_NO_MULTIPLE = 'DoNotUpdate';
	private static final String SALES_CLOUD_FILEDNAME = 'Id';
	private static final String SALES_CLOUD_FIELDTYPE = 'id';
	private static final String SALES_CLOUD_UPDATETYPE = 'OverWriteNewValue';
	private static final String SALES_CLOUD_TRUE = 'true';
	private static final String SALES_CLOUD_FALSE = 'false';
	private static final String SALES_CLOUD_TYPE = 'boolean';
	private static final String SALES_CLOUD_MAPPINGTYPE = 'Constant';
	private static final String SALES_CLOUD_PROCESS = 'static';
	private static final String SALES_CLOUD_APPLICATION_EXTENSION_KEY = 'Salesforce_Activity';		
	private static final String SALES_CLOUD_EXPRESSION_BULDER_PREFIX = 'Bulletin';


    public static final String EVENT_SOURCE_TYPE_NAME = OC_AN_Constants.DEAudience;
    
    /**************************************************************************************************
	 * @Method Name : getInternalJourneyRestBody
	 * @Description : This will for the rest body for the journey which needs to be created.
	 * @Param       : bulletinId - The bulletin id for which the journey needs to be created.
	 * @Param       : bulletinName - Name of the bulletin
	 * @Param       : emailId - EmailId which has to be added to the journey
	 * @Param       : dataExtensionId - Dataextension for the journey to pick the correct one
	 * @Param       : sfmc_Config - Marketing cloud related confis.
	 * @Return      : flowType - flow type describes internal or external journey
	 ****************************************************************************************************/
	public static String getInternalJourneyRestBody(String bulletinId, String bulletinName, Integer emailId, String dataExtensionId, Map<String, String> sfmc_Config, String flowType){
		OC_AN_MC_ID_Journey_JSON jsonVo = new OC_AN_MC_ID_Journey_JSON();

		// Basic parameters (Verified)
		jsonVo.key = flowType + bulletinId;
		jsonVo.name = flowType + bulletinId;
		jsonVo.workflowApiVersion = 1;
		jsonVo.entryMode = OC_AN_Constants.MULTIPLEENTRIES;
		jsonVo.definitionType = OC_AN_Constants.MULTISTEP;
		jsonVo.defaults = new OC_AN_MC_ID_Journey_JSON.Defaults();
		jsonVo.defaults.email = new List<String>();
		jsonVo.defaults.email.add(OC_AN_Constants.EVENT + EVENT_SOURCE_TYPE_NAME + bulletinId + flowType + OC_AN_Constants.EMAIL);
		// Activities
		jsonVo.Activities = new List<OC_AN_MC_ID_Journey_JSON.Activities>();
		// Email activity
		OC_AN_MC_ID_Journey_JSON.Activities email = new OC_AN_MC_ID_Journey_JSON.Activities();
		email.key = OC_AN_Constants.EMAILV2_1;
		email.name = bulletinName + JOURNEY_NAME_SEPERATOR + bulletinId;
		email.type = OC_AN_Constants.EMAILV2;
		email.outcomes = new List<OC_AN_MC_ID_Journey_JSON.Outcomes>();
		OC_AN_MC_ID_Journey_JSON.Outcomes outcomesEmail = new OC_AN_MC_ID_Journey_JSON.Outcomes();
		outcomesEmail.next = OC_AN_Constants.WAITBYDURATION_1;
		email.outcomes.add(outcomesEmail);
		email.configurationArguments = new OC_AN_MC_ID_Journey_JSON.ConfigurationArguments();
		email.configurationArguments.isModified = true;
		email.configurationArguments.applicationExtensionKey = OC_AN_Constants.JB_EMAIL_ACTIVITY;
		email.configurationArguments.triggeredSend = new OC_AN_MC_ID_Journey_JSON.TriggeredSend();
		email.configurationArguments.triggeredSend.autoAddSubscribers = true;
		email.configurationArguments.triggeredSend.autoUpdateSubscribers = true;
		email.configurationArguments.triggeredSend.emailId = emailId;
		email.configurationArguments.triggeredSend.dynamicEmailSubject = bulletinName;
		email.configurationArguments.triggeredSend.emailSubject = bulletinName;
		email.configurationArguments.triggeredSend.sendClassificationId = sfmc_Config.get(SEND_CLASSIFICATION);
		email.configurationArguments.triggeredSend.deliveryProfileId = sfmc_Config.get(DELIVERY_PROFILE_ACCOUNT);
		email.configurationArguments.triggeredSend.isTrackingClicks = true;
		email.configurationArguments.triggeredSend.isSalesforceTracking = true;
		email.configurationArguments.triggeredSend.isMultipart = true;
		email.configurationArguments.triggeredSend.isSendLogging = true;
		email.configurationArguments.triggeredSend.isStoppedOnJobError = false;
		email.configurationArguments.triggeredSend.priority = 4;
		email.metaData = new OC_AN_MC_ID_Journey_JSON.MetaData_Z();
		email.metaData.isConfigured = true;
		jsonVo.Activities.add(email);

		// Wait Duration 1
		OC_AN_MC_ID_Journey_JSON.Activities waitActivity1 = new OC_AN_MC_ID_Journey_JSON.Activities();
		waitActivity1.key = OC_AN_Constants.WAITBYDURATION_1;
		waitActivity1.name = OC_AN_Constants.ONE_MINUTE;
		waitActivity1.type = OC_AN_Constants.WAIT;
		waitActivity1.outcomes = new List<OC_AN_MC_ID_Journey_JSON.Outcomes>();
        OC_AN_MC_ID_Journey_JSON.Outcomes outcomesWait1 = new OC_AN_MC_ID_Journey_JSON.Outcomes();
        outcomesWait1.next = SALES_CLOUD_ACTIVITY_NAME;  
        waitActivity1.outcomes.add(outcomesWait1);		
		waitActivity1.configurationArguments = new OC_AN_MC_ID_Journey_JSON.ConfigurationArguments();
		waitActivity1.configurationArguments.waitDuration = 1;
		waitActivity1.configurationArguments.waitUnit = OC_AN_Constants.MINUTES;
		waitActivity1.configurationArguments.timeZone = OC_AN_Constants.TIME_IN_IST;
		waitActivity1.configurationArguments.specifiedTime = OC_AN_Constants.TWELVE;
		jsonVo.Activities.add(waitActivity1);

        // Update Bulletin
        OC_AN_MC_ID_Journey_JSON.Activities updateContact = new OC_AN_MC_ID_Journey_JSON.Activities();
        updateContact.key = SALES_CLOUD_ACTIVITY_NAME;
        updateContact.name = SALES_CLOUD_ACTIVITY +JOURNEY_NAME_SEPERATOR + bulletinId;
        updateContact.type = SALES_CLOUD_ACTIVITY;
        updateContact.outcomes = new List<OC_AN_MC_ID_Journey_JSON.Outcomes>();
        OC_AN_MC_ID_Journey_JSON.Outcomes outcomesUpdate = new OC_AN_MC_ID_Journey_JSON.Outcomes();
        outcomesUpdate.next = OC_AN_Constants.WAITBYDURATION_2;  
        updateContact.outcomes.add(outcomesUpdate);
        updateContact.arguments = new OC_AN_MC_ID_Journey_JSON.Arguments();
		updateContact.arguments.version = '1.0';
        updateContact.arguments.objectMap = new OC_AN_MC_ID_Journey_JSON.ObjectMap();
		updateContact.arguments.objectMap.objects = new List<OC_AN_MC_ID_Journey_JSON.Objects>();
		OC_AN_MC_ID_Journey_JSON.Objects contactObject = new OC_AN_MC_ID_Journey_JSON.Objects();
		contactObject.type = BULLETIN_ID_NAME;
		contactObject.order = '1';
        contactObject.action = SALES_CLOUD_ACTION;
		contactObject.lookup = new OC_AN_MC_ID_Journey_JSON.Lookup();
		contactObject.lookup.type = SALES_CLOUD_LOOKUP_TYPE;
		contactObject.lookup.lookupObject = BULLETIN_ID_NAME;
		contactObject.lookup.MultiOutComeOption = SALES_CLOUD_UPDATE_MULTIPLE;
        contactObject.lookup.ZeroOutComeOption = SALES_CLOUD_NO_MULTIPLE;
		contactObject.lookup.steps = new List<OC_AN_MC_ID_Journey_JSON.Steps>();
		OC_AN_MC_ID_Journey_JSON.Steps steps = new OC_AN_MC_ID_Journey_JSON.Steps();
		steps.criteria = new List<OC_AN_MC_ID_Journey_JSON.Criteria>();
		OC_AN_MC_ID_Journey_JSON.Criteria criteria = new OC_AN_MC_ID_Journey_JSON.Criteria();
		criteria.FieldName = SALES_CLOUD_FILEDNAME;
		criteria.FieldValue = '{{Event."'+EVENT_SOURCE_TYPE_NAME + bulletinId + flowType+'"."'+DATA_EXTENSION_BULLETIN_ID+'"}}'; 
		criteria.FieldValueLabel = DATA_EXTENSION_BULLETIN_ID;
		criteria.FieldType = SALES_CLOUD_FIELDTYPE;
		steps.criteria.add(criteria);
		contactObject.lookup.steps.add(steps);
		contactObject.fields = new List<OC_AN_MC_ID_Journey_JSON.Fields>();
		OC_AN_MC_ID_Journey_JSON.Fields fields = new OC_AN_MC_ID_Journey_JSON.Fields();
		fields.UpdateType = SALES_CLOUD_UPDATETYPE;
		fields.Updateable = SALES_CLOUD_TRUE;
		fields.FieldName = BULLETIN_FIELD_TO_UPDATE;
		fields.FieldLabel = BULLETIN_FIELD_TO_UPDATE_LABEL;
		fields.FieldValue = SALES_CLOUD_TRUE;
		fields.FieldValueLabel = SALES_CLOUD_TRUE;
		fields.Required = SALES_CLOUD_FALSE;
		fields.FieldType = SALES_CLOUD_TYPE;
		fields.MappingType = SALES_CLOUD_MAPPINGTYPE;
		fields.Processor = SALES_CLOUD_PROCESS;
		contactObject.fields.add(fields);
		updateContact.arguments.objectMap.objects.add(contactObject);
		updateContact.configurationArguments = new OC_AN_MC_ID_Journey_JSON.ConfigurationArguments();
		updateContact.configurationArguments.applicationExtensionKey = SALES_CLOUD_APPLICATION_EXTENSION_KEY;
		updateContact.metaData = new OC_AN_MC_ID_Journey_JSON.MetaData_Z();
		updateContact.metaData.isConfigured = true;
		updateContact.metaData.expressionBuilderPrefix = SALES_CLOUD_EXPRESSION_BULDER_PREFIX;
        jsonVo.Activities.add(updateContact);

		// Wait Duration 2
		OC_AN_MC_ID_Journey_JSON.Activities waitActivity2 = new OC_AN_MC_ID_Journey_JSON.Activities();
		waitActivity2.key = OC_AN_Constants.WAITBYDURATION_2;
		waitActivity2.name = OC_AN_Constants.ONE_MINUTE;
		waitActivity2.type = OC_AN_Constants.WAIT;
		waitActivity2.outcomes = new List<OC_AN_MC_ID_Journey_JSON.Outcomes>();
		waitActivity2.configurationArguments = new OC_AN_MC_ID_Journey_JSON.ConfigurationArguments();
		waitActivity2.configurationArguments.waitDuration = 1;
		waitActivity2.configurationArguments.waitUnit = OC_AN_Constants.MINUTES;
		waitActivity2.configurationArguments.timeZone = OC_AN_Constants.TIME_IN_IST;
		waitActivity2.configurationArguments.specifiedTime = OC_AN_Constants.TWELVE;
		jsonVo.Activities.add(waitActivity2);

		//Triggers (Verified)
		jsonVo.triggers = new List<OC_AN_MC_ID_Journey_JSON.Triggers>();
		OC_AN_MC_ID_Journey_JSON.Triggers trig = new OC_AN_MC_ID_Journey_JSON.Triggers();
		trig.key = OC_AN_Constants.TYPE_TRIGGER;
		trig.name = OC_AN_Constants.TYPE_TRIGGER;
		trig.type = OC_AN_Constants.AUTOMATIONAUDIENCE;
		trig.metaData = new OC_AN_MC_ID_Journey_JSON.MetaData_W();
		trig.metaData.eventDefinitionId = dataExtensionId;
		trig.metaData.eventDefinitionKey = EVENT_SOURCE_TYPE_NAME + bulletinId + flowType;       // This is what is deciding the DE Source
		trig.metaData.chainType = OC_AN_Constants.NONE;
		trig.metaData.configurationRequired = false;
		trig.metaData.iconUrl = OC_AN_Constants.DATAEXTENSION_URL;
		trig.metaData.title = OC_AN_Constants.DATAEXTENSION;
		trig.metaData.entrySourceGroupConfigUrl = OC_AN_Constants.ENTRYSOURCE_GROUP_CONFIGURL;
		jsonVo.triggers.add(trig);

		String json = System.JSON.serialize(jsonVo, true);
		return json;
	}
   

	/**************************************************************************************************
	 * @Method Name : getExternalJourneyRestBody
	 * @Description : This will for the rest body for the journey which needs to be created.
	 * @Param       : bulletinId - The bulletin id for which the journey needs to be created.
	 * @Param       : bulletinName - Name of the bulletin
	 * @Param       : emailId - EmailId which has to be added to the journey
	 * @Param       : dataExtensionId - Dataextension for the journey to pick the correct one
	 * @Param       : sfmc_Config - Marketing cloud related confis.
	 * @Return      : flowType - flow type describes internal or external journey
	 ****************************************************************************************************/
	public static String getExternalJourneyRestBody(String bulletinId, String bulletinName, Integer emailId, String dataExtensionId, Map<String, String> sfmc_Config, String flowType){
		OC_AN_MC_ID_Journey_JSON jsonVo = new OC_AN_MC_ID_Journey_JSON();		
		// Basic parameters (Verified)
		jsonVo.key = flowType + bulletinId;
		jsonVo.name = flowType + bulletinId;
		jsonVo.workflowApiVersion = 1;
		jsonVo.entryMode = OC_AN_Constants.MULTIPLEENTRIES;
		jsonVo.definitionType = OC_AN_Constants.MULTISTEP;
		jsonVo.defaults = new OC_AN_MC_ID_Journey_JSON.Defaults();
		jsonVo.defaults.email = new List<String>();
		jsonVo.defaults.email.add(OC_AN_Constants.EVENT + EVENT_SOURCE_TYPE_NAME + bulletinId + flowType + OC_AN_Constants.EMAILADDRESS);
		// Activities
		jsonVo.Activities = new List<OC_AN_MC_ID_Journey_JSON.Activities>();
		// Email activity
		OC_AN_MC_ID_Journey_JSON.Activities email = new OC_AN_MC_ID_Journey_JSON.Activities();
		email.key = OC_AN_Constants.EMAILV2_1;
		email.name = bulletinName + JOURNEY_NAME_SEPERATOR + bulletinId;
		email.type = OC_AN_Constants.EMAILV2;
		email.outcomes = new List<OC_AN_MC_ID_Journey_JSON.Outcomes>();
		OC_AN_MC_ID_Journey_JSON.Outcomes outcomesEmail = new OC_AN_MC_ID_Journey_JSON.Outcomes();
		outcomesEmail.next = OC_AN_Constants.WAITBYDURATION_1;
		email.outcomes.add(outcomesEmail);
		email.configurationArguments = new OC_AN_MC_ID_Journey_JSON.ConfigurationArguments();
		email.configurationArguments.isModified = true;
		email.configurationArguments.applicationExtensionKey = OC_AN_Constants.JB_EMAIL_ACTIVITY;
		email.configurationArguments.triggeredSend = new OC_AN_MC_ID_Journey_JSON.TriggeredSend();
		email.configurationArguments.triggeredSend.autoAddSubscribers = true;
		email.configurationArguments.triggeredSend.autoUpdateSubscribers = true;
		email.configurationArguments.triggeredSend.emailId = emailId;
		email.configurationArguments.triggeredSend.dynamicEmailSubject = bulletinName;
		email.configurationArguments.triggeredSend.emailSubject = bulletinName;
		email.configurationArguments.triggeredSend.sendClassificationId = sfmc_Config.get(SEND_CLASSIFICATION);
		email.configurationArguments.triggeredSend.deliveryProfileId = sfmc_Config.get(DELIVERY_PROFILE_ACCOUNT);
		email.configurationArguments.triggeredSend.isTrackingClicks = true;
		email.configurationArguments.triggeredSend.isSalesforceTracking = true;
		email.configurationArguments.triggeredSend.isMultipart = true;
		email.configurationArguments.triggeredSend.isSendLogging = true;
		email.configurationArguments.triggeredSend.isStoppedOnJobError = false;
		email.configurationArguments.triggeredSend.priority = 4;
		email.metaData = new OC_AN_MC_ID_Journey_JSON.MetaData_Z();
		email.metaData.isConfigured = true;
		jsonVo.Activities.add(email);

		// Wait Duration 1
		OC_AN_MC_ID_Journey_JSON.Activities waitActivity1 = new OC_AN_MC_ID_Journey_JSON.Activities();
		waitActivity1.key = OC_AN_Constants.WAITBYDURATION_1;
		waitActivity1.name = OC_AN_Constants.ONE_MINUTE;
		waitActivity1.type = OC_AN_Constants.WAIT;
		waitActivity1.outcomes = new List<OC_AN_MC_ID_Journey_JSON.Outcomes>();
        OC_AN_MC_ID_Journey_JSON.Outcomes outcomesWait1 = new OC_AN_MC_ID_Journey_JSON.Outcomes();
        outcomesWait1.next = SALES_CLOUD_ACTIVITY_NAME;  
        waitActivity1.outcomes.add(outcomesWait1);		
		waitActivity1.configurationArguments = new OC_AN_MC_ID_Journey_JSON.ConfigurationArguments();
		waitActivity1.configurationArguments.waitDuration = 1;
		waitActivity1.configurationArguments.waitUnit = OC_AN_Constants.MINUTES;
		waitActivity1.configurationArguments.timeZone = OC_AN_Constants.TIME_IN_IST;
		waitActivity1.configurationArguments.specifiedTime = OC_AN_Constants.TWELVE;
		jsonVo.Activities.add(waitActivity1);

		// Update Bulletin
        OC_AN_MC_ID_Journey_JSON.Activities updateContact = new OC_AN_MC_ID_Journey_JSON.Activities();
        updateContact.key = SALES_CLOUD_ACTIVITY_NAME;
        updateContact.name = SALES_CLOUD_ACTIVITY +JOURNEY_NAME_SEPERATOR + bulletinId;
        updateContact.type = SALES_CLOUD_ACTIVITY;
        updateContact.outcomes = new List<OC_AN_MC_ID_Journey_JSON.Outcomes>();
        OC_AN_MC_ID_Journey_JSON.Outcomes outcomesUpdate = new OC_AN_MC_ID_Journey_JSON.Outcomes();
        outcomesUpdate.next = OC_AN_Constants.WAITBYDURATION_2;  
        updateContact.outcomes.add(outcomesUpdate);
        updateContact.arguments = new OC_AN_MC_ID_Journey_JSON.Arguments();
		updateContact.arguments.version = '1.0';
        updateContact.arguments.objectMap = new OC_AN_MC_ID_Journey_JSON.ObjectMap();
		updateContact.arguments.objectMap.objects = new List<OC_AN_MC_ID_Journey_JSON.Objects>();
		OC_AN_MC_ID_Journey_JSON.Objects contactObject = new OC_AN_MC_ID_Journey_JSON.Objects();
		contactObject.type = BULLETIN_ID_NAME;
		contactObject.order = '1';
        contactObject.action = SALES_CLOUD_ACTION;
		contactObject.lookup = new OC_AN_MC_ID_Journey_JSON.Lookup();
		contactObject.lookup.type = SALES_CLOUD_LOOKUP_TYPE;
		contactObject.lookup.lookupObject = BULLETIN_ID_NAME;
		contactObject.lookup.MultiOutComeOption = SALES_CLOUD_UPDATE_MULTIPLE;
        contactObject.lookup.ZeroOutComeOption = SALES_CLOUD_NO_MULTIPLE;
		contactObject.lookup.steps = new List<OC_AN_MC_ID_Journey_JSON.Steps>();
		OC_AN_MC_ID_Journey_JSON.Steps steps = new OC_AN_MC_ID_Journey_JSON.Steps();
		steps.criteria = new List<OC_AN_MC_ID_Journey_JSON.Criteria>();
		OC_AN_MC_ID_Journey_JSON.Criteria criteria = new OC_AN_MC_ID_Journey_JSON.Criteria();
		criteria.FieldName = SALES_CLOUD_FILEDNAME;
		criteria.FieldValue = '{{Event."'+EVENT_SOURCE_TYPE_NAME + bulletinId + flowType+'"."'+BULLETIN_ID_NAME+'"}}'; 
		criteria.FieldValueLabel = BULLETIN_ID_NAME;
		criteria.FieldType = SALES_CLOUD_FIELDTYPE;
		steps.criteria.add(criteria);
		contactObject.lookup.steps.add(steps);
		contactObject.fields = new List<OC_AN_MC_ID_Journey_JSON.Fields>();
		OC_AN_MC_ID_Journey_JSON.Fields fields = new OC_AN_MC_ID_Journey_JSON.Fields();
		fields.UpdateType = SALES_CLOUD_UPDATETYPE;
		fields.Updateable = SALES_CLOUD_TRUE;
		fields.FieldName = BULLETIN_EX_FIELD_TO_UPDATE;
		fields.FieldLabel = BULLETIN_EX_FIELD_TO_UPDATE_LABEL;
		fields.FieldValue = SALES_CLOUD_TRUE;
		fields.FieldValueLabel = SALES_CLOUD_TRUE;
		fields.Required = SALES_CLOUD_FALSE;
		fields.FieldType = SALES_CLOUD_TYPE;
		fields.MappingType = SALES_CLOUD_MAPPINGTYPE;
		fields.Processor = SALES_CLOUD_PROCESS;
		contactObject.fields.add(fields);
		updateContact.arguments.objectMap.objects.add(contactObject);
		updateContact.configurationArguments = new OC_AN_MC_ID_Journey_JSON.ConfigurationArguments();
		updateContact.configurationArguments.applicationExtensionKey = SALES_CLOUD_APPLICATION_EXTENSION_KEY;
		updateContact.metaData = new OC_AN_MC_ID_Journey_JSON.MetaData_Z();
		updateContact.metaData.isConfigured = true;
		updateContact.metaData.expressionBuilderPrefix = SALES_CLOUD_EXPRESSION_BULDER_PREFIX;
        jsonVo.Activities.add(updateContact);
		
		// Wait Duration 2
		OC_AN_MC_ID_Journey_JSON.Activities waitActivity2 = new OC_AN_MC_ID_Journey_JSON.Activities();
		waitActivity2.key = OC_AN_Constants.WAITBYDURATION_2;
		waitActivity2.name = OC_AN_Constants.ONE_MINUTE;
		waitActivity2.type = OC_AN_Constants.WAIT;
		waitActivity2.outcomes = new List<OC_AN_MC_ID_Journey_JSON.Outcomes>();
		waitActivity2.configurationArguments = new OC_AN_MC_ID_Journey_JSON.ConfigurationArguments();
		waitActivity2.configurationArguments.waitDuration = 1;
		waitActivity2.configurationArguments.waitUnit = OC_AN_Constants.MINUTES;
		waitActivity2.configurationArguments.timeZone = OC_AN_Constants.TIME_IN_IST;
		waitActivity2.configurationArguments.specifiedTime = OC_AN_Constants.TWELVE;
		jsonVo.Activities.add(waitActivity2);

		//Triggers (Verified)
		jsonVo.triggers = new List<OC_AN_MC_ID_Journey_JSON.Triggers>();
		OC_AN_MC_ID_Journey_JSON.Triggers trig = new OC_AN_MC_ID_Journey_JSON.Triggers();
		trig.key = OC_AN_Constants.TYPE_TRIGGER;
		trig.name = OC_AN_Constants.TYPE_TRIGGER;
		trig.type = OC_AN_Constants.AUTOMATIONAUDIENCE;
		trig.metaData = new OC_AN_MC_ID_Journey_JSON.MetaData_W();
		trig.metaData.eventDefinitionId = dataExtensionId;
		trig.metaData.eventDefinitionKey = EVENT_SOURCE_TYPE_NAME + bulletinId + flowType;       // This is what is deciding the DE Source
		trig.metaData.chainType = OC_AN_Constants.NONE;
		trig.metaData.configurationRequired = false;
		trig.metaData.iconUrl = OC_AN_Constants.DATAEXTENSION_URL;
		trig.metaData.title = OC_AN_Constants.DATAEXTENSION;
		trig.metaData.entrySourceGroupConfigUrl = OC_AN_Constants.ENTRYSOURCE_GROUP_CONFIGURL;
		jsonVo.triggers.add(trig);

		String json = System.JSON.serialize(jsonVo, true);
		return json;
	}
    
	/**************************************************************************************************
	 * @Method Name : getExternalJourneyRestBody
	 * @Description : This will for the rest body for the journey which needs to be created.
	 * @Param       : bulletinId - The bulletin id for which the journey needs to be created.
	 * @Param       : bulletinName - Name of the bulletin
	 * @Param       : emailId - EmailId which has to be added to the journey
	 * @Param       : dataExtensionId - Dataextension for the journey to pick the correct one
	 * @Param       : sfmc_Config - Marketing cloud related confis.
	 * @Return      : flowType - flow type describes internal or external journey
	 ****************************************************************************************************/
	public static String getExternalJourneyRestBodyU2984U2990(String bulletinId, String bulletinName, Integer emailId, String dataExtensionId, Map<String, String> sfmc_Config, String flowType){
		OC_AN_MC_ID_Journey_JSON jsonVo = new OC_AN_MC_ID_Journey_JSON();		
		// Basic parameters (Verified)
		jsonVo.key = flowType + bulletinId;
		jsonVo.name = flowType + bulletinId;
		jsonVo.workflowApiVersion = 1;
		jsonVo.entryMode = OC_AN_Constants.MULTIPLEENTRIES;
		jsonVo.definitionType = OC_AN_Constants.MULTISTEP;
		jsonVo.defaults = new OC_AN_MC_ID_Journey_JSON.Defaults();
		jsonVo.defaults.email = new List<String>();
		jsonVo.defaults.email.add(OC_AN_Constants.EVENT + EVENT_SOURCE_TYPE_NAME + bulletinId + flowType + OC_AN_Constants.EMAILADDRESS);
		// Activities
		jsonVo.Activities = new List<OC_AN_MC_ID_Journey_JSON.Activities>();
		// Email activity
		OC_AN_MC_ID_Journey_JSON.Activities email = new OC_AN_MC_ID_Journey_JSON.Activities();
		email.key = OC_AN_Constants.EMAILV2_1;
		email.name = bulletinName + JOURNEY_NAME_SEPERATOR + bulletinId;
		email.type = OC_AN_Constants.EMAILV2;
		email.outcomes = new List<OC_AN_MC_ID_Journey_JSON.Outcomes>();
		OC_AN_MC_ID_Journey_JSON.Outcomes outcomesEmail = new OC_AN_MC_ID_Journey_JSON.Outcomes();
		outcomesEmail.next = OC_AN_Constants.WAITBYDURATION_1;
		email.outcomes.add(outcomesEmail);
		email.configurationArguments = new OC_AN_MC_ID_Journey_JSON.ConfigurationArguments();
		email.configurationArguments.isModified = true;
		email.configurationArguments.applicationExtensionKey = OC_AN_Constants.JB_EMAIL_ACTIVITY;
		email.configurationArguments.triggeredSend = new OC_AN_MC_ID_Journey_JSON.TriggeredSend();
		email.configurationArguments.triggeredSend.autoAddSubscribers = true;
		email.configurationArguments.triggeredSend.autoUpdateSubscribers = true;
		email.configurationArguments.triggeredSend.emailId = emailId;
		email.configurationArguments.triggeredSend.dynamicEmailSubject = bulletinName;
		email.configurationArguments.triggeredSend.emailSubject = bulletinName;
		email.configurationArguments.triggeredSend.sendClassificationId = sfmc_Config.get(SEND_CLASSIFICATION);
		email.configurationArguments.triggeredSend.deliveryProfileId = sfmc_Config.get(DELIVERY_PROFILE_ACCOUNT);
		email.configurationArguments.triggeredSend.isTrackingClicks = true;
		email.configurationArguments.triggeredSend.isSalesforceTracking = true;
		email.configurationArguments.triggeredSend.isMultipart = true;
		email.configurationArguments.triggeredSend.isSendLogging = true;
		email.configurationArguments.triggeredSend.isStoppedOnJobError = false;
		email.configurationArguments.triggeredSend.priority = 4;
		email.metaData = new OC_AN_MC_ID_Journey_JSON.MetaData_Z();
		email.metaData.isConfigured = true;
		jsonVo.Activities.add(email);

		// Wait Duration 1
		OC_AN_MC_ID_Journey_JSON.Activities waitActivity1 = new OC_AN_MC_ID_Journey_JSON.Activities();
		waitActivity1.key = OC_AN_Constants.WAITBYDURATION_1;
		waitActivity1.name = OC_AN_Constants.ONE_MINUTE;
		waitActivity1.type = OC_AN_Constants.WAIT;
		waitActivity1.outcomes = new List<OC_AN_MC_ID_Journey_JSON.Outcomes>();
        OC_AN_MC_ID_Journey_JSON.Outcomes outcomesWait1 = new OC_AN_MC_ID_Journey_JSON.Outcomes();
        outcomesWait1.next = SALES_CLOUD_ACTIVITY_NAME;  
        waitActivity1.outcomes.add(outcomesWait1);		
		waitActivity1.configurationArguments = new OC_AN_MC_ID_Journey_JSON.ConfigurationArguments();
		waitActivity1.configurationArguments.waitDuration = 1;
		waitActivity1.configurationArguments.waitUnit = OC_AN_Constants.MINUTES;
		waitActivity1.configurationArguments.timeZone = OC_AN_Constants.TIME_IN_IST;
		waitActivity1.configurationArguments.specifiedTime = OC_AN_Constants.TWELVE;
		jsonVo.Activities.add(waitActivity1);

		// Update Bulletin
        OC_AN_MC_ID_Journey_JSON.Activities updateContact = new OC_AN_MC_ID_Journey_JSON.Activities();
        updateContact.key = SALES_CLOUD_ACTIVITY_NAME;
        updateContact.name = SALES_CLOUD_ACTIVITY +JOURNEY_NAME_SEPERATOR + bulletinId;
        updateContact.type = SALES_CLOUD_ACTIVITY;
        updateContact.outcomes = new List<OC_AN_MC_ID_Journey_JSON.Outcomes>();
        OC_AN_MC_ID_Journey_JSON.Outcomes outcomesUpdate = new OC_AN_MC_ID_Journey_JSON.Outcomes();
        outcomesUpdate.next = OC_AN_Constants.WAITBYDURATION_2;  
        updateContact.outcomes.add(outcomesUpdate);
        updateContact.arguments = new OC_AN_MC_ID_Journey_JSON.Arguments();
		updateContact.arguments.version = '1.0';
        updateContact.arguments.objectMap = new OC_AN_MC_ID_Journey_JSON.ObjectMap();
		updateContact.arguments.objectMap.objects = new List<OC_AN_MC_ID_Journey_JSON.Objects>();
		OC_AN_MC_ID_Journey_JSON.Objects contactObject = new OC_AN_MC_ID_Journey_JSON.Objects();
		contactObject.type = BULLETIN_ID_NAME;
		contactObject.order = '1';
        contactObject.action = SALES_CLOUD_ACTION;
		contactObject.lookup = new OC_AN_MC_ID_Journey_JSON.Lookup();
		contactObject.lookup.type = SALES_CLOUD_LOOKUP_TYPE;
		contactObject.lookup.lookupObject = BULLETIN_ID_NAME;
		contactObject.lookup.MultiOutComeOption = SALES_CLOUD_UPDATE_MULTIPLE;
        contactObject.lookup.ZeroOutComeOption = SALES_CLOUD_NO_MULTIPLE;
		contactObject.lookup.steps = new List<OC_AN_MC_ID_Journey_JSON.Steps>();
		OC_AN_MC_ID_Journey_JSON.Steps steps = new OC_AN_MC_ID_Journey_JSON.Steps();
		steps.criteria = new List<OC_AN_MC_ID_Journey_JSON.Criteria>();
		OC_AN_MC_ID_Journey_JSON.Criteria criteria = new OC_AN_MC_ID_Journey_JSON.Criteria();
		criteria.FieldName = SALES_CLOUD_FILEDNAME;
		criteria.FieldValue = '{{Event."'+EVENT_SOURCE_TYPE_NAME + bulletinId + flowType+'"."'+BULLETIN_ID_NAME+'"}}'; 
		criteria.FieldValueLabel = BULLETIN_ID_NAME;
		criteria.FieldType = SALES_CLOUD_FIELDTYPE;
		steps.criteria.add(criteria);
		contactObject.lookup.steps.add(steps);
		contactObject.fields = new List<OC_AN_MC_ID_Journey_JSON.Fields>();
		OC_AN_MC_ID_Journey_JSON.Fields fields = new OC_AN_MC_ID_Journey_JSON.Fields();
		fields.UpdateType = SALES_CLOUD_UPDATETYPE;
		fields.Updateable = SALES_CLOUD_TRUE;
		fields.FieldName = BULLETIN_EX_FIELD_TO_UPDATE;
		fields.FieldLabel = BULLETIN_EX_FIELD_TO_UPDATE_LABEL;
		fields.FieldValue = SALES_CLOUD_TRUE;
		fields.FieldValueLabel = SALES_CLOUD_TRUE;
		fields.Required = SALES_CLOUD_FALSE;
		fields.FieldType = SALES_CLOUD_TYPE;
		fields.MappingType = SALES_CLOUD_MAPPINGTYPE;
		fields.Processor = SALES_CLOUD_PROCESS;
		contactObject.fields.add(fields);
		updateContact.arguments.objectMap.objects.add(contactObject);
		updateContact.configurationArguments = new OC_AN_MC_ID_Journey_JSON.ConfigurationArguments();
		updateContact.configurationArguments.applicationExtensionKey = SALES_CLOUD_APPLICATION_EXTENSION_KEY;
		updateContact.metaData = new OC_AN_MC_ID_Journey_JSON.MetaData_Z();
		updateContact.metaData.isConfigured = true;
		updateContact.metaData.expressionBuilderPrefix = SALES_CLOUD_EXPRESSION_BULDER_PREFIX;
        jsonVo.Activities.add(updateContact);
				
		// Wait Duration 2
		OC_AN_MC_ID_Journey_JSON.Activities waitActivity2 = new OC_AN_MC_ID_Journey_JSON.Activities();
		waitActivity2.key = OC_AN_Constants.WAITBYDURATION_2;
		waitActivity2.name = OC_AN_Constants.ONE_MINUTE;
		waitActivity2.type = OC_AN_Constants.WAIT;
		waitActivity2.outcomes = new List<OC_AN_MC_ID_Journey_JSON.Outcomes>();
		OC_AN_MC_ID_Journey_JSON.Outcomes outcomesWait2 = new OC_AN_MC_ID_Journey_JSON.Outcomes();
        outcomesWait2.next = SALES_CLOUD_ACTIVITY_NAME_2;  
        waitActivity2.outcomes.add(outcomesWait2);
		waitActivity2.configurationArguments = new OC_AN_MC_ID_Journey_JSON.ConfigurationArguments();
		waitActivity2.configurationArguments.waitDuration = 1;
		waitActivity2.configurationArguments.waitUnit = OC_AN_Constants.MINUTES;
		waitActivity2.configurationArguments.timeZone = OC_AN_Constants.TIME_IN_IST;
		waitActivity2.configurationArguments.specifiedTime = OC_AN_Constants.TWELVE;
		jsonVo.Activities.add(waitActivity2);

		// Update Bulletin --- NEWNEWNEW		
        OC_AN_MC_ID_Journey_JSON.Activities updateContact2 = new OC_AN_MC_ID_Journey_JSON.Activities();
        updateContact2.key = SALES_CLOUD_ACTIVITY_NAME_2;
        updateContact2.name = 'Update Bulletin_Account_Product Activity';
        updateContact2.type = SALES_CLOUD_ACTIVITY;
        updateContact2.outcomes = new List<OC_AN_MC_ID_Journey_JSON.Outcomes>();
        OC_AN_MC_ID_Journey_JSON.Outcomes outcomesUpdate2 = new OC_AN_MC_ID_Journey_JSON.Outcomes();
        outcomesUpdate2.next = OC_AN_Constants.WAITBYDURATION_3;  
        updateContact2.outcomes.add(outcomesUpdate2);
        updateContact2.arguments = new OC_AN_MC_ID_Journey_JSON.Arguments();
		updateContact2.arguments.version = '1.0';
        updateContact2.arguments.objectMap = new OC_AN_MC_ID_Journey_JSON.ObjectMap();
		updateContact2.arguments.objectMap.objects = new List<OC_AN_MC_ID_Journey_JSON.Objects>();
		OC_AN_MC_ID_Journey_JSON.Objects contactObject2 = new OC_AN_MC_ID_Journey_JSON.Objects();
		contactObject2.type = 'OC_AN_Bulletin_Account_Product__c';
		contactObject2.order = '1';
        contactObject2.action = SALES_CLOUD_ACTION;
		contactObject2.lookup = new OC_AN_MC_ID_Journey_JSON.Lookup();
		contactObject2.lookup.type = SALES_CLOUD_LOOKUP_TYPE;
		contactObject2.lookup.lookupObject = 'OC_AN_Bulletin_Account_Product__c';
		contactObject2.lookup.MultiOutComeOption = SALES_CLOUD_UPDATE_MULTIPLE;
        contactObject2.lookup.ZeroOutComeOption = SALES_CLOUD_NO_MULTIPLE;
		contactObject2.lookup.steps = new List<OC_AN_MC_ID_Journey_JSON.Steps>();
		OC_AN_MC_ID_Journey_JSON.Steps steps2 = new OC_AN_MC_ID_Journey_JSON.Steps();
		steps2.criteria = new List<OC_AN_MC_ID_Journey_JSON.Criteria>();
		OC_AN_MC_ID_Journey_JSON.Criteria criteria2 = new OC_AN_MC_ID_Journey_JSON.Criteria();
		criteria2.FieldName = SALES_CLOUD_FILEDNAME;
		criteria2.FieldValue = '{{Event."'+EVENT_SOURCE_TYPE_NAME + bulletinId + flowType+'"."'+BULLETIN_ID_NAME+'"}}'; // This will change!
		criteria2.FieldValueLabel = BULLETIN_ID_NAME;
		criteria2.FieldType = SALES_CLOUD_FIELDTYPE;
		steps2.criteria.add(criteria2);
		contactObject2.lookup.steps.add(steps2);
		contactObject2.fields = new List<OC_AN_MC_ID_Journey_JSON.Fields>();
		OC_AN_MC_ID_Journey_JSON.Fields fields2 = new OC_AN_MC_ID_Journey_JSON.Fields();
		fields2.UpdateType = SALES_CLOUD_UPDATETYPE;
		fields2.Updateable = SALES_CLOUD_TRUE;
		fields2.FieldName = 'Oc_an_isExternallyDistributed__c';
		fields2.FieldLabel = 'Oc_an_isExternallyDistributed';
		fields2.FieldValue = SALES_CLOUD_TRUE;
		fields2.FieldValueLabel = SALES_CLOUD_TRUE;
		fields2.Required = SALES_CLOUD_FALSE;
		fields2.FieldType = SALES_CLOUD_TYPE;
		fields2.MappingType = SALES_CLOUD_MAPPINGTYPE;
		fields2.Processor = SALES_CLOUD_PROCESS;
		contactObject2.fields.add(fields2);
		updateContact2.arguments.objectMap.objects.add(contactObject2);
		updateContact2.configurationArguments = new OC_AN_MC_ID_Journey_JSON.ConfigurationArguments();
		updateContact2.configurationArguments.applicationExtensionKey = SALES_CLOUD_APPLICATION_EXTENSION_KEY;
		updateContact2.metaData = new OC_AN_MC_ID_Journey_JSON.MetaData_Z();
		updateContact2.metaData.isConfigured = true;
		updateContact2.metaData.expressionBuilderPrefix = SALES_CLOUD_EXPRESSION_BULDER_PREFIX;
        jsonVo.Activities.add(updateContact2);

		// Wait Duration 3
		OC_AN_MC_ID_Journey_JSON.Activities waitActivity3 = new OC_AN_MC_ID_Journey_JSON.Activities();
		waitActivity3.key = OC_AN_Constants.WAITBYDURATION_3;
		waitActivity3.name = OC_AN_Constants.ONE_MINUTE;
		waitActivity3.type = OC_AN_Constants.WAIT;
		waitActivity3.outcomes = new List<OC_AN_MC_ID_Journey_JSON.Outcomes>();
		waitActivity3.configurationArguments = new OC_AN_MC_ID_Journey_JSON.ConfigurationArguments();
		waitActivity3.configurationArguments.waitDuration = 1;
		waitActivity3.configurationArguments.waitUnit = OC_AN_Constants.MINUTES;
		waitActivity3.configurationArguments.timeZone = OC_AN_Constants.TIME_IN_IST;
		waitActivity3.configurationArguments.specifiedTime = OC_AN_Constants.TWELVE;
		jsonVo.Activities.add(waitActivity3);

		//Triggers (Verified)
		jsonVo.triggers = new List<OC_AN_MC_ID_Journey_JSON.Triggers>();
		OC_AN_MC_ID_Journey_JSON.Triggers trig = new OC_AN_MC_ID_Journey_JSON.Triggers();
		trig.key = OC_AN_Constants.TYPE_TRIGGER;
		trig.name = OC_AN_Constants.TYPE_TRIGGER;
		trig.type = OC_AN_Constants.AUTOMATIONAUDIENCE;
		trig.metaData = new OC_AN_MC_ID_Journey_JSON.MetaData_W();
		trig.metaData.eventDefinitionId = dataExtensionId;
		trig.metaData.eventDefinitionKey = EVENT_SOURCE_TYPE_NAME + bulletinId + flowType;       // This is what is deciding the DE Source
		trig.metaData.chainType = OC_AN_Constants.NONE;
		trig.metaData.configurationRequired = false;
		trig.metaData.iconUrl = OC_AN_Constants.DATAEXTENSION_URL;
		trig.metaData.title = OC_AN_Constants.DATAEXTENSION;
		trig.metaData.entrySourceGroupConfigUrl = OC_AN_Constants.ENTRYSOURCE_GROUP_CONFIGURL;
		jsonVo.triggers.add(trig);

		String json = System.JSON.serialize(jsonVo, true);
		return json;
	}
    
}