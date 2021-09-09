/**
 * @File Name          : MC_AN_EventDefinitionVo
 * @Description        : Value object class for creating the event defination.
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

public with sharing class MC_AN_EventDefinitionVo {

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
    
    /**************************************************************************************************
	 * @Method Name : populate
	 * @Description : This method will form the request for event defination
	 * @Param       : argumentValueMap - Map contains bulletin id ,dataextensionid,automationId
	 * 				  which requires to create event.
	 * @Param       : internalEventDefination - InternalEventDefination
	 * @Return      : String
	 ****************************************************************************************************/

    public static String populate(Map<String,String> argumentValueMap, String internalEventDefination){
        MC_AN_EventDefinitionVo edVo = new MC_AN_EventDefinitionVo();
        edVo.type = OC_AN_Constants.AUTOMATIONAUDIENCE;
        edVo.name = argumentValueMap.get(OC_AN_HandleCalloutWhenBulletinApproved.BULLETIN_ID);
        edVo.mode = OC_AN_Constants.MODE;
        edVo.eventDefinitionKey = OC_AN_MC_ID_Journey_Util.EVENT_SOURCE_TYPE_NAME + argumentValueMap.get(OC_AN_HandleCalloutWhenBulletinApproved.BULLETIN_ID)+internalEventDefination;
        edVo.dataExtensionId = argumentValueMap.get(OC_AN_HandleCalloutWhenBulletinApproved.BULLETIN_DATA_EXTENSION_ID);
        edVo.iconUrl = OC_AN_Constants.DATAEXTENSION_URL;
        edVo.isVisibleInPicker = false;
        edVo.automationId =  argumentValueMap.get(OC_AN_HandleCalloutWhenBulletinApproved.BULLETIN_AUTOMATION_ID);
        edVo.category = OC_AN_Constants.CATEGORY;
        edVo.arguments = new MC_AN_EventDefinitionVo.Arguments();
        edvo.arguments.automationId = argumentValueMap.get(OC_AN_HandleCalloutWhenBulletinApproved.BULLETIN_AUTOMATION_ID);
        edVo.arguments.eventDefinitionKey = OC_AN_MC_ID_Journey_Util.EVENT_SOURCE_TYPE_NAME + argumentValueMap.get(OC_AN_HandleCalloutWhenBulletinApproved.BULLETIN_ID)+internalEventDefination;
        edVo.arguments.dataExtensionId = argumentValueMap.get(OC_AN_HandleCalloutWhenBulletinApproved.BULLETIN_DATA_EXTENSION_ID);
        return System.JSON.serialize(edVo,true);         
    }
}