/**
* @File Name          : OC_ContentControllerSubDocuments
* @Description        : Class to fetch documents to display on Document Hub and Recent Document Activities page
* @Author             : Rohit Gaba
* @Group              : OmniChannel - Service
* @Created Date       : 12th May 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-05-12              Rohit Gaba               Initial Version
  2.0        2020-05-15              Richa Gupta              Add method to fetch Document Hub data
**/
public with sharing class OC_ContentControllerSubDocuments {
	//This will provide the Latest Documents Data to Recent Docuements Section, which will be added on OmniChannel Home Page.    
    public static OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse processOmniChannelThemeRequestRecentDocuments(OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request){
        OmniChannelThemeRequestReponseWrappers.OCResponseDocument response = new OmniChannelThemeRequestReponseWrappers.OCResponseDocument();
        OmniChannelThemeRequestReponseWrappers.OCResponseDocumentRecentData requestedData = new OmniChannelThemeRequestReponseWrappers.OCResponseDocumentRecentData();
        requestedData.documentRecentItems = new  List<OmniChannelThemeRequestReponseWrappers.OCResponseDocumentRecentDataItem>();
        response.requestType = request.requestType;
        response.requestedData = requestedData;        
        
        Set<Id> set_accessibleAccounts = new Set<Id>();
        
        if(UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType() == 'CustomerSuccess' || UserInfo.getUserType() == 'PowerCustomerSuccess'){
            set_accessibleAccounts.add([Select AccountId from User where id =: UserInfo.getUserId()].AccountId);
        }
        else if(UserInfo.getUserType() == 'Standard'){ /*Admin, Service User, Data Manager All this access to be checked in AccessController as part of Document Hub Access Management include External users*/
            //Libraries access will be brought up with new customers
            set_accessibleAccounts.addAll((new map<Id,Account>([Select Id from Account])).keyset());
        }
        else{
            throw new AuraHandledException(System.Label.OC_Generic_Exception_Message);
        }
        
        //This Query should always run Shating Context
        List<ContentDocumentLink> list_documents = [SELECT Id, ContentDocumentId, ContentDocument.Title, ContentDocument.LastModifiedDate, ContentDocument.ContentSize, ContentDocument.FileExtension, ContentDocument.LastModifiedBy.Name FROM ContentDocumentLink where linkedEntityId IN :set_accessibleAccounts and IsDeleted = false ORDER BY ContentDocument.LastModifiedDate DESC Limit 5];
        List<OmniChannelThemeRequestReponseWrappers.OCResponseDocumentRecentDataItem> tempList = new List<OmniChannelThemeRequestReponseWrappers.OCResponseDocumentRecentDataItem>();
        OmniChannelThemeRequestReponseWrappers.OCResponseDocumentRecentDataItem tempItem;
        
        for(ContentDocumentLink tempDocument :list_documents){
            tempItem = new OmniChannelThemeRequestReponseWrappers.OCResponseDocumentRecentDataItem();
            tempItem.documentId = tempDocument.ContentDocumentId;
            tempItem.documentTitle = tempDocument.ContentDocument.Title;
            tempItem.documentSize = OC_ContentControllerSubContentFormatter.BytesToSize(tempDocument.ContentDocument.ContentSize);
            tempItem.documentType = tempDocument.ContentDocument.FileExtension;
            tempItem.documentUploadedBy = tempDocument.ContentDocument.LastModifiedBy.Name;
            tempItem.documentUploadedDate = tempDocument.ContentDocument.LastModifiedDate;
            //tempItem.accessibleAccountId = new list<Id>(set_accessibleAccounts)[0];
            tempList.add(tempItem);
        }
        requestedData.documentRecentItems.addAll(tempList);
        
        return response;
    }
    
/****************************************************************
* @author: Richa Gupta
* @date: 2020-05-15
* @param: request
* @description: Returns list of files to display on Document Hub screen
*****************************************************************/    
    
    public static OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse processOmniChannelThemeRequestDocumentHub(OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request){
        OmniChannelThemeRequestReponseWrappers.OCResponseDocument response = new OmniChannelThemeRequestReponseWrappers.OCResponseDocument();
        OmniChannelThemeRequestReponseWrappers.OCResponseDocumentData requestedData = new OmniChannelThemeRequestReponseWrappers.OCResponseDocumentData();
        OmniChannelThemeRequestReponseWrappers.OCRequestDocumentHub requestBody = (OmniChannelThemeRequestReponseWrappers.OCRequestDocumentHub) JSON.deserialize(JSON.serialize(request.requestBody), OmniChannelThemeRequestReponseWrappers.OCRequestDocumentHub.class) ;
        requestedData.documentItems = new  List<OmniChannelThemeRequestReponseWrappers.OCResponseDocumentDataItem>();
        response.requestType = request.requestType;
        response.requestedData = requestedData; 
        response.currentPageNumber = Integer.valueOf(requestBody.currentPageNumber);    
        
        //Below is the set of accessible Accounts to a user
        Set<Id> set_accessibleAccounts = new Set<Id>();
        
        //Below are customer users
        if(UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType() == 'CustomerSuccess' || UserInfo.getUserType() == 'PowerCustomerSuccess'){
            set_accessibleAccounts.add([Select AccountId from User where id =: UserInfo.getUserId()].AccountId);
            response.currentAccountId = new list<Id>(set_accessibleAccounts)[0];
        }
        //Below are Salesforce users
        else if(UserInfo.getUserType() == 'Standard'){ 
            set_accessibleAccounts.addAll((new map<Id,Account>([Select Id from Account])).keyset());
        }
        else{
            throw new AuraHandledException(System.Label.OC_Generic_Exception_Message);
        }
        
        //Below query fetches the total count of documents for the pagination component to know
        response.totalDocuments = [Select count() from ContentDocumentLink where linkedEntityId IN :set_accessibleAccounts and IsDeleted = false];
        
        //Below query fetches the list of files to be displayed on the page
        List<ContentDocumentLink> list_documents = [SELECT Id, ContentDocumentId, ContentDocument.LatestPublishedVersionId,ContentDocument.Title, ContentDocument.LastModifiedDate, ContentDocument.ContentSize, ContentDocument.FileExtension, ContentDocument.LastModifiedBy.Name FROM ContentDocumentLink where linkedEntityId IN :set_accessibleAccounts and IsDeleted = false ORDER BY ContentDocument.LastModifiedDate DESC Limit 10 Offset :Integer.valueOf(requestBody.offset)];
        List<OmniChannelThemeRequestReponseWrappers.OCResponseDocumentDataItem> tempList = new List<OmniChannelThemeRequestReponseWrappers.OCResponseDocumentDataItem>();
        OmniChannelThemeRequestReponseWrappers.OCResponseDocumentDataItem tempItem;
        
        //Below loop prepares the response to be sent
        for(ContentDocumentLink tempDocument :list_documents){
            tempItem = new OmniChannelThemeRequestReponseWrappers.OCResponseDocumentDataItem();
            tempItem.documentId = tempDocument.ContentDocument.Id;
            tempItem.latestVersionId = tempDocument.ContentDocument.LatestPublishedVersionId;
            tempItem.documentTitle = tempDocument.ContentDocument.Title.contains('.') ? tempDocument.ContentDocument.Title.substringBefore('.') : tempDocument.ContentDocument.Title;
            tempItem.documentSize = OC_ContentControllerSubContentFormatter.BytesToSize(tempDocument.ContentDocument.ContentSize);
            tempItem.documentSizeOriginal = tempDocument.ContentDocument.ContentSize;
            tempItem.documentType = tempDocument.ContentDocument.FileExtension;
            tempItem.documentUploadedBy = tempDocument.ContentDocument.LastModifiedBy.Name;
            tempItem.documentUploadedDate = tempDocument.ContentDocument.LastModifiedDate;
            tempItem.baseURL = URL.getSalesforceBaseUrl().toExternalForm();  
            
            tempList.add(tempItem);
        }
        requestedData.documentItems.addAll(tempList);
        
        return response;
    }
}