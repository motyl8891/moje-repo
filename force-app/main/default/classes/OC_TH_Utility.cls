/**
* @File Name          : OC_TH_Utility
* @Description        : Collection of Utility Methods
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 20th July 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-07-20                 IBM                   Initial Version
* 2.0        2020-08-26                 Richa Gupta           Added checkCaseAccessibility method 
* 3.0        2021-05-07                 Aishwarya Aithal	  Added getUTCDateTime method
**/
public with sharing class OC_TH_Utility {
    
    /**************************************************************************************
* @Description  This method gets all the attachments associated to a Sobject record. 
* @Param        Id of Sobject record
* @Return       List of Attachment records
**************************************************************************************/ 
    Public Static List<ContentDocumentLink> getSobjectRecordAttachments(Id sObjRecordId) {
        system.debug('sObjRecordId>>>' +sObjRecordId);
        List<ContentDocumentLink> attachmentsList = [SELECT Id, ContentDocumentId,ContentDocument.Title, ContentDocument.LastModifiedDate, ContentDocument.ContentSize  
                                                     FROM ContentDocumentLink 
                                                     WHERE linkedEntityId=:sObjRecordId
                                                     AND IsDeleted = false 
                                                     ORDER BY ContentDocument.LastModifiedDate];
        system.debug('attachmentsList in utility>>>' +attachmentsList);
        return attachmentsList;    	
    }
    
    /**************************************************************************************
* @Description  This method checks whether a Case is accessible to a Contact or not. 
* @Param        Contact Id, Case Id
* @Return       boolean 
**************************************************************************************/ 
    Public Static Boolean checkCaseAccessibility(Id inputContactId, Id inputCaseId) {
        
        Set<Id> accountIdSet = new Set<Id>();
        for(AccountContactRelation acr : [SELECT AccountId FROM AccountContactRelation WHERE ContactId =: inputContactId]){
            accountIdSet.add(acr.AccountId);
        } 
        Id caseAccountId = [Select AccountId from Case where id = :inputCaseId][0].AccountId;
        if(accountIdSet.contains(caseAccountId)){
            return true;
        }else{
            return false;
        }
    }
    /***********************************************************************************
GetManagedTopic
****************************************************************************************/    
    
    public static List<ConnectApi.ManagedTopic> getManagedTopics() {
        ConnectAPI.ManagedTopicCollection mTopics = ConnectAPI.ManagedTopics.getManagedTopics(
            Network.getNetworkId(),
            ConnectApi.ManagedTopicType.Navigational,2
        );
        
        // system.debug('community topics--'+mTopics.managedTopics);
        
        return mTopics.managedTopics;
    }
    /**************************************************************************************
* @Description  This method converts time to UTC timezone. 
* @Param        dateTime dt
* @Return       boolean 
**************************************************************************************/ 
    public static String getUTCDateTime(DateTime dt){
        Datetime UTCDate = Datetime.newInstance(
            dt.year(),
            dt.month(),
            dt.day(),
            dt.hour(),
            dt.minute(),
            dt.second()); 
        return UTCDate.formatGmt('YYYY-MM-dd hh:mm:ss a');    
    }      
}