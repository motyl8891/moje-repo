public with sharing class OC_AN_MC_EventDefinationVo {

    public String type {get;set;} 
    public String name {get;set;} 
    public String mode {get;set;} 
    public String eventDefinitionKey {get;set;} 
    public String dataExtensionId {get;set;} 
    public String iconUrl {get;set;} 
    public Boolean isVisibleInPicker {get;set;} 
    public String automationId {get;set;} 
    public String category {get;set;} 
    public Arguments arguments {get;set;} 

    public class Arguments{
        public String automationId {get;set;} 
        public String eventDefinitionKey {get;set;} 
        public String dataExtensionId {get;set;} 
        
    }

    public static String populate(Map<String,String> argumentValueMap, String internalEventDefination){
        MC_AN_EventDefinitionVo edVo = new MC_AN_EventDefinitionVo();
        edVo.type = 'AutomationAudience';
        edVo.name = argumentValueMap.get(OC_AN_HandleCalloutWhenBulletinApproved.BULLETIN_ID);
        edVo.mode = 'Production';
        edVo.eventDefinitionKey = OC_AN_MC_ID_Journey_Util.EVENT_SOURCE_TYPE_NAME + argumentValueMap.get(OC_AN_HandleCalloutWhenBulletinApproved.BULLETIN_ID)+internalEventDefination;
        edVo.dataExtensionId = argumentValueMap.get(OC_AN_HandleCalloutWhenBulletinApproved.BULLETIN_DATA_EXTENSION_ID);
        edVo.iconUrl = '/images/icon-data-extension.svg';
        edVo.isVisibleInPicker = false;
        edVo.automationId =  argumentValueMap.get(OC_AN_HandleCalloutWhenBulletinApproved.BULLETIN_AUTOMATION_ID);
        edVo.category = 'Audience';
        edVo.arguments = new MC_AN_EventDefinitionVo.Arguments();
        edvo.arguments.automationId = argumentValueMap.get(OC_AN_HandleCalloutWhenBulletinApproved.BULLETIN_AUTOMATION_ID);
        edVo.arguments.eventDefinitionKey = OC_AN_MC_ID_Journey_Util.EVENT_SOURCE_TYPE_NAME + argumentValueMap.get(OC_AN_HandleCalloutWhenBulletinApproved.BULLETIN_ID)+internalEventDefination;
        edVo.arguments.dataExtensionId = argumentValueMap.get(OC_AN_HandleCalloutWhenBulletinApproved.BULLETIN_DATA_EXTENSION_ID);
        return System.JSON.serialize(edVo,true);         
    }
}