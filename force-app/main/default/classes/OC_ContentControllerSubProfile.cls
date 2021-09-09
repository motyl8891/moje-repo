/**
* @File Name          : OC_ContentControllerSubProfile
* @Description        : Provide data to OmniChannel Profile Menu Section
* @Author             : Rohit Gaba
* @Group              : OmniChannel - Service
* @Created Date       : 17th April 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-04-17              Rohit Gaba               Initial Version
* 2.0        2021-01-13              IBM                      U-2424 Dynamic copyright year
**/
public with sharing class OC_ContentControllerSubProfile {
    
    //This Map Dataset will have three categorical informations about User, Links on Profile Menu Page and the Copyright Label 
    public static OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse processOmniChannelThemeRequest(OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request){
        OmniChannelThemeRequestReponseWrappers.OCResponseUserProfile response = new OmniChannelThemeRequestReponseWrappers.OCResponseUserProfile();
        OmniChannelThemeRequestReponseWrappers.OCResponseUserProfileData requestedData = new OmniChannelThemeRequestReponseWrappers.OCResponseUserProfileData();
        
        User tempUser = [select Id, Name, AccountId, Account.Name, ContactId, Email, FullPhotoUrl, SmallPhotoUrl from User Where Id = :UserInfo.getUserId()];
        String sitePathPrefix = Site.getPathPrefix();
        
        response.requestType = request.requestType;
        requestedData.accounts = new List<Map<String, Object>>();
        requestedData.user = new Map<String, Object>();
        requestedData.link = new Map<String, Object>();
        
        //Accounts Data
        if(tempUser.AccountId != NULL){
            List<AccountContactRelation> tempList_associatedAccounts = [SELECT AccountId, Account.Name, IsDirect FROM AccountContactRelation WHERE ContactId = :tempUser.ContactId ORDER BY IsDirect DESC];
            Map<String, Object> tempMap;
            for(AccountContactRelation temp :tempList_associatedAccounts){
                tempMap = new Map<String, Object>();
                tempMap.put('accountName', temp.Account.Name);
                if(temp.IsDirect){
                    tempMap.put('isPrimary', true);
                }
                else{
                    tempMap.put('isPrimary', false);
                }
                requestedData.accounts.add(tempMap);
            }
        }
        
        
        //User Data
        requestedData.user.put('name', tempUser.Name);
        requestedData.user.put('email', tempUser.Email);
        requestedData.user.put('smallPhoto', tempUser.SmallPhotoUrl);
        requestedData.user.put('largePhoto', tempUser.FullPhotoUrl);
        if(tempUser.AccountId == NULL){
            requestedData.user.put('hasAccount', false);
        }
        else{
            requestedData.user.put('hasAccount', true);
        }
        
        //Links Data
        //requestedData.link.put('home', sitePathPrefix + '/');
        //requestedData.link.put('myProfile', sitePathPrefix + '/profile/' + tempUser.Id);
        //requestedData.link.put('mySettings', sitePathPrefix + '/settings/' + tempUser.Id);
        //requestedData.link.put('myAccount', sitePathPrefix + '/detail/' + tempUser.AccountId);
        //requestedData.link.put('messages', sitePathPrefix + '/messages/Home/');
        //requestedData.link.put('contactSupport', sitePathPrefix + '/contactsupport/');
        requestedData.link.put('logout', (sitePathPrefix + '/secur/logout.jsp').replace('/s/','/'));
        requestedData.link.put('extranetSupport', System.Label.OC_ProfileMenu_ExtranetSupport);
        requestedData.link.put('privacy', System.Label.OC_ProfileMenu_Privacy);
        requestedData.link.put('legal', System.Label.OC_ProfileMenu_Legal);
        
        //Copyright
        //2.0 2021-01-13 IBM U-2424 Dynamic copyright year
        requestedData.copyright = System.Label.OC_ProfileMenu_Copyright?.replace('<year>', String.valueof(Date.today().year()));
        
        response.requestedData = requestedData;
        
        
        return response;
    }
}