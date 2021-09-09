/**
* @File Name          : OC_ContentControllerSubForum
* @Description        : Class to fetch latest forums to display on recent forum section
* @Author             : Rohit Gaba
* @Group              : OmniChannel - Service
* @Created Date       : 13th May 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-05-13              Rohit Gaba               Initial Version
* 2.0        2020-08-17                 IBM                   R20_09 U-2013 Limiting Forum Results after Fourth Quadrant on MyWorkspace to show Recent Tickets
**/
public without sharing class OC_ContentControllerSubForum {
    
    //This will provide the Latest Forums Data to Recent Forum Section, which will be added on OmniChannel Home Page. 
    public static OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse processOmniChannelThemeRequestRecentPosts(OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request){
        OmniChannelThemeRequestReponseWrappers.OCResponseForum response = new OmniChannelThemeRequestReponseWrappers.OCResponseForum();
        OmniChannelThemeRequestReponseWrappers.OCResponseForumRecentData requestedData = new OmniChannelThemeRequestReponseWrappers.OCResponseForumRecentData();
        requestedData.forumRecentItems = new  List<OmniChannelThemeRequestReponseWrappers.OCResponseForumRecentDataItem>();
        response.requestType = request.requestType;
        response.requestedData = requestedData;        
        
        Map<Id, FeedItem> feedItemsMap;
        
        if(UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType() == 'CustomerSuccess' || UserInfo.getUserType() == 'PowerCustomerSuccess'){
            feedItemsMap = new Map<Id,FeedItem>([SELECT Id, Title, SystemModstamp, CreatedBy.Name FROM FeedItem WHERE NetworkScope = :Network.getNetworkId() AND Type = 'QuestionPost' AND Visibility = 'AllUsers' ORDER BY SystemModstamp DESC Limit 5]);
        }
        else if(UserInfo.getUserType() == 'Standard'){ /*Admin, Service User, Data Manager All this access to be checked in AccessController as part of Document Hub Access Management include External users*/
            feedItemsMap = new Map<Id,FeedItem>([SELECT Id, Title, SystemModstamp, CreatedBy.Name FROM FeedItem WHERE NetworkScope = :Network.getNetworkId() AND Type = 'QuestionPost' ORDER BY SystemModstamp DESC Limit 5]);
        }
        else{
            feedItemsMap = new Map<Id,FeedItem>();
        }
        
        List<TopicAssignment> topicsAssignmentList = [SELECT TopicId, Topic.Name, Topic.ManagedTopicType, EntityId FROM TopicAssignment WHERE EntityType = 'FeedItem' AND EntityId IN :feedItemsMap.keyset()];
        Map<Id, TopicAssignment> topicsAssignmentMap = new Map<Id, TopicAssignment>();
        
        for(TopicAssignment tempTopic :topicsAssignmentList){
            if( !String.isBlank(tempTopic.Topic.ManagedTopicType) && tempTopic.Topic.ManagedTopicType.contains('Featured')){
                topicsAssignmentMap.put(tempTopic.EntityId, tempTopic);
            }
            else if(!topicsAssignmentMap.containsKey(tempTopic.EntityId) &&  !String.isBlank(tempTopic.Topic.ManagedTopicType) && tempTopic.Topic.ManagedTopicType.contains('Navigational')){
                topicsAssignmentMap.put(tempTopic.EntityId, tempTopic);
            }
            else if(!topicsAssignmentMap.containsKey(tempTopic.EntityId)){
                topicsAssignmentMap.put(tempTopic.EntityId, tempTopic);
            }
            
        }
        
        List<OmniChannelThemeRequestReponseWrappers.OCResponseForumRecentDataItem> tempList = new List<OmniChannelThemeRequestReponseWrappers.OCResponseForumRecentDataItem>();
        OmniChannelThemeRequestReponseWrappers.OCResponseForumRecentDataItem tempItem;
        
        for(Id tempKey :feedItemsMap.keyset()){
            tempItem = new OmniChannelThemeRequestReponseWrappers.OCResponseForumRecentDataItem();
            tempItem.itemTitle = feedItemsMap.get(tempKey).Title;
            tempItem.itemURL = Site.getPathPrefix() + '/question/'+ String.valueOf(feedItemsMap.get(tempKey).Id);
            if(topicsAssignmentMap.containsKey(tempKey)){
                tempItem.itemTopic = topicsAssignmentMap.get(tempKey).Topic.Name;
                tempItem.itemTopicURL = Site.getPathPrefix() + '/topic/'+ String.valueOf(topicsAssignmentMap.get(tempKey).TopicId);
            }
            tempItem.itemUpdatedDateTime = feedItemsMap.get(tempKey).SystemModStamp;
            tempItem.itemUser = feedItemsMap.get(tempKey).CreatedBy.Name;
            tempList.add(tempItem);      
            
        }
        requestedData.forumRecentItems.addAll(tempList);
        
        return response;
    }
}