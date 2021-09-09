/**
* @File Name          : OC_AN_SOAPParserTest 
* @Description        : Test class for OC_AN_SOAPParser
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 10 August 2021
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-08-10                IBM                   Initial Version
**/

@istest
public class OC_AN_SOAPParserTest {
    
    
    @istest
    public static void fetchListOfContactIdFromResponseTest1(){
        String responseXML = '<?xml version="1.0" encoding="utf-8"?>'+
            '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'+
            '<env:Header xmlns:env="http://www.w3.org/2003/05/soap-envelope">'+
            '<wsa:Action>RetrieveResponse</wsa:Action>'+
            '<wsa:MessageID>urn:uuid:7667f112-80b7-45a5-8b44-17998fc9ee89</wsa:MessageID>'+
            '<wsa:RelatesTo>urn:uuid:206e57ca-cf45-4223-be16-ec0a91a78d99</wsa:RelatesTo>'+
            '<wsa:To>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:To>'+
            '<wsse:Security>'+
            '   <wsu:Timestamp wsu:Id="Timestamp-38fe3a28-7df6-4f84-bcd5-9a42eeff79a5">'+
            '      <wsu:Created>2021-08-09T06:49:26Z</wsu:Created>'+
            '     <wsu:Expires>2021-08-09T06:54:26Z</wsu:Expires>'+
            '</wsu:Timestamp>'+
            '</wsse:Security>'+
            '</env:Header>'+
            '<soap:Body>'+
            '   <RetrieveResponseMsg xmlns="http://exacttarget.com/wsdl/partnerAPI">'+
            '      <OverallStatus>OK</OverallStatus>'+
            '     <RequestID>67c13685-03b0-4170-8cdd-188cd757a4b7</RequestID>'+
            '    <Results xsi:type="DataExtensionObject">'+
            '       <PartnerKey xsi:nil="true" />'+
            '      <ObjectID xsi:nil="true" />'+
            '     <Type>DataExtensionObject</Type>'+
            '    <Properties>'+
            '       <Property>'+
            '          <Name>ContactId</Name>'+
            '         <Value>0031l00000qkOvGAAU</Value>'+
            '    </Property>'+
            '</Properties>'+
            '</Results>'+
            '</RetrieveResponseMsg>'+
            '</soap:Body>'+
            '</soap:Envelope>';
        OC_AN_SOAPParser.fetchListOfContactIdFromResponse(responseXML);
            
    }
    
    
}