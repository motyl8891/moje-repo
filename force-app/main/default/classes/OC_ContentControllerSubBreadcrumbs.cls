/**
* @File Name          : OC_ContentControllerSubBreadcrumbs
* @Description        : Provide data for Breadcrumb Navigation on OmniChannel Pages like Forum-TopicDetail, Forum-PostDetail
* @Author             : Rohit Gaba
* @Group              : OmniChannel - Service
* @Created Date       : 11th May 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-05-11              Rohit Gaba               Initial Version
* 2.0        2020-07-20                IBM                    Breadcrumbs for Tickets Pages
* 3.0        2020-12-17              IBM                      R21_01 U-2350 Appending PrefixedCasNumber (OC_TH_Case_Number__c) in Breadcrumb for Case record
*4.0         2021-04-16               IBM                     U-1977 - To Display full path of navigation in customerPortal for topics and feed.
**/
public class OC_ContentControllerSubBreadcrumbs {
    
    //Prepare linked list data set for Breadcrumb component. Pages Involved - Forum-TopicDetail, Forum-PostDetail
    public static OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse processOmniChannelThemeRequestRetrieveBreadcrumbs(OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request){
        OmniChannelThemeRequestReponseWrappers.OCResponseBreadcrumbs response = new OmniChannelThemeRequestReponseWrappers.OCResponseBreadcrumbs();
        OmniChannelThemeRequestReponseWrappers.OCResponseBreadcrumbsData requestedData = new OmniChannelThemeRequestReponseWrappers.OCResponseBreadcrumbsData();
        requestedData.breadcrumbs = new OmniChannelThemeRequestReponseWrappers.OCResponseBreadCrumbsDataItem();
        response.requestType = request.requestType;
        response.requestSubType = request.requestSubType;
        response.requestedData = requestedData;
        
        OmniChannelThemeRequestReponseWrappers.OCRequestBreadcrumbs requestBody = (OmniChannelThemeRequestReponseWrappers.OCRequestBreadcrumbs) JSON.deserialize(JSON.serialize(request.requestBody), OmniChannelThemeRequestReponseWrappers.OCRequestBreadcrumbs.class);
        if(requestBody != NULL){
            if(String.isNotBlank(requestBody.entityId)){
                
                //Forum-TopicDetail
                if(Id.valueOf(requestBody.entityId).getSobjectType() == Topic.SObjectType){
                    Topic tempTopic = [SELECT Id, Name FROM Topic WHERE Id = :requestBody.entityId AND NetworkId = :Network.getNetworkId() LIMIT 1];
                    
                    if(tempTopic != NULL){
                        /*U-1977 Itterating the list of parentTopics to display the path*/
                        OmniChannelThemeRequestReponseWrappers.OCResponseBreadCrumbsDataItem latestBreadcrumbChild = requestedData.breadcrumbs;                     
                        latestBreadcrumbChild.itemTitle = 'Forum';
                        latestBreadcrumbChild.itemURL = Site.getPathPrefix()+'/topiccatalog';
                        latestBreadcrumbChild.itemChild = new OmniChannelThemeRequestReponseWrappers.OCResponseBreadCrumbsDataItem();
                        latestBreadcrumbChild = latestBreadcrumbChild.itemChild;
                        
                        //OC_Utility.debugMethod();
                        
                        if(!Test.isRunningTest()){
                            List<OC_Utility.TopicTreeWrapper> TopicList = OC_Utility.getNavigationTopics(tempTopic.Id);
                            
                            for(OC_Utility.TopicTreeWrapper topiclst :TopicList){
                                latestBreadcrumbChild.itemTitle = topiclst.topicName;
                                latestBreadcrumbChild.itemURL = Site.getPathPrefix()+'/topic/'+topiclst.topicId;
                                latestBreadcrumbChild.itemChild = new OmniChannelThemeRequestReponseWrappers.OCResponseBreadCrumbsDataItem();
                                latestBreadcrumbChild = latestBreadcrumbChild.itemChild;
                            }
                        }
                        else{
                            latestBreadcrumbChild.itemTitle = tempTopic.Name;
                            latestBreadcrumbChild.itemURL = Site.getPathPrefix()+'/topic/'+tempTopic.Id;
                            latestBreadcrumbChild.itemChild = new OmniChannelThemeRequestReponseWrappers.OCResponseBreadCrumbsDataItem();
                            latestBreadcrumbChild = latestBreadcrumbChild.itemChild;
                        } 
                        
                        /*U-1977 changes ends here*/
                    }
                }
                //Forum-PostDetail
                else if(Id.valueOf(requestBody.entityId).getSobjectType() == FeedItem.SObjectType){
                    Boolean hasFeaturedTopicAssigned = false;
                    Boolean hasNavigationalTopicAssigned = false;
                    OmniChannelThemeRequestReponseWrappers.OCResponseBreadCrumbsDataItem latestBreadcrumbChild = requestedData.breadcrumbs;
                    FeedItem feedQuestion = [SELECT Id, Title FROM FeedItem WHERE Id = :requestBody.entityId AND Type = 'QuestionPost' AND NetworkScope = :Network.getNetworkId() LIMIT 1];
                    List<TopicAssignment> topicsAssignmentList;
                    
                    if(feedQuestion != NULL){
                        //Parent - TopicCatalog Page
                        latestBreadcrumbChild.itemTitle = 'Forum';
                        latestBreadcrumbChild.itemURL = Site.getPathPrefix()+'/topiccatalog';
                        latestBreadcrumbChild.itemChild = new OmniChannelThemeRequestReponseWrappers.OCResponseBreadCrumbsDataItem();
                        latestBreadcrumbChild = latestBreadcrumbChild.itemChild;
                        
                        /*U-1977 Itterating the list of parentTopics to display the path*/
                        topicsAssignmentList = [SELECT TopicId, Topic.Name, Topic.ManagedTopicType FROM TopicAssignment WHERE NetworkId = :Network.getNetworkId() AND EntityId = :requestBody.entityId AND EntityType = :String.valueOf(FeedItem.SObjectType) order by CreatedDate limit 1];
                        
                        if(!Test.isRunningTest()){
                            List<OC_Utility.TopicTreeWrapper> TopicList = OC_Utility.getNavigationTopics(topicsAssignmentList[0].TopicId);
                            
                            for(OC_Utility.TopicTreeWrapper topiclst :TopicList){
                                latestBreadcrumbChild.itemTitle = topiclst.topicName;
                                latestBreadcrumbChild.itemURL = Site.getPathPrefix()+'/topic/'+topiclst.topicId;
                                latestBreadcrumbChild.itemChild = new OmniChannelThemeRequestReponseWrappers.OCResponseBreadCrumbsDataItem();
                                latestBreadcrumbChild = latestBreadcrumbChild.itemChild;
                            }
                        }
                        /*U-1977 changes ends here*/
                        //Self
                        latestBreadcrumbChild.itemTitle = feedQuestion.Title;
                        latestBreadcrumbChild.itemURL = Site.getPathPrefix()+'/question/'+feedQuestion.Id;
                        latestBreadcrumbChild.itemChild = new OmniChannelThemeRequestReponseWrappers.OCResponseBreadCrumbsDataItem();
                        latestBreadcrumbChild = latestBreadcrumbChild.itemChild;
                        
                    }
                }
                /* Breadcrumbs for ticket handling - Begin */
                else if (Id.valueOf(requestBody.entityId).getSobjectType() == Case.SObjectType){
                    OmniChannelThemeRequestReponseWrappers.OCResponseBreadCrumbsDataItem latestBreadcrumbChild = requestedData.breadcrumbs;
                    Case caseRec = [SELECT Id, OC_TH_Case_Number__c, Subject FROM Case WHERE Id=:requestBody.entityId];
                    
                    //Parent
                    requestedData.breadcrumbs.itemTitle = OC_TH_Constants.TicketHandling;
                    requestedData.breadcrumbs.itemURL = Site.getPathPrefix()+ '/'+OC_TH_Constants.ticket_handling;
                    requestedData.breadcrumbs.itemChild = new OmniChannelThemeRequestReponseWrappers.OCResponseBreadCrumbsDataItem();
                    
                    //child
                    //3.0 2020-12-17 IBM R21_01 U-2350 Appending PrefixedCasNumber (OC_TH_Case_Number__c) in Breadcrumb for Case record
                    requestedData.breadcrumbs.itemChild.itemTitle = caseRec.OC_TH_Case_Number__c + ' // ' + caseRec.subject;
                    requestedData.breadcrumbs.itemChild.itemURL = Site.getPathPrefix()+'/'+OC_TH_Constants.caseLiteral+'/'+caseRec.Id;
                    requestedData.breadcrumbs.itemChild.itemChild = NULL;
                }
                /* Breadcrumbs for ticket handling - End */
            }
        }
        return response;
    }
    
    
}