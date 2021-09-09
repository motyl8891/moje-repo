/* Class Name : OC_TH_CaseCheckLI_CSR
* Description : This class handles CaseMilestone logic.
* Author      : IBM.
*/
public with sharing class OC_TH_CaseCheckLI_CSR {
     /****************************************************************************************
@ Description : This method used to convert NON LICSR to  LICSR(cases) with certain public group members.
***************************************************************************************/
    public static void caseCheckLI_CSR(list<case> caseRecList){
        Set<String> setCaseCountry = new Set<String>();
        map<id,id> mapCaseCheckWithOwner = new map<id,id>();
        set<id> setCurrentUserId = new set<id>();
        boolean isExistUser = false;
        String userId = UserInfo.getUserId();
        Set<String> setGroupDeveloperName = new Set<String>();
        try{
            List<Case> csList = [SELECT Id,LastModifiedByid,CaseNumber,Account.Name, Account.BillingCountry, Owner.Name,OwnerId, OC_TH_LI_CSR__c FROM Case 
                                 WHERE Id =: caseRecList AND Accountid != null AND Account.BillingCountry != null];
          
            for(Case objCase : csList){ 
                setCaseCountry.add(objCase.Account.BillingCountry);
                setCurrentUserId.add(userId);           
            }
            for(OC_TH_LICSR_Country__mdt licsrMdt : [SELECT Id,DeveloperName, OC_TH_User_Country__c, OC_TH_Public_Group_Country__c,OC_TH_Accout_Billing_Country__c FROM OC_TH_LICSR_Country__mdt 
                                                     WHERE OC_TH_Accout_Billing_Country__c =: setCaseCountry
                                                     AND OC_TH_Public_Group_Country__c != null]){
                                                         setGroupDeveloperName.add(licsrMdt.OC_TH_Public_Group_Country__c);
                                                     }
            if(!setGroupDeveloperName.isEmpty()){
                for(GroupMember m : [Select Id, UserOrGroupId,GroupId,Group.type From GroupMember Where Group.DeveloperName IN : setGroupDeveloperName]) {
                    if(setCurrentUserId.contains(m.UserOrGroupId)){
                        isExistUser = true;
                    }  
                }
            }
            for(case objCase: caseRecList){
                if(isExistUser){
                    objCase.ownerid = userId;
                }
            }
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_caseCheckLI_CSR,OC_TH_Constants.method_basedOnQueueAssignment,null, false, e));
        }  
    }
  
    
    /****************************************************************************************
@ Description : This method used to send mail to  LICSR(cases) with certain public group members matched with queue members.
***************************************************************************************/
    public static void sendEmailtoPublicGroup(Map<Id, SObject> newItems){
        Map<Id,Case> mapCaseIdAndBillingCountry = new Map<Id,Case>();
        Set<String> setCaseCountry = new Set<String>();
        Set<String> setGroupDeveloperName = new Set<String>();
        set<String> queueName = new set<String>();
        set<id> setGroupId = new set<id>();
        set<id> setGroupSecId = new set<id>();
        set<id> setGroupQueueId = new set<id>();
        set<id> setUserId = new set<id>();
        set<id> setGroupWithMemberId = new set<id>();
        map<String,id> mailToAddresses = new map<String,id>();
        Map<String,String> mapBillingCountryAndGroup = new Map<String,String>();
        String strDeveloperName= OC_TH_Constants.getEmailTemplate;
        List<CustomNotificationType> CustomNotificationTypeList = OC_SystemUtility.licsrFetchCustomNotificationType(OC_TH_Constants.customNotificationType);
        
        try{
            List<Case> csList = OC_SystemUtility.licsrCases(newItems);
            if(!csList.isEmpty()){
            for(Case caselist : csList){  
                //For metadata use only
                setCaseCountry.add(caselist.Account.BillingCountry);
                if(string.isNotEmpty(caselist.OC_TH_Latest_Queue_Name__c)){
                    //Direct comparing in group
                    queueName.add(caselist.OC_TH_Latest_Queue_Name__c); 
                }
            }
            if(queueName.size() > 0){
               list<Group> lstGroup =  [Select Id from Group where type =: OC_TH_Constants.getQueue and Name=: queueName];
               for(Group objGroup : lstGroup){
                   setGroupId.add(objGroup.id);
               }
            }
            if(setGroupId.size() > 0){
                for(GroupMember groupMeb : [Select UserOrGroupId From GroupMember where GroupId =:setGroupId]){
                    String userId = groupMeb.UserOrGroupId;
                        if(userId.startsWith(OC_TH_Constants.userId)){
                            setGroupQueueId.add(groupMeb.UserOrGroupId);
                        }else{
                            setGroupWithMemberId.add(groupMeb.UserOrGroupId);
                        }
                    
                }
            }
            if(setGroupWithMemberId.size() > 0){
               list<Group> lstGroup =  [Select Id from Group where id=: setGroupWithMemberId];
               for(Group objGroup : lstGroup){
                   setGroupSecId.add(objGroup.id);
               }
            }    
            if(setGroupSecId.size() > 0){
                for(GroupMember groupMeb : [Select UserOrGroupId From GroupMember where GroupId =:setGroupSecId]){
                    setGroupQueueId.add(groupMeb.UserOrGroupId);
                }
            }
            for(OC_TH_LICSR_Country__mdt licsrMdt : [SELECT Id,DeveloperName, OC_TH_User_Country__c, OC_TH_Public_Group_Country__c,OC_TH_Accout_Billing_Country__c FROM OC_TH_LICSR_Country__mdt 
                                                     WHERE OC_TH_Accout_Billing_Country__c =: setCaseCountry
                                                     AND OC_TH_Public_Group_Country__c != null]){
                                                         mapBillingCountryAndGroup.put(licsrMdt.OC_TH_Accout_Billing_Country__c,licsrMdt.OC_TH_Public_Group_Country__c);
                                                         setGroupDeveloperName.add(licsrMdt.OC_TH_Public_Group_Country__c);
                                                     }
            for(Group grp : [Select Id,Type,DeveloperName, Name,(SELECT UserOrGroupId FROM GroupMembers) from Group where DeveloperName =: setGroupDeveloperName]){
                for (GroupMember gm : grp.GroupMembers) {
                    //Matching the queue member with group member
                    if(setGroupQueueId.contains(gm.UserOrGroupId)){
                        setUserId.add(gm.UserOrGroupId);
                    }
                }
            }
            List<User> userList = OC_SystemUtility.licsrFetchUser(setUserId);
            for(User u : userList) {
                mailToAddresses.put(u.email,u.id);
            }
            if(!mailToAddresses.isEmpty()){
                OC_SystemUtility.sendMail(mailToAddresses,strDeveloperName); 
                OC_SystemUtility.sendCustomNotification(mailToAddresses,CustomNotificationTypeList[0].id,System.Label.OC_TH_Custom_Notification_Bell_Icon,System.Label.OC_TH_Custom_Notification_Bell_Icon,csList[0].id);   
            }
            }
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_caseCheckLI_CSR,OC_TH_Constants.method_sendEmailtoPublicGroup,null, false, e));
        }  
    }
   
}