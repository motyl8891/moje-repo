/* Class Name : OC_TH_FeedItemTriggerHandler
* Description : This class handles all the trigger events for FeedItem object. 
* Author      : IBM.
* @Group              : OmniChannel - Service
* @Created Date       : 13 April 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-04-13                 IBM                   Initial Version
**/   
public with sharing class OC_TH_FeedItemTriggerHandler implements OC_TriggerInterface{
    
    /**************************************************************************************
* @Description  This method prevents non-investigation leader from
sharing information to external User.
* @Param        List -Case newItems. 
**************************************************************************************/  
    
    public void BeforeInsert(List<SObject> newItems){     
      /*  List<FeedItem> listToNewFeedItem = (List<FeedItem>) newItems;
        Set<Id> setfeedParentId = new Set<Id>();
        List<Case> caseList = new List<Case>();
        List<User> userList = new List<User>();
        Set<Id> setCaseOwnerId = new Set<Id>();
        Set<Id> setUserId = new Set<Id>();*/
        
        /*Fetch record type of task object.*/
      /*  Id standardRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getStandardCsrRecordType).getRecordTypeId();
        
        for(FeedItem feeditem : listToNewFeedItem){
            setfeedParentId.add(feeditem.ParentId);
        }
        
        caseList = [SELECT Id,OwnerId from Case where RecordTypeId =: standardRecordType AND Id IN: setfeedParentId];
        for(Case cs : caseList){
            setCaseOwnerId.add(cs.OwnerId);
        }*/
        /*Fetch Users profile ID */
     /*   Id profileId = userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;*/
        
        /*Query to check if case owner is a logged in user*/
       /* List<AuthSession> authSessionList = new List<AuthSession>();
        authSessionList = [Select Id, UsersId, Users.Name, UserType From AuthSession Where UsersId =: setCaseOwnerId];
        for(AuthSession authSession : authSessionList){
            setUserId.add(authSession.UsersId);
        }*/
        /*Check user is not an external customer */
        /*Prevent non investigation leader from sharing information on feed Item case object*/
        /*if(OC_checkTriggerRecursive.runAgentTimeSpentPerDayValidationOnce()){
            
            if(profileName != OC_TH_Constants.getCustomerCommunityPlusCustomUserProfile){
                for(FeedItem fdItem : listToNewFeedItem){ 
                    for(Id csOwnerId : setCaseOwnerId){
                        
                        if(fdItem.Visibility == OC_TH_Constants.getFeedItemVisibilityAllUser && fdItem.ParentId != null && !setUserId.contains(csOwnerId)){
                            fdItem.AddError(System.Label.OC_TH_CaseFeedItemAlert);
                        }
                    }  
                }
            } 
        }*/
    }
    
    public static void AfterInsert(Map<Id, SObject> newItems){}
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
    
    public void BeforeDelete(Map<Id, SObject> oldItems){}
    
    public void AfterDelete(Map<Id, SObject> oldItems){}
    
    public void AfterUndelete(Map<Id, SObject> oldItems){}
    
}