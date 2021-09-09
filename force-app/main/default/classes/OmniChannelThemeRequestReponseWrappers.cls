/**
* @File Name          : OmniChannelThemeRequestReponseWrappers
* @Description        : This class will provide all the Request & Repsonse formats used in OmniChannel and Service funtionality.
* @Author             : Rohit Gaba
* @Group              : OmniChannel - Service
* @Created Date       : 08th April - 18th May 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-04-08              Rohit Gaba               Initial Version
* 2.0        2020-08-17                 IBM                   R20_09 U-2013 Limiting Forum Results after Fourth Quadrant on MyWorkspace to show Recent Tickets
* 3.0        2020-08-20                 IBM                   R20_09 U-2008,2009,2010 Add request Params for Task Update
* 4.0        2020-12-10                 IBM                   R21_01 U-2113 Add comments while rejecting a remedy/answer
* 5.0        2021-05-10              Sandeep Singh            U-2728 Added additional parameter for date filter in OCRequestGSTSearch.
* 6.0        2021-07-05              Sandeep Singh            U-2729 Added additional parameter for Format filter in OCRequestGSTSearch.
* 7.0        2021-08-18              Sandeep Singh            U-2730 Added additional parameter for customer portal GST Search Hits Design filter in OCRequestGSTSearch.
**/
public class OmniChannelThemeRequestReponseWrappers {
    
    //Requests//
    public class OmniChannelThemeRequest{
        @AuraEnabled public String requestType {public get;public set;}
        @AuraEnabled public String requestSubType {public get; public set;}
        @AuraEnabled public Object requestBody {public get; public set;}
        
        
    }
    
    public virtual class OmniChannelThemeRequestBody{
        public OmniChannelThemeRequestBody(){}
    }
    
    public class OCRequestGSTSearch extends OmniChannelThemeRequestBody{
        
        @AuraEnabled public String searchText {public get; public set;}
        @AuraEnabled public Integer maxHits {public get; public set;}
        @AuraEnabled public Integer offset {public get; public set;}
        @AuraEnabled public Boolean paggination {public get; public set;}
        //U-2728 Sandeep param added for date filter
        @AuraEnabled public String dateFilter {public get; public set;}
        //U-2729 Sandeep param added for format filter
        @AuraEnabled public String formattype {public get; public set;}
        @AuraEnabled public String selectedSource {public get; public set;}
        @AuraEnabled public String selectedCategory {public get; public set;}
        @AuraEnabled public String selectedStatus {public get; public set;}
        @AuraEnabled public String selectedOpUnit {public get; public set;}
        @AuraEnabled public String selectedProdtVer {public get; public set;}
        @AuraEnabled public List<String> prodtVerFilterArray {public get; public set;}
        @AuraEnabled public String selectedWC1 {public get; public set;}
        @AuraEnabled public String selectedWC2 {public get; public set;} 
    }
    
    //Pagination for Document Hub
    public class OCRequestDocumentHub extends OmniChannelThemeRequestBody{
        
        @AuraEnabled public Integer offset {public get;public set;}
        @AuraEnabled public Boolean paggination {public get;public set;}
        @AuraEnabled public Integer currentPageNumber {public get;public set;}
    }
    
    public class OCRequestGSTSearchItemClick extends OmniChannelThemeRequestBody{
        @AuraEnabled public String searchItemUrl {public get; public set;}
        //LPAS-65 Subashini Arulalan -params added for click
        @AuraEnabled public String GSTclickURL {public get; public set;}
    }
    
    public class OCRequestBreadcrumbs extends OmniChannelThemeRequestBody{
        @AuraEnabled public String entityId {public get; public set;}
    }
    public class OCRequestTicketDetail extends OmniChannelThemeRequestBody{
        @AuraEnabled public String entityId {public get; public set;}
    }
    public class OCRequestTicketHandling extends OmniChannelThemeRequestBody {
        @AuraEnabled public String contextSearchText {public get; public set;}
        @AuraEnabled public Map<String,String> contextSearchMap;
        @AuraEnabled public Integer offset {public get; public set;}
        @AuraEnabled public Integer currentPageNumber {public get; public set;}
    }
    /*public class OCRequestAddTicketComment extends OmniChannelThemeRequestBody{
        @AuraEnabled public String entityId {public get; public set;}
        @AuraEnabled public String entityData {public get;public set;}
    }*/
    //Params added for Task update
    public class OCRequestUpdateTaskStatus extends OmniChannelThemeRequestBody{
        @AuraEnabled public String entityId {public get; public set;}
        @AuraEnabled public String entityData {public get; public set;}
        @AuraEnabled public String entityComment {public get; public set;}
    }
    
    public class OCRequestAddRFIComment extends OmniChannelThemeRequestBody{
        @AuraEnabled public String taskId {public get; public set;}
        @AuraEnabled public String newComment {public get; public set;}
    }
    //Till here
    //Responses//
    public virtual class OmniChannelThemeResponse{
        @AuraEnabled public string requestType;
        @AuraEnabled public String requestSubType;
        @AuraEnabled public Object requestedData;
        @AuraEnabled public OmniChannelThemeRequest originalRequest;
    }
    
    public virtual class OmniChannelThemeRequestedData{
        public OmniChannelThemeRequestedData(){}
    }
    public virtual class OmniChannelThemeRequestedDataItem{
        public OmniChannelThemeRequestedDataItem(){}
    }
    
    public class OCResponseGSTSearch extends OmniChannelThemeResponse{
        @AuraEnabled public OCResponseGSTSourceItemsCount searchItemsCount;
        @AuraEnabled public Integer currentPageNumber;
    }
    public class OCResponseGSTSourceItemsCount{
        @AuraEnabled public Integer elex;
        @AuraEnabled public Integer forum;
    }
    public class OCResponseForum extends OmniChannelThemeResponse{}
    public class OCResponseUserProfile extends OmniChannelThemeResponse{}
    public class OCResponseDocument extends OmniChannelThemeResponse{
        @AuraEnabled public Integer totalDocuments;
        @AuraEnabled public Integer currentPageNumber;
        @AuraEnabled public Id currentAccountId;
    }
    public class OCResponseLandingModules extends OmniChannelThemeResponse{}
    public class OCResponseNavigation extends OmniChannelThemeResponse{}
    public class OCResponseBreadcrumbs extends OmniChannelThemeResponse{}

    public class OCResponseTicketHandling extends OmniChannelThemeResponse{
        @AuraEnabled public Integer totaltickets;
        @AuraEnabled public Integer currentPageNumber;
        @AuraEnabled public Id currentAccountId;
        //test code
        @AuraEnabled public List<String> typePicklistValues;
        @AuraEnabled public List<String> priorityPicklistValues;
        @AuraEnabled public List<String> statusPicklistValues;
        
    }
    
    public class OCResponseTicketDetail extends OmniChannelThemeResponse{}
    
    public class OCResponseCustomerLists extends OmniChannelThemeRequestedData{
        @AuraEnabled public Id customerId;
        @AuraEnabled public String customerName;
    }
    
    public class OCResponseUserProfileData extends OmniChannelThemeRequestedData{
        @AuraEnabled public Map<String, Object> user;
        @AuraEnabled public Map<String, Object> link;
        @AuraEnabled public List<Map<String, Object>> accounts;
        @AuraEnabled public String copyright;
    }
    
    public class OCResponseForumRecentData extends OmniChannelThemeRequestedData{
        @AuraEnabled public List<OCResponseForumRecentDataItem> forumRecentItems;
    }

    public class OCResponseDocumentData extends OmniChannelThemeRequestedData{
        @AuraEnabled public List<OCResponseDocumentDataItem> documentItems;
    }
    
    public class OCResponseDocumentRecentData extends OmniChannelThemeRequestedData{
        @AuraEnabled public List<OCResponseDocumentRecentDataItem> documentRecentItems;
    }
    
    public class OCResponseLandingModulesData extends OmniChannelThemeRequestedData{
        @AuraEnabled public List<OCResponseLandingModulesDataItem> moduleItems;
    }
    
    public class OCResponseNavigationData extends OmniChannelThemeRequestedData{
        @AuraEnabled public List<OCResponseNavigationDataItem> navigationItems;
    }
    
    public class OCResponseBreadcrumbsData extends OmniChannelThemeRequestedData{
        @AuraEnabled public OCResponseBreadCrumbsDataItem breadcrumbs;
    }
    

    public class OCResponseTickethandlingRecentData extends OmniChannelThemeRequestedData{
        @AuraEnabled public List<OCResponseTicketHandlingDataItem> tickethandlingRecentItems;
    }
    //added for TH
    public class OCResponseTickethandlingData extends OmniChannelThemeRequestedData{
        @AuraEnabled public List<OCResponseTicketHandlingDataItem> tickethandlingItems;
    }
    
    public class OCResponseTicketData extends OmniChannelThemeRequestedData{
        @AuraEnabled public String itemId;
        @AuraEnabled public String itemPriority;
        @AuraEnabled public String itemAccountId;
        @AuraEnabled public String itemAccountName;
        @AuraEnabled public String itemAssetId;
        @AuraEnabled public String itemAssetName;
        @AuraEnabled public String itemTitle;
        @AuraEnabled public String itemDescription;
        @AuraEnabled public String itemExtReference;
        @AuraEnabled public String itemStatus;
        @AuraEnabled public String itemType;
        @AuraEnabled public String itemContactName;
        @AuraEnabled public List<OCResponseContentDocumentDataItem> itemAttachments;
        //Params added for Task update
        @AuraEnabled public list<Task> answerTaskList;
        @AuraEnabled public list<Task> remedyTaskList;
        @AuraEnabled public list<Task> requestForInfoTaskList;
        // till here
        // LPAS-874
        @AuraEnabled public Boolean showAttachments;
    }
    
    public virtual class OCResponseDocumentDataItem extends OmniChannelThemeRequestedDataItem{
        @AuraEnabled public Id documentId;
        @AuraEnabled public Id latestVersionId;
        @AuraEnabled public String documentTitle;
        @AuraEnabled public String documentSize;
        @AuraEnabled public Long documentSizeOriginal;
        @AuraEnabled public String documentType;
        @AuraEnabled public String documentUploadedBy;
        @AuraEnabled public DateTime documentUploadedDate;
        @AuraEnabled public String baseURL;
    }
    
    public class OCResponseDocumentRecentDataItem extends OCResponseDocumentDataItem{}
    
    public class OCResponseForumRecentDataItem extends OmniChannelThemeRequestedDataItem{
        @AuraEnabled public String itemTitle;
        @AuraEnabled public String itemURL;
        @AuraEnabled public String itemTopic;
        @AuraEnabled public String itemTopicURL;
        @AuraEnabled public DateTime itemUpdatedDateTime;
        @AuraEnabled public String itemUser;
    }

    public class OCResponseLandingModulesDataItem extends OmniChannelThemeRequestedDataItem{
        @AuraEnabled public String itemTitle;
        @AuraEnabled public String itemURL;
        @AuraEnabled public String itemURLTarget;
        @AuraEnabled public String itemDesc;
        @AuraEnabled public Integer itemOrder;
    }
    
    public class OCResponseNavigationDataItem extends OmniChannelThemeRequestedDataItem{
        @AuraEnabled public String itemId;
        @AuraEnabled public String itemLabel;
        @AuraEnabled public String itemDeveloperName;
        @AuraEnabled public String itemURL;
        @AuraEnabled public List<OCResponseNavigationLinksDataItem> itemLinks;
    }
    
    public class OCResponseNavigationLinksDataItem extends OmniChannelThemeRequestedDataItem{
        @AuraEnabled public String itemId;
        @AuraEnabled public String itemLabel;
        @AuraEnabled public String itemDeveloperName;
        @AuraEnabled public String itemParent;
        @AuraEnabled public Integer itemOrder;
        @AuraEnabled public String itemURL;
        @AuraEnabled public Boolean itemHasRecordId;
        @AuraEnabled public String itemBreadCrumbLabel;
    }
    
    public class OCResponseBreadCrumbsDataItem extends OmniChannelThemeRequestedDataItem{
        @AuraEnabled public String itemTitle;
        @AuraEnabled public String itemURL;
        @AuraEnabled public OCResponseBreadCrumbsDataItem itemChild;
    }
    
    public class OCResponseTicketHandlingDataItem extends OmniChannelThemeRequestedDataItem{
        @AuraEnabled public String id;
        @AuraEnabled public String casenumber;
        @AuraEnabled public String caseURL;
        @AuraEnabled public String type;
        @AuraEnabled public String priority;
        @AuraEnabled public String asset;
        @AuraEnabled public String subject;
        @AuraEnabled public String status;
        @AuraEnabled public String extReference;
        @AuraEnabled public Date expectedDate;
        @AuraEnabled public String waitingOn;
    }
    public virtual class OCResponseContentDocumentDataItem extends OmniChannelThemeRequestedDataItem{
        @AuraEnabled public String documentId;
        @AuraEnabled public String documentTitle;
        @AuraEnabled public String documentSize;
        @AuraEnabled public Long documentSizeOriginal;
        
    }
    public class OCTicketLists extends OmniChannelThemeRequestBody{
        
        public String searchText;
        public Map<String,String> searchValueByFieldMap;
        public String orderBy;
        public Integer offset;
        public Set<Id> accessibleAccounts;
        public Id recordType;
        public Id userId;
        public Id contactId;
        public Boolean isDeleted;
        public Boolean isLiCsr;
        public Integer count;
		public List<Case> caseList;
        
    }
    public class OCTicketPicklistRequest extends OmniChannelThemeRequestBody{
        
        public String yourObjectName;
        public String yourFieldName;
               
    }
    public class OCTicketPicklistResponseBody extends OmniChannelThemeResponse{
        
        public List<String> picklistValues ;
    }
    public class OCTicketPicklistResponse extends OmniChannelThemeResponse{}
}