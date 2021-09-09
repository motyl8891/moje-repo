public with sharing class OC_AN_MC_Journey_Util {
   

    private static final String SEND_CLASSIFICATION = 'OC_AN_SendClassificationId';
    private static final String DELIVERY_PROFILE_ACCOUNT = 'OC_AN_DeliveryProfileId';
    public static final String EVENT_SOURCE_TYPE_NAME = 'DEAudience-';

    public static String getJourneyRestBody(String namePreset, String bulletinId, String bulletinName, Integer emailId, String dataExtensionId, Map<String, String> sfmc_Config){
        OC_AN_MC_ID_Journey_JSON jsonVo = new OC_AN_MC_ID_Journey_JSON();

        // Basic parameters (Verified)
        jsonVo.key = namePreset+bulletinId;
        jsonVo.name = namePreset + bulletinId; 
        jsonVo.workflowApiVersion = 1;
        jsonVo.entryMode = 'MultipleEntries';
        jsonVo.definitionType = 'Multistep';
        jsonVo.defaults = new OC_AN_MC_ID_Journey_JSON.Defaults();
        jsonVo.defaults.email = new List<String>();
        jsonVo.defaults.email.add('{{Event.'+EVENT_SOURCE_TYPE_NAME+bulletinId+'.\"Email\"}}');

        // Activities
        jsonVo.Activities = new List<OC_AN_MC_ID_Journey_JSON.Activities>();
        // Email activity
        OC_AN_MC_ID_Journey_JSON.Activities email = new OC_AN_MC_ID_Journey_JSON.Activities();
        email.key = 'EMAILV2-1';
        email.name = bulletinName+'_'+bulletinId;
        email.type = 'EMAILV2';
        email.outcomes = new List<OC_AN_MC_ID_Journey_JSON.Outcomes>();
        OC_AN_MC_ID_Journey_JSON.Outcomes outcomesEmail = new OC_AN_MC_ID_Journey_JSON.Outcomes();
        outcomesEmail.next = 'WAITBYDURATION-1';
        email.outcomes.add(outcomesEmail);
        email.configurationArguments = new OC_AN_MC_ID_Journey_JSON.ConfigurationArguments();
        email.configurationArguments.isModified = true;
        email.configurationArguments.applicationExtensionKey = 'jb-email-activity';
        email.configurationArguments.triggeredSend = new OC_AN_MC_ID_Journey_JSON.TriggeredSend();
        email.configurationArguments.triggeredSend.autoAddSubscribers = true;
        email.configurationArguments.triggeredSend.autoUpdateSubscribers = true;
        email.configurationArguments.triggeredSend.emailId = emailId;
        email.configurationArguments.triggeredSend.dynamicEmailSubject = bulletinName; // Strange, the validation works a whole lot better with this set.
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

        // Wait Duration
        OC_AN_MC_ID_Journey_JSON.Activities waitActivity1 = new OC_AN_MC_ID_Journey_JSON.Activities();
        waitActivity1.key = 'WAITBYDURATION-1';
        waitActivity1.name = '1 minute';
        waitActivity1.type = 'WAIT';
        waitActivity1.outcomes = new List<OC_AN_MC_ID_Journey_JSON.Outcomes>();
        waitActivity1.configurationArguments = new OC_AN_MC_ID_Journey_JSON.ConfigurationArguments();
        waitActivity1.configurationArguments.waitDuration = 1;
        waitActivity1.configurationArguments.waitUnit = 'MINUTES';       
        waitActivity1.configurationArguments.timeZone = 'India Standard Time';       
        waitActivity1.configurationArguments.specifiedTime = '00:00';       
        jsonVo.Activities.add(waitActivity1);
 
        //Triggers (Verified)
        jsonVo.triggers = new List<OC_AN_MC_ID_Journey_JSON.Triggers>();
        OC_AN_MC_ID_Journey_JSON.Triggers trig = new OC_AN_MC_ID_Journey_JSON.Triggers();        
        trig.key = 'TRIGGER';
        trig.name = 'TRIGGER';
        trig.type = 'AutomationAudience';
        trig.metaData = new OC_AN_MC_ID_Journey_JSON.MetaData_W();
        trig.metaData.eventDefinitionId = dataExtensionId;
        trig.metaData.eventDefinitionKey = EVENT_SOURCE_TYPE_NAME+bulletinId;       // This is what is deciding the DE Source
        trig.metaData.chainType = 'None';
        trig.metaData.configurationRequired = false;
        trig.metaData.iconUrl = '/images/icon-data-extension.svg';
        trig.metaData.title = 'Data Extension';
        trig.metaData.entrySourceGroupConfigUrl = 'jb:///data/entry/audience/entrysourcegroupconfig.json';
        jsonVo.triggers.add(trig);

        String json = System.JSON.serialize(jsonVo,true);
        return json;
    }
}