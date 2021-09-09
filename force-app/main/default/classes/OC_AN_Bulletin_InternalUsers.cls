/**
* @File Name          : OC_AN_Bulletin_InternalUsers()
* @Description        : This will display the all the Users List related to Alerts and Notifications
* 				        and will associate the selected public groups to the bulletin
*
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       :04th May
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-05-04                 IBM               Initial Version
**/

public class OC_AN_Bulletin_InternalUsers {
    
     /**************************************************************************************************
* @Description : This method will return the List of Users  related to Alerts and Notifications.
* @Return      : Return the List of Users.
****************************************************************************************************/
    
    Public static List<User> getBulletinIdsFromGroup(Id bulletinId){
        //get OC_AN_Bulletin__c by Id
        OC_AN_Bulletin__c bulletinObj = [SELECT Id, OC_AN_Bulletin_Template__c
        , OC_AN_Bulletin_Template__r.Name, OC_AN_Type__c 
        FROM OC_AN_Bulletin__c WHERE Id = :bulletinId];
       

        Id BulletinRecordTypeId = Schema.SObjectType.OC_AN_Bulletin_Account_Product__c.getRecordTypeInfosByDeveloperName().get('OC_AN_Public_Group').getRecordTypeId();
        Set<Id> groupIds  = new Set<Id>();
        List<Id> UserId = new  List<Id>();
        List<Id> userPreferencesUserIdList = new List<Id>();
        List<OC_AN_Bulletin_Account_Product__c> BulletinAccProdlist = [SELECT OC_AN_Product__c, OC_AN_GroupId__c
                                                                       From OC_AN_Bulletin_Account_Product__c Where OC_AN_Bulletin__c = :bulletinId 
                                                                       AND RecordTypeId =: BulletinRecordTypeId];
        for(OC_AN_Bulletin_Account_Product__c oc: BulletinAccProdlist){
            //Remove the system debug
            system.debug('oc.OC_AN_GroupId__c===>'+oc.OC_AN_GroupId__c);
            groupIds.add(oc.OC_AN_GroupId__c);
        }
        Map<Id,Id> result = new Map<Id,Id>();
        String userType = Schema.SObjectType.User.getKeyPrefix();     
        String groupType = Schema.SObjectType.Group.getKeyPrefix();
        system.debug('Test'+ groupType);
        Set<Id> groupIdProxys = new Set<Id>();
        //don't hard code use constant class
        Id internalUserID = [SELECT ID, DeveloperName FROM Group WHERE DeveloperName =: OC_AN_Constants.AllInternalUsers].Id;
        // //don't hard code use constant class    
        Map<Id, User> allUsers = new Map<Id, User>([SELECT ID FROM User WHERE isPortalEnabled = false AND UserType=: OC_AN_Constants.Standard 
                                                    and isactive = True]);
        set<Id> groupForInternalUser = new set<Id>();    
        for(GroupMember m : [SELECT Id, UserOrGroupId, GroupId FROM GroupMember WHERE GroupId IN :groupIds]) {
            if(m.UserOrGroupId == internalUserID){
                groupForInternalUser.add(m.GroupId);
            }
            else if(((String)m.UserOrGroupId).startsWith(userType)) {
                UserId.add((Id)m.UserOrGroupId);
            }
            else if (((String)m.UserOrGroupId).startsWith(groupType)) {               
                groupIdProxys.add(m.UserOrGroupId);
            }
        }
        

        UserId.addAll(allUsers.keySet());
        /*
        system.debug('UserId===>'+UserId);
        
        //get products of bulletin
         Set<Id> bulletinProductIds = new Set<Id>();
         for(OC_AN_Bulletin_Account_Product__c bap : BulletinAccProdlist){
            bulletinProductIds.add(bap.OC_AN_Product__c);
         }

        //check if the bulletin template type -- subscribed by the user for the bought Product
        List<OC_AN_User_Preferences__c> preferences = [SELECT Id,User__c FROM OC_AN_User_Preferences__c
        WHERE Name = :bulletinObj.OC_AN_Type__c
        AND Email__c = true AND Product__c IN :bulletinProductIds AND User__c IN: UserId
        ];

        for(OC_AN_User_Preferences__c pref: preferences){
            userPreferencesUserIdList.add(pref.User__c);
        }   

    */
        List<User> Userdata = new List<User>();
        Userdata = [select Id, Name, FirstName, LastName,Email from User where Id IN :userPreferencesUserIdList];
        system.debug('Result>>'+ Userdata);
        return Userdata;
        
    }
    
}