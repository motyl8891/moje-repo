/**
 * @File Name          : OC_AN_BulletinServices
 * @Description        : Controller class for DistributionSummary LWC
 * @Author             : IBM
 * @Group              : OmniChannel - Service
 * @Release            : R2109
 * @Created Date       : 20 Aug 2021
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0        2021-08-20                 IBM                   Initial Version
 **/
public with sharing class OC_AN_BulletinServices {
    
     /**************************************************************************************************
	 * @Method Name : sendEmailViaJourney
	 * @Description : Starts send Email Automation 
	 * @Param       : alertIdsList
	 ****************************************************************************************************/
    @Future(callout=true)
    public static void sendEmailViaJourney(List<Id> alertIdsList) {
        List<OC_AN_Bulletin_Account_Product__c> alertsList = [SELECT OC_AN_Bulletin__r.OC_AN_BulletinApprovedDate__c, OC_AN_Bulletin__r.OC_AN_ExternalAutomationId__c, OC_AN_Bulletin__r.LastModifiedDate, OC_AN_Bulletin__r.OC_AN_Delay__c, OC_AN_Bulletin__r.OC_AN_Type__c, OC_AN_Bulletin__r.RecordTypeId, OC_AN_Bulletin__c, OC_AN_Account__c, OC_AN_Account__r.ParentId FROM OC_AN_Bulletin_Account_Product__c WHERE Id IN: alertIdsList];
        Datetime timeStemp = Datetime.now();
        String accessToken = OC_AN_BulletinServices.createAccessToken();
        List<Datetime> dateChecker = null; 
        for (OC_AN_Bulletin_Account_Product__c alertRecord : alertsList) {
            dateChecker = new List<Datetime>();
            dateChecker.add(timeStemp);
            dateChecker.add(alertRecord.OC_AN_Bulletin__r.OC_AN_BulletinApprovedDate__c);
            dateChecker.sort();
            if(
                dateChecker[1] != null 
                && dateChecker[1] == timeStemp 
                && !String.IsBlank(alertRecord.OC_AN_Bulletin__r.OC_AN_ExternalAutomationId__c)
            ) {
                HttpResponse response = OC_IB_IntegrationBaseClass.RequestGenerationcallout(
                    OC_AN_MC_AutomationActivityUtils.startAutomation(alertRecord.OC_AN_Bulletin__r.OC_AN_ExternalAutomationId__c, accessToken)
                    , new Map<String,String>{OC_AN_Constants.CONTENT_TYPE => OC_AN_Constants.APPLICATION_SOAP}
                    , OC_AN_Constants.HTTPS + OC_AN_Constants.MC_INSTANCE + OC_AN_Constants.MC_SOAP_URL
                    , OC_AN_MC_Utils.POST_METHOD_TYPE
                );
            }
        }
    }

    	/**************************************************************************************************
	 * @Method Name : StopInternalJourney
	 * @Description : Stops Journey Request
	 * @Param       : String bulletinId
	 * @Return      : String
	 ****************************************************************************************************/
	public static String stopJourney(List<String> bulletinIdsList) {
        List<OC_AN_Bulletin__c> bulletinsList = [SELECT OC_AN_MC_Journey_Id__c, OC_AN_ExternalJourneyId__c FROM OC_AN_Bulletin__c WHERE Id IN:bulletinIdsList];
		List<String> journeyIdsList = new List<String>();
        for(OC_AN_Bulletin__c bulletinRecord : bulletinsList) {
            journeyIdsList.add(bulletinRecord.OC_AN_MC_Journey_Id__c);
            journeyIdsList.add(bulletinRecord.OC_AN_ExternalJourneyId__c);
        }
        String accessToken = OC_AN_BulletinServices.createAccessToken();
        
        String endPoint = OC_AN_Constants.HTTPS + OC_AN_Constants.MC_INSTANCE + OC_AN_Constants.MC_INTERACTION_REST_URL + OC_AN_Constants.MC_INTERACTION_STOP + bulletinIdsList[0] + OC_AN_Constants.JOURNEY_PUBLISH_URL_VERSION;
		HttpResponse response = OC_IB_IntegrationBaseClass.RequestGenerationcallout(
            null
            ,new Map<String,String>{OC_AN_Constants.CONTENT_TYPE => OC_AN_Constants.Content, OC_AN_Constants.AUTHORIZATION => OC_AN_Constants.BEARER + accessToken}
            ,endPoint
            ,OC_AN_MC_Utils.POST_METHOD_TYPE
        );
		String responseValue = OC_IB_ResponseHandler.handleResponseCallouts(response, OC_AN_Constants.OC_AN_Create_Journey);
		return responseValue;
	}

    public static void stopScheduledJobs(String bulletinId) {
        List<String> jobsToAbort = new List<String>();
        jobsToAbort.add('OC_AN_EX_DE' + bulletinId);
        jobsToAbort.add('OC_AN_IN_' + bulletinId);
        for (CronTrigger job : [SELECT Id
		                        FROM CronTrigger
		                        WHERE CronJobDetail.Name IN :(jobsToAbort)]){
			System.abortJob(job.Id);
		}
    }

           /**************************************************************************************************
	 * @Method Name : createAccessToken
	 * @Description : Generates Access Token
	 * @Param       : null
	 * @Return      : String
	 ****************************************************************************************************/
    public static String createAccessToken(){
        Map<String, String> sfmc_Config = new Map<String, String>();
        Map<String, String> headerMap = new Map<String, String>();
        headerMap.put(OC_AN_Constants.CONTENT_TYPE, OC_AN_Constants.APPLICATION_JSON);
        string username = OC_AN_Constants.userName;
        string password = OC_AN_Constants.password;
        
        for (OC_AN_AlertsAndNotification__mdt config : [SELECT Id, DeveloperName, Values__c
                                                        FROM OC_AN_AlertsAndNotification__mdt
                                                        WHERE DeveloperName =: OC_AN_Constants.MCAccountId]){
                                                            sfmc_Config.put(config.DeveloperName, config.Values__c);
                                                        }
        String requestBody = '{"'+OC_AN_Constants.grantType+'":"'+OC_AN_Constants.clientCreds+'", "'+OC_AN_Constants.clientId+'":"'+username+'", "'+OC_AN_Constants.clientSecret+'":"'+password+'", "'+OC_AN_Constants.accountId+'":"'+sfmc_Config.get('AccountId')+'"}';
        HttpResponse response = OC_IB_IntegrationBaseClass.RequestGenerationcallout(requestBody, headerMap, OC_AN_Constants.accessTokenEndPoint, 'POST');
        String responseValue = OC_IB_ResponseHandler.handleResponseCallouts(response, OC_AN_Constants.OC_AN_Auth_Url);
        return responseValue; 
    }
}