/**
* @File Name          : OC_AN_MC_DataExtensionUtils
* @Description        : This class is used to for all the DataExtension Activities in MC.
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2106
* @Created Date       : 20th May 2021
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-05-20                 IBM                   Initial Version
**/
public with sharing class OC_AN_MC_DataExtensionUtils {
    
    // ------------ Substitution values, aka in the SOAP envelope this static values are used to substitute with the arguments to the method.
    private static final String REPLACE_BULLETIN_ID = '{{bulletinId}}';
    private static final String REPLACE_CATEGORY_ID = '{{categoryId}}';
    private static final String REPLACE_ACCESS_TOKEN = '{{dne_etAccessToken}}';
    private static final String REPLACE_SOAP_URL = '{{et_subdomain}}';

    // ------------ Used to parse the response from the SOAP call
    private static final String RESPONSE_CUSTOMER_KEY = 'CustomerKey>';
    private static final String RESPONSE_NEW_OBJECT_ID = 'NewObjectID>'; 
    private static final String RESPONSE_OBJECT_ID = '<ObjectID>';
    private static final String RESPONSE_STATUS_CODE = '<StatusCode>';
    private static final String RESPONSE_STATUS_MESSAGE = '<StatusMessage>';
    private static final String RESPONSE_STATUS_ERROR = 'Error';

    private static final String SOAP_ENVELOPE = '<?xml version="1.0" encoding="UTF-8"?>'+
    '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'+
    '    <s:Header>'+
    '        <a:Action s:mustUnderstand="1">Create</a:Action>'+
    '        <a:To s:mustUnderstand="1">{{et_subdomain}}</a:To>'+
    '        <fueloauth xmlns="http://exacttarget.com">{{dne_etAccessToken}}</fueloauth>'+
    '    </s:Header>'+
    '    <s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'+
    '        <CreateRequest xmlns="http://exacttarget.com/wsdl/partnerAPI">'+
    '            <Objects xsi:type="DataExtension">'+
    '                <CustomerKey>InternalUser_{{bulletinId}}</CustomerKey>'+
    '                <Name>InternalUser_{{bulletinId}}</Name>'+
    '                <IsSendable>true</IsSendable>'+
    '                <CategoryID>{{categoryId}}</CategoryID>' +
    '                <SendableSubscriberField>'+
    '                    <Name>Subscriber Key</Name>'+
    '                    <Value>Email</Value>'+
    '                </SendableSubscriberField>'+
    '                <SendableDataExtensionField>'+
    '                    <CustomerKey>Email</CustomerKey>'+
    '                    <Name>Email</Name>'+
    '                    <FieldType>EmailAddress</FieldType>'+
    '                </SendableDataExtensionField>'+
    '                <Fields>'+
    '                    <Field>'+
    '                        <CustomerKey>Email</CustomerKey>'+
    '                        <Name>Email</Name>'+
    '                        <FieldType>EmailAddress</FieldType>'+
    '                        <IsRequired>true</IsRequired>'+
    '                        <IsPrimaryKey>true</IsPrimaryKey>'+
    '                    </Field>'+
    '                    <Field>'+
    '                        <CustomerKey>First_Name</CustomerKey>'+
    '                        <Name>First_Name</Name>'+
    '                        <FieldType>Text</FieldType>'+
    '                        <MaxLength>100</MaxLength>'+
    '                        <IsRequired>false</IsRequired>'+
    '                        <IsPrimaryKey>false</IsPrimaryKey>'+
    '                    </Field>'+
    '                    <Field>'+
    '                        <CustomerKey>Last_Name</CustomerKey>'+
    '                        <Name>Last_Name</Name>'+
    '                        <FieldType>Text</FieldType>'+
    '                        <MaxLength>100</MaxLength>'+
    '                        <IsRequired>false</IsRequired>'+
    '                        <IsPrimaryKey>false</IsPrimaryKey>'+
    '                    </Field>'+
    '                    <Field>'+
    '                        <CustomerKey>Name</CustomerKey>'+
    '                        <Name>Name</Name>'+
    '                        <FieldType>Text</FieldType>'+
    '                        <MaxLength>200</MaxLength>'+
    '                        <IsRequired>false</IsRequired>'+
    '                        <IsPrimaryKey>false</IsPrimaryKey>'+
    '                    </Field>'+
    '                    <Field>'+
    '                        <CustomerKey>User_Id</CustomerKey>'+
    '                        <Name>User_Id</Name>'+
    '                        <FieldType>Text</FieldType>'+
    '                        <MaxLength>18</MaxLength>'+
    '                        <IsRequired>false</IsRequired>'+
    '                        <IsPrimaryKey>false</IsPrimaryKey>'+
    '                    </Field>'+
    '                    <Field>'+
    '                        <CustomerKey>Is_Internal</CustomerKey>'+
    '                        <Name>Is_Internal</Name>'+
    '                        <FieldType>Boolean</FieldType>'+
    '                        <DefaultValue>True</DefaultValue>'+
    '                        <IsRequired>false</IsRequired>'+
    '                        <IsPrimaryKey>false</IsPrimaryKey>'+
    '                    </Field>'+
    '                    <Field>'+
    '                        <CustomerKey>Bulletin_Id</CustomerKey>'+
    '                        <Name>Bulletin_Id</Name>'+
    '                        <FieldType>Text</FieldType>'+
    '                        <MaxLength>18</MaxLength>'+
    '                        <IsRequired>false</IsRequired>'+
    '                        <IsPrimaryKey>false</IsPrimaryKey>'+
    '                    </Field>'+
	'						<Field>'+
    '                        <CustomerKey>Account__c</CustomerKey>'+
    '                        <Name>Account__c</Name>'+
    '                        <FieldType>Text</FieldType>'+
    '                        <MaxLength>50</MaxLength>'+
    '                        <IsRequired>false</IsRequired>'+
    '                        <IsPrimaryKey>false</IsPrimaryKey>'+
    '                    </Field>'+
	'					<Field>'+
    '                        <CustomerKey>Contact__c</CustomerKey>'+
    '                        <Name>Contact__c</Name>'+
    '                        <FieldType>Text</FieldType>'+
    '                        <MaxLength>50</MaxLength>'+
    '                        <IsRequired>false</IsRequired>'+
    '                        <IsPrimaryKey>false</IsPrimaryKey>'+
    '                    </Field>'+
	'					<Field>'+
    '                        <CustomerKey>Email__c</CustomerKey>'+
    '                        <Name>Email__c</Name>'+
    '                        <FieldType>Boolean</FieldType>'+
    '                        <IsRequired>false</IsRequired>'+
    '                        <IsPrimaryKey>false</IsPrimaryKey>'+
    '                    </Field>'+
	'					<Field>'+
    '                        <CustomerKey>BulletinName</CustomerKey>'+
    '                        <Name>BulletinName</Name>'+
    '                        <FieldType>Text</FieldType>'+
    '                        <MaxLength>50</MaxLength>'+
    '                        <IsRequired>false</IsRequired>'+
    '                        <IsPrimaryKey>false</IsPrimaryKey>'+
    '                    </Field>'+
	'					<Field>'+
    '                        <CustomerKey>Product__c</CustomerKey>'+
    '                        <Name>Product__c</Name>'+
    '                        <FieldType>Text</FieldType>'+
    '                        <MaxLength>50</MaxLength>'+
    '                        <IsRequired>false</IsRequired>'+
    '                        <IsPrimaryKey>false</IsPrimaryKey>'+
    '                    </Field>'+
	'					<Field>'+
    '                        <CustomerKey>User__c</CustomerKey>'+
    '                        <Name>User__c</Name>'+
    '                        <FieldType>Text</FieldType>'+
    '                        <MaxLength>50</MaxLength>'+
    '                        <IsRequired>false</IsRequired>'+
    '                        <IsPrimaryKey>false</IsPrimaryKey>'+
    '                    </Field>'+
	'					<Field>'+
    '                        <CustomerKey>BulletinType</CustomerKey>'+
    '                        <Name>BulletinType</Name>'+
    '                        <FieldType>Text</FieldType>'+
    '                        <MaxLength>50</MaxLength>'+
    '                        <IsRequired>false</IsRequired>'+
    '                        <IsPrimaryKey>false</IsPrimaryKey>'+
    '                    </Field>'+                
    '                </Fields>'+
    '            </Objects>'+
    '        </CreateRequest>'+
    '    </s:Body>'+
    '</s:Envelope>';
    public static final String INTERNAL_LIST = '{{INTERNAL_LIST_NAME}}';

    private static final String SOAP_ENVELOPE_INTERNAL_LISTS = '<?xml version="1.0" encoding="UTF-8"?>'+
    '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'+
    '    <s:Header>'+
    '        <a:Action s:mustUnderstand="1">Create</a:Action>'+
    '        <a:To s:mustUnderstand="1">{{et_subdomain}}</a:To>'+
    '        <fueloauth xmlns="http://exacttarget.com">{{dne_etAccessToken}}</fueloauth>'+
    '    </s:Header>'+
    '    <s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'+
    '        <CreateRequest xmlns="http://exacttarget.com/wsdl/partnerAPI">'+
    '            <Objects xsi:type="DataExtension">'+
    '                <CustomerKey>Internal_{{bulletinId}}_{{INTERNAL_LIST_NAME}}</CustomerKey>'+
    '                <Name>Internal_{{bulletinId}}_{{INTERNAL_LIST_NAME}}</Name>'+
    '                <IsSendable>true</IsSendable>'+
    '                <CategoryID>{{categoryId}}</CategoryID>' +
    '                <SendableSubscriberField>'+
    '                    <Name>Subscriber Key</Name>'+
    '                    <Value>Email</Value>'+
    '                </SendableSubscriberField>'+
    '                <SendableDataExtensionField>'+
    '                    <CustomerKey>Email</CustomerKey>'+
    '                    <Name>Email</Name>'+
    '                    <FieldType>EmailAddress</FieldType>'+
    '                </SendableDataExtensionField>'+
    '                <Fields>'+
    '                    <Field>'+
    '                        <CustomerKey>Email</CustomerKey>'+
    '                        <Name>Email</Name>'+
    '                        <FieldType>EmailAddress</FieldType>'+
    '                        <IsRequired>false</IsRequired>'+
    '                        <IsPrimaryKey>false</IsPrimaryKey>'+
    '                    </Field>'+
    '                    <Field>'+
    '                        <CustomerKey>First_Name</CustomerKey>'+
    '                        <Name>First_Name</Name>'+
    '                        <FieldType>Text</FieldType>'+
    '                        <MaxLength>100</MaxLength>'+
    '                        <IsRequired>false</IsRequired>'+
    '                        <IsPrimaryKey>false</IsPrimaryKey>'+
    '                    </Field>'+
    '                    <Field>'+
    '                        <CustomerKey>Last_Name</CustomerKey>'+
    '                        <Name>Last_Name</Name>'+
    '                        <FieldType>Text</FieldType>'+
    '                        <MaxLength>100</MaxLength>'+
    '                        <IsRequired>false</IsRequired>'+
    '                        <IsPrimaryKey>false</IsPrimaryKey>'+
    '                    </Field>'+
    '                    <Field>'+
    '                        <CustomerKey>Name</CustomerKey>'+
    '                        <Name>Name</Name>'+
    '                        <FieldType>Text</FieldType>'+
    '                        <MaxLength>200</MaxLength>'+
    '                        <IsRequired>false</IsRequired>'+
    '                        <IsPrimaryKey>false</IsPrimaryKey>'+
    '                    </Field>'+
    '                    <Field>'+
    '                        <CustomerKey>User__c</CustomerKey>'+
    '                        <Name>User__c</Name>'+
    '                        <FieldType>Text</FieldType>'+
    '                        <MaxLength>18</MaxLength>'+
    '                        <IsRequired>true</IsRequired>'+
    '                        <IsPrimaryKey>true</IsPrimaryKey>'+
    '                    </Field>'+
    '                    <Field>'+
    '                        <CustomerKey>Is_Internal</CustomerKey>'+
    '                        <Name>Is_Internal</Name>'+
    '                        <FieldType>Boolean</FieldType>'+
    '                        <DefaultValue>True</DefaultValue>'+
    '                        <IsRequired>false</IsRequired>'+
    '                        <IsPrimaryKey>false</IsPrimaryKey>'+
    '                    </Field>'+
    '                    <Field>'+
    '                        <CustomerKey>Bulletin_Id</CustomerKey>'+
    '                        <Name>Bulletin_Id</Name>'+
    '                        <FieldType>Text</FieldType>'+
    '                        <MaxLength>18</MaxLength>'+
    '                        <IsRequired>false</IsRequired>'+
    '                        <IsPrimaryKey>false</IsPrimaryKey>'+
    '                    </Field>'+
    '                    <Field>'+
    '                        <CustomerKey>Account__c</CustomerKey>'+
    '                        <Name>Account__c</Name>'+
    '                        <FieldType>Text</FieldType>'+
    '                        <MaxLength>50</MaxLength>'+
    '                        <IsRequired>false</IsRequired>'+
    '                        <IsPrimaryKey>false</IsPrimaryKey>'+
    '                    </Field>'+
    '                    <Field>'+
    '                        <CustomerKey>Contact__c</CustomerKey>'+
    '                        <Name>Contact__c</Name>'+
    '                        <FieldType>Text</FieldType>'+
    '                        <MaxLength>50</MaxLength>'+
    '                        <IsRequired>false</IsRequired>'+
    '                        <IsPrimaryKey>false</IsPrimaryKey>'+
    '                    </Field>'+
    '                    <Field>'+
    '                        <CustomerKey>Email__c</CustomerKey>'+
    '                        <Name>Email__c</Name>'+
    '                        <FieldType>EmailAddress</FieldType>'+
    '                        <IsRequired>false</IsRequired>'+
    '                        <IsPrimaryKey>false</IsPrimaryKey>'+
    '                    </Field>'+
    '                    <Field>'+
    '                        <CustomerKey>Product__c</CustomerKey>'+
    '                        <Name>Product__c</Name>'+
    '                        <FieldType>Text</FieldType>'+
    '                        <MaxLength>50</MaxLength>'+
    '                        <IsRequired>false</IsRequired>'+
    '                        <IsPrimaryKey>false</IsPrimaryKey>'+
    '                    </Field>'+
    '                        <CustomerKey>Id</CustomerKey>'+
    '                        <Name>Id</Name>'+
    '                        <FieldType>Text</FieldType>'+
    '                        <MaxLength>50</MaxLength>'+
    '                        <IsRequired>false</IsRequired>'+
    '                        <IsPrimaryKey>false</IsPrimaryKey>'+
    '                    </Field>'+
	'					<Field>'+
    '                        <CustomerKey>BulletinType</CustomerKey>'+
    '                        <Name>BulletinType</Name>'+
    '                        <FieldType>Text</FieldType>'+
    '                        <MaxLength>50</MaxLength>'+
    '                        <IsRequired>false</IsRequired>'+
    '                        <IsPrimaryKey>false</IsPrimaryKey>'+
    '                    </Field>'+ 
    '                </Fields>'+ 
    '            </Objects>'+
    '        </CreateRequest>'+
    '    </s:Body>'+
    '</s:Envelope>';

    /**
     * getSoapBodyEnvelope description used to create a new DataExtension in the Alert & Notification data extension folder (4471) and 
     * returns the SOAP Envelope for this operation.
     *
     * ## bulletinId (String): bulletinId The ID of the bulletin 
     * ## accessToken (String): accessToken The new AccessToken to be used.
     * ## urlIncludingServiceAtTheEnd (String): urlIncludingServiceAtTheEnd The URL to Marketing cloud.
     * @@ Return String: Return description will return the created SOAP envelope that can be posted to the correct URL
     */
    public static String getSoapBodyEnvelope(String bulletinId, String accessToken, String urlIncludingServiceAtTheEnd, String categoryId) {
        String returnXmlDataExtensionEnvelope = SOAP_ENVELOPE;
        returnXmlDataExtensionEnvelope = returnXmlDataExtensionEnvelope.replace(REPLACE_BULLETIN_ID, bulletinId);
        returnXmlDataExtensionEnvelope = returnXmlDataExtensionEnvelope.replace(REPLACE_Category_ID, categoryId);
        returnXmlDataExtensionEnvelope = returnXmlDataExtensionEnvelope.replace(REPLACE_ACCESS_TOKEN, accessToken);
        returnXmlDataExtensionEnvelope = returnXmlDataExtensionEnvelope.replace(REPLACE_SOAP_URL, urlIncludingServiceAtTheEnd);
        return returnXmlDataExtensionEnvelope;
    }

    /**
     * getSoapBodyEnvelope description used to create a new DataExtension in the Alert & Notification data extension folder (4471) and 
     * returns the SOAP Envelope for this operation.
     *
     * ## bulletinId (String): bulletinId The ID of the bulletin 
     * ## accessToken (String): accessToken The new AccessToken to be used.
     * ## urlIncludingServiceAtTheEnd (String): urlIncludingServiceAtTheEnd The URL to Marketing cloud.
     * ## listEndingName (String): The ending of the list, we have List1 and List2 that is used to do product filtering on user level.
     * @@ Return String: Return description will return the created SOAP envelope that can be posted to the correct URL
     */
    public static String getSoapInternalListBodyEnvelope(String bulletinId, String accessToken, String urlIncludingServiceAtTheEnd, 
    String listEndingName, String categoryId) {
        String returnXmlDataExtensionEnvelope = SOAP_ENVELOPE_INTERNAL_LISTS;
        returnXmlDataExtensionEnvelope = returnXmlDataExtensionEnvelope.replace(REPLACE_BULLETIN_ID, bulletinId);
        returnXmlDataExtensionEnvelope = returnXmlDataExtensionEnvelope.replace(REPLACE_Category_ID, categoryId);
        returnXmlDataExtensionEnvelope = returnXmlDataExtensionEnvelope.replace(REPLACE_ACCESS_TOKEN, accessToken);
        returnXmlDataExtensionEnvelope = returnXmlDataExtensionEnvelope.replace(REPLACE_SOAP_URL, urlIncludingServiceAtTheEnd);
        returnXmlDataExtensionEnvelope = returnXmlDataExtensionEnvelope.replace(INTERNAL_LIST, listEndingName);
        
        return returnXmlDataExtensionEnvelope;
    }

    /**
     * getResponseDataExtensionId description Used to parse the response from posting the "getSoapBodyEnvelope" to Marketing Cloud.
     * Will eather throw a Exception if there was a error returned from Marketing Cloud (will happen if there is already a DataExtention with this name) or
     * return the new object Id.
     *
     * ## resp (HttpResponse): resp
     * @@ Return String: Returns an List of Strings where the first is the ObjectId and the second is the Customer Key.
     */
    public static String getResponseDataExtensionId(HttpResponse resp){
        return getResponseDataExtensionId(resp.getBody());
    }
    public static String getResponseDataExtensionId(String soapResponse){
        system.debug('soapResponse ===>'+soapResponse);
        String objectIdToReturn ;
        String soapResponseStatus = soapResponse.substring(soapResponse.indexOf(RESPONSE_STATUS_CODE)+RESPONSE_STATUS_CODE.length(), soapResponse.length());
        soapResponseStatus = soapResponseStatus.substring(0,soapResponseStatus.indexOf('<'));
        if( !String.isEmpty(soapResponseStatus) && soapResponseStatus.containsIgnoreCase(RESPONSE_STATUS_ERROR) ){
            String soapResponseError = soapResponse.substring(soapResponse.indexOf(RESPONSE_STATUS_MESSAGE)+RESPONSE_STATUS_MESSAGE.length(), soapResponse.length());
            soapResponseError = soapResponseError.substring(0,soapResponseError.indexOf('<'));
            throw new MCException('MC DataExtension error: '+soapResponseError);         
        }else{
            List<String> newObjectId = new List<String>();
            String objectId = soapResponse.substring(soapResponse.indexOf(RESPONSE_NEW_OBJECT_ID)+RESPONSE_NEW_OBJECT_ID.length(), soapResponse.length());
            objectId = objectId.substring(0,objectId.indexOf('<'));
            newObjectId.add(objectId);
            
            String customerKey = soapResponse.substring(soapResponse.indexOf(RESPONSE_CUSTOMER_KEY)+RESPONSE_CUSTOMER_KEY.length(), soapResponse.length());
            customerKey = customerKey.substring(0,customerKey.indexOf('<'));
            newObjectId.add(customerKey);
     
            if(!newObjectId.isEmpty()){
            objectIdToReturn = newObjectId.get(0);
                }
        }
        return objectIdToReturn;
    }

        // Used to give a Exception back since Marketing Cloud did not like what we did send.
        public class MCException extends Exception{

        }
}