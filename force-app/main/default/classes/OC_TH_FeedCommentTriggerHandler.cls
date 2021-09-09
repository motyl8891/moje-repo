/* Class Name : OC_TH_FeedCommentTriggerHandler
* Description : This class handles all the trigger events for FeedComment object. 
* Author      : IBM.
* @Group              : OmniChannel - Service
* @Created Date       : 13 April 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-04-15                 IBM                   Initial Version
**/
public class OC_TH_FeedCommentTriggerHandler implements OC_TriggerInterface{
    /**************************************************************************************
* @Description  This method prevents non-investigation leader from
                commenting on chatter feed on case object to external user.
* @Param        List -Case newItems. 
**************************************************************************************/  
    public void BeforeInsert(List<SObject> newItems){
      /*  List<FeedComment> listToNewFeedComment = (List<FeedComment>) newItems;
        List<Case> caseList = new List<Case>();
        List<FeedItem> feedItemList = new List<FeedItem>();
        set<Id> setFeedItemId = new set<Id>();
        set<Id> setCsOwnerId = new set<Id>();
        set<Id> setFeedParentId = new set<Id>();
        set<Id> setUserId = new set<Id>(); 
        Id standardRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getStandardCsrRecordType).getRecordTypeId();
        
        for(FeedComment feedcmt : listToNewFeedComment){
            setFeedItemId.add(feedcmt.FeedItemId);
        }
        
        feedItemList = [Select Id,ParentId,body,Visibility from feedItem where Id IN: setFeedItemId AND Visibility != 'InternalUsers'];
        for(FeedItem feedItem : feedItemList){
            setFeedParentId.add(feedItem.ParentId);
        }
        
        caseList = [SELECT Id,OwnerId from Case where RecordTypeId =: standardRecordType AND Id IN: setFeedParentId];
        for(Case cs : caseList){
            setCsOwnerId.add(cs.OwnerId);
        }
       
        Id profileId = userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        
        List<AuthSession> authSessionList = new List<AuthSession>();
        authSessionList = [Select Id, UsersId, Users.Name, UserType From AuthSession Where UsersId =: setCsOwnerId ];
        for(AuthSession authSession : authSessionList){
            setUserId.add(authSession.UsersId);
        }
        if(OC_checkTriggerRecursive.runTicketHandlingFeedCommentBeforeInsert()){ 
            if(profileName != OC_TH_Constants.getCustomerCommunityPlusCustomUserProfile){
                for(FeedComment fdComment : listToNewFeedComment){ 
                    for(Id csOwnerId : setCsOwnerId){
                        if(fdComment.FeedItemId != Null && fdComment.ParentId != Null && !setUserId.contains(csOwnerId)){
                            fdComment.AddError(System.Label.OC_TH_Case_FeedComment_Alert); 
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