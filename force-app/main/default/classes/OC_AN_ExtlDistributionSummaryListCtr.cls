/**
* @File Name          : OC_AN_ExtlDistributionSummaryListCtr 
* @Description        : Controller class for OC_AN_ExternalDistributionSummaryList Aura component.
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 10 August 2021
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-08-10                IBM                   Initial Version
**/


public with sharing class OC_AN_ExtlDistributionSummaryListCtr {
    
    private static final String endPoint = 'https://mcs82tyyyzfmk1mrbbjnd1m9f5l4.soap.marketingcloudapis.com/Service.asmx';
    
    /**************************************************************************************************
	* @Method Name : getExternalDistributionListSummary
	* @Description : Returns the list of the contacts to which email has been sent.
	* @Param       : bulletinId - id of the bulletin for which we require the external distribution user list.
	* @Return      : List of Contacts
	****************************************************************************************************/
    
    @AuraEnabled 
    public static List<Contact> getExternalDistributionListSummary(Id bulletinId){
        Map<String, String> headerMap = new Map<String, String>();
        List<Id> contactListId = new List<Id>();
        List<Contact> contactListToReturn = new List<Contact>();
        
        headerMap.put(OC_AN_Constants.CONTENT_TYPE, OC_AN_Constants.APPLICATION_SOAP);
        try{
            String accessToken = createAccessToken();
            
            String soapRequest =  '<?xml version="1.0" encoding="UTF-8"?>'+
                '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'+
                '<s:Header>'+
                '<a:Action s:mustUnderstand="1">Retrieve</a:Action>'+
                '<a:To s:mustUnderstand="1">'+ endPoint +'</a:To>'+
                '<fueloauth xmlns="http://exacttarget.com">'+ accessToken +'</fueloauth>'+
                '</s:Header>'+
                '<s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'+
                '<RetrieveRequestMsg xmlns="http://exacttarget.com/wsdl/partnerAPI">'+
                '<RetrieveRequest>'+
                '<ObjectType>DataExtensionObject[ExternalUsers_Archive]</ObjectType>'+
                '<Properties>ContactId</Properties>'+
                '<Filter xsi:type="SimpleFilterPart">'+
                '<Property>Bulletin_Id</Property>'+
                '<SimpleOperator>equals</SimpleOperator>'+
                '<Value>'+ bulletinId +'</Value>'+
                '</Filter>'+
                '</RetrieveRequest>'+
                '</RetrieveRequestMsg>'+
                '</s:Body>'+
                '</s:Envelope>';
            
            HttpResponse response = OC_IB_IntegrationBaseClass.RequestGenerationcallout(soapRequest, headerMap, endPoint, OC_AN_Constants.httpMethodPOST);
            String returnedResponse = response.getBody();
            if(!Test.isRunningTest()){
                contactListId = OC_AN_SOAPParser.fetchListOfContactIdFromResponse(response.getBody());
            }
            contactListToReturn = [SELECT Id,Name,Account.Name ,Email From Contact Where Id IN :contactListId 
                                   ORDER BY Account.Name];
            
            
        } catch (Exception e){
            EventLog.createLog(new EventLog.Error(OC_AN_Constants.OC_AN_ExtlDistributionSummaryListCtr, OC_AN_Constants.getExternalDistributionListSummary, null, false, e));
        }
        return contactListToReturn;
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