/**
* @File Name          : OC_GST_GSTForumIntegration
* @Description        : Apex Class to send Forum Post data to GST
* @Author             : Richa Gupta
* @Group              : OmniChannel - Service
* @Created Date       : 1st May 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-5-1              Richa Gupta               Initial Version
**/

public without sharing class OC_GST_GSTForumIntegration{
    
    /****************************************************************
* @author: Richa Gupta
* @date: 2020-05-1
* @param: none
* @description: Default constructor
*****************************************************************/   
    
    public OC_GST_GSTForumIntegration(){
    }
    
    
    /****************************************************************
* @author: Richa Gupta
* @date: 2020-05-1
* @param: none
* @description: Method to fetch GST API information from Custom Metadata
*****************************************************************/   
    
    public Map<String, GST_API_Details__c> getRequestToken() {
        Map<String, GST_API_Details__c> GSTcredentials = GST_API_Details__c.getAll();
        return GSTcredentials;       
    }
    
    
    /****************************************************************
* @author: Richa Gupta
* @date: 2020-05-1
* @param: feedItemsToSend
* @description: Method to send Forum Items and Forum Comments to GST
*****************************************************************/       
    
    public void sendDataToGST(list<FeedItem> feedItemsToSend) {
        try{ 
            OC_GST_GSTForumIntegration obj = new OC_GST_GSTForumIntegration();
            Map<String, GST_API_Details__c> httpInformation = obj.getRequestToken();
            list<String> assignedTopics = new list<String>();
            
            //Create JSON    
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartArray();
            //Iterate over each FeedItem
            for(FeedItem feedItemInst: feedItemsToSend){
                gen.writeStartObject();
                gen.writeStringField('_id', feedItemInst.id); 
                gen.writeStringField('type','FeedItem');
                gen.writeStringField('url',httpInformation.get('POST_URL').Value__c + feedItemInst.id);
                if(feedItemInst.Title != null){
                    gen.writeStringField('title', feedItemInst.Title);
                }
                if(feedItemInst.Body != null){
                    gen.writeStringField('body', feedItemInst.Body);
                }
                gen.writeDateTimeField('createdDate', feedItemInst.createdDate);
                gen.writeNumberField('CommentCount', feedItemInst.CommentCount);
                gen.writeBooleanField('HasVerifiedComment', feedItemInst.HasVerifiedComment);
                gen.writeNumberField('LikeCount', feedItemInst.LikeCount);
                gen.writeStringField('TypePost', feedItemInst.Type);
                assignedTopics = new list<String>();//An array of Topic Assignments
                for(TopicAssignment ta : feedItemInst.TopicAssignments){
                    assignedTopics.add(ta.Topic.Name);
                }
                gen.writeObjectField('Topics', assignedTopics);
                gen.writeStringField('CreatedById', feedItemInst.CreatedById);
                if(feedItemInst.BestCommentId != null){
                    gen.writeStringField('BestCommentId', feedItemInst.BestCommentId);
                }
                gen.writeBooleanField('IsRichText', feedItemInst.IsRichText); 
                //Check if there are any new/edited Feed Comments
                if(feedItemInst.FeedComments.size() > 0){
                    for(FeedComment feedCommentInst : feedItemInst.FeedComments){
                        if(String.isNotBlank(feedCommentInst.CommentBody)){
                            gen.writeStringField('Comment-Content-'+feedCommentInst.id, feedCommentInst.CommentBody);	
                            gen.writeDateTimeField('Comment-CreatedDate-'+feedCommentInst.id, feedCommentInst.CreatedDate);
                            gen.writeDateTimeField('Comment-SentToGSTDate-'+feedCommentInst.id, System.now()); 
                        }
                    }
                }
                gen.writeEndObject(); 
            }
            gen.writeEndArray();
            String reqBody = gen.getAsString();
            //Preparing http call    
            Http httpCallToGST = new Http();
            HttpRequest httpGSTrequest = new HttpRequest();
            httpGSTrequest.setMethod('PUT');
            httpGSTrequest.setEndpoint(httpInformation.get('OC_GST_End_Point').Value__c);
            httpGSTrequest.setHeader('Token', httpInformation.get('HeaderToken').Value__c); 
            httpGSTrequest.setHeader(httpInformation.get('Referrer_Header').Value__c, httpInformation.get('Referrer_Console').Value__c);      
            httpGSTrequest.setBody(reqBody);
            HttpResponse httpGSTresponse = httpCallToGST.send(httpGSTrequest);
            
            //log the response in Logger object    
            EventLog.createLog(new EventLog.Information('OC_GST_GSTForumIntegration','sendDataToGST','GST Forum Indexing',false,httpGSTresponse.getBody()));
        }catch(exception ex){
            EventLog.createLog(new EventLog.Error('OC_GST_GSTForumIntegration','sendDataToGST','GST Forum Indexing',true,ex));
        }    
    }
    
    /****************************************************************
* @author: Richa Gupta
* @date: 2020-05-1
* @param: idsToDelete
* @description: Method to delete Feed Items from GST
*****************************************************************/ 
    
    @future (callout=true)
    public static void deletePostFromGST(list<Id> idsToDelete) {
        try{ 
            OC_GST_GSTForumIntegration obj = new OC_GST_GSTForumIntegration();
            Map<String, GST_API_Details__c> httpInformation = obj.getRequestToken();
            
            //Prepare https call    
            Http httpCallToGST = new Http();
            HttpRequest httpGSTrequest = new HttpRequest();
            httpGSTrequest.setMethod('DELETE');
            httpGSTrequest.setEndpoint(httpInformation.get('OC_GST_End_Point').Value__c+'&id='+String.join(idsToDelete, ','));
            httpGSTrequest.setHeader('Token', httpInformation.get('HeaderToken').Value__c); 
            httpGSTrequest.setHeader(httpInformation.get('Referrer_Header').Value__c, httpInformation.get('Referrer_Console').Value__c);       
            HttpResponse httpGSTresponse = httpCallToGST.send(httpGSTrequest);
            
            //log the response in Logger object 
            EventLog.createLog(new EventLog.Information('OC_GST_GSTForumIntegration','deletePostFromGST','GST Forum Indexing',false,httpGSTresponse.getBody()));
        }catch(exception ex){
            EventLog.createLog(new EventLog.Error('OC_GST_GSTForumIntegration','deletePostFromGST','GST Forum Indexing',true,ex));
        }
    }
    
    /****************************************************************
* @author: Richa Gupta
* @date: 2020-05-1
* @param: feedCommentWithFeedPost
* @description: Method to delete Feed Comments from GST
*****************************************************************/    
    
    @future (callout=true)
    public static void deleteCommentFromGST(map<id,id> feedCommentWithFeedPost) {
        try{ 
            OC_GST_GSTForumIntegration obj = new OC_GST_GSTForumIntegration();
            Map<String, GST_API_Details__c> httpInformation = obj.getRequestToken();
            
            //Prepare JSON
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartArray();
            for(Id feedCommentInst: feedCommentWithFeedPost.keyset()){
                gen.writeStartObject();
                gen.writeStringField('_id', feedCommentWithFeedPost.get(feedCommentInst));
                gen.writeStringField('Comment-Content-'+feedCommentInst,'');
                gen.writeStringField('Comment-CreatedDate-'+feedCommentInst,'');
                gen.writeStringField('Comment-SentToGSTDate-'+feedCommentInst,''); 
                gen.writeEndObject(); 
            }
            gen.writeEndArray();
            String reqBody = gen.getAsString();
            
            //Prepare http callout
            Http httpCallToGST = new Http();
            HttpRequest httpGSTrequest = new HttpRequest();
            httpGSTrequest.setMethod('PUT');
            httpGSTrequest.setEndpoint(httpInformation.get('OC_GST_End_Point').Value__c);
            httpGSTrequest.setHeader('Token', httpInformation.get('HeaderToken').Value__c); 
            httpGSTrequest.setHeader(httpInformation.get('Referrer_Header').Value__c, httpInformation.get('Referrer_Console').Value__c);       
            httpGSTrequest.setBody(reqBody);
            HttpResponse httpGSTresponse = httpCallToGST.send(httpGSTrequest);
            
            //log the response in Logger object    
            EventLog.createLog(new EventLog.Information('OC_GST_GSTForumIntegration','deleteCommentFromGST','GST Forum Indexing',false,httpGSTresponse.getBody()));
        }catch(exception ex){
            EventLog.createLog(new EventLog.Error('OC_GST_GSTForumIntegration','deleteCommentFromGST','GST Forum Indexing',true,ex));
        }
    }
    
    /****************************************************************
* @author: IBM
* @date: 2021-04-19
* @param: none
* @description: 2020-11-25 IBM D-3426/ U-1706 Forum On/Off GST
2021-04-26 IBM D-3878/ U-2692 Forum off Customer should be able to post on chatter in Ticket Handling.
*****************************************************************/   
    
    public static void feedForumAccessibilityPermission(List<FeedComment> comments, List<FeedItem> posts) {
        
        /* Forum off to External User should be able to post/Comment on Ticket Handling chatter  */
        if(!FeatureManagement.checkPermission('OC_UAM_Forum_Accessibility') && UserInfo.getUserType() != 'Standard'){ 
            if(comments != null){
                for(FeedComment feedComment : comments) {
                    if(feedComment.ParentId.getSObjectType() != Case.SObjectType){ 
                        feedComment.addError(System.Label.OC_Error_Forum_Accessibility);
                    }
                }
            }
            else{
                for(FeedItem feeditems : posts) {
                    if(feeditems.ParentId.getSObjectType() !=  Case.SObjectType){      
                        feeditems.addError(System.Label.OC_Error_Forum_Accessibility);
                    } 
                }
            }
        }
    }
    
}