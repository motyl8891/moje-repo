/**
 * @File Name          : OC_AN_MC_ExtDataExtensionUtils
 * @Description        : Used to generate SOAP envelopes to be passed to MarketingCloud and parse the response
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
public class OC_AN_MC_ExtDataExtensionUtils {
    
    //private static final String endPoint= 'https://mcs82tyyyzfmk1mrbbjnd1m9f5l4.soap.marketingcloudapis.com/Service.asmx';
    public  static String accessToken= OC_AN_HandleExtCalloutBulletin.createAccessToken();
   /* public static String createExtDataExtension_ID(String accessToken, String BulletinId, string flowType  ){
        
        OC_AN_MC_AutomationActivityUtils.accessToken=accessToken;
        string dataExtCustomerkey = flowType+OC_AN_Constants.step3+BulletinId;
        string dataExtName= flowType+OC_AN_Constants.step3+BulletinId;
        return OC_AN_MC_ExtDataExtensionUtils.getSoapDataExtBodyEnvelope(dataExtCustomerkey,dataExtName, '', '' ); 
    }  */
    public static String createExtDataExtension_ID(String accessToken, String BulletinId, string flowType,string categoryId,string endPoint  ){
        
        OC_AN_MC_AutomationActivityUtils.accessToken=accessToken;
        string dataExtCustomerkey = flowType+OC_AN_Constants.step3+BulletinId;
        string dataExtName= flowType+OC_AN_Constants.step3+BulletinId;
        return OC_AN_MC_ExtDataExtensionUtils.getSoapDataExtBodyEnvelope(dataExtCustomerkey,dataExtName, categoryId, endPoint ); 
    }  
    
    public static String getSoapDataExtBodyEnvelope(string dataExtCustomerkey,string dataExtName,string categoryId,string endPoint ){
        
        String dataExtension = '<?xml version="1.0" encoding="UTF-8"?>'+
            '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'+
            '    <s:Header>'+
            '        <a:Action s:mustUnderstand="1">Create</a:Action>'+
            '        <a:To s:mustUnderstand="1">'+endPoint+'</a:To>'+
            '        <fueloauth xmlns="http://exacttarget.com">'+accessToken+'</fueloauth>'+
            '    </s:Header>'+
            '    <s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'+
            '        <CreateRequest xmlns="http://exacttarget.com/wsdl/partnerAPI">'+
            '            <Objects xsi:type="DataExtension">'+
            '                <CustomerKey>'+dataExtCustomerkey+'</CustomerKey>'+
            '                <Name>'+dataExtName+'</Name>'+
            '                <IsSendable>true</IsSendable>'+
            '                <CategoryID>'+categoryId+'</CategoryID>' +
            '                <SendableSubscriberField>'+
            '                    <Name>Subscriber Key</Name>'+
            '                    <Value>Email</Value>'+
            '                </SendableSubscriberField>'+
            '                <SendableDataExtensionField>'+
            '                    <CustomerKey>Email</CustomerKey>'+
            '                    <Name>EmailAddress</Name>'+
            '                    <FieldType>EmailAddress</FieldType>'+
            '                </SendableDataExtensionField>'+
            '                <Fields>'+
            '                <Field>'+
            '                        <CustomerKey>Is_Internal</CustomerKey>'+
            '                        <Name>Is_Internal</Name>'+
            '                        <FieldType>Boolean</FieldType>'+
            '                        <DefaultValue>false</DefaultValue>'+
            '                        <IsRequired>false</IsRequired>'+
            '                        <IsPrimaryKey>false</IsPrimaryKey>'+
            '                    </Field>'+
            '                    <Field>'+
            '                        <CustomerKey>Account_Name</CustomerKey>'+
            '                        <Name>Account_Name</Name>'+
            '                        <FieldType>Text</FieldType>'+
            '                        <MaxLength>255</MaxLength>'+    
            '                        <IsRequired>false</IsRequired>'+
            '                        <IsPrimaryKey>false</IsPrimaryKey>'+
            '                    </Field>'+
            '                    <Field>'+
            '                        <CustomerKey>EmailAddress</CustomerKey>'+
            '                        <Name>EmailAddress</Name>'+
            '                        <FieldType>EmailAddress</FieldType>'+
            '                        <MaxLength>254</MaxLength>'+
            '                        <IsRequired>false</IsRequired>'+
            '                        <IsPrimaryKey>false</IsPrimaryKey>'+
            '                    </Field>'+
            '                    <Field>'+
            '                        <CustomerKey>ContactName</CustomerKey>'+
            '                        <Name>ContactName</Name>'+
            '                        <FieldType>Text</FieldType>'+
            '                        <MaxLength>50</MaxLength>'+
            '                        <IsRequired>false</IsRequired>'+
            '                        <IsPrimaryKey>false</IsPrimaryKey>'+
            '                    </Field>'+
            '                    <Field>'+
            '                        <CustomerKey>Account_Id</CustomerKey>'+
            '                        <Name>Account_Id</Name>'+
            '                        <FieldType>Text</FieldType>'+
            '                        <MaxLength>50</MaxLength>'+
            '                        <IsRequired>false</IsRequired>'+
            '                        <IsPrimaryKey>false</IsPrimaryKey>'+
            '                    </Field>'+
            '                    <Field>'+
            '                        <CustomerKey>ContactId</CustomerKey>'+
            '                        <Name>ContactId</Name>'+
            '                        <FieldType>Text</FieldType>'+
            '                        <MaxLength>254</MaxLength>'+
            '                        <IsRequired>true</IsRequired>'+
            '                        <IsPrimaryKey>true</IsPrimaryKey>'+
            '                    </Field>'+
            '                    <Field>'+
            '                        <CustomerKey>LastName</CustomerKey>'+
            '                        <Name>LastName</Name>'+
            '                        <FieldType>Text</FieldType>'+
            '                        <MaxLength>50</MaxLength>'+
            '                        <IsRequired>false</IsRequired>'+
            '                        <IsPrimaryKey>false</IsPrimaryKey>'+
            '                    </Field>'+
            '                    <Field>'+
            '                        <CustomerKey>Preference_Name</CustomerKey>'+
            '                        <Name>Preference_Name</Name>'+
            '                        <FieldType>Text</FieldType>'+
            '                        <MaxLength>50</MaxLength>'+
            '                        <IsRequired>false</IsRequired>'+
            '                        <IsPrimaryKey>false</IsPrimaryKey>'+
            '                    </Field>'+
            '                    <Field>'+
            '                        <CustomerKey>Email__C</CustomerKey>'+
            '                        <Name>Email__C</Name>'+
            '                        <FieldType>Boolean</FieldType>'+
            '                        <IsRequired>false</IsRequired>'+
            '                        <IsPrimaryKey>false</IsPrimaryKey>'+
            '                    </Field>'+
            '                    <Field>'+
            '                        <CustomerKey>User__C</CustomerKey>'+
            '                        <Name>User__C</Name>'+
            '                        <FieldType>Text</FieldType>'+
            '                        <MaxLength>50</MaxLength>'+
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
            '                    <Field>'+
            '                        <CustomerKey>ProductAttribute__c</CustomerKey>'+
            '                        <Name>ProductAttribute__c</Name>'+
            '                        <FieldType>Text</FieldType>'+
            '                        <MaxLength>50</MaxLength>'+
            '                        <IsRequired>false</IsRequired>'+
            '                        <IsPrimaryKey>false</IsPrimaryKey>'+
            '                    </Field>'+
            '                    <Field>'+
            '                        <CustomerKey>OC_AN_Bulletin__c</CustomerKey>'+
            '                        <Name>OC_AN_Bulletin__c</Name>'+
            '                        <FieldType>Text</FieldType>'+
            '                        <MaxLength>18</MaxLength>'+
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
            '                        <CustomerKey>BAP_ID</CustomerKey>'+
            '                        <Name>BAP_ID</Name>'+
            '                        <FieldType>Text</FieldType>'+
            '                        <MaxLength>18</MaxLength>'+
            '                        <IsRequired>false</IsRequired>'+
            '                        <IsPrimaryKey>false</IsPrimaryKey>'+
            '                    </Field>'+
            '                </Fields>'+
            '            </Objects>'+
            '        </CreateRequest>'+
            '    </s:Body>'+
            '</s:Envelope>';
        system.debug('dataExtension->'+dataExtension);  
        return dataExtension;
    }
}