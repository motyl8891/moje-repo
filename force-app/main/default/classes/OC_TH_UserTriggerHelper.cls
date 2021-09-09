/* Class Name : OC_TH_UserTriggerHelper
* Description : This class handles user functionality logic.
* Author      : IBM.
* @Group              : OmniChannel - Service
* @Created Date       : 01 July 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-07-01                IBM                   Initial Version
*/
public with sharing class OC_TH_UserTriggerHelper {
    /****************************************************************************************
@ Description : This method handles adding User to 'Ericsson LI User Ericsson Service' 
permission set automatically
***************************************************************************************/   
    public static void addLiUserToPermissionSet(Set<Id> userId){
        /*Set Ericsson Service and Customer Community Plus Custom User Profiles*/
        String[] profileName = new String[] {OC_TH_Constants.getCustomerCommunityPlusCustomUserProfile,OC_TH_Constants.getEricssonServiceProfile};
            Set<Id> setEricServiceProfileId = new Set<Id>();
        Set<Id> setCommunityUserProfileId = new Set<Id>();
        Map<Id,User> mapUserIdAndValue = new Map<Id,User>();
        Map<String,Id> mapPermissionSetValuesAndId = new Map<String,Id>();
        try{
            for(Profile prof : [SELECT Id,Name FROM Profile WHERE Name IN: profileName]){
                if(prof.Name == OC_TH_Constants.getEricssonServiceProfile){
                    /*Set System admin or Ericsson Service profile Id */
                    setEricServiceProfileId.add(prof.Id);
                }
                /*Set Customer Community Plus Custom User profile Id */
                if(prof.Name == OC_TH_Constants.getCustomerCommunityPlusCustomUserProfile){
                    setCommunityUserProfileId.add(prof.Id);
                }
            }   
            
            for(User us : [SELECT Id,Name,OC_TH_LI_CSR_User__c,ProfileId,IsActive FROM User 
                           WHERE Id =: userId AND OC_TH_LI_CSR_User__c = True]){
                               mapUserIdAndValue.put(us.Id,us);   
                           }        
            
            for(PermissionSet ps : [SELECT Id,Name FROM PermissionSet]){
                if(ps.Name == OC_TH_Constants.getEricssonLiServiceUserPermissionSet){
                    mapPermissionSetValuesAndId.put(ps.Name,ps.Id);
                }
                if(ps.Name == OC_TH_Constants.getEricssonLiCommunityUserPermissionSet){
                    mapPermissionSetValuesAndId.put(ps.Name,ps.Id);
                }
            }
            List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment >();
            /* if OC_TH_LI_CSR_User__c check is true add User automatically to  OC_TH_Ericsson_LI_Service_User OR OC_TH_Ericsson_LI_community_user permission set */  
            if(!mapUserIdAndValue.isEmpty()){
                for(User uId : mapUserIdAndValue.Values()){
                    if(uId.IsActive == True && setEricServiceProfileId != Null && setEricServiceProfileId.contains(uId.ProfileId) && 
                       mapPermissionSetValuesAndId != Null &&  mapPermissionSetValuesAndId.containsKey(OC_TH_Constants.getEricssonLiServiceUserPermissionSet)){ 
                           /*Get OC_TH_Ericsson_LI_Service_User permission set ID*/
                           Id getLIServiceUserID = mapPermissionSetValuesAndId.get(OC_TH_Constants.getEricssonLiServiceUserPermissionSet);
                           PermissionSetAssignment psa = new PermissionSetAssignment();
                           psa.PermissionSetId = getLIServiceUserID;
                           psa.AssigneeId = uId.Id;
                           psaList.add(psa);                      
                       }
                    if(uId.IsActive == True && setCommunityUserProfileId != Null && setCommunityUserProfileId.contains(uId.ProfileId) &&  
                       mapPermissionSetValuesAndId != Null && mapPermissionSetValuesAndId.containsKey(OC_TH_Constants.getEricssonLiCommunityUserPermissionSet)){ 
                           /*Get OC_TH_Ericsson_LI_community_user permission set ID*/
                           Id getLICommunityUserID = mapPermissionSetValuesAndId.get(OC_TH_Constants.getEricssonLiCommunityUserPermissionSet);
                           PermissionSetAssignment psa1 = new PermissionSetAssignment();
                           psa1.PermissionSetId = getLICommunityUserID;
                           psa1.AssigneeId = uId.Id;
                           psaList.add(psa1); 
                       }
                }
            }
            if(psaList.size()>0){
                Database.Insert(psaList,False);  
            }
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_userHelperClass,OC_TH_Constants.method_updateAddLiUserToPermissionSet,null, false, e));
        }   
    }
    
    /****************************************************************************************
@ Description : This method handles adding Ericsson Service User to LICSR public group automatically
***************************************************************************************/ 
    public static void addUserToLicsrPublicGroup(set<Id> setUserId){ 
        /*Set Ericsson Service Profile*/
        String[] profileName = new String[] {OC_TH_Constants.getEricssonServiceProfile};     
            Set<Id> setEricServiceProfileId = new Set<Id>();  
        Map<Id,User> mapUserIdAndValue = new Map<Id,User>();
        try{
            for(Profile prof : [Select Id,Name from Profile Where Name IN: profileName]){ 
                setEricServiceProfileId.add(prof.Id);   
            }  
            for(User us : [SELECT Id,Name,OC_TH_LI_CSR_User__c,ProfileId,IsActive FROM User 
                           WHERE Id =: setUserId AND OC_TH_LI_CSR_User__c = True AND IsActive = True]){
                               mapUserIdAndValue.put(us.Id,us);   
                           }
            /* Fetch LICSR group Id*/
            Group grp = [SELECT Id,Type,DeveloperName, Name FROM Group 
                         WHERE DeveloperName =: OC_TH_Constants.getLICSRPublicGroup];                
            Id groupId = grp.Id;
            /*When LICSR checkbox is True add Ericsson Service User as group member to LICSR public group*/
            List<GroupMember> grpMemberList = new List<GroupMember>();
            if(!mapUserIdAndValue.isEmpty()){
                for(User u : mapUserIdAndValue.values()){
                    if(u.OC_TH_LI_CSR_User__c == True && setEricServiceProfileId != Null && setEricServiceProfileId.contains(u.ProfileId)){   
                        GroupMember gpMember = new GroupMember();
                        gpMember.UserOrGroupId = u.Id;
                        gpMember.GroupId = groupId;
                        grpMemberList.add(gpMember);
                    }
                }
            }
            if(grpMemberList.size()>0){
                Database.Insert(grpMemberList,False);  
            }
        }
        catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_userHelperClass,OC_TH_Constants.method_updateAddUserToLicsrPublicGroup,null, false, e));
        }
    }
    
    
    /****************************************************************************************
@ Description : This method handles deleting of User from 'Ericsson LI User Ericsson Service' 
and 'Ericsson LI community user ' permission set automatically
***************************************************************************************/ 
    
    public static void removeLiUserFromPermissionSet(set<Id> userId){
        
        Set<Id> storeUserId = new Set<Id>();   
        Map<Id,User> mapUser = new Map<Id,User>();
        Map<Id,String> mapPermissionSetIdAndValues = new Map<Id,String>();
        Set<Id> setPermissionSetId = new Set<Id>();
        Map<Id,PermissionSetAssignment> mapPsa = new Map<Id,PermissionSetAssignment>();
        try{
            for(User us : [SELECT Id,OC_TH_LI_CSR_User__c FROM User WHERE Id =: userId]){
                storeUserId.add(us.Id);
                mapUser.put(us.Id,us);
            }
            for(PermissionSet ps : [Select Id,Name from PermissionSet]){
                if(ps.Name == OC_TH_Constants.getEricssonLiServiceUserPermissionSet || ps.Name == OC_TH_Constants.getEricssonLiCommunityUserPermissionSet){
                    mapPermissionSetIdAndValues.put(ps.Id,ps.Name);
                    setPermissionSetId.add(ps.Id);
                }
            }
            if(storeUserId != null && setPermissionSetId != null){
                for(PermissionSetAssignment psaId : [SELECT Id,PermissionSetId,AssigneeId FROM PermissionSetAssignment 
                                                     WHERE AssigneeId =: storeUserId AND PermissionSetId =: setPermissionSetId]){
                                                         mapPsa.put(psaId.Id,psaId);
                                                     }
            } 
            /*When LICSR checkbox is false remove Ericsson Service user and community User from Permission set  */
            List<PermissionSetAssignment> deletePsaList = new List<PermissionSetAssignment >();
            Map<Id,PermissionSetAssignment> mapToDeletePermissionSetAssignee = new Map<Id,PermissionSetAssignment>();
            if(!mapUser.isEmpty() && !mapPsa.isEmpty()){
                for(User u : mapUser.values()){
                    for(PermissionSetAssignment psaId : mapPsa.values()){
                        Id permissionSetId = psaId.PermissionSetId;  
                        if(mapPermissionSetIdAndValues != Null && permissionSetId != Null && u.OC_TH_LI_CSR_User__c == False && mapPermissionSetIdAndValues.containsKey(permissionSetId)){
                            PermissionSetAssignment permissionSetAssignee = new PermissionSetAssignment();
                            permissionSetAssignee.PermissionSetId = permissionSetId;
                            permissionSetAssignee.AssigneeId = u.Id;
                            permissionSetAssignee.Id = psaId.Id;
                            deletePsaList.add(permissionSetAssignee); 
                            mapToDeletePermissionSetAssignee.putAll(deletePsaList);
                        }  
                    }
                }
            } 
            if(mapToDeletePermissionSetAssignee != Null && mapToDeletePermissionSetAssignee.size()>0){
                Database.Delete(mapToDeletePermissionSetAssignee.values());
            }  
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_userHelperClass,OC_TH_Constants.method_updateRemoveLiUserFromPermissionSet,null, false, e));
        }
    }
    
    /****************************************************************************************
@ Description : This method handles deleting of User from 'LICSR' Public group automatically
***************************************************************************************/ 
    
    public static void removeLiUserFromLIPublicGroup(set<Id> userId){
        
        Set<Id> liPublicGroup = new Set<Id>();
        Set<Id> storeUserId = new Set<Id>();
        Map<Id,User> mapUserId = new Map<Id,User>();
        Map<String,Id> mapGroupIdAndDevName = new Map<String,Id>();
        Map<Id,GroupMember> mapGrpMemberIdAndValue = new Map<Id,GroupMember>();
        try{
            for(User us : [SELECT Id,OC_TH_LI_CSR_User__c FROM User WHERE Id =: userId AND OC_TH_LI_CSR_User__c = False]){
                storeUserId.add(us.Id);
                mapUserId.put(us.Id,us);
            }  
            for(Group ligrp : [SELECT Id,Type,DeveloperName,Name FROM Group WHERE DeveloperName =: OC_TH_Constants.getLICSRPublicGroup]){
                liPublicGroup.add(ligrp.Id);  
                mapGroupIdAndDevName.put(ligrp.DeveloperName,ligrp.Id);
            }
            /*Fetch Group Member */
            for(GroupMember grpMem : [SELECT Id,UserOrGroupId, GroupId,Group.DeveloperName FROM GroupMember WHERE GroupId =: liPublicGroup AND UserOrGroupId =: storeUserId]){
                mapGrpMemberIdAndValue.put(grpMem.Id,grpMem);  
            }
            /*When LICSR checkbox is false remove Ericsson Service user from LICSR group  */
            List<GroupMember> deleteLiMemberList = new List<GroupMember>();
            Map<Id,GroupMember> mapToDeleteGrpMember = new Map<Id,GroupMember>();
            if(!mapUserId.isEmpty() && !mapGrpMemberIdAndValue.isEmpty()){
                for(User usId : mapUserId.values()){
                    for(GroupMember grpMemId : mapGrpMemberIdAndValue.values()){
                        String grpDevName = grpMemId.Group.DeveloperName;
                        if(!mapGroupIdAndDevName.isEmpty() && grpDevName != null &&  mapGroupIdAndDevName.containsKey(grpDevName)){
                            Id grpId = mapGroupIdAndDevName.get(grpDevName);
                            System.debug('grpId:--' +grpId);
                            if(usId.OC_TH_LI_CSR_User__c == False){
                                GroupMember liGroupMember = new GroupMember();
                                liGroupMember.UserOrGroupId = usId.ID;
                                liGroupMember.GroupId = grpId;
                                liGroupMember.Id = grpMemId.Id;
                                deleteLiMemberList.add(liGroupMember);   
                                System.debug('Deleted LI grp member :--' +deleteLiMemberList);
                                mapToDeleteGrpMember.putAll(deleteLiMemberList);
                            }
                        }
                    }
                }
            }
            if(mapToDeleteGrpMember != null && mapToDeleteGrpMember.size()>0){
                Database.Delete(mapToDeleteGrpMember.values());
            }   
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_userHelperClass,OC_TH_Constants.method_updateRemoveLiUserFromLIPublicGroup,null, false, e));
        }
    }
    /****************************************************************************************
@ Description : This method handles adding User to country specific public group automatically
***************************************************************************************/      
    public static void addUserToLiCountryPublicGroup(set<Id> setUserId){ 
        
        Map<String,String> mapGroupRelatedCountry = new  Map<String,String>();
        Map<Id,User> mapUserIdAndCountry = new Map<Id,User>();
        Set<String> setUserCountry = new Set<String>();
        Set<String> setGroupDeveloperName = new Set<String>();
        /*Set Ericsson Service Profile*/
        String[] profileName = new String[] {OC_TH_Constants.getEricssonServiceProfile};     
            Set<Id> setEricServiceProfileId = new Set<Id>();  
        try{
            for(Profile prof : [Select Id,Name from Profile Where Name IN: profileName]){ 
                setEricServiceProfileId.add(prof.Id);   
            } 
            for(User user : [SELECT Id,Name,OC_TH_Country_LI_CSR__c,OC_TH_LI_CSR_User__c,ProfileId FROM User 
                             Where OC_TH_Country_LI_CSR__c != Null AND ProfileId =: setEricServiceProfileId
                             AND OC_TH_LI_CSR_User__c = True 
                             AND Id IN: setUserId]){    
                                 /* Adding User Id and user values to Map */
                                 mapUserIdAndCountry.put(user.Id,user);
                                 /*List of string is used to split the multi-Select picklist value*/
                                 String[] countriesSplit = user.OC_TH_Country_LI_CSR__c.split(';');
                                 setUserCountry.addAll(countriesSplit);
                             }
            for(OC_TH_LICSR_Country__mdt licsr : [SELECT Id,OC_TH_User_Country__c,OC_TH_Public_Group_Country__c FROM OC_TH_LICSR_Country__mdt 
                                                  WHERE OC_TH_User_Country__c =: setUserCountry
                                                  AND OC_TH_Public_Group_Country__c != null]){
                                                      /*Adding user specific country and public grp to map */
                                                      mapGroupRelatedCountry.put(licsr.OC_TH_User_Country__c,licsr.OC_TH_Public_Group_Country__c);
                                                      /*setGroupDeveloperName set is used to compare with Public developer name */
                                                      setGroupDeveloperName.add(licsr.OC_TH_Public_Group_Country__c);    
                                                  }
            
            Map<String,Id> mapGroupIdAndDevName = new Map<String,Id>();
            for(Group gploop : [SELECT Id,Type,DeveloperName, Name FROM Group 
                                WHERE DeveloperName =: setGroupDeveloperName]){
                                    mapGroupIdAndDevName.put(gploop.DeveloperName,gploop.Id);
                                }
            
            List<GroupMember> grpMember = new List<GroupMember>();
            if(!mapUserIdAndCountry.isEmpty()){
                for(User userId : mapUserIdAndCountry.values()){ 
                    List<String> storeUserCountry = userId.OC_TH_Country_LI_CSR__c.split(';');
                    if(!mapGroupRelatedCountry.isEmpty()){
                        for(String metadataUserCountry:mapGroupRelatedCountry.keySet()){
                            if(storeUserCountry.contains(metadataUserCountry)){
                                String storeMetadataUserCountry = mapGroupRelatedCountry.get(metadataUserCountry);
                                if(!mapGroupIdAndDevName.isEmpty() && mapGroupIdAndDevName.containsKey(storeMetadataUserCountry)){
                                    Id groupId = mapGroupIdAndDevName.get(storeMetadataUserCountry);
                                    GroupMember grpConMbr = new GroupMember();
                                    grpConMbr.UserOrGroupId = userId.Id;
                                    grpConMbr.GroupId = groupId;
                                    grpMember.add(grpConMbr);
                                    System.debug('New Group member :--' +grpMember);   
                                }     
                            }
                        }
                    }
                }
            }
            if(grpMember != Null && grpMember.size()>0){
                Database.Insert(grpMember,False); 
            }
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_userHelperClass,OC_TH_Constants.method_updateAddUserToLiCountryPublicGroup,null, false, e));
        }
    }
    /****************************************************************************************
@ Description : This method handles deleting LICSR User from country specific public group automatically
***************************************************************************************/ 
    public static void deleteUserFromPublicGroup(set<Id> userId ,Map<Id,User> oldUserMap){ 
        
        Map<Id,User> mapUserIdValue = new Map<Id,User>();
        Set<String> userCountryValueSet = new Set<String>();
        Set<Id> userIdSet = new Set<Id>();
        Map<String,String> mapLicsrUserAndCounty = new Map<String,String>();
        Set<String> metadataPublicGrpSet = new Set<String>();
        Map<String,Id> mapGroupDevNameAndId = new Map<String,Id>();
        Set<Id> groupIdSet = new Set<Id>();
        Map<Id,GroupMember> mapGrpMemIdAndValue = new Map<Id,GroupMember>();
        try{
            for(User us : [SELECT Id,Name,OC_TH_Country_LI_CSR__c,OC_TH_LI_CSR_User__c FROM User Where Id IN: userId ]){
                if((us.OC_TH_Country_LI_CSR__c != null ||us.OC_TH_Country_LI_CSR__c == Null) && (us.OC_TH_LI_CSR_User__c == TRUE || us.OC_TH_LI_CSR_User__c == FALSE)){
                    User usOldCountry = oldUserMap.get(us.Id); 
                    if(usOldCountry != Null && usOldCountry.OC_TH_Country_LI_CSR__c != Null){
                        String[] countrySplit = usOldCountry.OC_TH_Country_LI_CSR__c.split(';');
                        userCountryValueSet.addAll(countrySplit);
                        userIdSet.add(us.Id);
                        mapUserIdValue.put(us.Id,us);
                    }
                }
            }
            for(OC_TH_LICSR_Country__mdt licsrMtd : [SELECT Id,OC_TH_User_Country__c,OC_TH_Public_Group_Country__c FROM OC_TH_LICSR_Country__mdt]){
                mapLicsrUserAndCounty.put(licsrMtd.OC_TH_User_Country__c,licsrMtd.OC_TH_Public_Group_Country__c);
                metadataPublicGrpSet.add(licsrMtd.OC_TH_Public_Group_Country__c);
            }
            for(Group grp : [SELECT Id,Type,DeveloperName, Name FROM Group WHERE DeveloperName =: metadataPublicGrpSet]){
                mapGroupDevNameAndId.put(grp.DeveloperName,grp.Id);
                groupIdSet.add(grp.Id);
            }
            for(GroupMember grpMem : [SELECT Id,UserOrGroupId, GroupId,Group.DeveloperName FROM GroupMember WHERE GroupId =: groupIdSet AND UserOrGroupId =:userIdSet ]){
                mapGrpMemIdAndValue.put(grpMem.Id,grpMem);
            }
            /*Deleting LICSR User from country specific public group automatically*/
            Map<Id,GroupMember> mapDeleteGrpMembers = new Map<Id,GroupMember>();
            List<GroupMember> deleteMemberList = new List<GroupMember>();
            if(!mapUserIdValue.isEmpty() && !mapGrpMemIdAndValue.isEmpty()){
                for(User uId : mapUserIdValue.values()){
                    Id getUserId = uId.Id;
                    for(GroupMember gmId : mapGrpMemIdAndValue.values()){
                        Id gmGrpId = gmId.GroupId;
                        Id gmUsId = gmId.UserOrGroupId;
                        if(userCountryValueSet != Null){
                            for(String country : userCountryValueSet){
                                if(uId.OC_TH_Country_LI_CSR__c != Null){
                                    String[] getCurrentCountry = uId.OC_TH_Country_LI_CSR__c.split(';');
                                    if(!mapLicsrUserAndCounty.isEmpty() && mapLicsrUserAndCounty.containsKey(country) && getCurrentCountry != Null && !getCurrentCountry.contains(country)){
                                        String getPublicGroup = mapLicsrUserAndCounty.get(country);
                                        if(!mapGroupDevNameAndId.isEmpty() && mapGroupDevNameAndId.containsKey(getPublicGroup)){
                                            Id getGrpId = mapGroupDevNameAndId.get(getPublicGroup);
                                            if(getGrpId.equals(gmGrpId) && getUserId.equals(gmUsId)){
                                                GroupMember grpMemRec = new GroupMember();
                                                grpMemRec.UserOrGroupId = getUserId;
                                                grpMemRec.GroupId = getGrpId;
                                                grpMemRec.Id = gmId.Id;
                                                deleteMemberList.add(grpMemRec);
                                                mapDeleteGrpMembers.putAll(deleteMemberList);
                                            }
                                        }
                                    }
                                }
                                if(uId.OC_TH_Country_LI_CSR__c == Null){
                                    if(!mapLicsrUserAndCounty.isEmpty() && mapLicsrUserAndCounty.containsKey(country)){
                                        String getPublicGroupforNull = mapLicsrUserAndCounty.get(country);
                                        if(!mapGroupDevNameAndId.isEmpty() && mapGroupDevNameAndId.containsKey(getPublicGroupforNull)){
                                            Id getGrpIdofNull = mapGroupDevNameAndId.get(getPublicGroupforNull);
                                            if(getGrpIdofNull.equals(gmGrpId) && getUserId.equals(gmUsId)){
                                                GroupMember grpMemNullRec = new GroupMember();
                                                grpMemNullRec.UserOrGroupId = getUserId;
                                                grpMemNullRec.GroupId = getGrpIdofNull;
                                                grpMemNullRec.Id = gmId.Id;
                                                deleteMemberList.add(grpMemNullRec);
                                                mapDeleteGrpMembers.putAll(deleteMemberList);
                                            }
                                        } 
                                    }
                                }
                            }
                        }
                    } 
                }
            }
            if(mapDeleteGrpMembers != null && mapDeleteGrpMembers.size()>0){  
                Database.Delete(mapDeleteGrpMembers.values());
            }
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_userHelperClass,OC_TH_Constants.method_updateDeleteUserFromPublicGroup,null, false, e));
        }
    }
}