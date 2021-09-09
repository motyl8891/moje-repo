/**
* @File Name          : OC_DH_FileUploadController
* @Description        : Class to upload file for document Hub
* @Author             : Mohit Tripathi
* @Group              : OmniChannel - Service
* @Created Date       : 18th May 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-5-18              Mohit Tripathi               Initial Version
**/

public class OC_DH_FileUploadController {
    
    @AuraEnabled
    public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) {
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  next time (in else) we are call the appentTOFile() method to update file with remaining chunks 
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        } else {
            appendToFile(fileId, base64Data);
        }
        
        return Id.valueOf(fileId);
    }
    //Method to create file record and attach with the parent Id provided
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        // create a content version record
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.ContentDocumentId = NULL;
        cv.VersionData = EncodingUtil.base64Decode(base64Data);
        cv.Title = fileName.substring(0, fileName.lastIndexOf('.'));
        cv.PathOnClient = filename;
        cv.isMajorversion = false;
        try{
            insert cv;  
        }catch(exception e){
            System.debug('Message: ' + e.getMessage()); 
        }
        //content document link record to link content version record with Account Id provided
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = parentId;
        cdl.ShareType = 'I';
        try{
            insert cdl;
        }catch(exception e){
            System.debug('Message: ' + e.getMessage()); 
        }
        //Id of content version to be retured as a file Id
        return cv.Id;
        
    }
    
    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        //fetch the existing contentVersion document with the file ID provided
        contentVersion cv = [select Id,VersionData from ContentVersion where Id =:fileId  ];
        
        String existingBody = EncodingUtil.base64Encode(cv.VersionData);
        //append the extra chunk on the existing body post encoding it
        cv.VersionData = EncodingUtil.base64Decode(existingBody + base64Data);
        try{
            update cv;
        }catch(exception e){
            System.debug('Message: ' + e.getMessage());   
        }
    }
}