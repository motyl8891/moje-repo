/**
* @File Name          : OC_ContentControllerSubNavigation
* @Description        : OmniChannel Theme Navigation Menu Items from Custom MetaData Types - OC_Navigation_MenuItem__mdt, OC_Navigation_Link__mdt
* @Author             : Rohit Gaba
* @Group              : OmniChannel - Service
* @Created Date       : 14th May 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-05-14              Rohit Gaba               Initial Version
**/
public class OC_ContentControllerSubNavigation {
    
    //To fetch OmniChannel Theme Navigation Menu Items from Custom MetaData Type - OC_Navigation_MenuItem__mdt
    //A Navigation Menu Item can have Sub Items which are being retrieved from OC_Navigation_Link__mdt
    //First Sub Item target url will contain the copy of its parent target url.
    public static OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse processOmniChannelThemeRequestRetrieveNavigations(OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request){
        OmniChannelThemeRequestReponseWrappers.OCResponseNavigation response = new OmniChannelThemeRequestReponseWrappers.OCResponseNavigation();
        OmniChannelThemeRequestReponseWrappers.OCResponseNavigationData requestedData = new OmniChannelThemeRequestReponseWrappers.OCResponseNavigationData();
        requestedData.navigationItems = new  List<OmniChannelThemeRequestReponseWrappers.OCResponseNavigationDataItem>();
        response.requestType = request.requestType;
        response.requestedData = requestedData;
        
        OC_Navigation_MenuItem__mdt [] navigationMappings = [SELECT Id, MasterLabel, DeveloperName, NavigationMenuItem_URL__c, NavigationMenuItem_Order__c, (SELECT Id, MasterLabel, DeveloperName, NavigationLink_HasRecordId__c, NavigationLink_MenuItem__c, NavigationLink_Order__c, NavigationLink_URL__c, OC_TH_NavigationLink_Breadcrumb_Label__c FROM OC_Navigation_Links__r) FROM OC_Navigation_MenuItem__mdt WHERE NavigationMenuItem_Active__c = TRUE ORDER BY NavigationMenuItem_Order__c ASC];
        
        List<OmniChannelThemeRequestReponseWrappers.OCResponseNavigationDataItem> tempList = new List<OmniChannelThemeRequestReponseWrappers.OCResponseNavigationDataItem>();
        List<OmniChannelThemeRequestReponseWrappers.OCResponseNavigationLinksDataItem> tempSubList = new List<OmniChannelThemeRequestReponseWrappers.OCResponseNavigationLinksDataItem>();
        OmniChannelThemeRequestReponseWrappers.OCResponseNavigationDataItem tempItem;
        OmniChannelThemeRequestReponseWrappers.OCResponseNavigationLinksDataItem tempSubItem;
        
        for(OC_Navigation_MenuItem__mdt tempNavigation :navigationMappings){
            tempItem = new OmniChannelThemeRequestReponseWrappers.OCResponseNavigationDataItem();
            tempSubList = new List<OmniChannelThemeRequestReponseWrappers.OCResponseNavigationLinksDataItem>();
            tempItem.itemId = tempNavigation.Id;
            tempItem.itemLabel = tempNavigation.MasterLabel;
            tempItem.itemDeveloperName = tempNavigation.DeveloperName;
            tempItem.itemURL = tempNavigation.NavigationMenuItem_URL__c;
            tempItem.itemLinks = tempSubList;
            
            for(OC_Navigation_Link__mdt tempNavigationLink :tempNavigation.OC_Navigation_Links__r){
                tempSubItem = new OmniChannelThemeRequestReponseWrappers.OCResponseNavigationLinksDataItem();
                tempSubItem.itemId = tempNavigationLink.Id;
                tempSubItem.itemLabel = tempNavigationLink.MasterLabel;
                tempSubItem.itemDeveloperName = tempNavigationLink.DeveloperName;
                tempSubItem.itemParent = tempNavigationLink.NavigationLink_MenuItem__c	;
                tempSubItem.itemOrder = Integer.valueOf(tempNavigationLink.NavigationLink_Order__c);
                tempSubItem.itemURL = tempNavigationLink.NavigationLink_URL__c;
                tempSubItem.itemHasRecordId = tempNavigationLink.NavigationLink_HasRecordId__c;
                tempSubItem.itemBreadCrumbLabel = tempNavigationLink.OC_TH_NavigationLink_Breadcrumb_Label__c;
                tempItem.itemLinks.add(tempSubItem);
            }
            
            tempList.add(tempItem);
            
        }
        
        requestedData.navigationItems.addAll(tempList);
        
        return response;
    }
}