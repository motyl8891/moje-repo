public with sharing class OC_AN_MC_AutomationUtils {

        // Used to give a Exception back 
        public class MCException extends Exception{

        }
    
        private static final String REPLACE_BULLETIN_NAME = '{{bulletinName}}';
        private static final String REPLACE_QUERY = '{{bulletinQuery}}';
        private static final String REPLACE_QUERY_TARGET_DS = '{{bulletinQueryTargetDataSource}}';
        private static final String REPLACE_QUERY_TARGET_NAME_DS = '{{bulletinQueryTargetDataSourceName}}';
        private static final String REPLACE_ACCESS_TOKEN = '{{dne_etAccessToken}}';
        private static final String REPLACE_SOAP_URL = '{{et_subdomain}}';
        private static final String REPLACE_QUERY_ID = '{{ObjectID}}';
        private static final String REPLACE_QUERY_ID_RESULT = '{{ObjectID2}}';
        private static final String REPLACE_QUERY_NAME = '{{Name}}';

        private static final String RESPONSE_NEW_OBJECT_ID = 'NewObjectID>';
        private static final String RESPONSE_OBJECT_ID = '<ObjectID>';
        private static final String RESPONSE_STATUS_CODE = '<StatusCode>';
        private static final String RESPONSE_STATUS_MESSAGE = '<StatusMessage>';
        private static final String RESPONSE_STATUS_ERROR = 'Error';
    
        private static final String CONTENT_TYPE = 'application/soap+xml; charset=utf-8';
    
        private static final String CREATE_AUTOMATION_QUERY = '<?xml version="1.0" encoding="UTF-8"?>'+
        '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'+
        '    <s:Header>'+
        '        <a:Action s:mustUnderstand="1">Create</a:Action>'+
        '        <a:To s:mustUnderstand="1">https://{{et_subdomain}}.soap.marketingcloudapis.com/Service.asmx</a:To>'+
        '        <fueloauth xmlns="http://exacttarget.com">{{dne_etAccessToken}}</fueloauth>'+
        '    </s:Header>'+
        '    <s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'+
        '        <CreateRequest xmlns="http://exacttarget.com/wsdl/partnerAPI">'+
        '            <Options></Options>'+
        '            <Objects xsi:type="QueryDefinition">'+
        '                <PartnerKey xsi:nil="true"></PartnerKey>'+
        '                <ObjectID xsi:nil="true"></ObjectID>'+
        '                <CustomerKey>{{bulletinName}}</CustomerKey>'+
        '                <Name>{{bulletinName}}</Name>'+
        '                <Description>Created from Service Cloud for Bulletin {{bulletinName}}</Description>'+
        '                <QueryText>{{bulletinQuery}}</QueryText>'+
        '                <TargetType>DE</TargetType>'+
        '                <DataExtensionTarget>'+
        '                    <PartnerKey xsi:nil="true"></PartnerKey>'+
        '                    <ObjectID xsi:nil="true"></ObjectID>'+
        '                    <CustomerKey>{{bulletinQueryTargetDataSource}}</CustomerKey>'+
        '                    <Name>{{bulletinQueryTargetDataSourceName}}</Name>'+
        '                </DataExtensionTarget>'+
        '                <TargetUpdateType>Overwrite</TargetUpdateType>'+
        '            </Objects>'+
        '        </CreateRequest>'+
        '    </s:Body>'+
        '</s:Envelope>';
    
        private static final String CREATE_AUTOMATION = '<?xml version="1.0" encoding="UTF-8"?>'+
        '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'+
        '    <s:Header>'+
        '        <a:Action s:mustUnderstand="1">Create</a:Action>'+
        '        <a:To s:mustUnderstand="1">https://{{et_subdomain}}.soap.marketingcloudapis.com/Service.asmx</a:To>'+
        '        <fueloauth xmlns="http://exacttarget.com">{{dne_etAccessToken}}</fueloauth>'+
        '    </s:Header>'+
        '    <s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'+
        '        <CreateRequest xmlns="http://exacttarget.com/wsdl/partnerAPI">'+
        '            <Options/>'+
        '            <Objects xsi:type="Automation">'+
        '                <Name>{{bulletinName}}</Name>'+
        '                <CustomerKey>{{bulletinName}}</CustomerKey>'+
        '                <Description>Generated from Service Cloud</Description>'+
        '            <AutomationTasks>'+
        '                <AutomationTask>'+
        '                    <PartnerKey xsi:nil="true"/>'+
        '                    <ObjectID xsi:nil="true"/>'+
        '                    <Name>{{bulletinName}}</Name>'+
        '                    <Activities>'+
        '                        <Activity>'+
        '                            <PartnerKey xsi:nil="true"/>'+
        '                            <Name>{{bulletinName}}_1</Name>'+
        '                            <!-- Name of Activity -->'+
        '                            <ActivityObject xsi:type="QueryDefinition">'+
        '                                <PartnerKey xsi:nil="true"/>'+
        '                                <ObjectID>{{ObjectID}}</ObjectID>'+
        '                                <Name>one</Name>'+
        '                                <!-- Name in automation -->'+
        '                            </ActivityObject>'+
        '                        </Activity>'+
        '                        <Activity>'+
        '                            <PartnerKey xsi:nil="true"/>'+
        '                            <Name>{{bulletinName}}_2</Name>'+
        '                            <!-- Name of Activity -->'+
        '                            <ActivityObject xsi:type="QueryDefinition">'+
        '                                <PartnerKey xsi:nil="true"/>'+
        '                                <ObjectID>{{ObjectID2}}</ObjectID>'+
        '                                <Name>two</Name>'+
        '                                <!-- Name in automation -->'+
        '                            </ActivityObject>'+
        '                        </Activity>'+
        '                    </Activities>'+
        '                </AutomationTask>'+
        '            </AutomationTasks>'+
        '            <AutomationType>scheduled</AutomationType>'+
        '        </Objects>'+
        '    </CreateRequest>'+
        '</s:Body>'+
        '</s:Envelope>';
    
        private static final String GET_AUTOMATION_ID  = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'+
            '<soapenv:Header>'+
            '        <Action mustUnderstand="1">Create</Action>'+
 
            '<fueloauth>{{dne_etAccessToken}}</fueloauth>'+
               '</soapenv:Header>'+
            '<soapenv:Body>'+
           '<RetrieveRequestMsg xmlns="http://exacttarget.com/wsdl/partnerAPI">'+
               '<RetrieveRequest>'+
                  '<ObjectType>Automation</ObjectType>'+
                     '<Properties>ProgramID</Properties>'+
                     '<Properties>Name</Properties>'+
                        '<Filter xsi:type="SimpleFilterPart" xmlns:ns1="http://exacttarget.com/wsdl/partnerAPI">'+
                        '<Property>Name</Property>'+
                         '<SimpleOperator>equals</SimpleOperator>'+
                         '<Value>{{Name}}</Value>'+
                        '</Filter>'+
                     '</RetrieveRequest>'+
                  '</RetrieveRequestMsg>'+
               '</soapenv:Body>'+
            '</soapenv:Envelope>';

            private static final String GET_AUTOMATION_ID_V2  = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'+
            '<soapenv:Header>'+
            '<fueloauth>{{dne_etAccessToken}}</fueloauth>'+
               '</soapenv:Header>'+
            '<soapenv:Body>'+
           '<RetrieveRequestMsg xmlns="http://exacttarget.com/wsdl/partnerAPI">'+
               '<RetrieveRequest>'+
                  '<ObjectType>Automation</ObjectType>'+
                     '<Properties>ProgramID</Properties>'+
                     '<Properties>Name</Properties>'+
                        '<Filter xsi:type="SimpleFilterPart" xmlns:ns1="http://exacttarget.com/wsdl/partnerAPI">'+
                        '<Property>Name</Property>'+
                         '<SimpleOperator>equals</SimpleOperator>'+
                         '<Value>{{Name}}</Value>'+
                        '</Filter>'+
                     '</RetrieveRequest>'+
                  '</RetrieveRequestMsg>'+
               '</soapenv:Body>'+
            '</soapenv:Envelope>';
 
    
    
        private static final String START_AUTOMATION = '<?xml version="1.0" encoding="UTF-8"?>'+
        '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'+
        '    <s:Header>'+
        '        <a:Action s:mustUnderstand="1">Perform</a:Action>'+
        '        <a:To s:mustUnderstand="1">https://{{et_subdomain}}.soap.marketingcloudapis.com/Service.asmx</a:To>'+
        '        <fueloauth xmlns="http://exacttarget.com">{{dne_etAccessToken}}</fueloauth>'+
        '    </s:Header>'+
        '    <s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'+
        '        <PerformRequestMsg xmlns="http://exacttarget.com/wsdl/partnerAPI" xmlns:ns2="urn:fault.partner.exacttarget.com">'+
        '            <Action>start</Action>'+
        '            <Definitions>'+
        '                <Definition xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="Automation">'+
        '                    <ObjectID>{{Name}}</ObjectID>'+
        '                </Definition>'+
        '            </Definitions>'+
        '        </PerformRequestMsg>'+
        '    </s:Body>'+
        '</s:Envelope>';
    
        /**
         * createAutomationQuery description
         *
         * ## queryToAdd (String): queryToAdd
         * ## bulletinName (String): bulletinName
         * ## accessToken (String): accessToken
         * @@ Return String: Return description
         */
        public static String createAutomationQuery(String queryToAdd, String bulletinName, String accessToken, String soapUrl, String targetDataSource, String targetDataSourceName){
            // Make adaptions
            String soapMessage = CREATE_AUTOMATION_QUERY;
            soapMessage = soapMessage.replace(REPLACE_QUERY, queryToAdd);
            soapMessage = soapMessage.replace(REPLACE_BULLETIN_NAME, bulletinName);
            soapMessage = soapMessage.replace(REPLACE_ACCESS_TOKEN, accessToken);
            soapMessage = soapMessage.replace(REPLACE_SOAP_URL, soapUrl);
            soapMessage = soapMessage.replace(REPLACE_QUERY_TARGET_DS, targetDataSource);
            soapMessage = soapMessage.replace(REPLACE_QUERY_TARGET_NAME_DS, targetDataSourceName);
            return soapMessage;
        }
    
        /**
         * createAutomation
         *
         * ## queryObjectId (String): queryObjectId
         * ## bulletinName (String): bulletinName
         * ## accessToken (String): accessToken
         * @@ Return String: Return description
         */
        public static String createAutomation(String queryObjectId, String queryObjectId2, String bulletinName, String accessToken, String soapUrl){
            // Make adaptions
            String soapMessage = CREATE_AUTOMATION;
            soapMessage = soapMessage.replace(REPLACE_QUERY_ID, queryObjectId);
            soapMessage = soapMessage.replace(REPLACE_QUERY_ID_RESULT, queryObjectId2);
            soapMessage = soapMessage.replace(REPLACE_BULLETIN_NAME, bulletinName);
            soapMessage = soapMessage.replace(REPLACE_ACCESS_TOKEN, accessToken);
            soapMessage = soapMessage.replace(REPLACE_SOAP_URL, soapUrl);
            return soapMessage;
        }

        public static String getAutomationId(String token, String automationName){
            // Make adaptions
            String soapMessage = GET_AUTOMATION_ID;
            soapMessage = soapMessage.replace(REPLACE_ACCESS_TOKEN, token);
            soapMessage = soapMessage.replace(REPLACE_QUERY_NAME, automationName);
            return soapMessage;
        }

        /**
         * startAutomation description
         *
         * ## automationId (String): automationId
         * ## accessToken (String): accessToken
         * ## soapUrl (String): soapUrl
         * @@ Return String: Return description
         */
        public static String startAutomation(String automationId, String accessToken, String soapUrl) {        
            // Make adaptions
            String soapMessage = START_AUTOMATION;
            soapMessage = soapMessage.replace(REPLACE_QUERY_NAME, automationId);
            soapMessage = soapMessage.replace(REPLACE_ACCESS_TOKEN, accessToken);
            soapMessage = soapMessage.replace(REPLACE_SOAP_URL, soapUrl);
            return soapMessage;
        }

}