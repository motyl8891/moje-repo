/**
* @File Name          : OmniChannelThemeContentController
* @Description        : This class is one entry point for all communication happening form OmniChannel Community Page
*						And all communication are coming from omnichannelthemeContentSubContainers component.
*						
*						*****   omnichannelthemeContentSubContainers.cmp   <==>   OmniChannelThemeContentController.cls   *****
*
* @Author             : Rohit Gaba
* @Group              : OmniChannel - Service
* @Created Date       : 08th April
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-04-08              Rohit Gaba               Initial Version
**/
public with sharing class OmniChannelThemeContentController{
    
    @AuraEnabled
    //This method will be one point to all request generated from Omnichannel Community Portal
    public static OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse processRequest(OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request) {
        
        //Access Management for each request need to be done here.
        if(!OmniChannelThemeAccessController.OCReuqestAccessCheck(request)){
            // Throw an Aura Exception with insufficient permission
            throw new AuraHandledException(System.Label.OC_Generic_Exception_Message);
        }
        
        //Request to Sub-Controller
        
        OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse response = OmniChannelThemeContentControllerSub.processOmniChannelThemeRequest(request);
        response.originalRequest = request;
        response.originalRequest.requestBody = null;
        
        return response;
    }
}