/**
* @File Name          : OC_AN_FetchUsersFromPG
* @Description        : This will fetch all the users from the added groups to the bulletin
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2107
* @Created Date       : 07th June 2021
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-06-07                 IBM                   Initial Version
* 2.0        2021-07-12                 IBM                   Updated as part of U-2979
**/



public with sharing class OC_AN_FetchUsersFromPG {
    
    
    private static Map<Id,String> ChildGroupIdWithRolesAsParent = new Map<Id,String>();
    private static Set<Id> ChildGroupIdWithoutRoles = new Set<Id>();
    
    public static List<OC_AN_UserAndContactsWrapper> getInternalUsersForBulletin(string idOfBulletin){
        
        set<Id> groupIdsFromBulletin = new Set<Id>();
        set<Id> allContactIds = new Set<Id>();
        set<Id> allUserId = new Set<Id>();
        
        List<OC_AN_UserAndContactsWrapper> userAndContactsWrapper = new List<OC_AN_UserAndContactsWrapper>();
        Map<Id,String> groupIdSetOfRoles = new Map<Id,String>();
        
        for(OC_AN_Bulletin_Account_Product__c oc : 
            [SELECT OC_AN_GroupId__c,OC_AN_RoleForA_N__c
             FROM OC_AN_Bulletin_Account_Product__c
             WHERE OC_AN_Bulletin__c =: idOfBulletin
             AND RecordTypeId =: OC_AN_Constants.recTypeId_PublicGroup]){
                 if(!oc.OC_AN_RoleForA_N__c.contains('Internal Contact')){
                     groupIdSetOfRoles.put(oc.OC_AN_GroupId__c,oc.OC_AN_RoleForA_N__c);
                 }else{
                     groupIdsFromBulletin.add(oc.OC_AN_GroupId__c); 
                 }
             }
        
        
        OC_AN_FetchUsersFromPG.fetchAllTheGroupIdsMap(groupIdSetOfRoles);
        OC_AN_FetchUsersFromPG.fetchAllTheGroupIdsSet(groupIdsFromBulletin);
        
        if(!ChildGroupIdWithRolesAsParent.isEmpty()){
            groupIdSetOfRoles.putAll(ChildGroupIdWithRolesAsParent);
        }
        if(!ChildGroupIdWithoutRoles.isEmpty()){
            groupIdsFromBulletin.addAll(ChildGroupIdWithoutRoles);
        }
        
        for(OC_AN_Group_Member__c userOrContact : [SELECT Id,OC_AN_User__c,OC_AN_User__r.OC_AN_UserRoleForAlertsAndNotifications__c,
                                                   OC_AN_Contact__c, OC_AN_Child_Group__c, OC_AN_Parent_Group__c
                                                   FROM OC_AN_Group_Member__c 
                                                   WHERE OC_AN_Parent_Group__c IN : groupIdSetOfRoles.keySet()  
                                                   OR OC_AN_Child_Group__c IN : groupIdSetOfRoles.keySet() 
                                                  ]){ 
                                                      
                                                      if(userOrContact.OC_AN_User__c != null && userOrContact.OC_AN_User__r.OC_AN_UserRoleForAlertsAndNotifications__c != null
                                                         && groupIdSetOfRoles.containsKey(userOrContact.OC_AN_Parent_Group__c)){
                                                             List<String> rolesAsList = userOrContact.OC_AN_User__r.OC_AN_UserRoleForAlertsAndNotifications__c.split(';');
                                                             List<String> groupRolesAsList = groupIdSetOfRoles.get(userOrContact.OC_AN_Parent_Group__c).split(';');
                                                             for(String st : groupRolesAsList){
                                                                 if(rolesAsList.contains(st)){
                                                                     allUserId.add(userOrContact.OC_AN_User__c);
                                                                     break;
                                                                 }  
                                                             }
                                                             
                                                         }
                                                      
                                                      allContactIds.add(userOrContact.OC_AN_Contact__c) ;
                                                  }
        
        for(OC_AN_Group_Member__c userOrContact : [SELECT Id,OC_AN_User__c,
                                                   OC_AN_Contact__c, OC_AN_Child_Group__c, OC_AN_Parent_Group__c
                                                   FROM OC_AN_Group_Member__c 
                                                   WHERE OC_AN_Parent_Group__c IN : groupIdsFromBulletin  
                                                   OR OC_AN_Child_Group__c IN : groupIdsFromBulletin 
                                                  ]){ 
                                                      
                                                      system.debug('allUserId>>>'+allUserId);
                                                      allUserId.add(userOrContact.OC_AN_User__c);
                                                      system.debug('allContactIds>>>'+allContactIds);
                                                      allContactIds.add(userOrContact.OC_AN_Contact__c) ;
                                                  }
        
        
        for(User usr :[SELECT Id, Name, FirstName, LastName,Email, OC_AN_UserRoleForAlertsAndNotifications__c
                       FROM User
                       WHERE isactive = True and ID IN:allUserId]){
                           //String firstName , String lastName, String Id, String name, String email
                           OC_AN_UserAndContactsWrapper userValue = new OC_AN_UserAndContactsWrapper(usr.FirstName,usr.LastName,usr.Id,usr.Name,usr.Email);
                           userAndContactsWrapper.add(userValue);
                       }
        for(Contact cont :[SELECT Id, Name, FirstName, LastName,Email 
                           FROM Contact 
                           WHERE ID IN:allContactIds]){
                               //String firstName , String lastName, String Id, String name, String email
                               OC_AN_UserAndContactsWrapper userValue = new OC_AN_UserAndContactsWrapper(cont.FirstName,cont.LastName,cont.Id,cont.Name,cont.Email);
                               userAndContactsWrapper.add(userValue);
                           }
        return userAndContactsWrapper;
    }
    
    
    public static void fetchAllTheGroupIdsMap(Map<Id,String> groupIdset){
        
        Set<Id> groupIdsToReturn = new Set<Id>();
        Map<Id,String> childGroupsWithRoles = new Map<Id,String>();
        
        for(OC_AN_Group_Member__c gm : [SELECT Id,OC_AN_Child_Group__r.Name,OC_AN_Parent_Group__c,OC_AN_Child_Group__c
                                        FROM OC_AN_Group_Member__c 
                                        WHERE OC_AN_Parent_Group__c IN: groupIdset.keySet()]){
                                            if(gm.OC_AN_Child_Group__c != null && groupIdset.containsKey(gm.OC_AN_Parent_Group__c) ){
                                                childGroupsWithRoles.put(gm.OC_AN_Child_Group__c,groupIdset.get(gm.OC_AN_Parent_Group__c)) ;
                                            }
                                        }
        if(!childGroupsWithRoles.isEmpty()){
            system.debug('ChildGroupIdWithRolesAsParent>>>>'+ChildGroupIdWithRolesAsParent);
            ChildGroupIdWithRolesAsParent.putAll(childGroupsWithRoles);
            fetchAllTheGroupIdsMap(childGroupsWithRoles);
        }
    }
    
    public static void fetchAllTheGroupIdsSet(Set<Id> groupIdset){
        
        Set<Id> groupIdsToReturn = new Set<Id>();
        Set<Id> childGroups = new Set<Id>();
        
        for(OC_AN_Group_Member__c gm : [SELECT Id,OC_AN_Child_Group__r.Name,OC_AN_Parent_Group__c,OC_AN_Child_Group__c
                                        FROM OC_AN_Group_Member__c 
                                        WHERE OC_AN_Parent_Group__c IN: groupIdset]){
                                            if(gm.OC_AN_Child_Group__c != null && groupIdset.contains(gm.OC_AN_Parent_Group__c) ){
                                                system.debug('childGroups>>>'+childGroups);
                                                childGroups.add(gm.OC_AN_Child_Group__c) ;
                                            }
                                        }
        if(!childGroups.isEmpty()){
            system.debug('ChildGroupIdWithoutRoles>>>'+ChildGroupIdWithoutRoles);
            ChildGroupIdWithoutRoles.addAll(childGroups);
            fetchAllTheGroupIdsSet(childGroups);
        }
    }
}