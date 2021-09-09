/****************************************************************
* @author: Aditya Mohapatra
* @date: 24-02-2020
* @User Story: 1651
* @description: This Aura Enabled class will set SAles CLM Checkboxes to true on Lightning Record Page for Agrrement Requests.
*****************************************************************/
public without sharing class UpdateCheckBoxCLM {
    /****************************************************************
* @author: Aditya Mohapatra
* @date: 24-02-2020
* @User Story: 1651
* @description: This Aura Enabled method will set SAles CLM Checkboxes to true on Lightning Record Page for Agrrement Requests.
*****************************************************************/   
    @AuraEnabled
    public static void updateCheck(String key){
        try{
            list<AgreementRequest__c> pl_list = [select id,Name,IsSendtoSalesCLM__c,SendToSalesCLM__c from AgreementRequest__c where id =: key  Limit 1];
            pl_list[0].IsSendtoSalesCLM__c=true;
            pl_list[0].SendToSalesCLM__c = true;
            database.update(pl_list) ;
        }catch(Exception e){EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.updateCheckBoxCLM, GlobalConstants.updateCheck, GlobalConstants.updateCheckBoxCLM, true, e)));
                           }
    }
    /****************************************************************
* @author: Richa Gupta
* @date: 19-03-2020
* @User Story: 1675
* @description: This Aura Enabled method will validate Attachement before sending to Send to Sales CLM.
*****************************************************************/   
    @AuraEnabled
    Public static String checkFileInformation(String agrId){
        
        string msg='Document Type of Attached file is validated';
        try{
            List<contentDocumentLink> contentDocLinks=[Select ContentDocumentId,LinkedEntityId ,id from ContentDocumentLink 
                                                       where LinkedEntityId=:agrId  Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            
            if(contentDocLinks.size()>0){
                Set<Id> contentDocIds = new Set<Id>(); 
                for(ContentDocumentLink contentDocLink : contentDocLinks) {
                    contentDocIds.add(contentDocLink.ContentDocumentId);
                }
              //  List<Id> contentDocIdList = new List<Id>(contentDocIds);
                List<ContentVersion> conVersion=[select Id,ContentDocumentId, DocumentType__c, ContentDocument.Description, ContentDocument.Title, 
                                                 ContentDocument.FileType, ContentDocument.FileExtension from ContentVersion where ContentDocumentId in:contentDocIds 
                                                 and DocumentType__c=null  Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows()) ];
                
                if(conVersion.size()>0){
                    msg='Document Type  is required before sending it to Sales CLM';
                }
            }else{
                msg='Please attach a document before sending it to Sales CLM';
            }
        }
        catch(Exception e){EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.updateCheckBoxCLM, GlobalConstants.checkFileInformation, GlobalConstants.updateCheckBoxCLM, true, e)));
                          }
        return msg;}}