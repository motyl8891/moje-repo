/**
 * @File Name          : OC_AN_MC_DataExtensionUtilsTest
 * @Description        : Test class for OC_AN_MC_DataExtensionUtils.
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


@IsTest
public class OC_AN_MC_DataExtensionUtilsTest {
    static testMethod void testParsing() {
        String returnSoapEnveloper = '<?xml version="1.0" encoding="utf-8"?>'+
    '    <soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'+
    '        <env:Header xmlns:env="http://www.w3.org/2003/05/soap-envelope">'+
    '            <wsa:Action>CreateResponse</wsa:Action>'+
    '            <wsa:MessageID>urn:uuid:21000425-2cb1-467c-ab13-19e7da9ccf68</wsa:MessageID>'+
    '            <wsa:RelatesTo>urn:uuid:afb5d43d-4a36-4f3f-aa19-e1b62dcacb01</wsa:RelatesTo>'+
    '            <wsa:To>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:To>'+
    '            <wsse:Security>'+
    '                <wsu:Timestamp wsu:Id="Timestamp-d2421b82-3a8f-4220-8b2d-026956a0a837">'+
    '                    <wsu:Created>2021-05-06T08:20:34Z</wsu:Created>'+
    '                    <wsu:Expires>2021-05-06T08:25:34Z</wsu:Expires>'+
    '                </wsu:Timestamp>'+
    '            </wsse:Security>'+
    '        </env:Header>'+
    '        <soap:Body>'+
    '            <CreateResponse xmlns="http://exacttarget.com/wsdl/partnerAPI">'+
    '                <Results>'+
    '                    <StatusCode>OK</StatusCode>'+
    '                    <StatusMessage>Data Extension created.</StatusMessage>'+
    '                    <OrdinalID>0</OrdinalID>'+
    '                    <NewID>0</NewID>'+
    '                    <NewObjectID>40a520e9-43ae-eb11-b836-f40343c98e90</NewObjectID>'+
    '                    <Object xsi:type="DataExtension">'+
    '                        <PartnerKey xsi:nil="true" />'+
    '                        <ObjectID>40a520e9-43ae-eb11-b836-f40343c98e90</ObjectID>'+
    '                        <CustomerKey>InternalUser_1234</CustomerKey>'+
    '                        <Name>InternalUser_12344</Name>'+
    '                        <IsSendable>true</IsSendable>'+
    '                        <SendableDataExtensionField>'+
    '                            <PartnerKey xsi:nil="true" />'+
    '                            <ObjectID xsi:nil="true" />'+
    '                            <CustomerKey>Email</CustomerKey>'+
    '                            <Name>Email</Name>'+
    '                            <FieldType>EmailAddress</FieldType>'+
    '                        </SendableDataExtensionField>'+
    '                        <SendableSubscriberField>'+
    '                            <Name>Subscriber Key</Name>'+
    '                            <Value>Email</Value>'+
    '                        </SendableSubscriberField>'+
    '                        <Fields>'+
    '                            <Field>'+
    '                                <PartnerKey xsi:nil="true" />'+
    '                                <ObjectID xsi:nil="true" />'+
    '                                <CustomerKey>Email</CustomerKey>'+
    '                                <Name>Email</Name>'+
    '                                <IsRequired>true</IsRequired>'+
    '                                <IsPrimaryKey>true</IsPrimaryKey>'+
    '                                <FieldType>EmailAddress</FieldType>'+
    '                            </Field>'+
    '                            <Field>'+
    '                                <PartnerKey xsi:nil="true" />'+
    '                                <ObjectID xsi:nil="true" />'+
    '                                <CustomerKey>First_Name</CustomerKey>'+
    '                                <Name>First_Name</Name>'+
    '                                <MaxLength>50</MaxLength>'+
    '                                <IsRequired>false</IsRequired>'+
    '                                <IsPrimaryKey>false</IsPrimaryKey>'+
    '                                <FieldType>Text</FieldType>'+
    '                            </Field>'+
    '                            <Field>'+
    '                                <PartnerKey xsi:nil="true" />'+
    '                                <ObjectID xsi:nil="true" />'+
    '                                <CustomerKey>Last_Name</CustomerKey>'+
    '                                <Name>Last_Name</Name>'+
    '                                <MaxLength>50</MaxLength>'+
    '                                <IsRequired>false</IsRequired>'+
    '                                <IsPrimaryKey>false</IsPrimaryKey>'+
    '                                <FieldType>Text</FieldType>'+
    '                            </Field>'+
    '                            <Field>'+
    '                                <PartnerKey xsi:nil="true" />'+
    '                                <ObjectID xsi:nil="true" />'+
    '                                <CustomerKey>Name</CustomerKey>'+
    '                                <Name>Name</Name>'+
    '                                <MaxLength>100</MaxLength>'+
    '                                <IsRequired>false</IsRequired>'+
    '                                <IsPrimaryKey>false</IsPrimaryKey>'+
    '                                <FieldType>Text</FieldType>'+
    '                            </Field>'+
    '                            <Field>'+
    '                                <PartnerKey xsi:nil="true" />'+
    '                                <ObjectID xsi:nil="true" />'+
    '                                <CustomerKey>User_Id</CustomerKey>'+
    '                                <Name>User_Id</Name>'+
    '                                <MaxLength>50</MaxLength>'+
    '                                <IsRequired>false</IsRequired>'+
    '                                <IsPrimaryKey>false</IsPrimaryKey>'+
    '                                <FieldType>Text</FieldType>'+
    '                            </Field>'+
    '                        </Fields>'+
    '                        <CategoryID>4471</CategoryID>'+
    '                    </Object>'+
    '                </Results>'+
    '                <RequestID>81811d16-a4fa-4bb3-b868-5cf9408ddd5a</RequestID>'+
    '                <OverallStatus>OK</OverallStatus>'+
    '            </CreateResponse>'+
    '        </soap:Body>'+
    '    </soap:Envelope>';
        String result = OC_AN_MC_DataExtensionUtils.getResponseDataExtensionId(returnSoapEnveloper);
        System.assertNotEquals('InternalUser_1234', result, 'Wrong value was returned!');
    }

    
    static testMethod void testParsingTestError() {
        Exception ex = null;
        try{
            String result = OC_AN_MC_DataExtensionUtils.getResponseDataExtensionId('Please throw a Exception <StatusCode>Error</StatusCode>');
        }catch(Exception e){
            ex = e;
        }
        System.assertNotEquals(null, ex, 'No Exception thrown');
    }
    
    static testMethod void getSoapBodyEnvelopeTest() {
        String result = OC_AN_MC_DataExtensionUtils.getSoapBodyEnvelope('bulletinId', 'accessToken', 'urlIncludingServiceAtTheEnd','4471');
        System.assertNotEquals(null, result, 'Body should not be null');
    }

    static testMethod void getSoapInternalListBodyEnvelopeTest() {
        String result = OC_AN_MC_DataExtensionUtils.getSoapInternalListBodyEnvelope('bulletinId', 'accessToken', 'urlIncludingServiceAtTheEnd', 'listEndingName','4471');
        System.assertNotEquals(null, result, 'Body should not be null');
    }

}