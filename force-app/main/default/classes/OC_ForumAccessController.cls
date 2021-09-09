/**
* @File Name          : OC_ForumAccessController
* @Description        : Class to assign/unassign permission set related to chatter accessibility. This can be invoked from User and Account Flows 
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 11th November 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-11-05                 IBM                   U-1706 Initial Version
**/
public class OC_ForumAccessController {
    @InvocableMethod
    public static List<String> getRecords(List<Id> ids) {
        Set<Id> set_accountIds = new Set<Id>();
        Set<Id> set_userIds = new Set<Id>();
        
        for(Id temp :ids){
            if(temp.getSObjectType() == User.sObjectType){
                set_userIds.add(temp);
            }
            else if(temp.getSObjectType() == Account.sObjectType){
                set_accountIds.add(temp);
            }
        }
        
        
        List<PermissionSetAssignment> tbCreated_PSA = new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> tbDeleted_PSA = new List<PermissionSetAssignment>();
        
        PermissionSet forumVisibilityPS = [Select Id, Name from PermissionSet where Name = :OC_Org_Defaults__c.getOrgDefaults().OC_Forum_Visibility_PermissionSetName__c LIMIT 1];
        
        //When a user will be created
        if(forumVisibilityPS != NULL && !set_userIds.isEmpty()){
            PermissionSetAssignment tempPSA;
            for(Id temp :set_userIds){
                tempPSA = new PermissionSetAssignment();
                tempPSA.AssigneeId = temp;
                tempPSA.PermissionSetId = forumVisibilityPS.Id;
                tbCreated_PSA.add(tempPSA);
            }
        }
        
        //When a service account will be updated with Forum Visibility true/false
        if(forumVisibilityPS != NULL && !set_accountIds.isEmpty()){
            List<Account> list_accounts = [Select Id, OC_UAM_Forum_Visibility__c from Account where ID IN :set_accountIds];
            
            List<Account> list_enabledForumVisibilityAccounts = new List<Account>();
            List<Account> list_disabledForumVisibilityAccounts = new List<Account>();
            
            for(Account temp :list_accounts){
                if(temp.OC_UAM_Forum_Visibility__c){
                    list_enabledForumVisibilityAccounts.add(temp);
                }
                else{
                    list_disabledForumVisibilityAccounts.add(temp);
                }
            }
            
            if(!list_enabledForumVisibilityAccounts.isEmpty()){
                PermissionSetAssignment tempPSA;
                for(User temp :[Select Id from User where AccountId IN :list_enabledForumVisibilityAccounts]){
                    tempPSA = new PermissionSetAssignment();
                    tempPSA.AssigneeId = temp.Id;
                    tempPSA.PermissionSetId = forumVisibilityPS.Id;
                    tbCreated_PSA.add(tempPSA);
                }
            }
            
            if(!list_disabledForumVisibilityAccounts.isEmpty()){
            	tbDeleted_PSA.addAll([SELECT Id FROM PermissionSetAssignment where PermissionSetId = :forumVisibilityPS.Id AND AssigneeId IN :[Select Id from User where AccountId IN :list_disabledForumVisibilityAccounts]]);
            }
        }
        
        
        if(! tbCreated_PSA.isEmpty()){
            Database.insert(tbCreated_PSA, false); //with false attribute. As permission set can also be existing. So Duplicate exception should not break other assignments.
        }
        
        if(! tbDeleted_PSA.isEmpty()){
            delete tbDeleted_PSA;
        }
        
        return NULL;
    }
}