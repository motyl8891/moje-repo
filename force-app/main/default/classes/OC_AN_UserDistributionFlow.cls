/**
* @File Name          : OC_AN_UserDistributionFlow
* @Description        : This class will fetch all the users from the public groups which are associated
						to the bulletin
*
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 18th May
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-05-18                 IBM               Initial Version
**/

public without sharing class OC_AN_UserDistributionFlow {
    
	/**************************************************************************************************
			* @Description : This method will return all the internal users based on bulletin Id.
			* @Param       : bulletinId - This will bulletin from which the users needs to be fetched
			* @Return      : List of public group records to display.
	****************************************************************************************************/

    public static List<User> getInternalUsersForBulletin(Id bulletinId){
        // get OC_AN_Bulletin__c
        OC_AN_Bulletin__c bulletinObj = getBulletinObject(bulletinId);
       
        // OC_AN_Bulletin_Account_Product__c -  OC_AN_Public_Group
        Map<Id, OC_AN_Bulletin_Account_Product__c> bulletinGroups = getBulletinAccountByRecordType(bulletinObj, 'OC_AN_Public_Group');

        // Group
        Set<Id> groupIds = new Set<Id>();
        List<Id> productIds = new List<Id>();
        for(OC_AN_Bulletin_Account_Product__c bap :  bulletinGroups.values()){
            if(bap.OC_AN_GroupId__c != null)
                groupIds.add(bap.OC_AN_GroupId__c);
            if(bap.OC_AN_Product__c != null)
                productIds.add(bap.OC_AN_Product__c);
        }
        // User
        Map<Id, User> bulletingInternalUsers = new Map<Id, User>();
        for(Id userId : getUserIdsFromGroupIds(groupIds)){
            bulletingInternalUsers.put(userId, null);
        }        
        
        return [SELECT Id, Name, FirstName, LastName,Email FROM User WHERE isactive = True and ID IN:bulletingInternalUsers.keySet()];
    }


   /**************************************************************************************************
			* @Description : This method will return all the external users based on bulletin Id.
			* @Param       : bulletinId - This will bulletin from which the users needs to be fetched
			* @Return      : List of user records.
	****************************************************************************************************/

    public static List<User> getExternalUsersForBulletin(Id bulletinId){
        // get OC_AN_Bulletin__c
        OC_AN_Bulletin__c bulletinObj = getBulletinObject(bulletinId);
       
        // OC_AN_Bulletin_Account_Product__c
        Map<Id, OC_AN_Bulletin_Account_Product__c> bulletinAccounts = getBulletinAccountByRecordType(bulletinObj, 'OC_AN_Account_Record');
        // Contact
        List<Id> accountIds = new List<Id>();
        List<Id> productIds = new List<Id>();
        for(OC_AN_Bulletin_Account_Product__c bap :  bulletinAccounts.values()){
            accountIds.add(bap.OC_AN_Account__c);
            productIds.add(bap.OC_AN_Product__c);
        }
        Map<Id, Contact> bulletinContacts = getContactByAccount(accountIds);
        // User
        Map<Id, User> bulletingExternalUsers = new Map<Id, User>(
            [SELECT Id From User WHERE ContactId != null AND ContactId IN :bulletinContacts.keySet()]
        );
        // OC_AN_User_Preferences__c
        // User
        List<Id> bulletinWPrefUsers = new List<Id>();
        for(OC_AN_User_Preferences__c pref : getPreferencesForBulletin(bulletinObj.OC_AN_Type__c, bulletingExternalUsers.keySet(), productIds)){
            bulletinWPrefUsers.add(pref.OC_AN_User__c);
        }
        List<User> externalUsersForBulletin = getUsersForPreferences(bulletinWPrefUsers);
        
        return externalUsersForBulletin;
    }
    
    /**************************************************************************************************
			* @Description : This method will return all the user preferences
			* @Param       : name - Bulletin Preference Name
			* @Param       : userIds - all the users who are part of the bulletin
			* @Param       : productIds - product preferences of the bulletin
			* @Return      : List of user preferences records to display.
	****************************************************************************************************/

    public static List<OC_AN_User_Preferences__c> getPreferencesForBulletin(String name, Set<Id> userIds, List<Id> productIds) {
        if(productIds != null && productIds.size() >0)
            return [SELECT OC_AN_Account__c, OC_AN_Contact__c, 
            OC_AN_Email__c, Name, OC_AN_Product__c, OC_AN_User__c, Id 
            FROM OC_AN_User_Preferences__c 
            WHERE 
            OC_AN_User__c IN : userIds AND /**All Bulletin Users */
            Name = :name AND /** Bulletin Preference */
            OC_AN_Product__c IN :productIds AND /**Product Preference */
            OC_AN_Email__c = True /**if email Preference */];

        
        
        return [SELECT OC_AN_Account__c,OC_AN_Contact__c, 
        OC_AN_Email__c, Name, OC_AN_Product__c, OC_AN_User__c, Id 
        FROM OC_AN_User_Preferences__c 
        WHERE 
        OC_AN_User__c IN : userIds AND /**All Bulletin Users */
        Name = :name AND /** Bulletin Preference */
        /**Product__c IN :productIds AND Product Preference */
        OC_AN_Email__c = True /**if email Preference */];
    }
    
    
    /**************************************************************************************************
			* @Description : This method will return the bulletin object
			* @Param       : bulletinId - bulletin id of the object to be fetched
			* @Return      : List of user preferences records to display.
	****************************************************************************************************/
    public static OC_AN_Bulletin__c getBulletinObject(Id bulletinId) {
        return [SELECT Id, OC_AN_Type__c FROM OC_AN_Bulletin__c WHERE Id = :bulletinId];
    }
    
     /**************************************************************************************************
			* @Description : This method will return map of id and Bulletin Account Product Record
			* @Param       : bulletinObj - bulletin object againt which the data needs to be fetched
			* @Param       : rType - recordType of the Bulletin Account Product Record
			* @Return      : Map of Bulletin Account Product Records.
	****************************************************************************************************/

    public static Map<Id, OC_AN_Bulletin_Account_Product__c> getBulletinAccountByRecordType(OC_AN_Bulletin__c bulletinObj, String rType) {
        return new Map<Id, OC_AN_Bulletin_Account_Product__c>(
            [SELECT Name, OC_AN_Account__c, OC_AN_Bulletin__c, OC_AN_Bulletin__r.OC_AN_Type__c, 
            OC_AN_Product__c, OC_AN_Release__c, OC_AN_Verison__c, RecordTypeId, 
            RecordType.DeveloperName, OC_AN_GroupId__c, ID 
        FROM OC_AN_Bulletin_Account_Product__c 
        WHERE RecordType.DeveloperName = :rType AND OC_AN_Bulletin__c != null 
        AND OC_AN_Bulletin__c = :bulletinObj.Id]);
    }

    
     /**************************************************************************************************
			* @Description : This method will return map of id and Contact Record
			* @Param       : accountIds - accountIds against which contacts needs to be fetched
			* @Return      : Map of contact Records.
	****************************************************************************************************/
    public static Map<Id, Contact> getContactByAccount(List<Id> accountIds) {
        return new Map<Id, Contact>([
            SELECT Id 
            FROM Contact 
            WHERE AccountId IN :accountIds]);
    }
    
     /**************************************************************************************************
			* @Description : This method will return the list of users based on the preferences
			* @Param       : bulletinWPrefUsers - bulletin preferences against which the users needs to be fecthed
			* @Return      : List of users based on preferences.
	****************************************************************************************************/

    public static List<User> getUsersForPreferences(List<Id> bulletinWPrefUsers){
        return [SELECT id, Name, Email FROM User 
        WHERE Id IN :bulletinWPrefUsers];
    }

 /**************************************************************************************************
			* @Description : This method will the internal groupid's
			* @Param       : groupIds - groupid to check if there any internal groups in this 
			* @Return      : Set of group ids.
	****************************************************************************************************/

    public static Set<Id> getUserIdsFromGroupIds(Set<Id> groupIds){
         // store the results in a set so we don't get duplicates
        Set<Id> result=new Set<Id>();
        Id internalUserID = [SELECT ID, DeveloperName FROM Group WHERE DeveloperName =: OC_AN_Constants.AllInternalUsers LIMIT 1].Id;
        Boolean isHavingInternalUsers = false;
        String userType = Schema.SObjectType.User.getKeyPrefix();
        String groupType = Schema.SObjectType.Group.getKeyPrefix();
        Set<Id> groupIdProxys = new Set<Id>();
        // Loop through all group members in a group
        for(GroupMember m : [Select Id, UserOrGroupId From GroupMember Where GroupId in :groupIds])
        {
            if(m.UserOrGroupId == internalUserID)
                isHavingInternalUsers = true;
            else{
                // If the user or group id is a user
                if(((String)m.UserOrGroupId).startsWith(userType)) {
                    result.add(m.UserOrGroupId);
                }
                // If the user or group id is a group
                // Note: there may be a problem with governor limits if this is called too many times
                else if (((String)m.UserOrGroupId).startsWith(groupType)) {
                    // Call this function again but pass in the group found within this group
                    groupIdProxys.add(m.UserOrGroupId);
                }
            }
            
        }
        if(groupIdProxys.size() > 0){
            result.addAll(getUserIdsFromGroupIds(groupIdProxys));
        }
        Map<Id, User> internalUsers;
        if(isHavingInternalUsers){
            internalUsers = new Map<Id, User>([select Id, Name, FirstName, LastName,Email from User WHERE isPortalEnabled = false AND UserType =: OC_AN_Constants.Standard  
            and isactive = True]);
            result.addAll(internalUsers.keySet());
        }
        return result;  
    }
}