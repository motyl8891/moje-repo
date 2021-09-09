/**
* @File Name          : OC_GST_FeedItemTriggerHandler
* @Description        : TriggerHandler class to pick deleted Forum Post and send to GST to remove from their system
* @Author             : Richa Gupta
* @Group              : OmniChannel - Service
* @Created Date       : 1st May 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-5-17              Richa Gupta               Initial Version
* 2.0        2020-11-25             IBM                       D-3426/ U-1706 Forum On/Off GST
* 3.0        2021-04-16             Aishwarya Aithal		  U-2692 Prevent non investigation leader 
from sharing information on feed Item case object Tickect handling.                                                      
**/
public without sharing class OC_GST_FeedItemTriggerHandler implements TriggerInterface{
    
    /****************************************************************
* @author: Richa Gupta
* @date: 2020-05-1
* @param: oldItems
* @description: This method takes the list of deletedFeedItems and checks whether they were deleted after sent to gst
*****************************************************************/  
    
    public static void BeforeDelete(Map<Id, SObject> oldItems){ 
        List<FeedItem> deletedFeedItems = new List<FeedItem>();
        deletedFeedItems = oldItems.values();
        list<id> deleteFeedItems = new list<Id>();//list of FeedItems to be deleted from GST
        list<FeedItem> questionFeedItems = new list<FeedItem>();
        Datetime lastSyncDateTime ;
        Map<String, GST_API_Details__c> gstAPISettings = GST_API_Details__c.getAll();
        String communityId = gstAPISettings.get('OC_GST_CommunityId').Value__c;
        String scheduleJobName = '%'+gstAPISettings.get('OC_GST_Schedule_Job_Name').value__c+'%';
        //Below for loop collects all the Question Posts
        for(FeedItem fi : deletedFeedItems) {
            if(fi.Type == 'QuestionPost' && fi.NetworkScope == communityId){
                questionFeedItems.add(fi);
            }       
        }
        
        //Only if a Question Post is deleted
        if(!questionFeedItems.isEmpty()){
            
            //Fetch the details of the last schedule run which sends the data to GST 
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
            
            for(FeedItem fi : questionFeedItems) {
                //If the FeedItem was created after the last GST sync, then no need to send for deletion as it is not yet in GST
                if(fi.CreatedDate < lastSyncDateTime){
                    deleteFeedItems.add(fi.id);
                }
            }
            if(!deleteFeedItems.isEmpty()){
                OC_GST_GSTForumIntegration.deletePostFromGST(deleteFeedItems);
            }
        }
        /*2.0 2020-11-25 IBM D-3426/ U-1706 Forum On/Off GST*/
        if(!deletedFeedItems.isEmpty()){
            OC_GST_GSTForumIntegration.feedForumAccessibilityPermission(null,deletedFeedItems);
        }
        
    }
    
    /**************************************************************************************
* @Description  2021-04-16 U-2692 This method prevents non-investigation leader from
sharing information to external User.
2.0 2020-11-25 IBM D-3426/ U-1706 Forum On/Off
* @Param        List -FeedItem newItems. 
**************************************************************************************/  
    public static void BeforeInsert(List<SObject> newItems){     
        List<FeedItem> listToNewFeedItem = (List<FeedItem>) newItems;
        Set<Id> setfeedParentId = new Set<Id>();
        List<Case> caseList = new List<Case>();
        List<User> userList = new List<User>();
        Set<Id> setCaseOwnerId = new Set<Id>();
        Set<Id> setUserId = new Set<Id>();
        
        /*Fetch record type of task object.*/
        Id standardRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getStandardCsrRecordType).getRecordTypeId();
        
        for(FeedItem feeditem : listToNewFeedItem){
            setfeedParentId.add(feeditem.ParentId);
        }
        
        caseList = [SELECT Id,OwnerId from Case where RecordTypeId =: standardRecordType AND Id IN: setfeedParentId];
        for(Case cs : caseList){
            setCaseOwnerId.add(cs.OwnerId);
        }
        
        /*Fetch Users profile ID */
        Id profileId = userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        
        /*Query to fetch logged in user's Id*/
        Id userId = userinfo.getUserId();
        List<User> loggedInUserList = new List<User>();
        loggedInUserList = [SELECT Id FROM User Where Id =: userId];
        for(User us :loggedInUserList){
            setUserId.add(us.Id);
        }
        /*Check user is not an external customer */
        if(profileName != OC_TH_Constants.getCustomerCommunityPlusCustomUserProfile){
            for(FeedItem fdItem : listToNewFeedItem){ 
                for(Id csOwnerId : setCaseOwnerId){
                    /*Prevent non investigation leader from sharing information on feed Item case object*/
                    if(fdItem.Visibility == OC_TH_Constants.getFeedItemVisibilityAllUser && fdItem.ParentId != null && !setUserId.contains(csOwnerId)){
                        fdItem.AddError(System.Label.OC_TH_CaseFeedItemAlert);
                    }
                }  
            }
        } 
        /*2.0 2020-11-25 IBM D-3426/ U-1706 Forum On/Off*/
        if(!listToNewFeedItem.isEmpty()){
            OC_GST_GSTForumIntegration.feedForumAccessibilityPermission(null,listToNewFeedItem);
        }
        
    }
    /**************************************************************************************
* @Description  2020-11-25 IBM D-3426/ U-1706 Forum On/Off GST
* @Param        List -FeedItem newItems and oldItems. 
**************************************************************************************/    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        Map<Id,FeedItem> mapToNewFeedItem = (Map<Id,FeedItem>) newItems;
        Map<Id,FeedItem> mapToOldFeedItem = (Map<Id,FeedItem>) oldItems;
        
        /*2.0 2020-11-25 IBM D-3426/ U-1706 Forum On/Off GST*/
        if(!mapToNewFeedItem.isEmpty()){
            OC_GST_GSTForumIntegration.feedForumAccessibilityPermission(null,mapToNewFeedItem.values());
        }
    }
    
    public static void AfterInsert(Map<Id, SObject> newItems){}
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
    
    public void AfterDelete(Map<Id, SObject> oldItems){}
    
    public void AfterUndelete(Map<Id, SObject> oldItems){}
}