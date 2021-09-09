/**
* @File Name          : OC_GST_FeedCommentTriggerHandler
* @Description        : TriggerHandler class to pick deleted Forum Comment and send to GST to remove from their system
* @Author             : Richa Gupta
* @Group              : OmniChannel - Service
* @Created Date       : 1st May 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-5-17              Richa Gupta               Initial Version
* 2.0        2020-11-25             IBM                       D-3426/ U-1706 Forum On/Off GST
* 3.0        2021-04-16             Aishwarya Aithal		  U-2692 Prevent non investigation leader to comment on post in CSR object Tickect Handling.
**/
public without sharing class OC_GST_FeedCommentTriggerHandler implements TriggerInterface{
    
    /****************************************************************
* @author: Richa Gupta
* @date: 2020-05-1
* @param: deletedFeedComments
* @description: This method takes the list of deletedFeedComments and checks whether they were deleted after sent to gst
*****************************************************************/    
    
    public static void BeforeDelete(Map<Id, SObject> oldItems){
        Map<Id,FeedComment> deletedFeedComments = (Map<Id,FeedComment>) oldItems;
        map<id,id> deleteFeedCommentWithFeedItem = new map<id,id>();
        Datetime lastSyncDateTime ;
        Map<String, GST_API_Details__c> gstAPISettings = GST_API_Details__c.getAll();
        String communityId = gstAPISettings.get('OC_GST_CommunityId').Value__c;
        String scheduleJobName = '%'+gstAPISettings.get('OC_GST_Schedule_Job_Name').value__c+'%';
        map<Id,Id> feedCommentWithFeedItemId = new map<Id,Id>();
        for(FeedComment fc : deletedFeedComments.values()){
            feedCommentWithFeedItemId.put(fc.Id,fc.FeedItemId);
        }
        //Fetch only the comments whose FeedItem is of QuestionPost Type. "FeedItem.Type" relation doesn't work hence the below query
        
        list<CronTrigger> scheduleClassInfo = new list <CronTrigger>([SELECT CronJobDetailId,EndTime,
                                                                      Id,NextFireTime,PreviousFireTime,StartTime,State,
                                                                      TimesTriggered 
                                                                      FROM 
                                                                      CronTrigger 
                                                                      WHERE 
                                                                      CronJobDetail.Name LIKE :scheduleJobName ORDER BY PreviousFireTime DESC NULLS LAST LIMIT 1]);
        //Datetime GSTFullRefresh = Datetime.valueOf(gstAPISettings.get('OC_GST_Last_GST_Sync').Value__c).addHours(-7);
        String customSetDate = String.valueOf(gstAPISettings.get('OC_GST_Last_GST_Sync').Value__c);
        String dateTemp = customSetDate.substringBefore(' ');
        String timeTemp = customSetDate.substringAfter(' ');
        list<String> dateBReak = dateTemp.split('-');
        list<String> timeBReak = timeTemp.split(':');
        Datetime GSTFullRefresh = DateTime.newInstanceGmt(Integer.valueOf(dateBReak[0]), Integer.valueOf(dateBReak[1]), Integer.valueOf(dateBReak[2]), Integer.valueOf(timeBReak[0]), Integer.valueOf(timeBReak[1]), Integer.valueOf(timeBReak[2]));    
        if(!scheduleClassInfo.isEmpty()) {
            if(scheduleClassInfo[0].PreviousFireTime != null){
                lastSyncDateTime = scheduleClassInfo[0].PreviousFireTime > GSTFullRefresh ? scheduleClassInfo[0].PreviousFireTime : GSTFullRefresh;
            } else {
                //If the class has been scheduled but not yet executed even once
                lastSyncDateTime = GSTFullRefresh;
            }
        }else {
            //If there is no previous run of the schedule class take the time from Custom Setting
            lastSyncDateTime = GSTFullRefresh;
        }
        
        //Fetch only the comments whose FeedItem is of QuestionPost Type. "FeedItem.Type" relation doesn't work hence the below query
        list<FeedItem> questionFeedItem = new list<FeedItem>([Select id,(Select id from FeedComments where id IN :feedCommentWithFeedItemId.keyset() AND CreatedDate < :lastSyncDateTime) from FeedItem where id IN :feedCommentWithFeedItemId.values() AND Type = 'QuestionPost' AND NetworkScope =:communityId]);
        
        for(FeedItem fi : questionFeedItem) {            
            for(FeedComment fc : fi.FeedComments){
                deleteFeedCommentWithFeedItem.put(fc.id,fi.id);
            }
        }
        if(!deleteFeedCommentWithFeedItem.isEmpty()){
            OC_GST_GSTForumIntegration.deleteCommentFromGST(deleteFeedCommentWithFeedItem);
        }
        /*2.0 2020-11-25 IBM D-3426/ U-1706 Forum On/Off GST*/
        if(!deletedFeedComments.isEmpty()){
            OC_GST_GSTForumIntegration.feedForumAccessibilityPermission(deletedFeedComments.values(),null);
        }
    }
    
    /**************************************************************************************
* @Description  2021-04-16 U-2692 This method prevents non-investigation leader 
from commenting on chatter feed on case object to external user.
2.0 2020-11-25 IBM D-3426/ U-1706 Forum On/Off GST.
* @Param        List -FeedComment newItems. 
**************************************************************************************/ 
    public static void BeforeInsert(List<SObject> newItems){
        List<FeedComment> listToNewFeedComment = (List<FeedComment>) newItems;
        List<Case> caseList = new List<Case>();
        List<FeedItem> feedItemList = new List<FeedItem>();
        set<Id> setFeedItemId = new set<Id>();
        set<Id> setCsOwnerId = new set<Id>();
        set<Id> setFeedParentId = new set<Id>();
        set<Id> setUserId = new set<Id>(); 
        
        /*Fetch record type of case object Tickect Handling.*/
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
        
        /*Fetch Users profile ID */
        Id profileId = userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
       
        /*Query to fetch logged in user's Id */
        Id userId = userinfo.getUserId();
        List<User> loggedInUserList = new List<User>();
        loggedInUserList = [SELECT Id FROM User Where Id =: userId];
        for(User us :loggedInUserList){
            setUserId.add(us.Id);
        }  
        /*Check user is not an external customer */
        if(profileName != OC_TH_Constants.getCustomerCommunityPlusCustomUserProfile){
            for(FeedComment fdComment : listToNewFeedComment){ 
                for(Id csOwnerId : setCsOwnerId){  
                    /*Prevent non investigation leader from commenting on post in CSR object Ticket Handling.*/
                   if(fdComment.FeedItemId != Null && fdComment.ParentId != Null && !setUserId.contains(csOwnerId)){
                        fdComment.AddError(System.Label.OC_TH_Case_FeedComment_Alert); 
                    }    
                }
            }
        }
        /*2.0 2020-11-25 IBM D-3426/ U-1706 Forum On/Off GST*/
        if(!listToNewFeedComment.isEmpty()){
            OC_GST_GSTForumIntegration.feedForumAccessibilityPermission(listToNewFeedComment,null);
        }
    }
    /**************************************************************************************
* @Description  2020-11-25 IBM D-3426/ U-1706 Forum On/Off GST
* @Param        List -FeedComment newItems and oldItems. 
**************************************************************************************/ 
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        Map<Id,FeedComment> mapToNewFeedComment = (Map<Id,FeedComment>) newItems;
        Map<Id,FeedComment> mapToOldFeedComment = (Map<Id,FeedComment>) oldItems;
        
        /*2.0 2020-11-25 IBM D-3426/ U-1706 Forum On/Off GST*/
        if(!mapToOldFeedComment.isEmpty()){
            OC_GST_GSTForumIntegration.feedForumAccessibilityPermission(mapToNewFeedComment.values(), null);
        }
    }
    
    
    public void AfterInsert(Map<Id, SObject> newItems){}
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
    
    public void AfterDelete(Map<Id, SObject> oldItems){}
    
    public void AfterUndelete(Map<Id, SObject> oldItems){}
    
}