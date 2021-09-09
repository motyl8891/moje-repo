public class TestClassUsers {
        
    private static Map<Id,String> ChildGroupIdWithRolesAsParent = new Map<Id,String>();

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
                groupIdSetOfRoles.put(oc.OC_AN_GroupId__c,oc.OC_AN_RoleForA_N__c);
            }
        TestClassUsers.fetchAllTheGroupIdsMap(groupIdSetOfRoles);
        
      if(!ChildGroupIdWithRolesAsParent.isEmpty()){
       groupIdSetOfRoles.putAll(ChildGroupIdWithRolesAsParent);
        }
        
        system.debug('groupIdSetOfRoles====>'+groupIdSetOfRoles);

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
        
        
        system.debug('allUserId===>'+allUserId);
        
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
        system.debug(Logginglevel.ERROR,'userAndContactsWrapper:' + userAndContactsWrapper);
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
            ChildGroupIdWithRolesAsParent.putAll(childGroupsWithRoles);
            fetchAllTheGroupIdsMap(childGroupsWithRoles);
        }
    }
    
    

}