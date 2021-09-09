/**
* @File Name          : OC_AN_Insert_UserPrefrences
* @Description        : Controller class for oc_an_InsertDataViaCSV lwc Componet

*                       U-2758 Alerts & Notification: Creation of User Prefrences.
* @Author             : IBM
* @Group              : 
* @Created Date       : 11th June 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-06-11             	IBM               Initial Version
*/

public class OC_AN_Insert_UserPrefrences {
    
    @AuraEnabled
    public static string createUsrPrefRecord(List<OC_AN_User_Preferences__c> newRecords){
        //insert newRecords;
        String headerval;
        OC_AN_AlertsAndNotification__mdt headerValuesFromMetadata = OC_AN_AlertsAndNotification__mdt.getInstance('OC_AN_UserPref_Headers_APIs');
        if(headerValuesFromMetadata != null){
            headerval = headerValuesFromMetadata.Values__c;
        }
        List<String> headerValues = headerval.split(',');
        List<string> listRecordsStatus=new List<string>();
        Database.UpsertResult[] srList = Database.Upsert(newRecords, False);
        String getEachRecord = '';
        for (Integer i = 0; i < newRecords.size(); i++) {
            Database.UpsertResult upsertResultValue = srList[i];
            if (!upsertResultValue.isSuccess()) {
                //create csv file data for error records
                for(Database.Error err : upsertResultValue.getErrors()){
                    for(String headerValue:headerValues){
                        if(string.isNotBlank(getEachRecord)){                                  
                            getEachRecord =  getEachRecord+ newRecords[i].get(headerValue);
                            getEachRecord = getEachRecord.removeEnd(OC_AN_Constants.slashN)+OC_AN_Constants.comma;
                        }else{
                            getEachRecord = newRecords[i].get(headerValue)+OC_AN_Constants.comma;
                        }
                    }
                    //add the reason of error in the string
                    String replaceErrorMessage = err.getMessage();
                    List<String> errorFields = err.getFields();
                    String strErrorFields = String.valueOf(errorFields);
                    getEachRecord =  getEachRecord+err.getMessage()
                        +OC_AN_Constants.slashN;
                    getEachRecord = getEachRecord.remove(OC_AN_Constants.slashR );
                    //add the final string in the list
                }
            }else{
                //create csv file data for success records
                for(String headerValue:headerValues){
                    if(string.isNotBlank(getEachRecord)){ 
                        getEachRecord =  getEachRecord+ newRecords[i].get(headerValue)+OC_AN_Constants.comma;
                    }else{
                        getEachRecord = newRecords[i].get(headerValue)+OC_AN_Constants.comma;
                    }
                }
                getEachRecord=getEachRecord + OC_AN_Constants.success;
                getEachRecord = getEachRecord.removeEnd(OC_AN_Constants.comma);
                getEachRecord =  getEachRecord +OC_AN_Constants.slashN;
                getEachRecord = getEachRecord.remove(OC_AN_Constants.doubleComma); 
            }
        }
        getEachRecord=getEachRecord.replace('null',''); 
        return getEachRecord;
        
        
    }
    @AuraEnabled(cacheable=true)
    public static Map<String,String> get_MetaDataOfAN() {
        Map<String,String> sfmc_Config = new Map<String,String>();
        for(OC_AN_AlertsAndNotification__mdt config : [Select Id, Label,OC_AN_API_Name__c from OC_AN_AlertsAndNotification__mdt]){
            sfmc_Config.put(config.Label, config.OC_AN_API_Name__c);
        }
        return sfmc_Config;
        
    }
    @AuraEnabled(cacheable=true)
    public static Map<String,String> get_RecordTypeIds() {
        Map<String,String> rec_Config = new Map<String,String>();
        for(RecordType recs : [SELECT Id, Name, DeveloperName, sObjectType FROM RecordType WHERE IsActive = TRUE and sObjectType=:OC_AN_Constants.sObjectUserPref]){
            rec_Config.put(recs.Name, recs.Id);
        }
        return rec_Config;
        
    }
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getUserIdsRecs(List<string> usrNames) {
        Map<String,String> rec_Config = new Map<String,String>();
        for(User recs : [SELECT Id, username FROM User where username IN :usrNames]){
            rec_Config.put(recs.username, recs.Id);
        }
        return rec_Config;
    }
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getcontactIdsRecs(List<string> contactData) {
        Map<String,String> rec_Config = new Map<String,String>();
        for(Contact recs : [SELECT Id,email FROM Contact where email IN :contactData]){
            rec_Config.put(recs.email, recs.Id);
        }
        return rec_Config;
    }
    
    @AuraEnabled(cacheable=true)
    public static void sendEmailToController(String recordsStatusString){
        try{
            Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
            blob csvBlob = Blob.valueOf(recordsStatusString);
            string csvname= OC_AN_Constants.csvname;
            csvAttc.setFileName(csvname);
            csvAttc.setBody(csvBlob);
            String emailaddress=UserInfo.getUserEmail();
            Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
            String[] toAddresses = new list<string> {emailaddress};
                EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body 
                                               FROM EmailTemplate where name = 'OC_AN_UserPreferenceUploadStatus' LIMIT 1];
            email.setTemplateId(emailTemplate.Id);   
            email.setSubject(emailTemplate.Subject);
            email.setPlainTextBody(emailTemplate.Body);
            email.setToAddresses( toAddresses );
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }
}