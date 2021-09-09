@IsTest
public class OC_AN_XMLParserTest {
    
     static final String TEST_XML = '<?xml version="1.0" encoding="utf-8"?>' + 
					'<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'+
		'    <env:Header xmlns:env="http://www.w3.org/2003/05/soap-envelope">'+
		'        <wsa:Action>CreateResponse</wsa:Action>' + 
					'        <wsa:MessageID>urn:uuid:8aa93cab-1082-4d7f-8f56-e5a06e92c66a</wsa:MessageID>' + 
					'        <wsa:RelatesTo>urn:uuid:50ece874-1999-4f77-93f0-9544b8c3db63</wsa:RelatesTo>' + 
					'        <wsa:To>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:To>'+
		'        <wsse:Security>' + 
					'            <wsu:Timestamp wsu:Id="Timestamp-b111e933-9e8e-4179-b173-d610a781feae">' + 
					'                <wsu:Created>2021-05-13T05:18:20Z</wsu:Created>' + 
					'                <wsu:Expires>2021-05-13T05:23:20Z</wsu:Expires>' + 
					'            </wsu:Timestamp>' + 
					'        </wsse:Security>' + 
					'    </env:Header>' + 
					'    <soap:Body>' + 
					'        <CreateResponse xmlns="http://exacttarget.com/wsdl/partnerAPI">'+
		'            <Results>' + 
					'                <StatusCode>OK</StatusCode>' + 
					'                <StatusMessage>Data Extension created.</StatusMessage>' + 
					'                <OrdinalID>0</OrdinalID>' + 
					'                <NewID>0</NewID>' + 
					'                <NewObjectID>d8925b9b-aab3-eb11-b836-f40343c98e90</NewObjectID>' + 
					'                <Object xsi:type="DataExtension">' + 
					'                    <PartnerKey xsi:nil="true" />' + 
					'                    <ObjectID>d8925b9b-aab3-eb11-b836-f40343c98e90</ObjectID>' + 
					'                    <CustomerKey>ED_step1_BID7</CustomerKey>' + 
					'                    <Name>ED_step1_BID7</Name>' + 
					'                    <IsSendable>true</IsSendable>' + 
					'                    <SendableDataExtensionField>' + 
					'                        <PartnerKey xsi:nil="true" />' + 
					'                        <ObjectID xsi:nil="true" />' + 
					'                        <CustomerKey>Email</CustomerKey>' + 
					'                        <Name>EmailAddress</Name>' + 
					'                        <FieldType>EmailAddress</FieldType>' + 
					'                    </SendableDataExtensionField>' + 
					'                    <SendableSubscriberField>' + 
					'                        <Name>Subscriber Key</Name>' + 
					'                        <Value>Email</Value>' + 
					'                    </SendableSubscriberField>' + 
					'                    <Fields>' + 
					'                        <Field>' + 
					'                            <PartnerKey xsi:nil="true" />' + 
					'                            <ObjectID xsi:nil="true" />' + 
					'                            <CustomerKey>Account_Name</CustomerKey>' + 
					'                            <Name>Account_Name</Name>' + 
					'                            <MaxLength>255</MaxLength>' + 
					'                            <IsRequired>false</IsRequired>' + 
					'                            <IsPrimaryKey>false</IsPrimaryKey>' + 
					'                            <FieldType>Text</FieldType>' + 
					'                        </Field>' + 
					'                        <Field>' + 
					'                            <PartnerKey xsi:nil="true" />' + 
					'                            <ObjectID xsi:nil="true" />' + 
					'                            <CustomerKey>EmailAddress</CustomerKey>' + 
					'                            <Name>EmailAddress</Name>' + 
					'                            <MaxLength>254</MaxLength>' + 
					'                            <IsRequired>false</IsRequired>' + 
					'                            <IsPrimaryKey>false</IsPrimaryKey>' + 
					'                            <FieldType>EmailAddress</FieldType>' + 
					'                        </Field>' + 
					'                        <Field>' + 
					'                            <PartnerKey xsi:nil="true" />' + 
					'                            <ObjectID xsi:nil="true" />' + 
					'                            <CustomerKey>ContactName</CustomerKey>' + 
					'                            <Name>ContactName</Name>' + 
					'                            <MaxLength>50</MaxLength>' + 
					'                            <IsRequired>false</IsRequired>' + 
					'                            <IsPrimaryKey>false</IsPrimaryKey>' + 
					'                            <FieldType>Text</FieldType>' + 
					'                        </Field>' + 
					'                        <Field>' + 
					'                            <PartnerKey xsi:nil="true" />' + 
					'                            <ObjectID xsi:nil="true" />' + 
					'                            <CustomerKey>Account_Id</CustomerKey>' + 
					'                            <Name>Account_Id</Name>' + 
					'                            <MaxLength>50</MaxLength>' + 
					'                            <IsRequired>false</IsRequired>' + 
					'                            <IsPrimaryKey>false</IsPrimaryKey>' + 
					'                            <FieldType>Text</FieldType>' + 
					'                        </Field>' + 
					'                        <Field>' + 
					'                            <PartnerKey xsi:nil="true" />' + 
					'                            <ObjectID xsi:nil="true" />' + 
					'                            <CustomerKey>ContactId</CustomerKey>' + 
					'                            <Name>ContactId</Name>' + 
					'                            <MaxLength>254</MaxLength>' + 
					'                            <IsRequired>true</IsRequired>' + 
					'                            <IsPrimaryKey>true</IsPrimaryKey>' + 
					'                            <FieldType>Text</FieldType>' + 
					'                        </Field>' + 
					'                        <Field>' + 
					'                            <PartnerKey xsi:nil="true" />' + 
					'                            <ObjectID xsi:nil="true" />' + 
					'                            <CustomerKey>LastName</CustomerKey>' + 
					'                            <Name>LastName</Name>' + 
					'                            <MaxLength>50</MaxLength>' + 
					'                            <IsRequired>false</IsRequired>' + 
					'                            <IsPrimaryKey>false</IsPrimaryKey>' + 
					'                            <FieldType>Text</FieldType>' + 
					'                        </Field>' + 
					'                        <Field>' + 
					'                            <PartnerKey xsi:nil="true" />' + 
					'                            <ObjectID xsi:nil="true" />' + 
					'                            <CustomerKey>BulletinTemplateName</CustomerKey>' + 
					'                            <Name>BulletinTemplateName</Name>' + 
					'                            <MaxLength>50</MaxLength>' + 
					'                            <IsRequired>false</IsRequired>' + 
					'                            <IsPrimaryKey>false</IsPrimaryKey>' + 
					'                            <FieldType>Text</FieldType>' + 
					'                        </Field>' + 
					'                        <Field>' + 
					'                            <PartnerKey xsi:nil="true" />' + 
					'                            <ObjectID xsi:nil="true" />' + 
					'                            <CustomerKey>Email__C</CustomerKey>' + 
					'                            <Name>Email__C</Name>' + 
					'                            <IsRequired>false</IsRequired>' + 
					'                            <IsPrimaryKey>false</IsPrimaryKey>' + 
					'                            <FieldType>Boolean</FieldType>' + 
					'                        </Field>' + 
					'                        <Field>' + 
					'                            <PartnerKey xsi:nil="true" />' + 
					'                            <ObjectID xsi:nil="true" />' + 
					'                            <CustomerKey>User__C</CustomerKey>' + 
					'                            <Name>User__C</Name>' + 
					'                            <MaxLength>50</MaxLength>' + 
					'                            <IsRequired>false</IsRequired>' + 
					'                            <IsPrimaryKey>false</IsPrimaryKey>' + 
					'                            <FieldType>Text</FieldType>' + 
					'                        </Field>' + 
					'                        <Field>' + 
					'                            <PartnerKey xsi:nil="true" />' + 
					'                            <ObjectID xsi:nil="true" />' + 
					'                            <CustomerKey>Product__c</CustomerKey>' + 
					'                            <Name>Product__c</Name>' + 
					'                            <MaxLength>50</MaxLength>' + 
					'                            <IsRequired>false</IsRequired>' + 
					'                            <IsPrimaryKey>false</IsPrimaryKey>' + 
					'                            <FieldType>Text</FieldType>' + 
					'                        </Field>' + 
					'                        <Field>' + 
					'                            <PartnerKey xsi:nil="true" />' + 
					'                            <ObjectID xsi:nil="true" />' + 
					'                            <CustomerKey>ProductAttribute__c</CustomerKey>' + 
					'                            <Name>ProductAttribute__c</Name>' + 
					'                            <MaxLength>50</MaxLength>' + 
					'                            <IsRequired>false</IsRequired>' + 
					'                            <IsPrimaryKey>false</IsPrimaryKey>' + 
					'                            <FieldType>Text</FieldType>' + 
					'                        </Field>' + 
					'                    </Fields>' + 
					'                    <CategoryID>4471</CategoryID>' + 
					'                </Object>' + 
					'            </Results>' + 
					'            <RequestID>ce63b46f-d30a-4b0d-a3ec-3ddf8bfbdb39</RequestID>' + 
					'            <OverallStatus>OK</OverallStatus>' + 
					'        </CreateResponse>' + 
					'    </soap:Body>' + 
					'</soap:Envelope>';

    public static testMethod void dataExt_Init(){
        OC_AN_XMLParser xmlParser = new OC_AN_XMLParser();
        System.assertNotEquals(null, xmlParser, 'This should not be empty');
    }

    
    public static testMethod void readTest(){
        OC_AN_XMLParser xmlParser = new OC_AN_XMLParser();
        XmlStreamReader reader = new XmlStreamReader(TEST_XML);
		List<String> newObjectIds = xmlParser.parseBooks(reader);
        System.assertNotEquals(null, newObjectIds, 'This should not be empty');
    }

 
}