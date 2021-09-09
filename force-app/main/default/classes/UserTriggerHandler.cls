/* Class Name : UserTriggerHandler
* Description : This class handles all the trigger events for User object. 
* Author      : IBM. 
*
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        10-09-2020             Richa Gupta            U-1999 : Automate the process of assigning users to existing employee records.
* 1.1        2021-06-08             Aishwarya Aithal       U-2948 : Ticket Handling: LICSR User Setup      
**/
public class UserTriggerHandler implements TriggerInterface{
  /**************************************************************************************
* @Description :  This method for U-2948 Creates/Removes user from Public Groups and Permission set.                
* @Param          Map -User newMap.
**************************************************************************************/       
    public void AfterInsert(Map<Id, SObject> newItems){
        Map<Id,User> mapIdToNewUser = (Map<Id,User>) newItems;
        Map<Id,User> oldUsersMap = new Map<Id,User>();
        /*U-2948 - LICSR logic to add user automatically to permission set and Public grp*/
        Set<Id> adduserIdToGroupAndPermissionSet = new Set<Id>();
        Set<Id> addUserToCountryGroup = new Set<Id>();
         /*US - 1999 */
        List<User> newUsersList = new List<User>();
        
        for(User u : mapIdToNewUser.values()){
            newUsersList.add(u);
            System.debug('New user list :--'+newUsersList);
            oldUsersMap.put(u.Id,u);
            /*U-2948 - Ticket Handling: LICSR User Setup*/
            if(u.OC_TH_LI_CSR_User__c == True){
                adduserIdToGroupAndPermissionSet.add(u.Id);
                addUserToCountryGroup.add(u.Id);
            }
        }
        /*US - 1999 */
        if(!newUsersList.isEmpty()){
            UserTriggerHelper.mapUserToEmployee(newUsersList,oldUsersMap,True);  
        }
         /*US - 2948 */
        if(!adduserIdToGroupAndPermissionSet.isEmpty()){
            OC_TH_UserTriggerHelper.addLiUserToPermissionSet(adduserIdToGroupAndPermissionSet);
            OC_TH_UserTriggerHelper.addUserToLicsrPublicGroup(adduserIdToGroupAndPermissionSet);
        }
        /*US - 2948 */
        if(!addUserToCountryGroup.isEmpty()){
            OC_TH_UserTriggerHelper.addUserToLiCountryPublicGroup(addUserToCountryGroup);
        }
    }
  /**************************************************************************************
* @Description :  This method for U-2948 Creates/Removes user from Public Groups and Permission set.                   
* @Param          Map -User newMap and  Map -User oldMap.
**************************************************************************************/       
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        Map<Id,User> mapIdToNewUser = (Map<Id,User>) newItems;
        Map<Id,User> mapIdToOldUser = (Map<Id,User>) oldItems;
        List<User> newUsersList = new List<User>();
        /*U-2948 - LICSR logic to add user automatically to permission set and Public grp*/
        Set<Id> adduserIdToGroupAndPermissionSet = new Set<Id>();
        Set<Id> removeUserFromGroupAndPermissionSet = new Set<Id>();
        Set<Id> addUserToCountryGroup = new Set<Id>();
        Set<Id> deleteUserFromCountryGroup = new Set<Id>();
        for(User us : mapIdToNewUser.values()){
            newUsersList.add(us);
            /*U-2948 - Ticket Handling: LICSR User Setup*/
            if(us.OC_TH_LI_CSR_User__c == True){
                adduserIdToGroupAndPermissionSet.add(us.Id);
                addUserToCountryGroup.add(us.Id);
            }
            if(us.OC_TH_LI_CSR_User__c == False){
                removeUserFromGroupAndPermissionSet.add(us.Id);
            }
            deleteUserFromCountryGroup.add(us.Id);
        } 
        /*US - 1999 */
        if(!newUsersList.isEmpty()){
            UserTriggerHelper.mapUserToEmployee(newUsersList,mapIdToOldUser,false);  
        }
        /*US - 2948 */
        if(!adduserIdToGroupAndPermissionSet.isEmpty()){
            OC_TH_UserTriggerHelper.addLiUserToPermissionSet(adduserIdToGroupAndPermissionSet);
            OC_TH_UserTriggerHelper.addUserToLicsrPublicGroup(adduserIdToGroupAndPermissionSet);
        }
        /*US - 2948 */
        if(!removeUserFromGroupAndPermissionSet.isEmpty()){
            OC_TH_UserTriggerHelper.removeLiUserFromLIPublicGroup(removeUserFromGroupAndPermissionSet);
            OC_TH_UserTriggerHelper.removeLiUserFromPermissionSet(removeUserFromGroupAndPermissionSet);
        }
        /*US - 2948 */
        if(!addUserToCountryGroup.isEmpty()){
            OC_TH_UserTriggerHelper.addUserToLiCountryPublicGroup(addUserToCountryGroup);
        }
        /*US - 2948 */
        if(!deleteUserFromCountryGroup.isEmpty()){
            OC_TH_UserTriggerHelper.deleteUserFromPublicGroup(deleteUserFromCountryGroup, mapIdToOldUser);
        }
    }
/**************************************************************************************
* @Description :                     
* @Param          List -User newItems.
**************************************************************************************/     
    public void BeforeInsert(List<SObject> newItems){
        List<User> userList = (List<User>) newItems;
        /*US - 1999 */
         List<User> newUsersList = new List<User>();
        for(User us : userList){
            newUsersList.add(us);
            system.debug('Befre insert user :--'+newUsersList);
        }
        if(!newUsersList.isEmpty()){
        UserTriggerHelper.updateUserNickName(newUsersList);
        }
    }
/**************************************************************************************
* @Description :             
* @Param          Map -User newMap and  Map -User oldMap.
**************************************************************************************/     
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        Map<Id,User> mapIdToNewUser = (Map<Id,User>) newItems;
        Map<Id,User> mapIdToOldUser = (Map<Id,User>) oldItems;
        /*US - 1999 */
        List<User> newUsersList = new List<User>();
        try{  
            for(User us : mapIdToNewUser.values()){
                  newUsersList.add(us);
                 System.debug('User updated lst :='+newUsersList); 
            }
            if(!newUsersList.isEmpty()){
                UserTriggerHelper.upadteAssociatedTerritories(newUsersList,mapIdToOldUser);
            }  
        }catch(Exception e){
            System.debug('##'+e.getLineNumber()+'##'+e.getMessage());
        } 
    }
    
    public void BeforeDelete(Map<Id, SObject> oldItems){}
    public void AfterDelete(Map<Id, SObject> oldItems){}
    public void AfterUndelete(Map<Id, SObject> oldItems){}  
}