/**
* @File Name          : OC_ContentControllerSubLandingModules
* @Description        : Provide data for My Module section, which will be added on OmniChannel Home Page. Data configured in Custom MetaData Type - OC_LandingPage_Modules__mdt
* @Author             : Rohit Gaba
* @Group              : OmniChannel - Service
* @Created Date       : 13th May 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-05-13              Rohit Gaba               Initial Version
**/
public class OC_ContentControllerSubLandingModules {
    
    //My Modules data items being prepared from Custom MetaData Type - OC_LandingPage_Modules__mdt
	public static OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse processOmniChannelThemeRequestRetrieveLandingModules(OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request){
        OmniChannelThemeRequestReponseWrappers.OCResponseLandingModules response = new OmniChannelThemeRequestReponseWrappers.OCResponseLandingModules();
        OmniChannelThemeRequestReponseWrappers.OCResponseLandingModulesData requestedData = new OmniChannelThemeRequestReponseWrappers.OCResponseLandingModulesData();
        requestedData.moduleItems = new  List<OmniChannelThemeRequestReponseWrappers.OCResponseLandingModulesDataItem>();
        response.requestType = request.requestType;
        response.requestedData = requestedData;
        
        OC_LandingPage_Modules__mdt[] moduleMappings = [SELECT MasterLabel, Module_URL__c , Module_URL_Target__c, Module_Description__c, Module_Order__c FROM OC_LandingPage_Modules__mdt ORDER BY Module_Order__c ASC];
        
        List<OmniChannelThemeRequestReponseWrappers.OCResponseLandingModulesDataItem> tempList = new List<OmniChannelThemeRequestReponseWrappers.OCResponseLandingModulesDataItem>();
        OmniChannelThemeRequestReponseWrappers.OCResponseLandingModulesDataItem tempItem;
        
        for(OC_LandingPage_Modules__mdt tempModule :moduleMappings){
            tempItem = new OmniChannelThemeRequestReponseWrappers.OCResponseLandingModulesDataItem();
            tempItem.itemTitle = tempModule.MasterLabel;
            tempItem.itemURL = tempModule.Module_URL__c;
            tempItem.itemURLTarget = tempModule.Module_URL_Target__c;
            tempItem.itemDesc = tempModule.Module_Description__c;
            tempItem.itemOrder = Integer.valueOf(tempModule.Module_Order__c);
            tempList.add(tempItem);      
        
        }
        
        requestedData.moduleItems.addAll(tempList);
        
        return response;
    }
}