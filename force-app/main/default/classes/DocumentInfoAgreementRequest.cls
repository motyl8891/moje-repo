/****************************************************************
* @author: Richa Gupta
* @date: 19-03-2020
* @User Story: 1651
* @description: This Aura Enabled class will check ducument Type of Attched file before sending to sales CLM.
*****************************************************************/
public without sharing class DocumentInfoAgreementRequest {
    @AuraEnabled
    Public static List<ContentVersion> getFileInformation(String agrId){ 
        List<ContentVersion> conVersion= new List<ContentVersion> (); 
        try{
            List<contentDocumentLink> contentDocLinks=[Select ContentDocumentId,LinkedEntityId ,id from ContentDocumentLink where LinkedEntityId=:agrId Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            if(contentDocLinks.size()>0) {
                Set<Id> contentDocIds = new Set<Id>(); 
                for(ContentDocumentLink contentDocLink : contentDocLinks) {
                    contentDocIds.add(contentDocLink.ContentDocumentId);
                }
             //   List<Id> contentDocIdList = new List<Id>(contentDocIds);
                conVersion=[select Id,ContentDocumentId, DocumentType__c, ContentDocument.Description, ContentDocument.Title, 
                            ContentDocument.FileType, ContentDocument.FileExtension from ContentVersion where ContentDocumentId in:contentDocIds 
                            Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
                
            }}
        catch(Exception e) {EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.DocumentInfoAgreementRequest, GlobalConstants.getFileInformation, GlobalConstants.DocumentInfoAgreementRequest, true, e)));
                           }
        return conVersion;
    }
    /****************************************************************
* @author: Richa Gupta
* @date: 19-03-2020
* @User Story: 1651
* @description: This Aura Enabled method will get dynamic picklist value
*****************************************************************/
    @AuraEnabled
    public static List < String > getselectOptions(sObject objObject, string fld) { 
        List < String > allOpts = new list < String > ();
        try{
            Schema.sObjectType objType = objObject.getSObjectType();
            Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
            map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
            list < Schema.PicklistEntry > values =
                fieldMap.get(fld).getDescribe().getPickListValues();
            for (Schema.PicklistEntry a: values) {
                allOpts.add(a.getValue());
            }
        }catch(Exception e) {EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.DocumentInfoAgreementRequest, GlobalConstants.getselectOptions, GlobalConstants.DocumentInfoAgreementRequest, true, e)));
                            }
        return allOpts;
    }
    /****************************************************************
* @author: Richa Gupta
* @date: 19-03-2020
* @User Story: 1651
* @description: This Aura Enabled method will update Document Type of attached File
*****************************************************************/
    @AuraEnabled
    public static List <ContentVersion > UpdateDocumentType(List<ContentVersion> cVersion) {
        try{
            update cVersion;}
        catch(Exception e) {EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.DocumentInfoAgreementRequest, GlobalConstants.UpdateDocumentType, GlobalConstants.DocumentInfoAgreementRequest, true, e)));
                           }
        return cVersion;
    } 
}