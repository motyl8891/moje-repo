/**
* @File Name          : OC_AN_SOAPParser 
* @Description        : This class will be used to parse the SOAP response returned by the server.
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 10 August 2021
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-08-10                IBM                   Initial Version
**/

public with sharing class OC_AN_SOAPParser {
    
    
    /**************************************************************************************************
	* @Method Name : fetchListOfContactIdFromResponse
	* @Description : Returns the list of the contactId by parsing the SOAP response.
	* @Param       : responseXML - SOAP response which needs to be parsed.
	* @Return      : List of ContactIds
	****************************************************************************************************/
    public static List<Id> fetchListOfContactIdFromResponse(String responseXML){
        
        List<Id> contactIdList = new List<Id> ();
        
        DOM.Document doc = new DOM.Document();
        String toParse = responseXML;
        doc.load(toParse);
        
        DOM.XMLNode root = doc.getRootElement();
        
        String nms = root.getNameSpace();
        
        DOM.XMLNode body = root.getChildElement(OC_AN_Constants.XMLBody, nms);

        List<DOM.XMLNode> bodyChildrenList = body.getChildElements();
        
        for (DOM.XMLNode RetrieveResponseMsg : bodyChildrenList) {
            
            List<DOM.XMLNode> ResultsLists = RetrieveResponseMsg.getChildElements();
            
            for (DOM.XMLNode ResultList : ResultsLists) {
                
                List<DOM.XMLNode> PropertiesLists = ResultList.getChildElements();
                
                for (DOM.XMLNode PropertiesList : PropertiesLists) {
                    List<DOM.XMLNode> Property = PropertiesList.getChildElements();
                    
                    for (DOM.XMLNode data : Property) {
                        
                        List<DOM.XMLNode> ContactLists = data.getChildElements();
                        
                        for (DOM.XMLNode contact : ContactLists) {
                            if(contact.getName() == OC_AN_Constants.NodeValue){ 
                                contactIdList.add(contact.getText());
                            }
                        }
                    }
                }
            }
        }
        return contactIdList;
    }
    
}