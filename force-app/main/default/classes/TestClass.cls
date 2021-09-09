public class TestClass {
    public static void testM(){
        String str= '<?xml version="1.0" encoding="utf-8"?>'+
            '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'+
            '    <env:Header xmlns:env="http://www.w3.org/2003/05/soap-envelope">'+
            '        <wsa:Action>CreateResponse</wsa:Action>'+
            '        <wsa:MessageID>urn:uuid:44f03c0a-b15e-4667-a05e-11bb667ba0bb</wsa:MessageID>'+
            '        <wsa:RelatesTo>urn:uuid:2d1b5564-530a-4661-be6f-f7a11dc565d9</wsa:RelatesTo>'+
            '        <wsa:To>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:To>'+
            '        <wsse:Security>'+
            '            <wsu:Timestamp wsu:Id="Timestamp-46ab91e9-1e40-4945-b4e4-baf395c02d1e">'+
            '                <wsu:Created>2021-05-10T08:39:13Z</wsu:Created>'+
            '                <wsu:Expires>2021-05-10T08:44:13Z</wsu:Expires>'+
            '            </wsu:Timestamp>'+
            '        </wsse:Security>'+
            '    </env:Header>'+
            '    <soap:Body>'+
            '        <CreateResponse xmlns="http://exacttarget.com/wsdl/partnerAPI">'+
            '            <Results>'+
            '                <StatusCode>OK</StatusCode>'+
            '                <StatusMessage>QueryDefinition created</StatusMessage>'+
            '                <OrdinalID>0</OrdinalID>'+
            '                <NewID>0</NewID>'+
            '                <NewObjectID>b5b9acd0-92a4-4dfc-b27e-5a81d3af9258</NewObjectID>'+
            '                <Object xsi:type="QueryDefinition">'+
            '                    <PartnerKey xsi:nil="true" />'+
            '                    <ObjectID>b5b9acd0-92a4-4dfc-b27e-5a81d3af9258</ObjectID>'+
            '                    <CustomerKey>Test_1_2</CustomerKey>'+
            '                    <Name>Test_1_2</Name>'+
            '                    <QueryText>Select Id,Name,Email from Contact_Salesforce</QueryText>'+
            '                    <TargetType>DE</TargetType>'+
            '                    <DataExtensionTarget>'+
            '                        <PartnerKey xsi:nil="true" />'+
            '                        <ObjectID xsi:nil="true" />'+
            '                        <CustomerKey>D70C20BC-2665-4556-8945-F70450C10630</CustomerKey>'+
            '                        <Name>Test_Querycheck12</Name>'+
            '                    </DataExtensionTarget>'+
            '                    <TargetUpdateType>Overwrite</TargetUpdateType>'+
            '                </Object>'+
            '            </Results>'+
            '            <Results>'+
            '                <StatusCode>OK</StatusCode>'+
            '                <StatusMessage>QueryDefinition created</StatusMessage>'+
            '                <OrdinalID>1</OrdinalID>'+
            '                <NewID>0</NewID>'+
            '                <NewObjectID>a6967339-8663-4b07-ba48-59194e2a7bb2</NewObjectID>'+
            '                <Object xsi:type="QueryDefinition">'+
            '                    <PartnerKey xsi:nil="true" />'+
            '                    <ObjectID>a6967339-8663-4b07-ba48-59194e2a7bb2</ObjectID>'+
            '                    <CustomerKey>Test_1_1</CustomerKey>'+
            '                    <Name>Test_1_1</Name>'+
            '                    <QueryText>Select Id,Name,Email from Contact_Salesforce</QueryText>'+
            '                    <TargetType>DE</TargetType>'+
            '                    <DataExtensionTarget>'+
            '                        <PartnerKey xsi:nil="true" />'+
            '                        <ObjectID xsi:nil="true" />'+
            '                        <CustomerKey>D70C20BC-2665-4556-8945-F70450C10630</CustomerKey>'+
            '                        <Name>Test_Querycheck12</Name>'+
            '                    </DataExtensionTarget>'+
            '                    <TargetUpdateType>Overwrite</TargetUpdateType>'+
            '                </Object>'+
            '            </Results>'+
            '            <RequestID>4df6ba29-d94e-4be8-ba70-0fbc0f9c7c43</RequestID>'+
            '            <OverallStatus>OK</OverallStatus>'+
            '        </CreateResponse>'+
            '    </soap:Body>'+
            '</soap:Envelope>';
            }
}