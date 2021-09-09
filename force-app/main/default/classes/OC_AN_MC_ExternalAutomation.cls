public class OC_AN_MC_ExternalAutomation {
    // ------------ Substitution values, aka in the SOAP envelope this static values are used to substitute with the arguments to the method.
    private static final String REPLACE_BULLETIN_ID = '{{bulletinId}}';
    private static final String REPLACE_ACCESS_TOKEN = '{{dne_etAccessToken}}';
    private static final String REPLACE_SOAP_URL = '{{et_subdomain}}';
    
    // ------------ Used to parse the response from the SOAP call
    private static final String RESPONSE_CUSTOMER_KEY = 'CustomerKey>';
    private static final String RESPONSE_NEW_OBJECT_ID = 'NewObjectID>'; 
    private static final String RESPONSE_OBJECT_ID = '<ObjectID>';
    private static final String RESPONSE_STATUS_CODE = '<StatusCode>';
    private static final String RESPONSE_STATUS_MESSAGE = '<StatusMessage>';
    private static final String RESPONSE_STATUS_ERROR = 'Error';
    private static final String accessToken= OC_AN_MC_Rest_Callout.accessToken();
    
    
    private static final String SOAP_ENVELOPE = '<?xml version="1.0" encoding="UTF-8"?>'+
'<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'+
'<s:Header>'+
'	<a:Action s:mustUnderstand="1">Create</a:Action>'+
'	<a:To s:mustUnderstand="1">https://mcs82tyyyzfmk1mrbbjnd1m9f5l4.soap.marketingcloudapis.com/Service.asmx</a:To>'+
'	<fueloauth xmlns="http://exacttarget.com">'+accessToken+'</fueloauth>'+
'</s:Header>'+
'<s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'+
'	<CreateRequest xmlns="http://exacttarget.com/wsdl/partnerAPI">'+
'		<Object xsi:type="Automation">'+
'				<PartnerKey xsi:nil="true" />'+
'				<PartnerProperties>'+
'					<Name>AutomationType</Name>'+
'					<Value>Scheduled</Value>'+
'				</PartnerProperties>'+
'				<ObjectID>a41c4d53-0487-495d-b374-3427cc278fcd</ObjectID>'+
'				<CustomerKey>DataViews_Automation</CustomerKey>'+
'				<IsPlatformObject>false</IsPlatformObject>'+
'				<Name>System Data Views MS12</Name>'+
'				<Description />'+
'				<AutomationTasks>'+
'					<AutomationTask>'+
'						<PartnerKey xsi:nil="true" />'+
'						<ObjectID xsi:nil="true" />'+
'						<Activities>'+
'							<Activity>'+
'								<PartnerKey xsi:nil="true" />'+
'								<ObjectID>Test1245634</ObjectID>'+
'								<Name />'+
'								<Description />'+
'								<IsActive>false</IsActive>'+
'								<Definition>'+
'									<PartnerKey xsi:nil="true" />'+
'									<ObjectID xsi:nil="true" />'+
'								</Definition>'+
'								<Sequence>0</Sequence>'+
'							</Activity>'+
'						</Activities>'+
'					</AutomationTask>'+
'				</AutomationTasks>'+
'				<IsActive>true</IsActive>'+
'				<AutomationType>Scheduled</AutomationType>'+
'			</Object>'+
'	</CreateRequest>'+
'</s:Body>'+
'</s:Envelope>';
    
    public static String getSoapBodyEnvelope(String bulletinId, String accessToken, String urlIncludingServiceAtTheEnd) {
        String returnXmlDataExtensionEnvelope = SOAP_ENVELOPE;
        System.debug('---getSoapBodyEnvelope bulletinId:'+bulletinId+' urlIncludingServiceAtTheEnd: '+urlIncludingServiceAtTheEnd+'accessToken:'+accessToken);
        returnXmlDataExtensionEnvelope = returnXmlDataExtensionEnvelope.replace(REPLACE_BULLETIN_ID, bulletinId);
        returnXmlDataExtensionEnvelope = returnXmlDataExtensionEnvelope.replace(REPLACE_ACCESS_TOKEN, accessToken);
        returnXmlDataExtensionEnvelope = returnXmlDataExtensionEnvelope.replace(REPLACE_SOAP_URL, urlIncludingServiceAtTheEnd);
        System.debug('Generated the SOAP request');
        return returnXmlDataExtensionEnvelope;
    }
    
    /**
* getResponseDataExtensionId description Used to parse the response from posting the "getSoapBodyEnvelope" to Marketing Cloud.
* Will eather throw a Exception if there was a error returned from Marketing Cloud (will happen if there is already a DataExtention with this name) or
* return the new object Id.
*
* ## resp (HttpResponse): resp
* @@ Return String: Returns an List of Strngs where the first is the ObjectId and the second is the Customer Key.
*/
    public static String getResponseDataExtensionId(HttpResponse resp){
        return getResponseDataExtensionId(resp.getBody());
    }
    public static String getResponseDataExtensionId(String soapResponse){
        System.debug('SOAP Response: '+soapResponse);
        String soapResponseStatus = soapResponse.substring(soapResponse.indexOf(RESPONSE_STATUS_CODE)+RESPONSE_STATUS_CODE.length(), soapResponse.length());
        soapResponseStatus = soapResponseStatus.substring(0,soapResponseStatus.indexOf('<'));
        System.debug('SOAP Response: '+soapResponseStatus);
        if( !String.isEmpty(soapResponseStatus) && soapResponseStatus.containsIgnoreCase(RESPONSE_STATUS_ERROR) ){
            String soapResponseError = soapResponse.substring(soapResponse.indexOf(RESPONSE_STATUS_MESSAGE)+RESPONSE_STATUS_MESSAGE.length(), soapResponse.length());
            soapResponseError = soapResponseError.substring(0,soapResponseError.indexOf('<'));
            System.debug('SOAP Error: '+soapResponseError);   
            throw new MCException('MC DataExtension error: '+soapResponseError);         
        }else{
            List<String> newObjectId = new List<String>();
            String objectId = soapResponse.substring(soapResponse.indexOf(RESPONSE_NEW_OBJECT_ID)+RESPONSE_NEW_OBJECT_ID.length(), soapResponse.length());
            objectId = objectId.substring(0,objectId.indexOf('<'));
            newObjectId.add(objectId);
            
            String customerKey = soapResponse.substring(soapResponse.indexOf(RESPONSE_CUSTOMER_KEY)+RESPONSE_CUSTOMER_KEY.length(), soapResponse.length());
            customerKey = customerKey.substring(0,customerKey.indexOf('<'));
            newObjectId.add(customerKey);
            
            System.debug(newObjectId);
            return newObjectId.get(1);
        }
    }
    // Used to give a Exception back since Marketing Cloud did not like what we did send.
    public class MCException extends Exception{
        
    }
    
    
}